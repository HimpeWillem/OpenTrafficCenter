function xt_plot(data,xco,km_loc,time,name_figure,varargin)

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


figure('color','white');hold on;
% surf(time,xco,data,'LineStyle','none');%,'facecolor','texturemap' %time,xco
temp_data = data;
if nargin>5
    temp_data(varargin{1}==0)=NaN;
end

if 10 < mean(mean(data(~isnan(data)))) && mean(mean(data(~isnan(data)))) < 120

    temp_data(~isnan(temp_data)) = min(temp_data(~isnan(temp_data)),140);

    contourf(time,xco,temp_data,[0:10:130],'LineStyle','none');
    cbP = colorbar('EastOutside');
    
    
    
    dr=[0.5,0,0]; % 0
    r=[1,0,0]; %30
    y=[1,1,0]; %90
    g=[0.3125,1,0.6875]; %140
    
    caxis([0,140]);    
%     my_jet = jet(512);
%     my_jet(212:-1:1,:)=[];
%     colormap(my_jet(300:-1:20,:));
%     
    my_jet = [interp1([0 30],[dr;r],[0:1:30]);interp1([30 80],[r;y],[30:1:80]);interp1([80 140],[y;g],[80:1:140])];
    colormap(my_jet)
    set(cbP,'YLim',[0 120],'YTick',[0:10:120],'YTickLabel',[0:10:120]);
elseif mean(mean(data(~isnan(data))))>1000
    temp_data = temp_data + rand(size(data))*eps;
    contourf(time,xco,temp_data,'LineStyle','none');

    my_jet = jet(512);
    my_jet(256:-1:1,:)=[];
    colormap(my_jet(1:256,:));
    cbP = colorbar('EastOutside');
else
%     temp_data(isnan(temp_data))=mean(mean(data));
    contourf(time,xco,temp_data,'LineStyle','none','LevelStep',10);

    my_jet = cool(512);
    my_jet(256:-1:1,:)=[];
    colormap(my_jet(256:-1:1,:));
    cbP = colorbar('EastOutside');

end


% set(gca,'Ydir','reverse')
% set(gca,'XTick',[min(time):1/(24*2):max(time)])
for i=1:numel(km_loc)
    plot(time,km_loc(i)*ones(length(time),1),'k');%time, km_loc(i)*ones(length(time),1),
end
% view(2);
% xlabel('Time (minutes)','FontSize',12)
% ylabel('Distance (km)','FontSize',12)
% title(['Speed '])
% 
% colorbar
axis('tight')

set(gca,'XTick',[min(ceil(time*48)/48):1/(24*2):max(floor(time*48)/48)]);%%%% set(gca,'XTick',[1:1/(24*2):length(time)]);
set(gca,'XTickLabel',datestr(ceil(time*48)/48:1/(24*2):max(floor(time*48)/48),'HH:MM'));
% xticklabel_rotate([],45,[]);
% yyaxis 'right';
set(gca,'YTick',sort(km_loc));
xlabel('Time [hr]','FontSize',12)
ylabel('Distance [km]','FontSize',12)
% caxis([0 max(max(data))]);
% cbP = colorbar('peer',gca,'EastOutside');


% colormap(my_jet(end:-1:1,:));

grid on
title(['Space - Time graph: ',name_figure],'FontSize',14,'fontweight','b')
