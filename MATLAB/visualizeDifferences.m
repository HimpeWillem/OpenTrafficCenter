function visualizeDifferences(nodes,links,detectors,time_plot,simFlows_up,simFlows_down,simSpeeds,time,link_id,km_pos,flows_pae,speeds,link_id_on,flows_pae_on,speeds_on,link_id_off,flows_pae_off,speeds_off)

%% Disclaimer
% This file is part of the matlab package OpenTrafficCenter
% developed by the KULeuven. 
%
% Copyright (C) 2018  Himpe Willem, Leuven, Belgium
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


% 
maxNodesNo=max(nodes.No);
maxLinksNo=max(links.No);
xco=zeros(maxNodesNo,1);
yco=zeros(maxNodesNo,1);
xco(nodes.No)=nodes.Xcoord;
yco(nodes.No)=nodes.Ycoord;

toNode = zeros(2*maxLinksNo,1);
fromNode = zeros(2*maxLinksNo,1);
toNode(links.No) = links.toNode;
fromNode(links.No) = links.fromNode;

%local rename link properties
strN = links.fromNode;
endN = links.toNode;
x=nodes.xco;
y=nodes.yco;

x_temp = zeros(length(strN)*3,1);
x_temp(1:3:end) = x(strN);
x_temp(2:3:end) = x(endN);
x_temp(3:3:end) = NaN;

y_temp = zeros(length(strN)*3,1);
y_temp(1:3:end) = y(strN);
y_temp(2:3:end) = y(endN);
y_temp(3:3:end) = NaN;
% 
% plot(x_temp, y_temp,'Color',[0 0 0]); %[0.9 0.7 0]

% Show all detector positions
f=plotLoadedLinks(nodes,links,10*arrayfun(@(x)any(detectors.link_id==x),links.No),false,[],[],[]);
hold on;
%look for all detectors on the main road
lu=1:length(km_pos);
text((x(strN(lu))+x(endN(lu)))/2,(y(strN(lu))+y(endN(lu)))/2,num2str(km_pos));

