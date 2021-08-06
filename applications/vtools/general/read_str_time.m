%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17337 $
%$Date: 2021-06-10 13:14:13 +0200 (Thu, 10 Jun 2021) $
%$Author: chavarri $
%$Id: D3D_bct.m 17337 2021-06-10 11:14:13Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_bct.m $
%
%read string with time

function [t0_dtime,units]=read_str_time(str_time)

if iscell(str_time)
    error('input must be char')
end

tok=regexp(str_time,' ','split');
if numel(tok)>4
    t0_dtime=datetime(sprintf('%s %s',tok{1,3},tok{1,4}),'InputFormat','yyyy-MM-dd HH:mm:ss','TimeZone',tok{1,5});
else
    t0_dtime=datetime(sprintf('%s %s',tok{1,3},tok{1,4}),'InputFormat','yyyy-MM-dd HH:mm:ss','TimeZone','+00:00');
    messageOut(NaN,'There is no time zone. I assume +00:00');
end
units=tok{1,1};