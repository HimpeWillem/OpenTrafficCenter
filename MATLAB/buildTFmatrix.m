function [tf_matrix,fromL,toL,n_ind,nFromL,nToL] = buildTFmatrix(TF,links,timeSeries,dt,totT)
    
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


%build tfmatrix
tf_matrix = num2cell(ones(size(TF,1),totT));
timeSteps = dt*[0:1:totT];
timeSeries = cell2mat(timeSeries);

for t=1:totT
    tempSlices = unique([find(timeSeries<=timeSteps(t),1,'last'),find(timeSeries<timeSteps(t+1),1,'last')]);
    if length(tempSlices)==1
        for n=1:size(TF,1)
            tf_matrix{n,t}=TF{n,tempSlices};
        end
    elseif length(tempSlices)>1
        for n=1:size(TF,1)
            if length([TF{n,tempSlices}])>2
                tf_matrix{n,t}=sum(reshape([TF{n,tempSlices}],2,[]),2)'/2;
            else
                tf_matrix{n,t}=TF{n,tempSlices(1)};
            end
        end
    end
end

nodes=unique([links.fromNode;links.toNode]);


fromL = [];
toL = [];
nToL = [];
nFromL = [];
n_ind = 1;

for n=1:length(nodes)
    to_l = find(links.fromNode==n);
    from_l = find(links.toNode==n);
    nToL = [nToL;length(to_l)];
    nFromL = [nFromL;length(from_l)];
    if isempty(from_l) from_l = 0; end
    if isempty(to_l) to_l = 0; end
    fromL = [fromL;repmat(from_l,length(to_l),1)];
    toL = [toL;sort(repmat(to_l,length(from_l),1))];
    n_ind = [n_ind;n_ind(end)+length(to_l)*length(from_l)];
end
tf = zeros(length(toL),totT);

for t=1:totT
    tf(:,t) = cell2mat(cellfun(@(x)reshape(x,[],1),tf_matrix(:,t),'UniFormOutput',0));
end
tf_matrix = tf;
end
