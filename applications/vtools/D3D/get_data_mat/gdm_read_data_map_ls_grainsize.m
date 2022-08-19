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

function data=gdm_read_data_map_ls_grainsize(fpath_map,simdef,varargin)
        
fpath_sed=simdef.file.sed;
if simdef.D3D.structure==4
    fpath_sed=strrep(fpath_sed,[filesep,'0',filesep],filesep); %the path is relative to the mdu in the <source> directory
end
dchar=D3D_read_sed(fpath_sed);
varargin={varargin{:},'dchar',dchar};

data=gdm_read_data_map_ls(fpath_map,'mesh2d_lyrfrac',varargin{:});

Fa=data.val;
switch varname
    case 'd10'
        val=grain_size_dX_mat(Fa,dchar,10);
    case 'd50'
        val=grain_size_dX_mat(Fa,dchar,50);
    case 'd90'
        val=grain_size_dX_mat(Fa,dchar,90);
    case 'dm'
        val=sum(Fa.*permute(dchar,[1,3,4,2]),4); %arithmetic mean grain size
end
data.val=val;

end %function