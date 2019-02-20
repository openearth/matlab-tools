function wricon(fileInp,bnd,nfs_inf,bndval,add_inf)

% wricon : Write transport boundary conditions to a bcc (Delft3D) or timser (SIMONA) file

modelType = EHY_getModelType(fileInp);

switch modelType
   case 'd3d'
      nesthd_wricon_bcc    (fileInp,bnd,nfs_inf,bndval,add_inf);
   case 'simona'
      nesthd_wricon_timeser(fileInp,bnd,nfs_inf,bndval,add_inf);
end
