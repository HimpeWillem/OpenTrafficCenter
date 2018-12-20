function f=visualiseDetector(id,lane,name,km_pos,time,speed_h,flow_pae,name_figure)

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


%open up a new figure
f = figure('color','white','name',name_figure);
movegui(f,'center')

%max values on axis of figures;
max_flw=2800;
max_spd=130;
max_occ=100;

%add controlers
nameTextHandle = uicontrol(f, 'Style', 'Text',...
     'String', name{1},...
     'Horizontalalignment', 'left',...
     'Position', [50 180 180 40],...
     'FontWeight','bold',...
     'BackgroundColor','w');

popup_pos = uicontrol('Style', 'popup',...
    'String', num2str(km_pos'),...%
    'Position', [50 120 120 50],...
    'Background','white',...
    'Value',1,'Callback',@popup_pos_Callback);

text_pos = uicontrol('Style', 'text',...
    'String', ' Position: ',...
    'Background','white',...
    'HorizontalAlignment','left',...
    'Position', [50 170 120 18]);

popup_lane = uicontrol('Style', 'popup',...
    'String', ['SUM';cellstr(num2str(id{get(popup_pos,'Value')}'))],...%
    'Position', [50 70 120 50],...
    'Background','white',...
    'Value',1,'Callback',@popup_lane_Callback);

text_lane = uicontrol('Style', 'text',...
    'String', ' Lane:',...
    'Background','white',...
    'HorizontalAlignment','left',...
    'Position', [50 120 120 18]);


str = [' Sum of all lanes [',num2str(length(lane{1})),' lanes]'];
text_des = uicontrol('Style', 'text',...
    'String', str,...
    'Background','white',...
    'HorizontalAlignment','left',...
    'Position', [50 70 150 18]);
last_des = 'SUM';

popup_agg = uicontrol('Style', 'popup',...
    'String', {'1 min';'5 min';'10 min';'15 min'},...%
    'Position', [50 0 120 50],...
    'Background','white',...
    'Value',1,'Callback',@popup_agg_Callback);

text_agg = uicontrol('Style', 'text',...
    'String', ' Aggregation: ',...
    'Background','white',...
    'HorizontalAlignment','left',...
    'Position', [50 50 120 18]);



%get data
flw = sum(flow_pae(get(popup_pos,'Value'),:,:),3)*60;
spd = zeros(size(flw));
for i=1:length(id{get(popup_pos,'Value')})
    temp = (flow_pae(get(popup_pos,'Value'),:,i)*60)./speed_h(get(popup_pos,'Value'),:,i);
    spd(~isnan(temp)) = spd(~isnan(temp)) + temp(~isnan(temp));
end
spd = flw./spd;
occ = flw./spd;

%add graphs

%fundamental relation of speed and flow
s1=subplot(2,3,1);
fxs=plot(flw,spd,'g.');
xlabel('Flow (veh/h)')
ylabel('Speed (km/h)')
grid on;
axis([0 length(lane{1})*max_flw 0 max_spd]);

%fundamental relation of flow and speed
s2=subplot(2,3,2);
oxs=plot(occ,spd,'b.');
xlabel('Density (veh/km)')
ylabel('Speed (km/h)')
grid on;
axis([0 length(lane{1})*max_occ 0 max_spd]);

%fundamental relation of flow and occupancy
s3=subplot(2,3,3);
oxf=plot(occ,flw,'r.');
xlabel('Density (veh/km)')
ylabel('Flow (veh/h)')
grid on;
axis([0 length(lane{1})*max_occ 0 length(lane{1})*max_flw]);

%timeseries of the speed
s5=subplot(2,3,5);
txs=plot(time,spd,'m');
xlabel('Time (h)')
ylabel('Speed (km/h)')
set(gca,'XTick',[min(ceil(time*48)/48):1/24:max(floor(time*48)/48)]);%%%% set(gca,'XTick',[1:1/(24*2):length(time)]);
set(gca,'XTickLabel',datestr(ceil(time*48)/48:1/24:max(floor(time*48)/48),'HH:MM'));
axis([min(time) max(time) 0 max_spd]);
grid on;

%timeseries of the flow
s6=subplot(2,3,6);
txf=plot(time,flw,'c');
xlabel('Time (h)')
ylabel('Flow (veh/h)')
set(gca,'XTick',[min(ceil(time*48)/48):1/24:max(floor(time*48)/48)]);%%%% set(gca,'XTick',[1:1/(24*2):length(time)]);
set(gca,'XTickLabel',datestr(ceil(time*48)/48:1/24:max(floor(time*48)/48),'HH:MM'));
axis([min(time) max(time) 0 length(lane{1})*max_flw]);
grid on;

% callback for the drop-down menu of the position
    function popup_pos_Callback(obj,event)
        pos  = get(popup_pos,'Value');
        
        %set the name
        set(nameTextHandle,'String',name{pos});

        %get all lanes
        set(popup_lane,'String',['SUM';cellstr(num2str(id{pos}'))]);
       
        %select lane based on last selection
        switch last_des
            case 'SUM'
                %select lane with same reference
                set(popup_lane,'Value',1);
                
                %update data
                flw = sum(flow_pae(pos,:,1:length(id{pos})),3)*60;
                spd = zeros(size(flw));
                for i=1:length(id{pos})
                    temp = 60*flow_pae(pos,:,i)./speed_h(pos,:,i);
                    spd(~isnan(temp)) = spd(~isnan(temp)) + temp(~isnan(temp));
                end
                spd = flw./spd;
                occ = flw./spd;
                last_des='SUM';
                sl = length(lane{pos});
                
                %update text
                str = [' Sum of all lanes [',num2str(length(lane{pos})),' lanes]'];
                set(text_des,'String',str); 
                        
            case lane{pos}
                %select lane with same reference
                ln=find(strcmp(lane{pos},last_des))+1;
                set(popup_lane,'Value',ln);
                
                %update data
                flw = flow_pae(pos,:,ln-1)*60;
                spd = speed_h(pos,:,ln-1);
                occ = flw./spd;
                last_des=lane{pos}{ln-1};
                sl = 1;
                
                %update text
                str = [' Lane description: ',lane{pos}{ln-1}];
                set(text_des,'String',str);  
                                
            otherwise
                %just select a lane ('R10')
                ln=find(strcmp(lane{pos},'R10'))+1;
                set(popup_lane,'Value',ln);
                
                 %update data
                flw = flow_pae(pos,:,ln-1)*60;
                spd = speed_h(pos,:,ln-1);
                occ = flw./spd;
                last_des=lane{pos}{ln-1};
                sl = 1;
                
                %update text
                str = [' Lane description: ',lane{pos}{ln-1}];
                set(text_des,'String',str);        
        end            
        
        %aggregate the data
        switch get(popup_agg,'Value')
            case 1
                %only set time correct
                time_agg = time;
            case 2
                %filter data 
                flw=filter(ones(5,1)/5,1,flw);
                spd=filter(ones(5,1)/5,1,spd);
                occ=filter(ones(5,1)/5,1,occ);
                flw=flw(5:5:end);
                spd=spd(5:5:end);
                occ=occ(5:5:end);
                time_agg = time(5:5:end);
            case 3
                flw=filter(ones(10,1)/10,1,flw);
                spd=filter(ones(10,1)/10,1,spd);
                occ=filter(ones(10,1)/10,1,occ);
                flw=flw(10:10:end);
                spd=spd(10:10:end);
                occ=occ(10:10:end);
                time_agg = time(10:10:end);
            case 4
                flw=filter(ones(15,1)/15,1,flw);
                spd=filter(ones(15,1)/15,1,spd);
                occ=filter(ones(15,1)/15,1,occ);
                flw=flw(15:15:end);
                spd=spd(15:15:end);
                occ=occ(15:15:end);
                time_agg = time(15:15:end);
        end
        
        %update graphs
        set(fxs,'xdata',flw);
        set(fxs,'ydata',spd);
        axis(s1,[0 sl*max_flw 0 max_spd]);
        
        set(oxs,'xdata',occ);
        set(oxs,'ydata',spd);
        axis(s2,[0 sl*max_occ 0 max_spd]);
        
        set(oxf,'xdata',occ);
        set(oxf,'ydata',flw);
        axis(s3,[0 sl*max_occ 0 sl*max_flw]);
        
        set(txs,'xdata',time_agg);
        set(txs,'ydata',spd);
        
        set(txf,'xdata',time_agg);
        set(txf,'ydata',flw);
        axis(s6,[min(time) max(time) 0 sl*max_flw]);        
    end

% callback for the drop-down menu of the lane
    function popup_lane_Callback(obj,event)
        pos = get(popup_pos,'Value');
        ln = get(popup_lane,'Value');
        
        %update text
        if ln==1
            str = [' Sum of all lanes [',num2str(length(lane{pos})),' lanes]'];
        else
            str = [' Lane description: ',lane{pos}{ln-1}];
        end
        set(text_des,'String',str);
        
        %update data
        if ln==1
            flw = sum(flow_pae(pos,:,1:length(id{pos})),3)*60;
            spd = zeros(size(flw));
            for i=1:length(id{pos})
                temp = 60*flow_pae(pos,:,i)./speed_h(pos,:,i);
                spd(~isnan(temp)) = spd(~isnan(temp)) + temp(~isnan(temp));
            end
            spd = flw./spd;
            occ = flw./spd;
            last_des='SUM';
            sl = length(lane{pos});
        else
            flw = flow_pae(pos,:,ln-1)*60;
            spd = speed_h(pos,:,ln-1);
            occ = flw./spd;
            last_des=lane{pos}{ln-1};
            sl = 1;
        end
                
        %aggregate the data
        switch get(popup_agg,'Value')
            case 1
                %only set time correct
                time_agg = time;
            case 2
                %interpolate NaN
                flw= interp1q(time(~isnan(flw)),flw(~isnan(flw))',time)';
                spd= interp1q(time(~isnan(spd)),spd(~isnan(spd))',time)';
                occ= interp1q(time(~isnan(occ)),occ(~isnan(occ))',time)';
                                
                %filter data 
                flw=filter(ones(5,1)/5,1,flw);
                spd=filter(ones(5,1)/5,1,spd);
                occ=filter(ones(5,1)/5,1,occ);
                flw=flw(5:5:end);
                spd=spd(5:5:end);
                occ=occ(5:5:end);
                time_agg = time(5:5:end);
            case 3
                %interpolate NaN
                flw= interp1q(time(~isnan(flw)),flw(~isnan(flw))',time)';
                spd= interp1q(time(~isnan(spd)),spd(~isnan(spd))',time)';
                occ= interp1q(time(~isnan(occ)),occ(~isnan(occ))',time)';

                %filter data 
                flw=filter(ones(10,1)/10,1,flw);
                spd=filter(ones(10,1)/10,1,spd);
                occ=filter(ones(10,1)/10,1,occ);
                flw=flw(10:10:end);
                spd=spd(10:10:end);
                occ=occ(10:10:end);
                time_agg = time(10:10:end);
            case 4
                %interpolate NaN
                flw= interp1q(time(~isnan(flw)),flw(~isnan(flw))',time)';
                spd= interp1q(time(~isnan(spd)),spd(~isnan(spd))',time)';
                occ= interp1q(time(~isnan(occ)),occ(~isnan(occ))',time)';

                %filter data 
                flw=filter(ones(15,1)/15,1,flw);
                spd=filter(ones(15,1)/15,1,spd);
                occ=filter(ones(15,1)/15,1,occ);
                flw=flw(15:15:end);
                spd=spd(15:15:end);
                occ=occ(15:15:end);
                time_agg = time(15:15:end);
        end
            
        %update graphs
        set(fxs,'xdata',flw);
        set(fxs,'ydata',spd);
        axis(s1,[0 sl*max_flw 0 max_spd]);
        
        set(oxs,'xdata',occ);
        set(oxs,'ydata',spd);
        axis(s2,[0 sl*max_occ 0 max_spd]);
        
        set(oxf,'xdata',occ);
        set(oxf,'ydata',flw);
        axis(s3,[0 sl*max_occ 0 sl*max_flw]);
        
        set(txs,'xdata',time_agg);
        set(txs,'ydata',spd);
        
        set(txf,'xdata',time_agg);
        set(txf,'ydata',flw);
    end

% callback for the drop-down menu of the lane
    function popup_agg_Callback(obj,event)
        pos = get(popup_pos,'Value');
        ln = get(popup_lane,'Value');
               
        if ln==1
            flw = sum(flow_pae(pos,:,1:length(id{pos})),3)*60;
            spd = zeros(size(flw));
            for i=1:length(id{pos})
                temp = 60*flow_pae(pos,:,i)./speed_h(pos,:,i);
                spd(~isnan(temp)) = spd(~isnan(temp)) + temp(~isnan(temp));
            end
            spd = flw./spd;
            occ = flw./spd;
            last_des='SUM';
            sl = length(lane{pos});
        else
            flw = flow_pae(pos,:,ln-1)*60;
            spd = speed_h(pos,:,ln-1);
            occ = flw./spd;
            last_des=lane{pos}{ln-1};
            sl = 1;
        end
        
        %aggregate the data
        switch get(popup_agg,'Value')
            case 1
                %only set time correct
                time_agg = time;
            case 2
                %interpolate NaN
                flw= interp1q(time(~isnan(flw)),flw(~isnan(flw))',time)';
                spd= interp1q(time(~isnan(spd)),spd(~isnan(spd))',time)';
                occ= interp1q(time(~isnan(occ)),occ(~isnan(occ))',time)';
                
                %filter data 
                flw=filter(ones(5,1)/5,1,flw);
                spd=filter(ones(5,1)/5,1,spd);
                occ=filter(ones(5,1)/5,1,occ);
                flw=flw(5:5:end);
                spd=spd(5:5:end);
                occ=occ(5:5:end);
                time_agg = time(5:5:end);
            case 3
                %interpolate NaN
                flw= interp1q(time(~isnan(flw)),flw(~isnan(flw))',time)';
                spd= interp1q(time(~isnan(spd)),spd(~isnan(spd))',time)';
                occ= interp1q(time(~isnan(occ)),occ(~isnan(occ))',time)';
                
                %filter data 
                flw=filter(ones(10,1)/10,1,flw);
                spd=filter(ones(10,1)/10,1,spd);
                occ=filter(ones(10,1)/10,1,occ);
                flw=flw(10:10:end);
                spd=spd(10:10:end);
                occ=occ(10:10:end);
                time_agg = time(10:10:end);
            case 4
                %interpolate NaN
                flw= interp1q(time(~isnan(flw)),flw(~isnan(flw))',time)';
                spd= interp1q(time(~isnan(spd)),spd(~isnan(spd))',time)';
                occ= interp1q(time(~isnan(occ)),occ(~isnan(occ))',time)';
                
                %filter data 
                flw=filter(ones(15,1)/15,1,flw);
                spd=filter(ones(15,1)/15,1,spd);
                occ=filter(ones(15,1)/15,1,occ);
                flw=flw(15:15:end);
                spd=spd(15:15:end);
                occ=occ(15:15:end);
                time_agg = time(15:15:end);
        end
            
        %update graphs
        set(fxs,'xdata',flw);
        set(fxs,'ydata',spd);
        axis(s1,[0 sl*max_flw 0 max_spd]);
        
        set(oxs,'xdata',occ);
        set(oxs,'ydata',spd);
        axis(s2,[0 sl*max_occ 0 max_spd]);
        
        set(oxf,'xdata',occ);
        set(oxf,'ydata',flw);
        axis(s3,[0 sl*max_occ 0 sl*max_flw]);
        
        set(txs,'xdata',time_agg);
        set(txs,'ydata',spd);
                
        set(txf,'xdata',time_agg);
        set(txf,'ydata',flw);
    end
end
