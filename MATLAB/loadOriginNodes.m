%Nested function that assigns the origin flow
function [cvn,l_list]=loadOriginNodes(t,origins,fromNodes,ODmatrix,TF,n_ind,cvn_up,dt)
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
%update origin nodes
for o_index=1:length(origins)
    o = origins(o_index);
    outgoingLinks = find(fromNodes==o);
    for l_index=1:length(outgoingLinks)
        l=outgoingLinks(l_index);
        l_list = [l_list,l];
        %calculation sending flow
        tf=reshape(TF(n_ind(o):n_ind(o+1)-1,t-1),1,1);
        SF = tf.*sum(ODmatrix(o_index,:,t-1))*dt;
        cvn=[cvn,cvn_up(l,t-1) + SF];
    end
end
end
