%% Disclaimer
% This file is part of the matlab package OpenTrafficCenter
% developed by the KULeuven. 
%
% Copyright (C) 2016  Himpe Willem, Leuven, Belgium
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
% More information at: https://github.com/HimpeWillem/OpenTrafficCenter
% or contact: willem.himpe {@} kuleuven.be

%% Set the demand 
% Add ODmatrices
[timeSeries,ODmatrices] = createODs(links,origins,id,link_id,time,speed_h,flows_pae);

% Add TF
[TF] = createTFs(nodes,links,id,link_id,time,speed_h,flows_pae);

%% Set model time steps
display('Constructing OD and TF for model time interval...')

%reshape the links
cumsum_links = filter([0.5 0.5],1,[0;cumsum(links.length(1:main_links))]);
cumsum_links(1)=[];
links.length = max(0.1,links.length);

%setup the time interval and total number of time steps
dt = min(links.length./links.speed);
totT = round((timeSeries{end}-timeSeries{1})/dt);

tic
%build the demand for each time interval
[ODmatrix,org,dest] = buildODmatrix(ODmatrices,timeSeries,dt,totT);
%build the turning rates for each time interval 
[TFmatrix,fromL,toL,n_ind,nFromL,nToL] = buildTFmatrix(TF,links,timeSeries,dt,totT);
toc;

%% Set standard values

capacity_per_lane = 2100;
kjam_per_lane = 100;
max_speed = 100;
links.capacity = links.lanes*capacity_per_lane;
links.freeSpeed = min(max_speed,links.speed);
links.kJam = links.lanes*kjam_per_lane;

%set capacity of onramps to a higher number for merging behavior
links.capacity(main_links+1:main_links+1+on_links) = 2800*links.lanes(main_links+1:main_links+1+on_links);
links.kJam(main_links+1:main_links+1+on_links) = 300*links.lanes(main_links+1:main_links+1+on_links);
links.capacity(main_links+1+on_links:end) = 2600*links.lanes(main_links+1+on_links:end);
links.kJam(main_links+1+on_links:end) = 200*links.lanes(main_links+1+on_links:end);

%% Set manual capacity values

[links]=setCapacity(nodes,links);
links.wSpeed = links.capacity./(links.kJam-links.capacity./links.freeSpeed);

%% Run the simulation
display('Running the model...')

tic
% Compute LTM with single commodity
[cvn_up,cvn_down] = LTM_SC_v3_mex(links.fromNode,links.toNode,links.freeSpeed,links.capacity,links.kJam,links.length,links.wSpeed,fromL,toL,n_ind,nFromL,nToL,origins,destinations,ODmatrix,dt,totT,TFmatrix);
toc

[simDensity] = cvn2dens(cvn_up,cvn_down,totT,links);
[simFlows_down] = cvn2flows(cvn_down,dt);
[simFlows_up] = cvn2flows(cvn_up,dt);
[simTT] = cvn2tt(cvn_up,cvn_down,dt,totT,links);
simSpeeds = repmat(links.length,1,totT+1)./simTT;

%% Main road
time_plot = floor(time(1)*48)/48+(dt*[0:totT])/24;

xt_plot(simSpeeds(1:main_links,1:10:end),cumsum_links',km_pos,time_plot(1:10:end),'XT-graph of speeds on the highway: LTM');
xt_plot(round(simFlows_up(1:main_links,1:10:end)),cumsum_links',km_pos,time_plot(1:10:end-1),'XT-graph of flows on the highway: LTM');

%% visualize the travel time along the main route (from split to merge)

%Simulated travel time
timeSteps=0:dt:totT*dt;
forwTT=timeSteps;
backTT=timeSteps;
for l=1:main_links
    forwTT=forwTT+interp1(timeSteps,simTT(l,:),forwTT);
end
forwTT=forwTT-timeSteps;

%Observed travel time
agg_speed_noNan = speed_main;
agg_speed_noNan(isnan(speed_main))=120;
[tt_TH_Filtered] = LOGGHEvvc(agg_speed_noNan,flow_main,km_pos,1,km_pos(1)+0.1,km_pos(end)-0.1);

%plot the travel time
figure('Units','pixels','color','white');
xlabel('Time [hr]','FontSize',12);
ylabel('Travel Time [min]','FontSize',12);
title('Travel time graph','FontSize',14,'fontweight','b');
hold on;
plot(time(1)+timeSteps/24,forwTT*60,'b');
plot(time(1:end-1),tt_TH_Filtered(:,2)','g')
hold off;
% axis tight;
set(gca,'XTick',[min(ceil(time*48)/48):1/(24*2):max(floor(time*48)/48)]);%%%% set(gca,'XTick',[1:1/(24*2):length(time)]);
set(gca,'XTickLabel',datestr(ceil(time*48)/48:1/(24*2):max(floor(time*48)/48),'HH:MM'));
title('Travel time on the highway','FontSize',14,'fontweight','b');
legend('Simulated','Observed')

%% Make an animation of the result
% The variation of densities is animated in the network by considering only 
% every 10th simulation interval.
%
% 
fRate = 20; %set frame rate
% fRate = inf; %allows the for manual control using space bar
animateSimulation(nodes,links,min(max(links.kJam(1:main_links)),simDensity(:,1:10:end)),datestr(time_plot(1:10:end)),fRate); %only shows every 10th frame

%% Visualize the flows

visualizeDifferences(nodes,links,detectors,time_plot,simFlows_up,simFlows_down,simSpeeds,time,link_id(main_id),cumsum_links,60*tot_flow(main_id,:),agg_speed(main_id,:),link_id(on_id),60*tot_flow(on_id,:),agg_speed(on_id,:),link_id(off_id),60*tot_flow(off_id,:),agg_speed(off_id,:))

