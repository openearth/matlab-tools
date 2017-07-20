      function [bndval] = detcon(fid_adm,bnd,nfs_inf,add_inf,filename)

%***********************************************************************
% delft hydraulics                         marine and coastal management
%
% subroutine         : detcon
% version            : v1.0
% date               : May 1999
% programmer         : Theo van der Kaaij
%
% function           : Determines transport boundary conditions
%                      (time-series)
% limitations        :
% subroutines called : getwgh, check, getwcr
%***********************************************************************
h = waitbar(0,'Generating transport boundary conditions','Color',[0.831 0.816 0.784]);


no_pnt = length(bnd.DATA);
notims = nfs_inf.notims;
kmax   = nfs_inf.kmax;
lstci  = nfs_inf.lstci;
mnstat = nfs_inf.mnstat;

for itim = 1: notims
    bndval(itim).value(1:no_pnt,1:kmax,1:lstci) = 0.;
end

%
%-----cycle over all boundary support points
%
for i_pnt = 1: no_pnt
    
    waitbar(i_pnt/no_pnt);
    
    %
    %-----------first get nesting stations, weights and orientation
    %           of support point
    %
  
    mnbcsp = bnd.Name{i_pnt};
    [mnnes,weight]               = nesthd_getwgh2 (fid_adm,mnbcsp,'z');

    if isempty(mnnes)
        error = true;
        close(h);
        simona2mdf_message({'Inconsistancy between boundary definition and' 'administration file'},'Window','Nesthd2 Error','Close',true,'n_sec',10);
        return
    end

    % !!!! Temporarely, for testing porposes only, remove all spavce from nfs_inf.names && mnnes
    mnnes         = simona2mdu_replacechar(mnnes        ,' ','');
    nfs_inf.names = simona2mdu_replacechar(nfs_inf.names,' ','');

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
    % Determine time series of the boundary conditions
    %
    
    for iwght = 1: 4
        if ines(iwght) ~=0
            for l = 1:lstci
                
                %
                % If bc for this constituent are requested
                %
                
                if add_inf.genconc(l)
                    
                    %
                    % Get the time series
                    %
                    
                    conc = nesthd_getdata_tran(filename,ines(iwght),nfs_inf,l);
                    
                    %
                    % Determine weighed value
                    %
                    
                    for itim = 1: notims
                        for k = 1: kmax
                            bndval(itim).value(i_pnt,k,l) = bndval(itim).value(i_pnt,k,l) +             ...
                                conc(itim,k)*weight(iwght);
                        end
                    end
                end
            end
        end
    end
    
    %
    % Adjust boundary conditions
    %
    
    for l = 1: lstci
        if add_inf.genconc(l)
            for itim = 1 : notims
                bndval(itim).value(i_pnt,:,l) =  bndval(itim).value(i_pnt,:,l) + add_inf.add(l);
                bndval(itim).value(i_pnt,:,l) =  min(bndval(itim).value(i_pnt,:,l),add_inf.max(l));
                bndval(itim).value(i_pnt,:,l) =  max(bndval(itim).value(i_pnt,:,l),add_inf.min(l));
            end
        end
    end
end

close(h);
