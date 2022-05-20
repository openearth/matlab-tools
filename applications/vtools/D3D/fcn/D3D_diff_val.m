%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18035 $
%$Date: 2022-05-10 16:01:00 +0200 (Tue, 10 May 2022) $
%$Author: chavarri $
%$Id: plot_his_sal_diff_01.m 18035 2022-05-10 14:01:00Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_his_sal_diff_01.m $
%
%

function val_diff=D3D_diff_val(val,val_ref,gridInfo,gridInfo_ref)

if isstruct(gridInfo)
    if size(val)==size(val_ref)
        %may not be strong enough and you have to check the grids
        val_int=val;
    else
        idx_nn=find(~isnan(gridInfo.Xcen));
        x_in=gridInfo.Xcen(idx_nn);
        y_in=gridInfo.Ycen(idx_nn);
        val_in=val(idx_nn);
        F=scatteredInterpolant(x_in,y_in,val_in);
        val_int=F(gridInfo_ref.Xcen,gridInfo_ref.Ycen);
    %     val_atref=NaN(size(val_ref));
    %     val_atref(idx_int)=val_int;
    %     val_diff=val_atref-val_ref;
        
    end
else
    if size(val)==size(val_ref)
        %may not be strong enough and you have to check the grids
        val_int=val;
    else
        bol_nn=~isnan(gridInfo);
        x_in=gridInfo(bol_nn);
        val_in=val(bol_nn);
        F=griddedInterpolant(x_in,val_in);
        val_int=F(gridInfo_ref)';
    end
end

val_diff=val_int-val_ref;

end %function