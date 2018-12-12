%Nested function that assigns the destination flow
function [cvn,l_list]=loadDestinationNodes(t,destinations,toNodes,cvn_up,cvn_down,lengths,freeSpeeds,capacities,timeSlices,dt)
%#codegen
%coder.inline('never');

cvn = [];
l_list = [];
%update destination nodes
for d_index=1:length(destinations)
    d = destinations(d_index);
    incomingLinks = find(toNodes==d);
    for l_index=1:length(incomingLinks)
        l=incomingLinks(l_index);
        l_list = [l_list,l];
        %calculation sending flow
        SF = capacities(l)*dt;
        SF = min(SF,findCVN(cvn_up(l,:),max(eps,timeSlices(t)-lengths(l)/freeSpeeds(l)),timeSlices,dt)-cvn_down(l,t-1));
        cvn=[cvn,cvn_down(l,t-1) + SF];
    end
end
end