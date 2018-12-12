%Nested function that assigns the origin flow
function [cvn,l_list]=loadOriginNodes(t,origins,fromNodes,ODmatrix,TF,n_ind,cvn_up,dt)
%#codegen
%coder.inline('never');

cvn = [];
l_list = [];
%update origin nodes
for o_index=1:length(origins)
    o = origins(o_index);
    outgoingLinks = find(fromNodes==o);
    for l_index=1:length(outgoingLinks)
        l=outgoingLinks(l_index);
        l_list = [l_list,l];
        %calculation sending flow
        tf=reshape(TF(n_ind(o):n_ind(o+1)-1,t-1),1,1);
        SF = tf.*sum(ODmatrix(o_index,:,t-1))*dt;
        cvn=[cvn,cvn_up(l,t-1) + SF];
    end
end
end