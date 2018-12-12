function [n_select] = nodes_on_map(nodes,links,detectors)


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
