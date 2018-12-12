function [speed,flow] = aggregateLanes(speed_h,flow_veh)

%% Compute harmonic speed average over all lanes
    speed = zeros(size(speed_h,1),size(speed_h,2));
    flow = zeros(size(flow_veh,1),size(flow_veh,2));
    for i=1:size(speed_h,3)
        temp = flow_veh(:,:,i)./speed_h(:,:,i);
        speed(find(~isnan(temp))) = speed(find(~isnan(temp))) + temp(find(~isnan(temp)));
        flow = flow + flow_veh(:,:,i);
    end
    speed = flow./speed;
       
    display('Aggregated lanes');
end