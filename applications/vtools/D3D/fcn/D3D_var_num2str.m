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

function var_str=D3D_var_num2str(var_num)

if ischar(var_num)
    var_str=var_num;
else
    var_str=fcn_num2str(var_num);
end

end %function

%%
%% FUNCTIONS
%%

function var_str=fcn_num2str(var_num)

switch var_num
    case -4
        var_str='d90';
    case -3
        var_str='d50';
    case -2
        var_str='d10';
    case -1
        var_str='dm';
    case 1
        var_str='mesh2d_mor_bl';
    case 2 
        var_str='mesh2d_waterdepth';
    case 10 
        var_str='mesh2d_ucmag';
    case 11 
        var_str='mesh2d_umod';
    case 12 
        var_str='mesh2d_s1';
    case 14
        var_str='La';
    case 19
        var_str='mesh2d_sbc'; 
    case 23
        var_str='mesh2d_stot';   
    case 26
        var_str='mesh2d_dg';
    case 27 
        var_str='Ltot';
    case 33
        var_str='mesh2d_czs';
    case 44
        var_str='sbtot';
otherwise
    error('add')
end %var_num

end %function

