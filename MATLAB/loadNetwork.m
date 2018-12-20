function [nodes,links,detectors] = loadNetwork

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


nodes = [];
links = [];

fprintf('Loading the network from the server...')

global conn_KUL conn_type;

%Query the database and collect the data in matlab
quer = ['SELECT id, source, target, geom AS geometry, cost, lanes, speed, ST_ASText(geom) AS geom FROM public.osm_highway_v1'];
curs = exec(conn_KUL, [quer]);
curs = fetch(curs);
links = curs.Data;
if conn_type == 'odbc'
    links = cell2table(links,'VariableNames',{'id','source','target','geometry','cost','lanes','speed','geom'});
end
links.Properties.VariableNames{'id'}='No';
links.Properties.VariableNames{'source'}='fromNode';
links.Properties.VariableNames{'target'}='toNode';
links.Properties.VariableNames{'cost'}='length';
co = arrayfun(@(x) [cell2mat(textscan(strrep(strrep(strrep(links.geom{x},'LINESTRING(',''),')',''),',',' '),'%f %f'));NaN NaN],[1:length(links.geom)]','UniformOutput',0);
links.co = co;

quer = ['SELECT id, ST_ASText(the_geom) AS geometry  FROM public.osm_highway_vertices'];
curs = exec(conn_KUL, [quer]);
curs = fetch(curs);
nodes = curs.Data;
if conn_type == 'odbc'
    nodes = cell2table(nodes,'VariableNames',{'id','geometry'});
end
nodes.Xcoord=zeros(size(nodes,1),1);
nodes.Ycoord=zeros(size(nodes,1),1);
out=cellfun(@(x) textscan(x,'POINT(%f %f)'),nodes.geometry,'UniformOutput',0);
out = cellfun(@(x)cat(2,x{1,1},x{1,2}),out,'un',0);
out = cell2mat(out);
nodes.Xcoord=out(:,1);
nodes.Ycoord=out(:,2);
nodes.Properties.VariableNames{'id'}='No';

if nargout==3

    quer = ['SELECT beschrijvende_id, volledige_naam, rijstrook,unieke_id AS detector_id,link_id,link_projection,ST_ASText(geom) AS geometry  FROM public.miv_config'];
    curs = exec(conn_KUL, [quer]);
    curs = fetch(curs);
    detectors = curs.Data;
    if conn_type == 'odbc'
        detectors = cell2table(detectors,'VariableNames',{'beschrijvende_id', 'volledige_naam', 'rijstrook','detector_id','link_id','link_projection','geometry'});
    end
%     detectors.Properties.VariableNames{'unieke_id'}='No';
%     detectors.Properties.VariableNames{'beschrijvende_id'}='id';
%     detectors.Properties.VariableNames{'volledige_naam'}='name';
%     detectors.Properties.VariableNames{'rijstrook'}='lane';

		out=cellfun(@(x) textscan(x,'POINT(%f %f)'),detectors.geometry,'UniformOutput',0);
		out = cellfun(@(x)cat(2,x{1,1},x{1,2}),out,'un',0);
		out = cell2mat(out);
		detectors.Xcoord=out(:,1);
		detectors.Ycoord=out(:,2);
end
fprintf('done\n')
end
