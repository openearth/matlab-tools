% nc1 = 'p:\11210364-d-fast-mi-2024\C_Work\01_simulations\r062\sim\output\148320.min\trim-bem_map.nc'; 
% nc2 = 'p:\11210364-d-fast-mi-2024\C_Work\22_simulations_measures\r004\sim\output\135360.min\trim-bem_map.nc'; 
% 
% nc_diff = 'difference_file.nc'; 

function D3D_ugrid_diff(nc1, nc2, nc_diff); 

path_log = 'temp.txt'; 

copyfile(nc1,nc_diff); 
%%

if isnan(path_log)
    fid=NaN;
else
    fid=fopen(path_log,'w');
end

ncinf_1=ncinfo(nc1);
ncinf_2=ncinfo(nc2);

varname_1={ncinf_1.Variables.Name};
varname_2={ncinf_2.Variables.Name};

var1_sel = setdiff(varname_1, {'mesh2d', 'mesh2d_node_x' , 'mesh2d_node_y', 'mesh2d_face_nodes'}); 
var2_sel = setdiff(varname_2, {'mesh2d', 'mesh2d_node_x' , 'mesh2d_node_y', 'mesh2d_face_nodes'}); 

% varname_all=[varname_1,varname_2];
% var_u=unique(varname_all);
% % 
% nv=numel(var_u);
% 
% kv1 = find_str_in_cell(varname_1,var1_sel); 
% kv2 = find_str_in_cell(varname_2,var2_sel); 

var_1=ncread(nc1,var1_sel{1});
var_2=ncread(nc2,var2_sel{1});

var_diff=var_2 - var_1; 
ncwrite(nc_diff, var1_sel{1}, var_diff);
% 
% for kv=1:nv
% 
%     %in file 1
%     if isnan(find_str_in_cell(varname_1,var_u(1,kv)))
%         isvar_1=false;
%         messageOut(fid,'    Does not exist in file 1');
%     else
%         isvar_1=true;
%         var_1=ncread(nc1,var_u{1,kv});
%         ncinf_new_1=ncinfo(nc1,var_u{1,kv});
%     end
% 
%     %in file 2
%     if isnan(find_str_in_cell(varname_2,var_u(1,kv)))
%         isvar_2=false;
%         messageOut(fid,'    Does not exist in file 2');
%     else
%         isvar_2=true;
%         var_2=ncread(nc2,var_u{1,kv});
%     end
% 
%     %compare
%     if isvar_1 && isvar_2
%         if isinteger(var_1)
% %             var_norm=var_1-var_2;
%             messageOut(fid,'Integer');
%         elseif isnumeric(var_1)
%             if isfield(ncinf_new_1.Dimensions, 'Name'); 
%                 if any(strcmp({ncinf_new_1.Dimensions.Name},'mesh2d_nfaces'))
%                     if ~any(strcmp({ncinf_new_1.Dimensions.Name},'mesh2d_nmax_face_nodes'))
%                     if ~any(strcmp({ncinf_new_1.Dimensions.Name},'mesh2d_nnodes'))
%                         messageOut(fid,sprintf('Variable %s:',var_u{1,kv}));
%                         var_diff=var_2 - var_1; 
%                         ncwrite(nc_diff, var_u{1,kv}, var_diff);
%                     end
%                     end
%                 end
%             end
%         end                    
%     end
% 
% end %kv

end