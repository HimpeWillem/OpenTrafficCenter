%% Visualise Traffic Data allong a corridor or at a specific location
% Code developed for Athens Course at the KUL (November 2018)
% Contact info: willem.himpe ([@]) kuleuven.be

% First go to http://db.itscrealab.be/download/loop_detectors/ and download
% the data you want to visualize. Next extract the .csv files into the main
% folder.


%% Set a winter vs summer time boolean
global summer_time;
summer_time = 0;

%% Load the network in matlab
% A .mat file that contains a network with all the highways in Belgium is 
% available. It is a connected graph constructed with GRB & OpenStreetMap.
load network_full;

%% Construct a route
%select the route begin and end point
[name_figure,str_point,end_point,int_point]=selectRoute(nodes_full,links_full,detectors_full);

%% Select the time
[str_time,end_time]=selectTime_noDB;

%% Create network model
%starting from the full network create a subnetwork of the selected route
[nodes,links,origins,destinations,detectors,data,main_links,on_links] = createNetworkModel_noDB(nodes_full,links_full,detectors_full,str_point,end_point,int_point,str_time,end_time);

%Format the data into lanes
[id,lane,name,km_pos,time,speed_h,speed_m,flows_veh,flows_pae,occupancy,link_id,projection] = selectData(data,detectors);

% Visualize individual detector data
f=visualizeDetector(id,lane,name,km_pos,time,speed_h,flows_pae,'All detectors');

% Remove detectors that are useless
display('close figure to continue');
while true
    pause(0.1);
    if ~ishghandle(f) 
        break; 
    end 
end
[detectors]=removeDetectors(nodes,links,detectors,km_pos,name,id);
[id,lane,name,km_pos,time,speed_h,speed_m,flows_veh,flows_pae,occupancy,link_id] = selectData(data,detectors);
link_id=arrayfun(@(x)find(links.No==x),link_id);
time_agg = time(5:5:end);

%% Show the selected route & detectors
showCorridor(nodes_full,links_full,nodes,links,detectors,data);

%% Visualize the result in a space time diagram

%Aggregate over all lanes
[agg_speed,tot_flow]=aggregateLanes(speed_h,flows_pae);

%Get the detectors allong the main route
main_id=arrayfun(@(x)find(link_id==x)',1:main_links,'UniformOutput',0);
km_pos = [0;cumsum(links.length(1:main_links))];
km_pos(cellfun(@(x)isempty(x),main_id))=[];
main_id(cellfun(@(x)isempty(x),main_id))=[];
num_det=cellfun(@(x)length(x),main_id);
ind_temp=cell2mat(arrayfun(@(x,y)y*ones(1,x),num_det,1:length(num_det),'UniformOutput',0));
km_pos=km_pos(ind_temp);
main_id=cell2mat(main_id);
km_pos=km_pos+projection(main_id);
[km_pos,ind_temp]=sort(km_pos);
main_id=main_id(ind_temp);
%[ind,pos]=sort(main_id);
speed_main = agg_speed(main_id,:);
flow_main = tot_flow(main_id,:);

%filter data for higher resolution (100m)
[flow_filtered,speed_filtered,xco] = helbingFilter(flow_main',speed_main',km_pos',0,1);
%show  the result in a colourful plot
xt_plot(speed_filtered',xco,km_pos,time,name_figure);
xt_plot(60*flow_filtered',xco,km_pos,time,name_figure);
% Visualize individual detector data
visualizeDetector(id(main_id),lane(main_id),name(main_id),km_pos',time,speed_h(main_id,:,:),flows_pae(main_id,:,:),'Main road');

%% Visualize the onramps

on_id=arrayfun(@(x)find(link_id==x)',main_links+1:main_links+on_links,'UniformOutput',0);
on_id(cellfun(@(x)isempty(x),on_id))=[];
on_id=cell2mat(on_id);
%select a detector in show the resulting 
visualizeDetector(id(on_id),lane(on_id),name(on_id),on_id,time,speed_h(on_id,:,:),flows_pae(on_id,:,:),'On-ramps');

%% Visualize the offramps

off_id=arrayfun(@(x)find(link_id==x)',main_links+on_links+1:size(links,1),'UniformOutput',0);
off_id(cellfun(@(x)isempty(x),off_id))=[];
off_id=cell2mat(off_id);
%select a detector in show the resulting 
visualizeDetector(id(on_id),lane(on_id),name(on_id),on_id,time,speed_h(on_id,:,:),flows_pae(on_id,:,:),'Off-ramps');
