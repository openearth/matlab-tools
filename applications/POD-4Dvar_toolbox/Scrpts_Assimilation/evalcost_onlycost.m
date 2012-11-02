function [J,the_correlations, rmse] = evalcost_onlycost(options,elmodel, obs, bgCov, bgTerm)
%        [J,the_correlations, thefig] = evalcost_onlycost(options,elmodel, obs, bgCov, bgTerm)
% options.bgCovScaling
% options.makeplots 
% if options.makeplots then options.file_save_name


    cont = 1; 
    ntrschied = [];
    
    
    [logic,loc] = ismember(cellstr(datestr([obs.times],'yyyymmddTHHMM')),cellstr(datestr(elmodel.times,'yyyymmddTHHMM')));
    
    disp('Warning: The observed times :')
    disp(datestr([obs(logic==0).times],'HH:MM dd mmm yyyy'));
    disp('were not modeled'); 
    
    if isempty(find(logic'))
        disp('No modeled values for corresponding observation times.');
        error;
    end
    for iTime = find(logic')
        
        indRow = loc(iTime);        

        if isempty(indRow), 
            disp(['Warning: The observed time ',num2str(fix(obs(iTime).times)) ,' hr. was not modeled']); 
        else
            modelvalues = obs(iTime).operator*elmodel.vectors.dps(:,indRow);
            
            ntrschied.obsNo(cont) = iTime;
            ntrschied.vectors(:,cont)  = modelvalues - obs(iTime).data(:,3);   % You want to know the norm? ntrschied.norm(cont) = norm(ntrschied.vectors(:,cont));
            ntrschied.operator{cont}   = obs(iTime).operator;                  % If an observation is skipped, then the operators of the obs struct are no longer usefull... we would need to know which operator to use. 
            
            ntrschied.matcov{cont}     = obs(iTime).matCov;
            ntrschied.modelIndex(cont) = indRow;
                     
            the_correlations(cont) = min(min(corrcoef(modelvalues,obs(iTime).data(:,3))));
            
            cont = cont+1;
        end
    end
        
    % Background term.
    bgCov = bgCov.*options.bgCovScaling;
    J = 0.5*bgTerm'*(bgCov\bgTerm);
    
    % Background term and Sum of Squared Errors
    for iTStep = 1:1:size(ntrschied.vectors,2)
        weightsmat = ntrschied.matcov{iTStep};
        J = J + 0.5*ntrschied.vectors(:,iTStep)'*(weightsmat\ntrschied.vectors(:,iTStep));
    end
    
    
    
    
    %% MAKE PLOTS IF ASKED FOR    
    if options.makeplots
        % close all
        theobs = ntrschied.obsNo;
        numobs = length(theobs);
        h = figure('visible','off');
        posSw = get(h,'Position');  
        set(h,'PaperPositionMode','auto');       
        set(h,'Position', [209, ...
                           528 - 200*ceil(numobs/3), ...
                           1031, ...
                           500* ceil(numobs/3) ])
        
        for iobs = 1:length(theobs)
            [qx,qy] = meshgrid(unique(obs(iobs).data(:,1)), unique(obs(iobs).data(:,2)));
            %f = TriScatteredInterp(obs(theobs(iobs)).data(:,1) ,obs(theobs(iobs)).data(:,2),ntrschied.vectors(:,iobs));
            %qz = f(qx,qy);
            
            qz = [reshape(ntrschied.vectors(:,iobs),size(qx,2),size(qx,1))]';
            
            h1 = subplot(ceil(numobs/3),3,iobs);
            pcolor(qx,qy,qz);
            title(['Time: ',num2str(obs(iobs).hr),':',num2str(obs(iobs).mn,'%02.0f')],'fontweight','bold')
            rmse(iobs) = roundto(sqrt(1/numel(qz)*sum(qz(:).^2)),5);
            xlabel(['RMSE: ', num2str(rmse(iobs)), ...
           char(10),'r: '   , num2str(the_correlations(iobs))                   ],'fontweight','bold')
            if iobs == 1
                the_color_lims = clim;
                hColorbar = colorbar('westoutside');
                initpos = get(hColorbar,'Position');             
                set(hColorbar, ...
                       'Position',[initpos(1)-0.11, ...
                                   initpos(2), ...
                                   initpos(3), ...
                                   initpos(4)]);
            else
               clim(the_color_lims) 
            end
            
            shading flat;
            hold on;
            contour(qx,qy,qz,'k-');
        end
        
        print('-depsc2',options.file_save_name);
        print('-dpng',options.file_save_name);
        saveas(h,options.file_save_name,'fig')
        close(h)
    end