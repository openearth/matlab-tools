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

function data=gdm_read_data_map_ls_grainsize(fdir_mat,fpath_map,varname,simdef,varargin)
        
fpath_sed=simdef.file.sed;
if simdef.D3D.structure==4
    %the path is relative to the mdu in the <source> directory
%     fpath_sed=strrep(fpath_sed,[filesep,'0',filesep],filesep); 
    %in the new SMT, the path is correct. Maybe here we should check whether is it old or new SMT, or do try catch
end
switch simdef.D3D.structure
    case {1,5}
        varname_lyrfrac='LYRFRAC';
    case {2,4}
        varname_lyrfrac='mesh2d_lyrfrac';
end
dchar=D3D_read_sed(fpath_sed);
% varargin={varargin{:},'dchar',dchar}; %why was I passing it?

data=gdm_read_data_map_ls(fdir_mat,fpath_map,varname_lyrfrac,varargin{:});

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