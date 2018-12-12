function [links] = setCapacity(nodes,links)

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