%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18070 $
%$Date: 2022-05-20 18:33:29 +0200 (Fri, 20 May 2022) $
%$Author: chavarri $
%$Id: D3D_var_num2str.m 18070 2022-05-20 16:33:29Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_var_num2str.m $
%
%

function data=gdm_read_data_map_ls_simdef(fpath_map,simdef,varname,sim_idx_loc,varargin)
            
if simdef.D3D.structure==4
    %this may not be strong enough. It will fail if the run is in path with <\0\> in the name. 
    fpath_map_loc=strrep(fpath_map,[filesep,'0',filesep],[filesep,num2str(sim_idx_loc),filesep]); 
else
    fpath_map_loc=fpath_map;
end

switch varname
    case {'d10','d50','d90','dm'}
        fpath_sed=simdef.file.sed;
        if simdef.D3D.structure==4
            fpath_sed=strrep(fpath_sed,[filesep,'0',filesep],filesep); %the path is relative to the mdu in the <source> directory
        end
        dchar=D3D_read_sed(fpath_sed);
        varargin={varargin{:},'dchar',dchar};
end

data=gdm_read_data_map_ls(fpath_map_loc,varname,varargin{:});

end %function