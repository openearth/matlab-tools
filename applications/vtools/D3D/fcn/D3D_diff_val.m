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

function [val_diff,val_int,val_ref]=D3D_diff_val(val,val_ref,gridInfo,gridInfo_ref)

if isstruct(gridInfo)
    if size(val)==size(val_ref)
        val_int=val_int_same_size(val,gridInfo_ref.Xcen',gridInfo.Xcen');
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
        %consider using:
        % val_int=val_int_same_size(val,gridInfo_ref,gridInfo);
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

%%
%% FUNCTIONS
%%

function val_int=val_int_same_size(val,x_ref,x)

if isvector(val) %fm
    %There is a problem here. If the coordinates are exactly the same as in
    %idealized case, then only the first ones are taken. This needs to be
    %rethough. Maybe with a flag? Check uniqueness? Done inside
    %`reorder_matrix`
    [~,idx]=reorder_matrix(x_ref,x);
    val_int=val(idx);
else %d3d4
    %we assume it is the same.
    val_int=val;
end


end