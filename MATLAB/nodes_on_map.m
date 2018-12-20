function [n_select] = nodes_on_map(nodes,links,detectors)

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
%plot nodes
plot(xco(unique([links.fromNode;links.toNode])),yco(unique([links.fromNode;links.toNode])),'.','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 0 0]);

%plot detectors
plot(detectors.Xcoord,detectors.Ycoord,'d','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 0 1]);

%plot links
co = cell2mat(links.co);
plot(co(:,1),co(:,2),'Color',[0 0 0]); %[0.9 0.7 0]
title('Zoom into the region of the node you want to select (see command window for instructions)')

% pause;

[x_select,y_select] = ginput2(1);

if ishandle(f)
    [val,n_select]=min((nodes.Xcoord-x_select).^2+(nodes.Ycoord-y_select).^2);
    title('Selected node')
    plot(nodes.Xcoord(n_select),nodes.Ycoord(n_select),'o','MarkerEdgeColor',[1 0 0],'MarkerFaceColor',[1 0 0]);
    display(['You have selected node ',num2str(nodes.No(n_select))]);
    pause(0.6)
    close(f);
else
    display(['figure closed before a node was selected']);
    n_select = [];
end
