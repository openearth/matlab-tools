%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17754 $
%$Date: 2022-02-11 06:38:51 +0100 (vr, 11 feb 2022) $
%$Author: chavarri $
%$Id: angle_polyline.m 17754 2022-02-11 05:38:51Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/polyline/angle_polyline.m $
%
%Extend the groynes of by a certain distance towards the main channel. 
%
%INPUT:
%   -fpath_fxw = full path to the file with fixed weirs [char]
%   -fpath_rkm = full path to the file with river kilometers (see format in `convert2rkm`) [char]
%   -str_mod   = string contained in the fixed weirs to modify [char]. E.g., `'groynes'`.
%   -rkm_lim   = limits of the river kilometers to modify [double(1,2)]. E.g., `[880,890]`.
%   -branch    = branch tag to be modified [char]. E.g. `'WA'`.
%   -groyne_extension = distance of the groyne to be extended [double(1,1)]. E.g., `50`.
%
%OUTPUT:
%   -A new fixed weir file at the same location as the original one with string `_mod` added to the name. 
%   -A figure in both png and fig format with the original groynes that are modified and the modified ones. 
%
%E.G.:
%
% fpath_sim=fullfile(fpaths.fdir_sim_runs,'S_1020');
% fpath_rkm=fullfile(fpaths.fdir_rkm,'rkm_rijntakken_rhein.csv');
% str_mod='groyne';
% rkm_lim=[880,890];
% branch='WA';
% groyne_extension=50;
%
% simdef=D3D_simpath(fpath_sim);
% fpath_fxw=simdef.file.fxw;
% 
% D3D_extend_groynes(fpath_fxw,fpath_rkm,str_mod,rkm_lim,branch,groyne_extension);

function D3D_extend_groynes(fpath_fxw,fpath_rkm,str_mod,rkm_lim,branch,groyne_extension)

%% read

messageOut(NaN,sprintf('Reading input: %s',fpath_fxw));
fxw=D3D_io_input('read',fpath_fxw);
fxw_mod=fxw;

%% proces

messageOut(NaN,sprintf('Processing input: %4.2f %%',0));
nfxw=numel(fxw);
bol_get=false(nfxw,1);
for kfxw=1:nfxw

    fprintf('Processing input: %4.2f %% \n',kfxw/nfxw*100);
    %only process the ones we want (e.g., `groynes`)
    if ~contains(fxw(kfxw).name,str_mod)
        continue
    end
    
    %only process the ones in the RKM and branch we want
    xy=fxw(kfxw).xy(:,1:2);
    xy_m=mean(xy,1);
    [rkm,br]=convert2rkm(fpath_rkm,xy_m,'TolMinDist',5000);
    if rkm<rkm_lim(1) || rkm>rkm_lim(2) || ~contains(lower(branch),lower(br))
        continue
    end

    %get point closest to talweg
    rkm_xy=convert2rkm(fpath_rkm,rkm,br);
    dist=hypot(xy(:,1)-rkm_xy(1),xy(:,2)-rkm_xy(2));
    idx_m=absmintol(dist,0,'tol',5000);

    %angle of the (tip of the) groyne
    if idx_m==1
        xy_tip=flipud(xy(1:2,:));
    else %idx_m should be the `end`
        xy_tip=xy(end-1:end,:);
    end

    angle_gr=angle_polyline(xy_tip(:,1),xy_tip(:,2));
    new_point=xy_tip(end,:)+groyne_extension.*[cos(angle_gr(1)),sin(angle_gr(1))];

    %save
    prop_new_point=fxw(kfxw).xy(idx_m,:);
    prop_new_point(1,1:2)=new_point;
    if idx_m==1
        fxw_mod(kfxw).xy=[prop_new_point;fxw(kfxw).xy];
    else
        fxw_mod(kfxw).xy=[fxw(kfxw).xy;prop_new_point];
    end

    bol_get(kfxw)=true;
end %kfxw

%% paths

[fdir,fname,fext]=fileparts(fpath_fxw);
fpath_mod=fullfile(fdir,sprintf('%s_mod%s',fname,fext));
fpath_fig=fullfile(fdir,sprintf('%s_mod%s',fname,'.fig'));
fpath_png=fullfile(fdir,sprintf('%s_mod%s',fname,'.png'));

%% plot

han_fig=figure('visible','off');
hold on
axis equal
for kfxw=1:nfxw
    if bol_get(kfxw)
        plot(fxw_mod(kfxw).xy(:,1),fxw_mod(kfxw).xy(:,2),'r')
        plot(fxw(kfxw).xy(:,1),fxw(kfxw).xy(:,2),'k')
    end
end
printV(han_fig,fpath_fig);
printV(han_fig,fpath_png);

%% save

messageOut(NaN,sprintf('Writing new file %s:', fpath_mod));
D3D_io_input('write',fpath_mod,fxw_mod);

%% done

messageOut(NaN,'Done!',3);

end %function