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
%Generate the variable name for saving and reading mat-file. 
%
%In most cases, the save and read name is the same. The exception is when
%there is some postprocessing. E.g., `detab_ds` (streamwise slope). The 
%variable that needs to be read is the bed level, and this will first need
%to be saved as bed level. However, when reading it for plotting, we want
%to load `deta_ds`.
%
%INPUT
%   -varname_input = identifies what variable to read [char] or [double]
%
%OUTPUT
%   -varname_save_mat = name of the variable for saving the mat-file associated to variables varname_input [char]
%   -varname_read_variable = name of the variable for calling the function that will read varname_input [char]
%   -varname_load_mat = name of the variable for loading the mat-file associated to variables varname_input [char]

function [varname_save_mat,varname_read_variable,varname_load_mat]=D3D_var_num2str(varname_input,varargin)

%%

parin=inputParser;

addOptional(parin,'is1d',false);
addOptional(parin,'is3d',false);
addOptional(parin,'ismor',false);
addOptional(parin,'structure',2);
addOptional(parin,'res_type','map');

parse(parin,varargin{:});

is1d=parin.Results.is1d;
is3d=parin.Results.is3d;
ismor=parin.Results.ismor;
structure=parin.Results.structure;
res_type=parin.Results.res_type;

%%

varname_read_variable=varname_input;
varname_save_mat=varname_input;
varname_load_mat=varname_input;

if ischar(varname_input)
    switch varname_input
        case 'detab_ds'
            varname_save_mat='mesh2d_mor_bl';
            varname_load_mat=varname_input;
            varname_read_variable=varname_save_mat;
        case 'bl'
            if is1d
                if ismor
                    varname_read_variable='mesh1d_mor_bl';
                else
                    varname_read_variable='mesh1d_flowelem_bl';
                end
            else
                switch structure
                    case {1,5}
                        switch res_type
                            case 'map'
                                if ismor
                                    varname_read_variable='DPS';
                                else
                                    varname_read_variable='DP0';
                                end
                            case 'his'
                                if ismor
                                    varname_read_variable='ZDPS';
                                else
                                    varname_read_variable='DPS';
                                end
                        end
                    case {2,4}
                        if ismor
                            varname_read_variable='mesh2d_mor_bl';
                        end
                    otherwise
                        error('ups')
                end
            end
            varname_save_mat='bl';
            varname_load_mat=varname_save_mat;
        case {'h','wd','waterdepth'}
            if is1d==1
                varname_read_variable='mesh1d_waterdepth';
            else
                switch structure
                    case {1,5}
%                         switch res_type
%                             case 'map'
%                                 if ismor
                                    varname_read_variable='waterdepth'; %read by EHY
%                                 else
%                                     var_id_out='DP0';
%                                 end
%                             case 'his'
%                                 if ismor
%                                     var_id_out='ZDPS';
%                                 else
%                                     var_id_out='DPS';
%                                 end
%                         end
                    case {2,4}
                        varname_read_variable='mesh2d_waterdepth';
