%Nested function used for finding CVN values inbetween time slices
function val = findCVN(cvn,time,timeSlices,dt)
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



% if time<=timeSlices(1)
%     val=0;
%     return;
% elseif time>=timeSlices(end)
%     val=cvn(end);
%     return;
% else
    t1=ceil(time/dt);
    t2=t1+1;
    val = cvn(t1)+(time/dt-t1+1)*(cvn(t2)-cvn(t1));
% end
end
