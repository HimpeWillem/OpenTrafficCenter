function [nodes_net,links_net,origins,destinations,detectors_net,data,lmain,lorg] = createNetworkModel_v2(nodes,links,detectors,str_point,end_point,int_point,str_time,end_time)

global conn_KUL conn_type;


%% Find the main route
maxNodesNo=max(nodes.No);
[rp,ci,ai]=sparse_to_csr(links.fromNode,links.toNode,links.length,maxNodesNo); %
[rp_,ci_,ai_]=sparse_to_csr(links.toNode,links.fromNode,links.length,maxNodesNo); %
[~, par,~] = dijkstra_v2(rp,ci,ai,str_point);
main_route =[]; u = end_point; while (u ~= str_point) main_route=[u main_route]; u=par(u); end

%find the actual links
func = @(x,y)find(links.fromNode==x & links.toNode==y);
main_route = arrayfun(func,main_route(1:end-1),main_route(2:end));
links_net = links(main_route',:);

%% Reset From & toNodes
fromNodes=1:size(links_net,1);
toNodes=1:size(links_net,1)+1;
maxN = size(links_net,1)+1;

%% Add on ramps
lmain = size(links_net,1);
id_on = 1;
for l=1:lmain-1
    if nnz(links.toNode==links_net.toNode(l))>1
        %found a merge node now following this links upstream until a detector is found
        rec_upstream([],links_net.toNode(l));
    end
end
lorg = size(links_net,1)-lmain;


%% Add off ramps
id_main = [];
id_off = [];
for l=2:lmain
    if nnz(links.fromNode==links_net.fromNode(l))>1
        %found a diverge node now following this links downstream until a detector is found
        l_off_before = length(id_off);
        rec_downstream([],links_net.fromNode(l));
        if length(id_off)-l_off_before>1
            %use function add_detector for this link
            display(['problem: a virtual detector is needed @ node ',num2str(links_net.fromNode(l))])
        end
        l_m = l;
        while ~any(detectors.link_id == links_net.No(l_m))
            l_m = l_m + 1;
        end
        id_main = [id_main,l_m];
    end
end


%% Set nodes (restructure based on increasing integegers)
[C,IA,IC] = unique([links_net.fromNode;links_net.toNode]);
nodes_conv = sparse(C,ones(length(IA),1),[1:length(IA)]');
links_net.fromNode = full(nodes_conv(links_net.fromNode));
links_net.toNode = full(nodes_conv(links_net.toNode));

nodes_net = nodes(C,:);

nodes_net.xco = nodes_net.Xcoord;
nodes_net.yco = nodes_net.Ycoord;
nodes_net.id = [1:length(nodes_net.No)]';
nodes_net.No = nodes_net.id;

origins = links_net.fromNode(id_on);
destinations = [links_net.toNode(id_off);links_net.toNode(lmain)];

%% Links length is in km
links_net.length = links_net.length/1000;

%% Collect all the data
data_links.edge = links_net.No;
%Collect the data from the KUL server
[data] = collectData(data_links,str_time,end_time);

%Select the dectors
unieke_id_detectors = unique(data.unieke_id);
detectors_net=detectors(arrayfun(@(x)find(x==detectors.detector_id), unieke_id_detectors),:);

%% Some recursive functions

    function [list] = rec_upstream(list,node)
        for ei=rp_(node):rp_(node+1)-1
            w=ci_(ei);
            l_in = find(links.fromNode==w & links.toNode==node);
            if any(links_net.No == links.No(l_in))
                continue;
            elseif any(detectors.link_id == links.No(l_in))
                links_net(end+1,:) = links(l_in,:);
                list = [list,l_in];
                id_on = [id_on,size(links_net,1)];
            else
                links_net(end+1,:) = links(l_in,:);
                list = [list,l_in];
                list = rec_upstream(list,links.fromNode(l_in));
            end
        end
    end

    function [list] = rec_downstream(list,node)
        for ei=rp(node):rp(node+1)-1
            w=ci(ei);
            l_out = find(links.toNode==w & links.fromNode==node);
            if any(links_net.No == links.No(l_out))
                continue;
            elseif any(detectors.link_id == links.No(l_out))
                links_net(end+1,:) = links(l_out,:);
                list = [list,l_out];
                id_off = [id_off,size(links_net,1)];
            else
                links_net(end+1,:) = links(l_out,:);
                list = [list,l_out];
                list = rec_downstream(list,links.toNode(l_out));
            end
        end
    end
end