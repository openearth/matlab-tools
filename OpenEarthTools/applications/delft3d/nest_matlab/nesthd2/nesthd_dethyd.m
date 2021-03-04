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
%
%***********************************************************************
      % temporary: to ensure that old shenzen history file keeps working
      shenzen = false;
      [~,name,~] = fileparts(fileInp);
      if strcmpi(name,'trih-w41_2') shenzen = true; end

      %% Initialisation
      error = false;
      
      if isfield(add_inf,'display')==0
          add_inf.display=1;
      end
      
      if add_inf.display==1
        h = waitbar(0,'Generating Hydrodynamic boundary conditions','Color',[0.831 0.816 0.784]);
      end
      
      nopnt  = length(bnd.DATA);
      notims = nfs_inf.notims;
      t0     = nfs_inf.times(1);
      tend   = nfs_inf.times(notims);
      kmax   = nfs_inf.kmax;
      names  = nfs_inf.names;

      g = 9.81;

      for itim = 1: notims
         bndval (itim).value(1:nopnt,1:2*kmax,1) = 0.;
      end

      modelType = EHY_getModelType(fileInp);

      load_wl = false;
      load_uv = false;

      %% -----cycle over all boundary support points
      for ipnt = 1: nopnt
          type = lower(bnd.DATA(ipnt).bndtype);
          if add_inf.display==1
            waitbar(ipnt/nopnt);
          else 
              fprintf('done %5.1f %% \n',ipnt/nopnt*100)
          end

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

          %% Error if no nesting stations are found
          if isempty(mnnes)
              error = true;
              if add_inf.display==1
                close(h);
              end
              simona2mdf_message({'Inconsistancy between boundary definition and' 'administration file'},'Window','Nesthd2 Error','Close',true,'n_sec',10);
              return
          end

          %% Temporary for testing with old hong kong model
          if shenzen
              for i_stat = 1: length(mnnes)
                  i_start = strfind(mnnes{i_stat},'(');
                  i_com   = strfind(mnnes{i_stat},',');
                  mnnes{i_stat} = [mnnes{i_stat}(1:i_start(2)) mnnes{i_stat}(i_start(2) + 2:i_com(2))  mnnes{i_stat}(i_com(2) + 2:end)];
              end
          end

          %% Get the needed data
          if ismember(type,{'z' 'r' 'x' 'n'})
              ipnt
              data          = EHY_getmodeldata(fileInp,mnnes,modelType,'varName','wl','t0',t0,'tend',tend);
              wl            = data.val;
              wl(isnan(wl)) = 0.;

              %% Exclude permanently dry points
              for i_stat = 1: 4
                  exist_stat(i_stat) = true;
                  index = find(wl(:,i_stat) == wl(1,i_stat));
                  if length(index) == notims
                      exist_stat(i_stat) = false;
                      weight    (i_stat) = 0.;
                  end
              end
          end
          if ismember(type,{'c' 'p' 'r' 'x'})
              data_uv   = EHY_getmodeldata(fileInp,mnnes,modelType,'varName','uv','t0',t0,'tend',tend);
              uu        = data_uv.vel_x; uu(isnan(uu)) = 0.;
              vv        = data_uv.vel_y; vv(isnan(vv)) = 0.;
              [uu,vv]   = nesthd_rotate_vector(uu,vv,pi/2. - angle);

              %% Exclude permanently dry points
              for i_stat = 1: 4
                  exist_stat(i_stat) = true;
                  index_u = find(uu(:,i_stat,1) == uu(1,i_stat,1));
                  index_v = find(vv(:,i_stat,1) == vv(1,i_stat,1));
                  if length(index_u) == notims && length(index_v) == notims
                      exist_stat(i_stat) = false;
                      weight    (i_stat) = 0.;
                  end
              end

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

          %% Normalise weights
          wghttot = sum(exist_stat.*weight);
          weight  = weight/wghttot;

          %% Generate boundary conditions
          for iwght = 1: 4
              nr_key = get_nr(nfs_inf.names,mnnes{iwght});
              if exist_stat(iwght)
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
                  x     = x     (exist_stat);
                  y     = y     (exist_stat);
                  mnnes = mnnes (exist_stat);

                  % Neumann boundaries require 3 surrounding support points
                  if length(x) >= 3

                      % Determine water level gradient
                      for itim = 1: notims
                          gradient_global              = nesthd_tri_grad      (x(1:3),y(1:3),wl(itim,1:3));
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
                  if shenzen
                      for i_stat = 1: length(mnnes)
                          i_start = strfind(mnnes{i_stat},'(');
                          i_com   = strfind(mnnes{i_stat},',');
                          mnnes{i_stat} = [mnnes{i_stat}(1:i_start(2)) mnnes{i_stat}(i_start(2) + 2:i_com(2))  mnnes{i_stat}(i_com(2) + 2:end)];
                      end
                  end

                  data_uv   = EHY_getmodeldata(fileInp,mnnes,modelType,'varName','uv','t0',t0,'tend',tend);
                  uu        = data_uv.vel_x; uu(isnan(uu)) = 0.;
                  vv        = data_uv.vel_y; vv(isnan(vv)) = 0.;
                  [uu,vv]   = nesthd_rotate_vector(uu,vv,pi/2. - angle);

                  %% Exclude permanently dry points
                  for i_stat = 1: 4
                      index_u = find(uu(:,i_stat,1) == uu(1,i_stat,1));
                      index_v = find(vv(:,i_stat,1) == vv(1,i_stat,1));
                      if length(index_u) == notims && length(index_v) == notims
                          exist_stat(i_stat) = false;
                          weight    (i_stat) = 0.;
                      end
                  end

                  %% Error if no nesting stations are found
                  if isempty(mnnes)
                      error = true;
                      if add_inf.display==1
                        close(h);
                      end
                      simona2mdf_message({'Inconsistancy between boundary definition and' 'administration file'},'Window','Nesthd2 Error','Close',true,'n_sec',10);
                      return
                  end

                  %% Normalise weights
                  wghttot = sum(exist_stat.*weight);
                  weight  = weight/wghttot;

                  for iwght = 1: 4
                      if exist_stat(iwght)
                          for itim = 1: notims
                              bndval(itim).value(ipnt,kmax+1:2*kmax,1) = bndval(itim).value(ipnt,kmax+1:2*kmax,1) + ...
                                                                         squeeze(vv(itim,iwght,:)*weight(iwght))' ;
                          end
                      end
                  end
          end
      end

      if add_inf.display==1
        close(h);
      end
