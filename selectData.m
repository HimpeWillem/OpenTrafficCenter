function [id,lane,name,km_pos,time,speed_h,speed_m,flow_veh,flow_pae,occupancy,link_id,link_projection] = selectData(data,detectors)
%% Setup a nice format for the detectors allong the route
global summer_time;

if any(strcmp(detectors.Properties.VariableNames,'location'))
    [~,unique_links] = unique(detectors.location,'stable');
else
    [~,unique_links] = unique([detectors.link_id,detectors.link_projection],'rows','stable');
end
id=cell(length(unique_links),1);
lane=cell(length(unique_links),1);
name=cell(length(unique_links),1);
link_id=zeros(length(unique_links),1);
link_projection=zeros(length(unique_links),1);
max_lanes=0;
km_pos=zeros(1,length(unique_links));
for i=1:length(unique_links)
    if any(strcmp(detectors.Properties.VariableNames,'location'))
        detector_index = find(detectors.location(unique_links(i))==detectors.location);
    else
        detector_index = find(detectors.link_id(unique_links(i))==detectors.link_id&detectors.link_projection(unique_links(i))==detectors.link_projection);
    end
    
    [~,sort_index]=sort(detectors.rijstrook(detector_index));
    %sort the result
    
    id{i} = detectors.detector_id(detector_index(sort_index))';
    
    lane{i} = detectors.rijstrook(detector_index(sort_index))';
    link_id(i) = unique(detectors.link_id(detector_index(sort_index)));
    link_projection(i) = unique(detectors.link_projection(detector_index(sort_index)));
    %remove lanes for busses, parking, reverse dircetion, shoulder,...
    remove_lanes=false(1,length(lane{i}));
    for j=1:length(lane{i})
        if ~isempty(strfind(lane{i}{j},'B'))||~isempty(strfind(lane{i}{j},'P'))||~isempty(strfind(lane{i}{j},'T'))||~isempty(strfind(lane{i}{j},'W'))||~isempty(strfind(lane{i}{j},'S'))||~isempty(strfind(lane{i}{j},'A'))
            remove_lanes(j)=true;
        end
    end
    id{i}(remove_lanes)=[];
    lane{i}(remove_lanes)=[];
    max_lanes = max(max_lanes,length(lane{i}));
    name{i}=detectors.volledige_naam(detector_index(1));
    %     ln_main{i,1} = detectors.rijstrook(detector_index(sort_index))';
    if any(strcmp(detectors.Properties.VariableNames,'location'))
        km_pos(i) = detectors.location(detector_index(1))/1000;
    else
        km_pos(i) = i;
    end
end


%% Create tables with measures for each unique detector location
for i=1:length(id)
    for j=1:length(id{i})
        mat_name = ['measures_',num2str(id{i}(j))];
        eval([mat_name,' = table2array(data(data.unieke_id==id{i}(j),:));']);
    end
end


%% proces the data
%time
time = unique(data.time_epoch);

%speed (mean)
speed_m = zeros(length(id),length(time),max_lanes);
for i=1:length(id)
    for j=1:length(id{i})
        val = sum(eval(['measures_',num2str(id{i}(j)),'(:,8:12)']).*eval(['measures_',num2str(id{i}(j)),'(:,3:7)']),2)./sum(eval(['measures_',num2str(id{i}(j)),'(:,3:7)']),2);
        speed_m(i,:,j) =  NaN;
        if ~isempty(val)
            time_temp =  eval(['measures_',num2str(id{i}(j)),'(:,2)']);
            [time_temp,time_temp_pos] = unique(time_temp);
            val = val(time_temp_pos);
            [~,~,time_temp_pos] = intersect(time,time_temp);
            speed_m(i,time_temp_pos,j) =  val;
        end
    end
end


%speed (harmonic)
speed_h = zeros(length(id),length(time),max_lanes);
for i=1:length(id)
    for j=1:length(id{i})
        val = sum(eval(['measures_',num2str(id{i}(j)),'(:,3:7)']),2)./sum(eval(['measures_',num2str(id{i}(j)),'(:,3:7)'])./eval(['measures_',num2str(id{i}(j)),'(:,13:17)']),2);
        speed_h(i,:,j) =  NaN;
        if ~isempty(val)
            time_temp =  eval(['measures_',num2str(id{i}(j)),'(:,2)']);
            [time_temp,time_temp_pos] = unique(time_temp);
            val = val(time_temp_pos);
            [~,~,time_temp_pos] = intersect(time,time_temp);
            speed_h(i,time_temp_pos,j) =  val;
        end
    end
end


%flow (#vehicles)
flow_veh = zeros(length(id),length(time),max_lanes);
for i=1:length(id)
    for j=1:length(id{i})
        val = sum(eval(['measures_',num2str(id{i}(j)),'(:,3:7)']),2);
        flow_veh(i,:,j) =  NaN;
        if ~isempty(val)
            time_temp =  eval(['measures_',num2str(id{i}(j)),'(:,2)']);
            [time_temp,time_temp_pos] = unique(time_temp);
            val = val(time_temp_pos);
            [~,~,time_temp_pos] = intersect(time,time_temp);
            flow_veh(i,time_temp_pos,j) =  val;
        end
    end
end

%flow (#pae)
size_bin = [0 1 4.9 6.9 12 18.75];
pae = size_bin(1:end-1)+diff(size_bin)/2;
pae = pae/pae(2);
pae = [0.5 1 1.5 2 2];
flow_pae = zeros(length(id),length(time),max_lanes);
for i=1:length(id)
    for j=1:length(id{i})
        val = eval(['measures_',num2str(id{i}(j)),'(:,3:7)']);
        flow_pae(i,:,j) =NaN;
        if ~isempty(val)
            time_temp =  eval(['measures_',num2str(id{i}(j)),'(:,2)']);
            [time_temp,time_temp_pos] = unique(time_temp);
            val = val(time_temp_pos,:);
            [~,~,time_temp_pos] = intersect(time,time_temp);
            flow_pae(i,time_temp_pos,j) = sum(val.*repmat(pae,length(time_temp_pos),1),2);
        end
    end
end

%occupancy
occupancy = zeros(length(id),length(time),max_lanes);
for i=1:length(id)
    for j=1:length(id{i})
        val =  eval(['measures_',num2str(id{i}(j)),'(:,18)']);
        occupancy(i,:,j)=NaN;
        if ~isempty(val)
            time_temp =  eval(['measures_',num2str(id{i}(j)),'(:,2)']);
            [time_temp,time_temp_pos] = unique(time_temp);
            val = val(time_temp_pos);
            [~,~,time_temp_pos] = intersect(time,time_temp);
            occupancy(i,time_temp_pos,j) = val;
        end
    end
end

if ~summer_time
    time=time-1/24;
end
end