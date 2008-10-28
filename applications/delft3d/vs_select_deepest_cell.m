function matrix2d = vs_select_deepest_cell(matrix3d, kbot)
%VS_SELECT_DEEPEST_CELL   From z-layer model select locally deepest cell
%
% matrix2d = vs_select_deepest_cell(matrix3d, kbot)
%
% where kbot is returned by VS_MESHGRID3DCORCEN for z-layer model.
%
%See also: D3D_Z, VS_MESHGRID2DCORCEN, VS_MESHGRID3DCORCEN

matrix2d = repmat(nan,size(matrix3d,1),size(matrix3d,2));

for ii=1:size(matrix3d,1)
for jj=1:size(matrix3d,2)

   k               = kbot    (ii,jj);
   
   if ~isnan(k)
   matrix2d(ii,jj) = matrix3d(ii,jj,k);
   end
   
end
end

%% EOF