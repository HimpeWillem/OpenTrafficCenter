function [TF] = createTFs(nodes,links,id,link_id,time,speed_h,flows_pae)

maxNodesNo=max(nodes.id);
[rp,ci,ai]=sparse_to_csr(links.fromNode,links.toNode,1:size(links,1),maxNodesNo); %
[rp_,ci_,ai_]=sparse_to_csr(links.toNode,links.fromNode,1:size(links,1),maxNodesNo); 

%% Set TF matrices
time_agg = time(5:5:end);
TF = num2cell(ones(size(nodes,1),length(time_agg)));
for n=1:size(nodes,1)
    if nnz(links.fromNode==nodes.id(n))>1
        in_l = find(links.fromNode==nodes.id(n))';
        flow_agg = zeros(length(in_l),length(time_agg));
        i=0;
        for l=in_l
            i=i+1;
            if any(l==link_id)
                flow_temp = sum(flows_pae(l==link_id,:,:),3);
                flow_temp = mean(flow_temp,1);
                flow_agg_temp=filter(ones(5,1)/5,1,flow_temp')';
                flow_agg(i,:) = flow_agg_temp(:,5:5:end);
                continue;
            end
            %move downstream until detector is found
            %(TODO: multiple splits are added)
            list = rec_downstream([],l);
            if ~isempty(list)
                flow_temp = zeros(1,length(time));
                j=0;
                for ll = list
                    j=j+1;
                    flow_temp = flow_temp + sign(list(j))*mean(sum(flows_pae(abs(ll)==link_id,:,:),3),1);
                end
                flow_agg_temp=filter(ones(5,1)/5,1,flow_temp')';
                flow_agg(i,:) = flow_agg_temp(:,5:5:end);
                continue;
            end
            %move upstream until detector is found
            %(TODO multiple merges are added)
            list = rec_upstream([],l);
            if ~isempty(list)
                flow_temp = zeros(1,length(time));
                j=0;
                for ll = list
                    j=j+1;
                    flow_temp = max(0,(flow_temp + sign(list(j))*mean(sum(flows_pae(abs(ll)==link_id,:,:),3),1)));
                end
                flow_agg_temp=filter(ones(5,1)/5,1,flow_temp')';
                flow_agg(i,:) = flow_agg_temp(:,5:5:end);
                continue;
            end
            display('problem could not find a detector, add a vitrual detector');
        end
        if any(any(isnan(flow_agg)))
            flow_agg(isnan(flow_agg)) = 0;
        end
        for t=1:length(time_agg)
            tot = sum(flow_agg(:,t));
            if tot>0
                TF{n,t} = [flow_agg(:,t)/tot]';
            else
                TF{n,t} = [mean(flow_agg,2)/sum(mean(flow_agg,2))]';
            end
        end
    end
end
for n=1:size(nodes,1)
    if nnz(links.toNode==nodes.id(n))>1 && size(TF{n,1},2)>1
        display('problem multiple incoming and outgoing links');
    elseif nnz(links.toNode==nodes.id(n))>1
        out_l = find(links.toNode==nodes.id(n));
        for t=1:length(time_agg)
            TF{n,t} = ones(length(out_l),1);
        end
    end
end

    function [list] = rec_downstream(list,l)
        node=links.toNode(l);
        if rp_(node+1)-rp_(node)>1
            for ei=rp_(node):rp_(node+1)-1
                l_loc = ai_(ei);
                if l_loc~=l
                    if any(link_id == l_loc)
                        list_temp = l_loc;
                    else
                        [list_temp] = rec_upstream([],l_loc);
                    end
                end
            end
            list = [list,-list_temp];
        end
            
        for ei=rp(node):rp(node+1)-1
            w=ci(ei);l_loc = ai(ei);
            if any(link_id == l_loc)
                list = [list,l_loc];
            else
                list = rec_downstream(list,l_loc);
            end
        end
    end
    
    function [list] = rec_upstream(list,l)
        node=links.fromNode(l);
        if rp(node+1)-rp(node)>1
            for ei=rp(node):rp(node+1)-1
                l_loc = ai(ei);
                if l_loc~=l
                    if any(link_id == l_loc)
                        list_temp = l_loc;
                    else
                        [list_temp] = rec_downstream([],l_loc);
                    end
                end
            end
            list = [list,-list_temp];
        end
        
        for ei=rp_(node):rp_(node+1)-1
            w=ci_(ei);l_loc = ai_(ei);
            if nnz(node==links.toNode)>1
                return;
            end
            if any(link_id == l_loc)
                list = [list,l_loc];
            else
                list = rec_upstream(list,l_loc);
            end
        end
    end
end
