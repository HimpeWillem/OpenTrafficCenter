function [links] = setCapacity(nodes,links)

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

selectionButton = questdlg('Do you want to change the capacity of a link?', ...
    'Select link', ...
    'From a List','On a Map','No', 'No');

while true
    switch selectionButton
        case 'From a List'
            %Load the list with paths
            list = arrayfun(@(x,y) sprintf('No:%d     Cap:%d',x,y),links.No,links.capacity,'UniformOutput',false);
            [ind,tf] = listdlg('ListString',(list),'SelectionMode','single');
            if tf
                awnser=inputdlg({['Set capacity (old capacity: ',num2str(links.capacity(ind)),')']},'New Capacity');
                links.capacity(ind)=str2double(awnser{1});
            end
        case 'On a Map'
            % Select the starting point
            [ind] = link_on_map(nodes,links);
            drawnow;
            awnser=inputdlg({['Set capacity (old capacity: ',num2str(links.capacity(ind)),')']},'New Capacity');
            links.capacity(ind)=str2double(awnser{1});
        case 'No'
            return;
    end
    
    selectionButton_continue = questdlg('Do you which to change another link?', ...
    '', ...
    'Yes','No', 'No');
    switch selectionButton_continue
        case 'Yes'
            selectionButton = questdlg('How do you like to select a link?', ...
                                        'Select link', ...
                                        'From a List','On a Map', 'From a List');
        case 'No'
            return;
    end
end

end
