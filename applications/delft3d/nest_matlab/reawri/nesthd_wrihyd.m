function wrihyd(fileOut,bnd,nfs_inf,bndval,add_inf)

% wrihyd : writes hydrodynamic bc to either Delft3D-Flow format or SIMONA format
[modelType,fileType] = EHY_getModelType(fileOut);

switch modelType
   case 'd3d'
      nesthd_wrihyd_bct(fileOut,bnd,nfs_inf,bndval,add_inf)
   case 'simona'
      nesthd_wrihyd_timeser(fileOut,bnd,nfs_inf,bndval,add_inf)
   case 'dfm'
       switch fileType
           
           % Old (HK) format 
           case 'tim'      
               nesthd_wrihyd_dflowfmtim (fileOut,bnd,nfs_inf,bndval,add_inf)
           % New inifile format
           case 'bc'
               nesthd_wrihyd_dflowfmbc  (fileOut,bnd,nfs_inf,bndval,add_inf)
       end
end