%                         if ismor
%                             var_id_out='mesh2d_mor_bl';
%                         end
                    case 3
                        varname_read_variable='water_depth';
                    otherwise
                        error('ups')
                end                
            end
            varname_save_mat='h';
            varname_load_mat=varname_save_mat;
        case {'umag','mesh2d_ucmag','mesh2d_ucmaga','mesh1d_ucmag'} %depth-averaged for 1D, 2D, and 3D
            %in 3D, `ucmag` is per layer and `ucmaga` is depth averaged.
            %There is a special function for reading depth-averaged velocity. Hence, here
            %we only need to pass that it is depth-averaged and the cases (1D, 2D, 3D) are
            %dealt in that function. 
            varname_save_mat='umag';
            varname_load_mat=varname_save_mat;
        case 'umag_layer' %depth_averaged for 1D and 2D, but per layer in 3D
            %in 3D, `ucmag` is per layer and `ucmaga` is depth averaged.
            if is1d
                varname_read_variable='mesh1d_ucmag';
            else
                varname_read_variable='mesh2d_ucmag';
            end
            varname_save_mat='umag_layer'; %I think we can use the same name, because we will always add a layer to the input. Although it can be dangerous.
            varname_load_mat=varname_save_mat;
        case 'wl'
            switch res_type
                case 'map'
                    switch structure
                        case {1,2,4,5}
                            if is1d
                                varname_read_variable='mesh1d_s1';
                            end
                    end
                case 'his'
                    %use `wl`
            end
            varname_save_mat='wl';
            varname_load_mat=varname_save_mat;
        case {'mesh2d_umod','mesh1d_umod','umod'}
            if is1d
                varname_read_variable='mesh1d_umod';
            else
                varname_read_variable='mesh2d_umod';
            end
            varname_save_mat='umod';
            varname_load_mat=varname_save_mat;
        case {'mesh2d_dg','mesh1d_dg','dg'}
            if is1d
                varname_read_variable='mesh1d_dg';
            else
                switch structure
                    case {1,5}
                        varname_read_variable='DG';
                    case {2,4}
                        varname_read_variable='mesh2d_dg';
                end
            end
            varname_save_mat='dg';
            varname_load_mat=varname_save_mat;
        case {'mesh2d_czs','mesh1d_czs','czs'}
            if is1d
                varname_read_variable='mesh1d_czs';
            else
                varname_read_variable='mesh2d_czs';
            end
            varname_save_mat='czs';
            varname_load_mat=varname_save_mat;
        case {'mesh2d_thlyr','mesh1d_thlyr','thlyr','La'}
            if is1d
                varname_read_variable='mesh1d_thlyr';
            else
                switch structure
                    case {1,5}
                        varname_read_variable='thlyr';
                    case {2,4}
                        varname_read_variable='mesh2d_thlyr';
                end
            end
            varname_save_mat='thlyr';
            varname_load_mat=varname_save_mat;
        case {'Fak','lyrfrac','mesh2d_lyrfrac','mesh1d_lyrfrac'}
            if is1d
                varname_read_variable='mesh1d_lyrfrac';
            else
                switch structure
                    case {1,5}
                        varname_read_variable='LYRFRAC';
                    case {2,4}
                        varname_read_variable='mesh2d_lyrfrac';
                end
            end
            varname_save_mat='lyrfrac';
            varname_load_mat=varname_save_mat;
        case {'ba','mesh2d_flowelem_ba'}
            if is1d
                error('no idea')
                varname_read_variable='mesh1d_lyrfrac';
            else
                varname_read_variable='mesh2d_flowelem_ba';
            end
            varname_save_mat='ba';
            varname_load_mat='ba';
        case {'cross_section_discharge'}
            switch structure
                case 3
                    varname_read_variable='water_discharge';
            end
            varname_save_mat='cross_section_discharge';
            varname_load_mat='cross_section_discharge';
        case {'duneheight'}
            varname_read_variable='mesh2d_duneheight';
            varname_save_mat='duneheight';
            varname_load_mat='duneheight';
        case {'dunelength'}
            varname_read_variable='mesh2d_dunelength';
            varname_save_mat='dunelength';
            varname_load_mat='dunelength';
        case {'mesh2d_taus','taub'}
            varname_read_variable='mesh2d_taus';
            varname_save_mat='taub';
            varname_load_mat='taub';
        case {'waveheight','mesh2d_hwav'}
            varname_read_variable='mesh2d_hwav';
            varname_save_mat='waveheight';
            varname_load_mat='waveheight';
        otherwise

    end
else
    varname_save_mat=fcn_num2str(varname_read_variable);
    varname_load_mat=varname_save_mat;
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
    case {1,5}
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
    case 20
        var_str='mesh1d_umod';
    case 21
        var_str='mesh1d_q1_main';
    case 23
        var_str='mesh2d_stot';   
    case 26
        var_str='mesh2d_dg';
    case 27 
        var_str='Ltot';
    case 28
        var_str='mesh1d_bl_ave';
    case 31
        var_str='mesh1d_mor_width_u';
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

