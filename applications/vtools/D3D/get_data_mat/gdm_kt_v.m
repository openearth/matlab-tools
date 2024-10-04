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

function kt_v=gdm_kt_v(flg,nt)

%% PARSE

flg=isfield_default(flg,'order_anl',1);
flg=isfield_default(flg,'order_anl_param',1);

%% CALC

switch flg.order_anl
    case 1
        kt_v=1:1:nt;
    case 2
        rng('shuffle')
        kt_v=randperm(nt);
    case 3
        rng(flg.order_anl_param)
        kt_v=randperm(nt);
    otherwise
        error('option does not exist')
end

end %function
