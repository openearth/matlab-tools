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
%Get information from `data` at a certain layer. It can be for both 2DV
%and 2DH. If `layer` is inf, it takes the first non-NaN layer.

function data=gdm_get_info_layer(data,layer)

is2dv=false;
if isfield(data,'gridInfo')
    is2dv=true;
    idx_faces=2;
    idx_layer=3;
else
    idx_faces=D3D_search_index_faces(data);
    idx_layer=D3D_search_index_layer(data);
end

if ~isempty(layer)
    if isinf(layer)
        np=size(data.val,idx_faces);
        val=NaN(1,np);
        if is2dv
            Ycor=NaN(1,np);
        end
        for kp=1:np
            data_loc=submatrix(data.val,idx_faces,kp);
            layer_loc=find(~isnan(data_loc),1,'first');
            val(1,kp)=data_loc(layer_loc);
            if is2dv
                Ycor(1,kp)=data.gridInfo.Ycor(1,kp,layer_loc);
            end
        end
        data.val=val;
        if is2dv
            data.gridInfo.Ycor=Ycor;
        end
    else
        data.val=submatrix(data.val,idx_layer,layer);
    end
end

end %function