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

function isCross=adcp_isCrossSection(s,varargin)

flg.limit_cs=Inf;
flg=setproperty(flg,varargin);

isCross=1;
if s(end)>flg.limit_cs
    isCross=0;
end

end