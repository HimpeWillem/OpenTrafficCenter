function [start_time,end_time]=selectTime

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


global summer_time;

%the database contains data for the last 7 days
start_time = now-7;
end_time = now;

f = figure('color','white');

dateTextHandle_1 = uicontrol(f, 'Style', 'Text','String', 'Starting date:','Horizontalalignment', 'left','Position', [100 200 100 20],'BackgroundColor','w');
dateTextHandle_2 = uicontrol(f, 'Style', 'Text','String', 'End date:','Horizontalalignment', 'left','Position', [100 135 100 20],'BackgroundColor','w');
dateEditBoxHandle_1 = uicontrol(f, 'Style', 'Edit','Position', [200 200 100 20],'BackgroundColor', 'w');
dateEditBoxHandle_2 = uicontrol(f, 'Style', 'Edit','Position', [200 135 100 20],'BackgroundColor', 'w');
calendarButtonHandle_1 = uicontrol(f, 'Style', 'PushButton','String', 'Select a starting date','Position', [100 175 200 20],'callback', @pushbutton_date_1);
calendarButtonHandle_2 = uicontrol(f, 'Style', 'PushButton','String', 'Select an end date','Position', [100 110 200 20],'callback', @pushbutton_date_2);

timeTextHandle_1 = uicontrol(f, 'Style', 'Text','String', 'Starting time:','Horizontalalignment', 'left','Position', [320 200 100 20],'BackgroundColor','w');
timeTextHandle_2 = uicontrol(f, 'Style', 'Text','String', 'End time:','Horizontalalignment', 'left','Position', [320 135 100 20],'BackgroundColor','w');
timeEditBoxHandle_1 = uicontrol(f, 'Style', 'Edit','Position', [420 200 100 20],'BackgroundColor', 'w');
timeEditBoxHandle_2 = uicontrol(f, 'Style', 'Edit','Position', [420 135 100 20],'BackgroundColor', 'w');
timeButtonHandle_1 = uicontrol(f, 'Style', 'PushButton','String', 'Select a start time','Position', [320 175 200 20],'callback', @pushbutton_time_1);
timeButtonHandle_2 = uicontrol(f, 'Style', 'PushButton','String', 'Select an end time','Position', [320 110 200 20],'callback', @pushbutton_time_2);


set(dateEditBoxHandle_1,'String',datestr(start_time,'dd-mmm-yyyy'));
set(dateEditBoxHandle_2,'String',datestr(end_time,'dd-mmm-yyyy'));
set(timeEditBoxHandle_1,'String',datestr(start_time,'HH:MM'));
set(timeEditBoxHandle_2,'String',datestr(end_time,'HH:MM'));

valid_days = [floor(start_time):floor(end_time)]';
dateboxcolors = [valid_days,zeros(length(valid_days),1),ones(length(valid_days),1),zeros(length(valid_days),1)];

calendarButtonHandle_3 = uicontrol(f, 'Style', 'PushButton','String', 'Ready','Position', [260 50 100 20],'callback', @pushbutton);

waitfor(f);
disp(['Time window from ', datestr(start_time,'dd-mmm-yyyy HH:MM'), ' to ',datestr(end_time,'dd-mmm-yyyy HH:MM')]);
if ~summer_time
    start_time = start_time+1/24;
    end_time = end_time+1/24;
end

    function pushbutton_date_1(hcbo, eventStruct)
        
        c=uicalendar('Weekend', [1 0 0 0 0 0 1], ...
            'SelectionType', 1, ...
            'DateBoxColor',dateboxcolors,...
            'DestinationUI', dateEditBoxHandle_1);
        while ishandle(c)
            pause(0.01);
        end
        date_string=get(dateEditBoxHandle_1,'String');
        set(dateEditBoxHandle_2,'String',date_string);
    end

    function pushbutton_date_2(hcbo, eventStruct)
        uicalendar('Weekend', [1 0 0 0 0 0 1], ...
            'SelectionType', 1, ...
            'DateBoxColor',dateboxcolors,...
            'DestinationUI', dateEditBoxHandle_2);
    end

    function pushbutton_time_1(hcbo, eventStruct)
        list_time = [0:0.5:24]';
        [ind,tf] = listdlg('ListString',datestr(list_time/24,'HH:MM'),'SelectionMode','single');
        if tf
            set(timeEditBoxHandle_1,'String',datestr(list_time(ind)/24,'HH:MM'));
            set(timeEditBoxHandle_2,'String',datestr(list_time(ind)/24+5/24,'HH:MM'));      
        end
    end

    function pushbutton_time_2(hcbo, eventStruct)
        list_time = [0:0.5:24]';
        [ind,tf] = listdlg('ListString',datestr(list_time/24,'HH:MM'),'SelectionMode','single');
        if tf
            set(timeEditBoxHandle_2,'String',datestr(list_time(ind)/24,'HH:MM'));      
        end
    end

    function pushbutton(hcbo, eventStruct)
        start_time = datenum(get(dateEditBoxHandle_1,'String'))+datenum(['0 1 0 ', get(timeEditBoxHandle_1,'String')],'yyyy mm dd HH:MM');
        end_time = datenum(get(dateEditBoxHandle_2,'String'))+datenum(['0 1 0 ', get(timeEditBoxHandle_2,'String'),':59'],'yyyy mm dd HH:MM:SS');
        close(f);
        drawnow;
    end

end
