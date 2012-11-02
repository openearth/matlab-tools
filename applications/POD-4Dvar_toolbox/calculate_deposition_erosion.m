function [erosion,deposition,cum_erosion_deposition] = calculate_deposition_erosion(thedps,gridcell_area,line1,line2,line3)
% EStimates the deposition and erosion. deposition is considered to be any
% positive increment in the bathymetry whereas erosion is consider to be
% any negative change in the bathymetry. 
%
% [erosion,deposition] = calculate_deposition_erosion(thedps)
% THEDPS is a cell array that stores bathymtries indexed in time. 

    
    if iscell(thedps)
        changes = cellfun(@minus,thedps(2:end),thedps(1:end-1),'Un',0);
        for itime=1:1:length(changes)
            erosion(itime)   = sum(changes{itime}(changes{itime}<0));
            deposition(itime) = sum(changes{itime}(changes{itime}>0));
        end
    else
        changes = thedps(:,2:end) - thedps(:,1:end-1);
        
        for itime=1:1:size(changes,2)
            erosion(itime)   = sum(changes(changes(:,itime)<0,itime));
            deposition(itime) = sum(changes(changes(:,itime)>0,itime));
        end
    end
%     
%     figure
%     plot(  [1:length(erosion)]/3/24 ,abs(erosion),'r--', ...
%            [1:length(deposition)]/3/24 ,deposition,'b--');
%        plot(  [1:length(erosion)-6]/24 ,abs(erosion(7:end)),'g--', ...
%            [1:length(deposition)-6]/24 ,deposition(7:end),'g--');
%     datetick('x','dd HH:MM','keeplimits','keepticks')
     

     
    if iscell(thedps)
        
    else
                        % Future                 % Today
        cum_changes = (thedps(:,2:end) - repmat(thedps(:,1),1,size(thedps,2)-1)).*gridcell_area;
        
        for itime=1:1:size(cum_changes,2)
            cum_erosion(itime)    = sum(cum_changes(cum_changes(:,itime)<0,itime)); % If tomorrow my column of sediment is less than today => erosion
            cum_deposition(itime) = sum(cum_changes(cum_changes(:,itime)>0,itime)); % If tomorrow my column of sediment is greater than today => deposition
            
            cum_erosion_deposition(itime) = sum(cum_changes(:,itime));              % Effective Change
        end
    end
    
%     plot(  [1:length(cum_erosion)]/3/24 ,abs(cum_erosion),line1, ...
%            [1:length(cum_deposition)]/3/24 ,cum_deposition,line2, ...
%            [1:length(cum_deposition)]/3/24 ,cum_erosion_deposition,line3, ...
%            'MarkerSize',3);
%     ylabel('Cumulative change [m^3]')
%     xlabel('Time [dd HH:MM]')
%     datetick('x','dd.HH:MM','keeplimits','keepticks')
%     set(gca,'fontsize',6);
    
    plot([1:length(cum_erosion_deposition)]/3/24 ,cum_erosion_deposition,line3, 'MarkerSize',3);
    ylabel('Volumetric change [ m^3 ] (with respecto to 00 00:00)')
    xlabel('Time [dd HH:MM]')
    datetick('x','dd.HH:MM','keeplimits','keepticks')
    set(gca,'fontsize',8);
end