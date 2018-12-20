function [ind] = link_on_map(nodes,links)

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


maxNodesNo=max(nodes.No);
maxLinksNo=max(links.No);
xco=zeros(maxNodesNo,1);
yco=zeros(maxNodesNo,1);
xco(nodes.No)=nodes.Xcoord;
yco(nodes.No)=nodes.Ycoord;

toNode = zeros(2*maxLinksNo,1);
fromNode = zeros(2*maxLinksNo,1);
toNode(links.No) = links.toNode;
fromNode(links.No) = links.fromNode;

%% Visulize the network (only links and nodes)
f=figure('units','normalized','outerposition',[0 0 1 1]);
hold on;
%local rename link properties
strN = links.fromNode;
endN = links.toNode;
x=nodes.xco;
y=nodes.yco;

plot(x,y,'.','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 0 0]);
    
x_temp = zeros(length(strN)*3,1);
x_temp(1:3:end) = x(strN);
x_temp(2:3:end) = x(endN);
x_temp(3:3:end) = NaN;

y_temp = zeros(length(strN)*3,1);
y_temp(1:3:end) = y(strN);
y_temp(2:3:end) = y(endN);
y_temp(3:3:end) = NaN;

plot(x_temp, y_temp,'Color',[0 0 0]); %[0.9 0.7 0]

%Setup figure
margX=0.1*(max(x)-min(x))+100*eps;
margY=0.1*(max(y)-min(y))+100*eps;
axis([min(x)-margX max(x)+margX min(y)-margY max(y)+margY]);
colorbar('EastOutside');

maxc=max(links.capacity);

% handle_ax=axes;

%make a rectangular object for each link
upX=x(strN);
downX=x(endN);
upY=y(strN);
downY=y(endN);

%set scale
scale = 1/maxc*0.25*sqrt((max(x)-min(x))^2+(max(y)-min(y))^2)/length(upX)^(1/2);

vx=downX-upX;
vy=downY-upY;
vl=sqrt(vx.^2+vy.^2);
vx=vx./vl;
vy=vy./vl;

sc=scale;
sc=eps+scale*links.capacity';

xrec=[upX';upX'+sc.*vy';downX'+sc.*vy';downX'];
yrec=[upY';upY'-sc.*vx';downY'-sc.*vx';downY'];


%set the colours
ctemp=hsv(128);
cmap=colormap(ctemp(50:-1:1,:));
% cmap=colormap(handle_ax,ctemp(50:-1:1,:));


minc=0;%possible one could also use the minimal positive value of the load  %max(0,min(load));

crec=cmap(ceil(49*(links.capacity'-minc+eps)/(maxc-minc+eps))',:);
caxis([minc maxc]);

%visualize all loads
handle_rect=patch(xrec,yrec,links.capacity');
set(handle_rect,'FaceColor','flat','FaceVertexCData',crec);
warning off verbose
% colorbar('EastOutside');

handle_txt=[];
cx=[x(strN)+x(endN)]/2;
cy=[y(strN)+y(endN)]/2;
id=[1:length(cx)]';
bl=(upX >= downX & upY <= downY);
tl=(upX < downX & upY < downY);
br=(upX >= downX & upY > downY);
tr=(upX < downX & upY >= downY);
t1=text(cx(bl),cy(bl),num2str(links.capacity(bl)),'Color',[0 0 0],'VerticalAlignment','Bottom','HorizontalAlignment','Left','FontWeight','bold','Clipping','on','hittest','off');
t2=text(cx(tl),cy(tl),num2str(links.capacity(tl)),'Color',[0 0 0],'VerticalAlignment','Top','HorizontalAlignment','Left','FontWeight','bold','Clipping','on','hittest','off');
t3=text(cx(br),cy(br),num2str(links.capacity(br)),'Color',[0 0 0],'VerticalAlignment','Bottom','HorizontalAlignment','Right','FontWeight','bold','Clipping','on','hittest','off');
t4=text(cx(tr),cy(tr),num2str(links.capacity(tr)),'Color',[0 0 0],'VerticalAlignment','Top','HorizontalAlignment','Right','FontWeight','bold','Clipping','on','hittest','off');
handle_txt=[t1;t2;t3;t4];

% %plot nodes
% plot(xco(unique([links.fromNode;links.toNode])),yco(unique([links.fromNode;links.toNode])),'.','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 0 0]);
% 
% %plot links
% x=nan(length(links.toNode)*3,1);
% y=nan(length(links.toNode)*3,1);
% x(1:3:end)=xco(fromNode(links.No));
% y(1:3:end)=yco(fromNode(links.No));
% x(2:3:end)=xco(toNode(links.No));
% y(2:3:end)=yco(toNode(links.No));
% plot(x,y,'Color',[0 0 0]); %[0.9 0.7 0]

display('Zoom into the region of the zone you want to select and press a key')
pause;

[x_select,y_select] = ginput(1);

act_l = [];
rad = 10^7;
while nnz(act_l)<min(length(links.capacity),100)
    act_l = [];
    act_l = (x_temp-x_select).^2 + (y_temp-y_select).^2 < rad;
    rad = rad + 1000;
    act_l=find(act_l(1:3:end)&act_l(2:3:end));
end


begin_l=[xco(links.fromNode(act_l)),yco(links.fromNode(act_l))];
end_l=[xco(links.toNode(act_l)),yco(links.toNode(act_l))];
P = repmat([x_select y_select],length(act_l),1);
W = P-begin_l;
V = end_l-begin_l;
frac = min(1,max(0,dot(W',V')./dot(V',V')));
prj = begin_l+repmat(frac',1,2).*V;
vec = P-prj;
sqr_dist = dot(vec',vec')';
angle = atan2(V(:,2),V(:,1))-atan2(W(:,2),W(:,1));
angle(angle<0) = angle(angle<0)+2*pi;
valid = angle<pi;
ind = act_l(find(abs(min(sqr_dist(valid))-sqr_dist)<eps*10 & valid));

clear val;
plot([xco(links.fromNode(ind)),xco(links.toNode(ind))],[yco(links.fromNode(ind)),yco(links.toNode(ind))],'r-','lineWidth',2);

pause(0.6)
close(f);
end
