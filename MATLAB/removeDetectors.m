function [detectors] = removeDetectors(nodes,links,detectors,km_pos,name,id)

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

active = ones(length(name),1);

selectionButton = questdlg('Do you want to remove a detector?', ...
    'Select position', ...
    'From a List', 'Text Input', 'No', 'No');

list = cellfun(@(x,y) [x,' ',y],cellstr(num2str(km_pos')),[name{:}]','UniformOutput',0);

while true
    switch selectionButton
        case 'From a List'
            %Load the list with paths
            
            [ind,tf] = listdlg('ListString',list,'SelectionMode','single');
            if tf
                list(ind)=[];
                detectors(arrayfun(@(x)find(x==detectors.detector_id), id{ind}'),:)=[];
                id(ind)=[];
            end
%         case 'On a Map'
%             % Select the starting point
%             
%             [ind] = link_on_map(nodes,links);
%             drawnow;
%             awnser=inputdlg({['Set capacity (old capacity: ',num2str(links.capacity(ind)),')']},'New Capacity');
%             links.capacity(ind)=str2double(awnser{1});
        case 'Text Input'
            awnser=inputdlg({'Position'},'Select position');
            if length(awnser)>1
                ind = str2num(awnser{1});
                detectors(arrayfun(@(x)find(x==detectors.detector_id), id{ind}'),:)=[];
            end
        case 'No'
            return;
    end
    
    selectionButton_continue = questdlg('Do you want to remove another detector?', ...
    '', ...
    'Yes','No', 'No');
    switch selectionButton_continue
        case 'Yes'
            selectionButton = questdlg('How do you like to select a detector?', ...
                                        'Select position', ...
                                        'From a List', 'Text Input', 'No', 'No');
        case 'No'
            return;
    end
end

end
