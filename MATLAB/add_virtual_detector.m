function add_detector(links,nodes,link_id)

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


%% Clean a bad detector or find a virtual value

%move trace downstream
%every merge (add negative values furter upstream)
%trace diverge (add positive values further downstream)

%move trace upstream
%every merge (add positive values furter upstream)
%trace diverge (add negative values further downstream)



%difference is to big?




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

end
