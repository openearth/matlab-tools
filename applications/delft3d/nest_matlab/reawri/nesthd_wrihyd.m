function wrihyd(filename,bnd,nfs_inf,bndval,add_inf)

% wrihyd : writes hydrodynamic bc to either Delft3D-Flow format or SIMONA format

filetype = nesthd_det_filetype(filename);

switch filetype
   case 'Delft3D'
      nesthd_wrihyd_bct(filename,bnd,nfs_inf,bndval,add_inf)
   case 'SIMONA'
      nesthd_wrihyd_timeser(filename,bnd,nfs_inf,bndval,add_inf)
end
