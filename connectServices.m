function connectServices(type)

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


global conn_KUL;
global conn_type;

conn_type = type;
switch type
    case 'odbc'
        conn_KUL = database('kul_db', 'student1','student1');

    case 'jdbc'
        conn_KUL = database('postgres', 'student1','student1', 'Vendor', 'POSTGRESQL', 'Server', 'db.itscrealab.be', 'PortNumber', 5432);
end
        
if isempty(conn_KUL.Message)
    display('Connection to KUL service succeeded');
else
    display('Connection to KUL service failed');
end

end
