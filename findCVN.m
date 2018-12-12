%Nested function used for finding CVN values inbetween time slices
function val = findCVN(cvn,time,timeSlices,dt)
%#codegen
%coder.inline('never');
% 
% if time<=timeSlices(1)
%     val=0;
%     return;
% elseif time>=timeSlices(end)
%     val=cvn(end);
%     return;
% else
    t1=ceil(time/dt);
    t2=t1+1;
    val = cvn(t1)+(time/dt-t1+1)*(cvn(t2)-cvn(t1));
% end
end
