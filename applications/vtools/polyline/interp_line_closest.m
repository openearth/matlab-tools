%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%

function [y,idx_1,idx_2]=interp_line_closest(xv_all,yv_all,x,x_thres)

idx_1=NaN;
idx_2=find(xv_all>x,1,'first');
% xv_all(idx_2)-x
if isempty(idx_2)
    idx_2=find(xv_all==x,1,'first');
    if isempty(idx_2)
        y=NaN;
    else
        idx_1=idx_2;
        y=yv_all(idx_2);
    end
else
%     idx_1=find(xv_all<x,1,'last'); 
    idx_1=idx_2-1;
%     xv_all(idx_1)
    if idx_1==0
        y=NaN;
    else
        
        if x+x_thres>xv_all(idx_2) && x-x_thres<xv_all(idx_1) %good
    %     xv=xv_all([idx_1,idx_2]);
    %     yv=yv_all([idx_1,idx_2]);
            y=interp_line(xv_all([idx_1,idx_2]),yv_all([idx_1,idx_2]),x);
        else
            y=NaN;
        end
    end
end

end