function [cvn_up,cvn_down] = LTM_SC_v3(fromNodes,toNodes,freeSpeeds,capacities,kJams,lengths,wSpeeds,fromL,toL,n_ind,nFromL,nToL,origins,destinations,ODmatrix,dt,totT,TF)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%link transmission model for network loading                              %
%                                                                         %
%destination based storing of commodities                                 %
%splitting rates at nodes based on TF                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This file is part of the matlab package for dynamic traffic assignments
% developed by the KULeuven.
%
% Copyright (C) 2016  Himpe Willem, Leuven, Belgium
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
% More information at: http://www.mech.kuleuven.be/en/cib/traffic/downloads
% or contact: willem.himpe {@} kuleuven.be

%size of the network
totLinks=length(fromNodes);

%time slices for which a solution is build
timeSlices = [0:totT]*dt;

%cumulative vehicle numbers (cvn) are stored on both upstream and
%dowsntream link end of each link for every time slice
cvn_up = zeros(totLinks,totT+1);
cvn_down = zeros(totLinks,totT+1);

%nodes that are not origins or destinations
normalNodes = setdiff(unique([fromNodes;toNodes]),sort([origins;destinations]));

%forward explicit scheme
%go sequentially over each time step (first time step => all zeros)
for t=2:totT+1
    %ORIGIN NODES<--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    %this nested function goes over all origin nodes
    [cvn,l_list]=loadOriginNodes(t,origins,fromNodes,ODmatrix,TF,n_ind,cvn_up,dt);
    cvn_up(l_list,t)=cvn;
    
    %ACTUAL LTM <---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    %go over all normal nodes in this time step
    for nIndex=1:length(normalNodes);
        %STANDARD NODES<--------------------------------------------------------------------------------------------------------------------------------------------------------------------
        %most function calls will end up here
        n=normalNodes(nIndex);
        
        %CALCULATE THE SENDING FLOW<--------------------------------------------------------------------------------------------------------------------------------------------------------
        %this is the maximum number of vehicles comming from the
        %incoming links that want to travel over a node within this
        %time interval
%         incomingLinks2 = unique(fromL(n_ind(n):n_ind(n+1)-1));
        incomingLinks = find(toNodes==n);
        nbIn = length(incomingLinks);
        SF = zeros(nbIn,1);
        for l_index=1:nbIn
            l=incomingLinks(l_index);
            SF_t = capacities(l)*dt;
            time = max(eps,timeSlices(t)-lengths(l)/freeSpeeds(l));
            t1=ceil(time/dt);
            val = cvn_up(l,t1)+(time/dt-t1+1)*(cvn_up(l,t1+1)-cvn_up(l,t1));
            SF(l_index) = max(0,min(SF_t,val-cvn_down(l,t-1)));
        end
        
        %CALCULATE RECEIVING FLOW<-----------------------------------------------------------------------------------------------------------------------------------------------------------
        %this is the maximum number of vehicles that can flow into the
        %outgoing links within this time interval
%         outgoingLinks2 = unique(toL(n_ind(n):n_ind(n+1)-1));
        outgoingLinks = find(fromNodes==n);
        nbOut = length(outgoingLinks);
        RF = zeros(nbOut,1);
        for l_index=1:nbOut
            l=outgoingLinks(l_index);
            RF_t = capacities(l)*dt;
            time = max(eps,timeSlices(t)-lengths(l)/wSpeeds(l));
            t1=ceil(time/dt);
            val = cvn_down(l,t1)+(time/dt-t1+1)*(cvn_down(l,t1+1)-cvn_down(l,t1))+kJams(l)*lengths(l);
            RF(l_index) = max(0,min(RF_t,val-cvn_up(l,t-1)));
        end
        
        %reshape the structure of TF
        tf=reshape(TF(n_ind(n):n_ind(n+1)-1,t-1),nbIn,nbOut);
        
        %compute transfer flows with the NODE MODEL
        TransferFlow = NodeModel(nbIn,nbOut,SF,tf,RF,capacities(incomingLinks)*dt);
        
        %update CVN values
        cvn_down(incomingLinks,t)=cvn_down(incomingLinks,t-1)+sum(TransferFlow,2);
        cvn_up(outgoingLinks,t)=cvn_up(outgoingLinks,t-1)+sum(TransferFlow,1)';      
    end
    
    %DESTINATION NODES<----------------------------------------------------------------------------------------------------------------------------
    %this nested function goes over all destination nodes
    [cvn,l_list] = loadDestinationNodes(t,destinations,toNodes,cvn_up,cvn_down,lengths,freeSpeeds,capacities,timeSlices,dt);
    cvn_down(l_list,t)=cvn;
end
end