while true
    % Select the starting point
    figure(f);
    hold on;
    display('Zoom into the region of the zone you want to select and press a key')
    display('If you want to exit close the window and press a key')
    pause;
    if ~ishghandle(f) 
        break; 
    end 
    [x_select,y_select] = ginput(1);

    act_l = [];
    rad = 10^7;
    while nnz(act_l)<min(length(links.capacity),100)
        act_l = (x_temp-x_select).^2 + (y_temp-y_select).^2 < rad;
        rad = rad + 1000;
    end
    act_l=unique([find(act_l(1:3:end));find(act_l(2:3:end))]);

    begin_l=[xco(links.fromNode(act_l)),yco(links.fromNode(act_l))];
    end_l=[xco(links.toNode(act_l)),yco(links.toNode(act_l))];
    P = repmat([x_select y_select],length(act_l),1);
    W = P-begin_l;
    V = end_l-begin_l;
    frac = min(1,max(0,dot(W',V')./dot(V',V')));
    prj = begin_l+repmat(frac',1,2).*V;
    vec = P-prj;
    sqr_dist = dot(vec',vec')';
%     angle = acos(dot(V',W')'./(sqrt(W(:,1).^2+W(:,2).^2).*sqrt(V(:,1).^2+V(:,2).^2)));
    angle = atan2(V(:,2),V(:,1))-atan2(W(:,2),W(:,1));
    angle(angle<0) = angle(angle<0)+2*pi;
    
    valid = angle<pi;
%     %1th kwadrant
%     valid(V(:,1)>=0 & V(:,2)>=0) = angle(V(:,1)>=0 & V(:,2)>=0)>pi & angle(V(:,1)>=0 & V(:,2)>=0)<2*pi;
%     %2th kwadrant
%     valid(V(:,1)<=0 & V(:,2)>=0) = angle(V(:,1)<=0 & V(:,2)>=0)>0 & angle(V(:,1)<=0 & V(:,2)>=0)<pi;
%     %3th kwadrant
%     valid(V(:,1)<=0 & V(:,2)<=0) = angle(V(:,1)<=0 & V(:,2)<=0)>pi/2 & angle(V(:,1)<=0 & V(:,2)<=0)<pi;
%     %4th kwadrant
%     valid(V(:,1)>=0 & V(:,2)<=0) = angle(V(:,1)>=0 & V(:,2)<=0)<pi/2 & angle(V(:,1)>=0 & V(:,2)<=0)<pi;

    ind = act_l(find(abs(min(sqr_dist(valid))-sqr_dist)<eps*10 & valid,1));

    clear val;
    h_l=plot([xco(links.fromNode(ind)),xco(links.toNode(ind))],[yco(links.fromNode(ind)),yco(links.toNode(ind))],'r-','lineWidth',2);
    hold off;
    figure;hold on;
    subplot(2,1,1)    
    plot(time_plot(1:end-1),simFlows_down(ind,:),'b',time_plot(1:end-1),simFlows_up(ind,:),'r');
    set(gca,'XTick',[min(ceil(time_plot*48)/48):1/(24*2):max(floor(time_plot*48)/48)]);%%%% set(gca,'XTick',[1:1/(24*2):length(time)]);
    set(gca,'XTickLabel',datestr(ceil(time_plot*48)/48:1/(24*2):max(floor(time_plot*48)/48),'HH:MM'));
    xlim([-inf inf])
    hold on;
    if any(ind==link_id)
        plot(time,mean(flows_pae(ind==link_id,:),1),'g');
        legend('simulated Flows (upstream)','simulated Flows (downstream)','Observerd Flows');
        title([detectors.volledige_naam(find(detectors.link_id==links.No(ind),1,'last')),['Position allong main highway: ',num2str(mean(km_pos(ind==link_id))),'km']]);
    elseif any(ind==link_id_on)
        plot(time,mean(flows_pae_on(ind==link_id_on,:),1),'g');
        legend('simulated Flows (upstream)','simulated Flows (downstream)','Observerd Flows');
        title([detectors.volledige_naam(find(detectors.link_id==links.No(ind),1,'first')),'Detector is locatated at an on-ramp']);
    elseif any(ind==link_id_off)
        plot(time',mean(flows_pae_off(ind==link_id_off,:),1),'g');
        legend('simulated Flows (upstream)','simulated Flows (downstream)','Observerd Flows');
        title([detectors.volledige_naam(find(detectors.link_id==links.No(ind),1,'first')),'Detector is locatated at an off-ramp']);
    else
        legend('simulated Flows (upstream)','simulated Flows (downstream)');
    end
    
    subplot(2,1,2)    
    plot(time_plot,simSpeeds(ind,:),'b');
    hold on;
    set(gca,'XTick',[min(ceil(time_plot*48)/48):1/(24*2):max(floor(time_plot*48)/48)]);%%%% set(gca,'XTick',[1:1/(24*2):length(time)]);
    set(gca,'XTickLabel',datestr(ceil(time_plot*48)/48:1/(24*2):max(floor(time_plot*48)/48),'HH:MM'));
    if any(ind==link_id)
        plot(time,mean(speeds(ind==link_id,:),1),'g');
        legend('Simulated Speeds','Observerd Speeds');
    elseif any(ind==link_id_on)
        plot(time,mean(speeds_on(ind==link_id_on,:),1),'g');
        legend('Simulated Speeds','Observerd Speeds');
    elseif any(ind==link_id_off)
        plot(time',mean(speeds_off(ind==link_id_off,:),1),'g');
        legend('Simulated Speeds','Observerd Speeds');
    else
        legend('Simulated Speeds');
    end
    xlim([-inf inf])
    hold off;
    selectionButton_continue = questdlg('Do you which to plot another link?', ...
    '', ...
    'Yes','No', 'No');
    switch selectionButton_continue
        case 'Yes'
            delete(h_l);
        case 'No'
            close(f);
            return;
    end
end

end
