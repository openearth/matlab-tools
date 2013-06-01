function mdf = simona2mdf_dryp(S,mdf,name_mdf)

% simona2mdf_dryp : gets dry points out of the parsed siminp tree

nesthd_dir = getenv('nesthd_path');

siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'MESH' 'DRYPOINTS' 'DAMPOINTS'});

if simona2mdf_fieldandvalue(siminp_struc,'ParsedTree.MESH.DRYPOINTS.DAMPOINTS.COORDINATES.DAMCOOR')
    
   drypoints  = siminp_struc.ParsedTree.MESH.DRYPOINTS.DAMPOINTS.COORDINATES.DAMCOOR;
   drypoints  = reshape(drypoints,2,[])';
   file       = [name_mdf '.dry'];
   delft3d_io_dry('write',file,drypoints(:,1),drypoints(:,2));
   mdf.fildry = simona2mdf_rmpath(file);
end



