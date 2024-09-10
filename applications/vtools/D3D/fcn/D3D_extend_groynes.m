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

function D3D_extend_groynes(fpath_fxw,fpath_rkm,str_mod,rkm_lim,branch,groyne_extension)

fxw=D3D_io_input('read',fpath_fxw);
fxw_mod=fxw;

%%
nfxw=numel(fxw);
bol_get=false(nfxw,1);
for kfxw=1:nfxw

    fprintf('%4.2f %% \n',kfxw/nfxw*100)
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


%%
figure
hold on
axis equal
for kfxw=1:nfxw
    if bol_get(kfxw)
        plot(fxw_mod(kfxw).xy(:,1),fxw_mod(kfxw).xy(:,2),'r')
        plot(fxw(kfxw).xy(:,1),fxw(kfxw).xy(:,2),'k')
    end
end

%% save

[fdir,fname,fext]=fileparts(simdef.file.fxw);
fpath_mod=fullfile(fdir,sprintf('%s_mod%s',fname,fext));
D3D_io_input('write',fpath_mod,fxw_mod);

end %function