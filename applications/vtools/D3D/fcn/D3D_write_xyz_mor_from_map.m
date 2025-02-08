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
%Write morphodynamic xyz files from map file.
%
%INPUT:
%   -fdir_sim = full path to the directory containing the mdu-file from which to extract the output. [char]
%   -fdir_write = full path to the directory where to write the output. [char]
%   -tim = time at which to extract the output. [datenum]
%
%OUTPUT:
%
%
%TO DO:
%   -Separate read and write to allow for modification.
%   -Provide output to be modified externally.
%   -Interpolate output at cell corners to prevent errors.
%   -Allow to provide directly map file rather than full simulation.
%   -Make `tag_folder_out` as optional input. 
%
%E.G.
%
% fdir_sim='C:\Users\chavarri\checkouts\riverlab\schematic\01_examples\r008\'; %simulation to extract output
% tim=datenum(2000,01,01,10,00,00);
% fdir_write='c:\Users\chavarri\Downloads\test';
% 
% D3D_write_xyz_mor_from_map(fdir_sim,fdir_write,tim)

function D3D_write_xyz_mor_from_map(fdir_sim,fdir_write,tim)

%% READ

simdef=D3D_simpath(fdir_sim);

gridInfo=EHY_getGridInfo(simdef.file.map,{'XYcor','XYcen','XYuv','edge_type'});

data_lyrfrac=EHY_getMapModelData(simdef.file.map,'varName','mesh2d_lyrfrac','t0',tim,'tend',tim);
data_thlyr=EHY_getMapModelData(simdef.file.map,'varName','mesh2d_thlyr','t0',tim,'tend',tim);

idx_cen = [1:length(gridInfo.Xcen)].'; 
Fidx = scatteredInterpolant(gridInfo.Xcen,gridInfo.Ycen,idx_cen,'nearest','nearest');
xyu_bnd_idx = find(gridInfo.edge_type>1); 

idx_bnd = Fidx(gridInfo.Xu(xyu_bnd_idx),gridInfo.Yu(xyu_bnd_idx));

idx = [idx_cen; idx_bnd]; 
%rename
%frac_cen=permute(squeeze(data_lyrfrac.val),[3,2,1]);
frac_cen= squeeze(data_lyrfrac.val);
thk_cen=squeeze(data_thlyr.val);

xy_cen_bnd =[gridInfo.Xcen,gridInfo.Ycen;gridInfo.Xu(xyu_bnd_idx),gridInfo.Yu(xyu_bnd_idx)];
frac_cen_bnd = frac_cen(idx,:,:);
thk_cen_bnd = thk_cen(idx,:);

%% WRITE

tag_folder_out='gsd';

cord_write=xy_cen_bnd;
frac_write=frac_cen_bnd;
thk_write=thk_cen_bnd;

simdef.mor.frac=frac_write; 
simdef.mor.frac_xy=cord_write;
simdef.mor.thk=thk_write;
simdef.mor.folder_out=tag_folder_out;

simdef.D3D.dire_sim=fdir_write;
simdef.D3D.structure=2;

mkdir_check(fdir_write);
mkdir(fullfile(fdir_write,simdef.mor.folder_out))

D3D_morini(simdef)
D3D_morini_files(simdef)

messageOut(NaN,'done writing files')

