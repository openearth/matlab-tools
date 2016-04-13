function wricon(filename,bnd,nfs_inf,bndval,add_inf)

% wricon : Write transport boundary conditions to a bcc (Delft3D) or timser (SIMONA) file

filetype = nesthd_det_filetype(filename);

switch filetype
   case 'Delft3D'
      nesthd_wricon_bcc    (filename,bnd,nfs_inf,bndval,add_inf);
   case 'SIMONA'
      nesthd_wricon_timeser(filename,bnd,nfs_inf,bndval,add_inf);
end
