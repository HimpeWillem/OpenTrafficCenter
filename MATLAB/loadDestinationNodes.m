%Nested function that assigns the destination flow
function [cvn,l_list]=loadDestinationNodes(t,destinations,toNodes,cvn_up,cvn_down,lengths,freeSpeeds,capacities,timeSlices,dt)
%#codegen
%coder.inline('never');

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


cvn = [];
l_list = [];
%update destination nodes
for d_index=1:length(destinations)
    d = destinations(d_index);
    incomingLinks = find(toNodes==d);
    for l_index=1:length(incomingLinks)
        l=incomingLinks(l_index);
        l_list = [l_list,l];
        %calculation sending flow
        SF = capacities(l)*dt;
        SF = min(SF,findCVN(cvn_up(l,:),max(eps,timeSlices(t)-lengths(l)/freeSpeeds(l)),timeSlices,dt)-cvn_down(l,t-1));
        cvn=[cvn,cvn_down(l,t-1) + SF];
    end
end
end
