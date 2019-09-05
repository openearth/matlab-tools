      function [bndval] = detcon(fid_adm,bnd,nfs_inf,add_inf,fileInp)

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

if isfield(add_inf,'display')==0
  add_inf.display=1;
end
      
if add_inf.display==1
h = waitbar(0,'Generating transport boundary conditions','Color',[0.831 0.816 0.784]);
end

no_pnt    = length(bnd.DATA);
notims    = nfs_inf.notims;
t0        = nfs_inf.times(1); 
tend      = nfs_inf.times(notims);
kmax      = nfs_inf.kmax;
lstci     = nfs_inf.lstci;
modelType = EHY_getModelType(fileInp);

for itim = 1: notims
    bndval(itim).value(1:no_pnt,1:kmax,1:lstci) = 0.;
end

%% Determine time series of the boundary conditions
for l = 1:lstci
    
    %% If bc for this constituent are requested
    if add_inf.genconc(l)
        
        %% Cycle over all boundary support points
        for i_pnt = 1: no_pnt
            
            if add_inf.display==1
                waitbar(i_pnt/no_pnt);
            else
                fprintf('done %5.1f %% \n',i_pnt/no_pnt*100)
            end
            
            %% First get nesting stations, weights and orientation of support points
            mnbcsp         = bnd.Name{i_pnt};
            [mnnes,weight] = nesthd_getwgh2 (fid_adm,mnbcsp,'z');
            
            if isempty(mnnes)
                error = true;
                if add_inf.display==1
                close(h);
                end
                simona2mdf_message({'Inconsistancy between boundary definition and' 'administration file'},'Window','Nesthd2 Error','Close',true,'n_sec',10);
                return
            end
            
            %% Temporary for testing with old hong kong model
            if strcmpi(modelType,'d3d')
                for i_stat = 1: length(mnnes)
                    i_start = strfind(mnnes{i_stat},'(');
                    i_com   = strfind(mnnes{i_stat},',');
                    mnnes{i_stat} = [mnnes{i_stat}(1:i_start(2)) mnnes{i_stat}(i_start(2) + 2:i_com(2))  mnnes{i_stat}(i_com(2) + 2:end)];
                end
            end
            
            %% Retrieve the data
            data      = EHY_getmodeldata(fileInp,mnnes,modelType,'varName',lower(nfs_inf.namcon{l}),'t0',t0,'tend',tend);
            
            %%  Fill conc array with concentrations for the requested stations
            conc              = data.val;
            conc(isnan(conc)) = 0.;
            
            %% Exclude permanently dry points
            for i_stat = 1: 4
                exist_stat(i_stat) = true;
                index = find(conc(:,i_stat,1) == conc(1,i_stat,1));
                if length(index) == notims
                    exist_stat(i_stat) = false;
                    weight    (i_stat) = 0.;
                end
            end
            
            %% Normalise weights
            wghttot = sum(exist_stat.*weight);
            weight  = weight/wghttot;
            
            % In case of Zmodel, replace nodata values (-999) with above or below layer
            if kmax>1 && strcmp(add_inf.profile,'3d-profile')==1
                for itim = 1: notims
                    for kk=kmax-1:-1:1
                        if conc(itim,:,kk)==-999
                            conc(itim,:,kk)=conc(itim,:,kk+1);
                        end
                    end
                    for kk=2:kmax
                        if conc(itim,:,kk)==-999
                            conc(itim,:,kk)=conc(itim,:,kk-1);
                        end
                    end
                end
            end
            
            %% Determine weighed value
            for iwght = 1: 4
                if exist_stat(iwght)
                    for itim = 1: notims
                        for k = 1: kmax
                            bndval(itim).value(i_pnt,k,l) = bndval(itim).value(i_pnt,k,l) +  ...
                                conc(itim,iwght,k)*weight(iwght);
                        end
                    end
                end
            end
        end
    end
end
    
%% Adjust boundary conditions
for l = 1: lstci
    if add_inf.genconc(l)
        for i_pnt = 1: no_pnt
            for itim = 1 : notims
                bndval(itim).value(i_pnt,:,l) =  bndval(itim).value(i_pnt,:,l) + add_inf.add(l);
                bndval(itim).value(i_pnt,:,l) =  min(bndval(itim).value(i_pnt,:,l),add_inf.max(l));
                bndval(itim).value(i_pnt,:,l) =  max(bndval(itim).value(i_pnt,:,l),add_inf.min(l));
            end
        end
    end
end

if add_inf.display==1
close(h);
end
