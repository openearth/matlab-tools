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
%

function [m,idx]=cell2mat_clean(c)

idx=[];
for k1=1:size(c,1)
    for k2=1:size(c,2)
        if ~isnumeric(c{k1,k2})
            idx=cat(1,idx,[k1,k2]);
            c{k1,k2}=NaN;
        end
    end
end

m=cell2mat(c);


