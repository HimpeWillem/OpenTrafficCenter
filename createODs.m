function [timeSeries,ODmatrices] = createODs(links,origins,id,link_id,time,speed_h,flows_pae)

maxNodesNo=max([links.fromNode;links.toNode]);
[rp,ci,ai]=sparse_to_csr(links.fromNode,links.toNode,1:size(links,1),maxNodesNo); %
[rp_,ci_,ai_]=sparse_to_csr(links.toNode,links.fromNode,1:size(links,1),maxNodesNo); 


%% Set OD matrices

timeSeries=[];
ODmatrices=[];
par = 0;

%select origin flows
origin_links=cell2mat(arrayfun(@(x)find(links.fromNode==x),origins,'UniformOutput',0));
% link_ind=cell2mat(arrayfun(@(x)find(link_id==x,1,'first'),origin_links,'UniformOutput',0));
% flows_pae_temp = flows_pae(link_ind,:,:);
% flow = sum(flows_pae_temp,3);
time_agg = time(5:5:end);
% flow_agg=filter(ones(5,1)/5,1,flow')';
% flow_agg = flow_agg(:,5:5:end);

i=0;
flow_agg = zeros(length(origins),length(time_agg));
for l=origin_links'
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
end

% 
% speed_h=speed_h(link_ind,:,:);
% speed = zeros(size(speed_h,1),size(speed_h,2));
% for i=1:size(speed_h,3)
%     temp = flows_pae_temp(:,:,i)./speed_h(:,:,i);
%     speed(find(~isnan(temp))) = speed(find(~isnan(temp))) + temp(find(~isnan(temp)));
% end
% speed = flow./speed;
% 
% l_temp=1:size(speed,2);
% for l=1:size(speed,1)
%     nanx = isnan(speed(l,:));
%     if any(nanx)
%         speed(l,nanx) = interp1(l_temp(~nanx), speed(l,~nanx), l_temp(nanx),'linear','extrap');
%     end
% end
% 
% speed_agg=filter(ones(5,1)/5,1,speed')';
% speed_agg = speed_agg(:,5:5:end);

% cellfun(@(x)length(x),id(link_ind))<links.lanes(origin_links)

% for l=1:size(flow_agg,1)
%     flow_agg(l,speed_agg(l,:)<50) = (1-par)*mean(flow_agg(l,speed_agg(l,:)>50)) + par*max(flow_agg(l,speed_agg(l,:)>50));
% end

flow_agg(isnan(flow_agg))=0;

for t=1:length(time_agg)
    timeSeries{1,t} = (time_agg(t)-min(time_agg))*24;
    ODmatrices{1,t} = zeros(length(origins),1);
    ODmatrices{1,t}(:,1) = flow_agg(:,t)*60;
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
