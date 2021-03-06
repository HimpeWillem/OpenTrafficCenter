function showCorridor(nodes_full,links_full,nodes,links,detectors,data)

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


f=figure();%'units','normalized','outerposition',[0 0 1 1]);
hold on;
%% plot all nodes
maxNodesNo=max(nodes_full.No);
xco=zeros(maxNodesNo,1);
yco=zeros(maxNodesNo,1);
xco(nodes_full.No)=nodes_full.Xcoord;
yco(nodes_full.No)=nodes_full.Ycoord;

plot(xco(unique([links_full.fromNode;links_full.toNode])),yco(unique([links_full.fromNode;links_full.toNode])),'.','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0 0 0]);

%% plot all links
co = cell2mat(links_full.co);
plot(co(:,1),co(:,2),'Color',[0 0 0]); %[0.9 0.7 0]

%% plot the selected corridor
co = cell2mat(links.co);
plot(co(:,1),co(:,2),'Color',[1 0 0]); %[0.9 0.7 0]


%% Show the selected detectors
for d=1:size(detectors,1)
	hdetectors(d)=line(detectors.Xcoord(d),detectors.Ycoord(d)); %[0.9 0.7 0]
end
rang_X=0.1*(max(detectors.Xcoord)-min(detectors.Xcoord));
rang_Y=0.1*(max(detectors.Ycoord)-min(detectors.Ycoord));
axis([min(detectors.Xcoord)-rang_X,max(detectors.Xcoord)+rang_X,min(detectors.Ycoord)-rang_Y,max(detectors.Ycoord)+rang_Y])

set(hdetectors, 'Marker', 'd', 'MarkerEdge', 'none', 'HitTest', 'on', 'MarkerFaceColor',[0 0 1])

% attach callback functions to nodes and link handles
set(hdetectors, 'ButtonDownFcn', @detectorSelectionCallback)
title('Selected corridor -- click on a detector to display its data');

	  function detectorSelectionCallback(h,temp)
            d = find(hdetectors == h);
            link_id=detectors.link_id(d);
            link_projection=detectors.link_projection(d);
            d= find(detectors.link_id==link_id&detectors.link_projection==link_projection);
			[id,lane,name,~,time,speed_h,~,~,flows_pae,~,~] = selectData(data,detectors(d,:));
            visualizeDetector(id,lane,name,1,time,speed_h,flows_pae,['Detectors on link ',num2str(link_id),'(',num2str(link_projection),')']);
    end


end
