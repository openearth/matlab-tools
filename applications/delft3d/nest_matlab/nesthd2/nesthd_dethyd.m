      function [bndval,error] = dethyd(fid_adm,bnd,nfs_inf,add_inf,filename)

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
      mnstat = nfs_inf.mnstat;
      names  = nfs_inf.names;

      g = 9.81;

      for itim = 1: notims
         bndval (itim).value(1:nopnt,1:2*kmax,1) = 0.;
      end

%
%-----cycle over all boundary support points
%
for ipnt = 1: nopnt
    type = lower(bnd.DATA(ipnt).bndtype);
    %
    %--------for water level or velocity boundaries
    %

    waitbar(ipnt/nopnt);
    %
    %-----------first get nesting stations, weights and orientation
    %           of support point
    %
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

     if isempty(mnnes)
        error = true;
        close(h);
        simona2mdf_message({'Inconsistancy between boundary definition and' 'administration file'},'Window','Nesthd2 Error','Close',true,'n_sec',10);
        return
    end
    
    % !!!! Temporarely, for testing porposes only, remove all spavce from nfs_inf.names && mnnes
    mnnes         = simona2mdu_replacechar(mnnes        ,' ','');
    mnnes         = simona2mdu_replacechar(mnnes        ,'(M,N)=','');
    nfs_inf.names = simona2mdu_replacechar(nfs_inf.names,' ','');
    nfs_inf.names = simona2mdu_replacechar(nfs_inf.names,'(M,N)=','');
    
   
    %
    % Get station numbers needed; store in ines
    %
        
    for iwght = 1: 4
        ines(iwght) = 0;
        if ~isempty(mnnes)
            istat       =  find(strcmp(nfs_inf.names,mnnes{iwght}) == 1,1,'first');
            if ~isempty(istat)
                ines(iwght) = nfs_inf.list_stations(istat);
            else
                weight(iwght) = 0;
            end
        end
    end

    %
    % Normalise weights (stations not found on history file)
    %

    wghttot = sum(weight);
    weight = weight/wghttot;
    %
    %-----------Determine time series of the boundary conditions
    %
    for iwght = 1: 4
        if ines(iwght) ~=0
            switch type
                %
                %----------------------a) For water level boundaries
                %
                case 'z'
                    [wl,~,~] = nesthd_getdata_hyd(filename,ines(iwght),nfs_inf,'wl');
                    for itim = 1: notims
                        bndval(itim).value(ipnt,1,1) = bndval(itim).value(ipnt,1,1) + ...
                            weight(iwght)*(wl(itim) + add_inf.a0);
                    end
                    %
                    %----------------------b) for velocity boundaries (perpendicular component)
                    %
                case {'c' 'p'}
                    [~,uu,vv] = nesthd_getdata_hyd(filename,ines(iwght),nfs_inf,'c');
					
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
					
                    [uu,~]     = nesthd_rotate_vector(uu,vv,pi/2. - angle);
                    for itim = 1: notims
                        bndval(itim).value(ipnt,1:kmax,1) = bndval(itim).value(ipnt,1:kmax,1) +  uu(itim,:)*weight(iwght);
                    end
                    %
                    %----------------------c) for Rieman boundaries
                    %
                case {'r' 'x'}
                    [wl,uu,vv] = nesthd_getdata_hyd(filename,ines(iwght),nfs_inf,'all');
					
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
					
                    [uu,~]     = nesthd_rotate_vector(uu,vv,pi/2. - angle);
                    ori = char(ori);
                    if ori(1:2) == 'in'
                        rpos = 1.0;
                    else
                        rpos = -1.0;
                    end
                    for itim = 1: notims
                        bndval(itim).value(ipnt,1:kmax,1) = bndval(itim).value(ipnt,1:kmax,1)  +               ...
                            (uu(itim,:) +  rpos*wl(itim)*sqrt(g/nfs_inf.dps(ines(iwght))))*weight(iwght);
                    end
            end
        end
    end
    %
    %-----------d) for Neumann boundaries
    %
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
                    gradient_global    = nesthd_tri_grad      (x(1:3),y(1:3),wl(1:3,itim));
                    [gradient_boundary,~]  = nesthd_rotate_vector (gradient_global(1),gradient_global(2),pi/2. - angle);
                    bndval(itim).value(ipnt,1,1) = gradient_boundary;
                end
            else
                bndval(itim).value(ipnt,1,1) = NaN;
            end
    end

    %
    %-----------Determine time series for the parallel velocity component
    %
    switch type
        case {'x' 'p'}
            [mnnes,weight,angle]         = nesthd_getwgh2 (fid_adm,mnbcsp,'c');
            
            % !!!! Temporarely, for testing porposes only, remove all spavce from nfs_inf.names && mnnes
            mnnes         = simona2mdu_replacechar(mnnes        ,' ','');
            mnnes         = simona2mdu_replacechar(mnnes        ,'(M,N)=','');
            nfs_inf.names = simona2mdu_replacechar(nfs_inf.names,' ','');
            nfs_inf.names = simona2mdu_replacechar(nfs_inf.names,'(M,N)=','');
            
            
            %
            % Get station numbers needed; store in ines
            %
            
            for iwght = 1: 4
                ines(iwght) = 0;
                if ~isempty(mnnes)
                    istat       =  find(strcmp(nfs_inf.names,mnnes{iwght}) == 1,1,'first');
                    if ~isempty(istat)
                        ines(iwght) = nfs_inf.list_stations(istat);
                    else
                        weight(iwght) = 0;
                    end
                end
            end
            
            %
            % Normalise weights (stations not found on history file)
            %

            wghttot = sum (weight);
            weight = weight/wghttot;

            for iwght = 1: 4
                if ines(iwght) ~=0
                    [~,uu,vv] = nesthd_getdata_hyd(filename,ines(iwght),nfs_inf,'c');
					
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
					
                    [~,vv]     = nesthd_rotate_vector(uu,vv,pi/2. - angle);
%                    vv = -vv;
                    for itim = 1: notims
                        bndval(itim).value(ipnt,kmax+1:2*kmax,1) = bndval(itim).value(ipnt,kmax+1:2*kmax,1) + vv(itim,:)*weight(iwght);
                    end
                end
            end
    end
end

close(h);
