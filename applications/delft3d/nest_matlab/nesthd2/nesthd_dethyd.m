      function [bndval,error] = nesthd_dethyd(fid_adm,bnd,nfs_inf,add_inf,fileInp)

      % dethyd : determines nested hydrodynamic boundary conditions (part of nesthd2)

%***********************************************************************
% delft hydraulics                         marine and coastal management
%
% subroutine         : dethyd
% version            : v1.0
% date               : May 1999
% programmer         : Theo van der Kaaij
%
% function           : Determines hydrodynamic boundary conditions
%                      (time-series)
% limitations        :
% subroutines called : getwgh, check, getwcr
%***********************************************************************
      error = false;

      h = waitbar(0,'Generating Hydrodynamic boundary conditions','Color',[0.831 0.816 0.784]);

      nopnt  = length(bnd.DATA);
      notims = nfs_inf.notims;
      kmax   = nfs_inf.kmax;
      names  = nfs_inf.names;

      g = 9.81;

      for itim = 1: notims
         bndval (itim).value(1:nopnt,1:2*kmax,1) = 0.;
      end

      modelType = EHY_getModelType(fileInp);
      
      %% -----cycle over all boundary support points
      for ipnt = 1: nopnt
          type = lower(bnd.DATA(ipnt).bndtype);
          waitbar(ipnt/nopnt);
          
          wl = [];
          uu = [];
          vv = [];
          
          %% -----------first get nesting stations, weights and orientation
          mnbcsp = bnd.Name{ipnt};
          switch type
              case 'z'
                  [mnnes,weight]               = nesthd_getwgh2 (fid_adm,mnbcsp,type);
              case {'c' 'p'}
                  [mnnes,weight,angle]         = nesthd_getwgh2 (fid_adm,mnbcsp,'c');
              case {'r' 'x'}
                  [mnnes,weight,angle,ori]     = nesthd_getwgh2 (fid_adm,mnbcsp,'r');
              case 'n'
                  [mnnes,weight,angle,ori,x,y] = nesthd_getwgh2 (fid_adm,mnbcsp,'n');
          end
          
          %% Temporary for testing with old hong kong model
          if strcmpi(modelType,'d3d')
              for i_stat = 1: length(mnnes)
                  i_start = strfind(mnnes{i_stat},'(');
                  i_com   = strfind(mnnes{i_stat},',');
                  mnnes{i_stat} = [mnnes{i_stat}(1:i_start(2)) mnnes{i_stat}(i_start(2) + 2:i_com(2))  mnnes{i_stat}(i_com(2) + 2:end)];
              end
          end
          
          if isempty(mnnes)
              error = true;
              close(h);
              simona2mdf_message({'Inconsistancy between boundary definition and' 'administration file'},'Window','Nesthd2 Error','Close',true,'n_sec',10);
              return
          end
          
          %% Normalise weights
          for iwght = 1: 4
              if ~isempty(mnnes)
                  nr_key    =  get_nr(nfs_inf.names,mnnes{iwght});
                  if isempty(nr_key)
                      weight(iwght) = 0;
                  end
              end
          end
          
          wghttot = sum(weight);
          weight = weight/wghttot;
          
          %% Get the needed data
          if ismember(type,{'z' 'r' 'x'})
              data      = EHY_getmodeldata(fileInp,mnnes,modelType,'varName','wl');
              wl        = data.val;
          end
          if ismember(type,{'c' 'p' 'r' 'x'})
              data      = EHY_getmodeldata(fileInp,mnnes,modelType,'varName','uv');
              uu        = data.vel_x;
              vv        = data.vel_y;
              [uu,vv]   = nesthd_rotate_vector(uu,vv,pi/2. - angle);
              
              % In case of Zmodel, replace nodata values (-999) with above or below layer
              if kmax>1 && strcmp(add_inf.profile,'3d-profile')==1
                  for itim = 1: notims
                      for kk=kmax-1:-1:1
                          if uu(itim,:,kk)==-999
                              uu(itim,:,kk)=uu(itim,:,kk+1);
                              vv(itim,:,kk)=vv(itim,:,kk+1);
                          end
                      end
                      for kk=2:kmax
                          if uu(itim,:,kk)==-999
                              uu(itim,:,kk)=uu(itim,:,kk-1);
                              vv(itim,:,kk)=vv(itim,:,kk-1);
                          end
                      end
                  end
              end
          end
          
          %% Generate boundary conditions
          for iwght = 1: 4
              nr_key = get_nr(nfs_inf.names,mnnes{iwght});
              if weight(iwght) ~=0
                  switch type
                      %
                      %% Water level boundaries
                      case 'z'
                          for itim = 1: notims
                              bndval(itim).value(ipnt,1,1) = bndval(itim).value(ipnt,1,1) + ...
                                                             weight(iwght)*(wl(itim,iwght) + add_inf.a0);
                          end
                          
                          %% Velocity boundaries (perpendicular component)
                      case {'c' 'p'}
                          for itim = 1: notims
                              bndval(itim).value(ipnt,1:kmax,1) = bndval(itim).value(ipnt,1:kmax,1)      + ...
                                                                  squeeze(uu(itim,iwght,:)*weight(iwght))';
                          end
                          
                          %% Rieman boundaries
                      case {'r' 'x'}
                          ori = char(ori);
                          if ori(1:2) == 'in'
                              rpos = 1.0;
                          else
                              rpos = -1.0;
                          end
                          for itim = 1: notims
                              bndval(itim).value(ipnt,1:kmax,1) = bndval(itim).value(ipnt,1:kmax,1)  + ...
                                                                 (squeeze(uu(itim,iwght,:))'         + ...
                                                                 rpos*wl(itim,iwght)*sqrt(g/nfs_inf.dps(nr_key)))*weight(iwght);
                          end
                  end
              end
          end
          
          %% Neumann boundaries (still to adjust, hardly ever used)
          switch type
              case 'n'
                  clear wl
                  x    = x   (ines ~= 0);
                  y    = y   (ines ~= 0);
                  ines = ines(ines ~= 0);
                  %
                  % Neumann boundaries require 3 surrounding support points
                  %
                  if length(ines) >= 3
                      for istat = 1: 3
                          [wl(istat,:),~,~] = nesthd_getdata_hyd(filename,ines(istat),nfs_inf,'wl');
                      end
                      for itim = 1: notims
                          gradient_global              = nesthd_tri_grad      (x(1:3),y(1:3),wl(1:3,itim));
                          [gradient_boundary,~]        = nesthd_rotate_vector (gradient_global(1),gradient_global(2),pi/2. - angle);
                          bndval(itim).value(ipnt,1,1) = gradient_boundary;
                      end
                  else
                      bndval(itim).value(ipnt,1,1) = NaN;
                  end
          end
          
          %% Determine time series for the parallel velocity component
          switch type
              case {'x' 'p'}
                  [mnnes,weight,angle]         = nesthd_getwgh2 (fid_adm,mnbcsp,'p');
                  %% Temporary for testing with old hong kong model
                  if strcmpi(modelType,'d3d')
                      for i_stat = 1: length(mnnes)
                          i_start = strfind(mnnes{i_stat},'(');
                          i_com   = strfind(mnnes{i_stat},',');
                          mnnes{i_stat} = [mnnes{i_stat}(1:i_start(2)) mnnes{i_stat}(i_start(2) + 2:i_com(2))  mnnes{i_stat}(i_com(2) + 2:end)];
                      end
                  end
                  
                  if isempty(mnnes)
                      error = true;
                      close(h);
                      simona2mdf_message({'Inconsistancy between boundary definition and' 'administration file'},'Window','Nesthd2 Error','Close',true,'n_sec',10);
                      return
                  end
                  
                  %% Normalise weights
                  for iwght = 1: 4
                      if ~isempty(mnnes)
                          nr_key    =  get_nr(nfs_inf.names,mnnes{iwght});
                          if isempty(nr_key)
                              weight(iwght) = 0;
                          end
                      end
                  end
                  
                  wghttot = sum(weight);
                  weight = weight/wghttot;
                  
                  
                  for iwght = 1: 4
                      if weight(iwght) ~=0
                          for itim = 1: notims
                              bndval(itim).value(ipnt,kmax+1:2*kmax,1) = bndval(itim).value(ipnt,kmax+1:2*kmax,1) + ...
                                  squeeze(vv(itim,iwght,:)*weight(iwght))';
                          end
                      end
                  end
          end
      end
      
      close(h);
