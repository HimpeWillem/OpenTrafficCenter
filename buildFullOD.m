function OD = buildFullOD(nodes,links,cvn_up,cvn_down,origins,destinations,dt)


%% Find the main route
maxNodesNo=max(nodes.No);
[rp,ci,ai]=sparse_to_csr(links.fromNode,links.toNode,links.length,maxNodesNo); %
totT = size(cvn_up,2);
OD = zeros(length(origins),length(destinations),totT-1);
time = 1:totT;

for o=origins'
    cvn = cvn_up(links.fromNode==o,:);
    OD = rec_downstream(OD,o,cvn,time);
end

    function [OD] = rec_downstream(OD,node,cvn,time)
        %find the sum of all outgoing links
        tot_up = zeros(1,totT-1);
        for ei=rp(node):rp(node+1)-1
            w=ci(ei);
            l_out = find(links.toNode==w & links.fromNode==node);
            rep_cvn=interp1q([-inf,1:totT,inf]',[0,cvn_up(l_out,:),cvn_up(l_out,end)]',time')';
            tot_up = tot_up + diff(rep_cvn);
        end
        
        for ei=rp(node):rp(node+1)-1
            w=ci(ei);
            l_out = find(links.toNode==w & links.fromNode==node);
            
            %split ratio
            rep_cvn=interp1q([-inf,1:totT,inf]',[0,cvn_up(l_out,:),cvn_up(l_out,end)]',time')';
            sp_rat=diff(rep_cvn)./tot_up;
            sp_rat(isnan(sp_rat))=1;
            cvn_new = cumsum([0,diff(cvn).*sp_rat]);
            
            %transfere to end of link
            [dcvn,icvn] = unique(cvn_down(l_out,:));
            out_time = interp1q([0,dcvn,dcvn(end)]',[-inf;icvn;inf],rep_cvn')';
            out_time(isnan(out_time))=inf;
                        
            if any(w==destinations)
                %fill in the od matrix a destination is found
                OD(find(o==origins),find(w==destinations),:)=diff(cvn_new)/dt;
            else
                %call the recursive function on the end node
                [OD] = rec_downstream(OD,w,cvn_new,out_time);
            end
        end
    end
end