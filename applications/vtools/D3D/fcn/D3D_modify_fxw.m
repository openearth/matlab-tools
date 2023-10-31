%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18780 $
%$Date: 2023-03-09 15:28:47 +0100 (do, 09 mrt 2023) $
%$Author: chavarri $
%$Id: D3D_adapt_time.m 18780 2023-03-09 14:28:47Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_adapt_time.m $
%
%Reads a fixed-weirs file and writes new files with only
%certain fixed weirs and/or a modify geometry.

function D3D_modify_fxw(fpath_fxw)

%% read

fxw=D3D_io_input('read',fpath_fxw);
fxw_geom_TB=fxw;

%% modify 

nfxw=numel(fxw);
fxw_type=cell(nfxw,1);
for kfxw=1:nfxw
    %get types
    tok=regexp(fxw(kfxw).name,'=','split');
    fxw_type{kfxw}=tok{1,2};

    %modify geometry
    np=size(fxw(kfxw).xy,1);
    fxw_geom_TB(kfxw).xy(:,6:8)=repmat([3,4,4],np,1); %geometry of Tabellenboek: Crest lengh = 3 m, slope u/s = 1/4, slope d/s = 1/4.
end %kfxw

fxw_u=unique(fxw_type);

bol_groyne=strcmp(fxw_type,'groyne');
bol_hvl=strcmp(fxw_type,'terrainjump');

fxw_groyne=fxw(bol_groyne);
fxw_ngroyne=fxw(~bol_groyne);
fxw_ngroyne_geom_TB=fxw_geom_TB(~bol_groyne);
fxw_nhvl=fxw(~bol_hvl);

%% modify geometry


%% write

[fdir,fname,fext]=fileparts(fpath_fxw);

fpath_wr=fullfile(fdir,sprintf('%s_groynes%s',fname,fext));
D3D_io_input('write',fpath_wr,fxw_groyne);

fpath_wr=fullfile(fdir,sprintf('%s_geomTB%s',fname,fext));
D3D_io_input('write',fpath_wr,fxw_geom_TB);

fpath_wr=fullfile(fdir,sprintf('%s_no_groynes%s',fname,fext));
D3D_io_input('write',fpath_wr,fxw_ngroyne);

fpath_wr=fullfile(fdir,sprintf('%s_no_groynes_geomTB%s',fname,fext));
D3D_io_input('write',fpath_wr,fxw_ngroyne_geom_TB);

fpath_wr=fullfile(fdir,sprintf('%s_no_hvl%s',fname,fext));
D3D_io_input('write',fpath_wr,fxw_nhvl);

end