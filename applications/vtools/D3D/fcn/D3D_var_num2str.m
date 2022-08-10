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
%INPUT
%   -var_id = identifies what variable to read [char] or [double]
%
%OUTPUT
%   -var_str_read = save name of the variable to read [char]
%   -var_str_save = save name of the processed variable [char]

function [var_str_read,var_id_out,var_str_save]=D3D_var_num2str(var_id,varargin)

%%

parin=inputParser;

addOptional(parin,'is1d',false);
addOptional(parin,'ismor',false);

parse(parin,varargin{:});

is1d=parin.Results.is1d;
ismor=parin.Results.ismor;

%%

var_id_out=var_id;
var_str_read=var_id;
var_str_save=var_id;

if ischar(var_id)
    switch var_id
        case 'detab_ds'
            var_str_read='mesh2d_mor_bl';
            var_str_save=var_id;
            var_id_out=var_str_read;
        case 'bl'
            if is1d
                if ismor
                    var_id_out='mesh1d_mor_bl';
                else
                    var_id_out='mesh1d_flowelem_bl';
                end
            end
        case 'h'
            if is1d
                var_id_out='mesh1d_waterdepth';
            end
        case 'umag'
            if is1d
                var_id_out='mesh1d_umod';
            else
                var_id_out='mesh2d_ucmag';
            end
        otherwise

    end
else
    var_str_read=fcn_num2str(var_id_out);
    var_str_save=var_str_read;
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
    case 3
        var_str='mesh2d_dm';
    case 8
        var_str='Fak';
    case 10 
        var_str='mesh2d_ucmag';
    case 11 
        var_str='mesh2d_umod';
    case 12 
        var_str='mesh2d_s1';
    case 14
        var_str='La';
    case 15
        var_str='mesh2d_taus';
    case 19
        var_str='mesh2d_sbc'; 
    case 23
        var_str='mesh2d_stot';   
    case 26
        var_str='mesh2d_dg';
    case 27 
        var_str='Ltot';
    case 32
        var_str='mesh2d_czs';
    case 44
        var_str='sbtot';
    case 47
        var_str='ba_mor';
    case 48
        var_str='stot';
    case 49
        var_str='dg_La';
otherwise
    error('add')
end %var_num

end %function

