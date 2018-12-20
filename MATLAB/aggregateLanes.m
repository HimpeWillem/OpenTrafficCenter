function [speed,flow] = aggregateLanes(speed_h,flow_veh)

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
