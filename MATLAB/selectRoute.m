function [name_figure,str_point,end_point,int_point] = selectRoute(nodes,links,detectors)

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


str_point=[];
end_point=[];
int_point=[];
name_figure=[];

selectionButton = questdlg('How do you like to select points?', ...
    'Select point', ...
    'From a List','On a Map', 'Text Input','From a List');

switch selectionButton
    case 'From a List'
        
        %Load the list with paths
        fileID = fopen('path_list.csv','r');
        dataArray = textscan(fileID, '%s%f%f%[^\n\r]', 'Delimiter', ',', 'EmptyValue' ,NaN,'HeaderLines' ,0, 'ReturnOnError', false);
        fclose(fileID);
        point_list = [dataArray{: , 2}, dataArray{: , 3}];
        path_list = dataArray{: , 1};
        [ind,tf] = listdlg('ListString',path_list,'SelectionMode','single');
        if tf
            name_figure = path_list{ind};
            str_point=point_list(ind,1);
            end_point=point_list(ind,2);
        end
        
    case 'On a Map'
                 
        disp(' ')
        disp('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$')
        disp('$ Select node             -> rigth mouse button                 $')
        disp('$ Zoom in                 -> left mouse button                  $')
        disp('$ Zoom out                -> double click left mouse button     $')
        disp('$ Pan                     -> hold left mouse button             $')
        disp('$ Zoom out all the way    -> Center mouse button                $')
        disp('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$')
        disp(' ')
        
        % Select the starting point
        [str_point] = nodes_on_map(nodes,links,detectors);
        % Select the end point
        [end_point] = nodes_on_map(nodes,links,detectors);
        name_figure = ['From node ',num2str(str_point),' to ',num2str(end_point)];
        drawnow;
        
    case 'Text Input'
        
        awnser=inputdlg({'Starting node','End node'},'Select node');
        if length(awnser)>1
            str_point = str2num(awnser{1});
            end_point = str2num(awnser{2});
            name_figure = ['From node ',num2str(str_point),' to ',num2str(end_point)];
        end
end

disp(['Corridor selected: ',name_figure])
end
