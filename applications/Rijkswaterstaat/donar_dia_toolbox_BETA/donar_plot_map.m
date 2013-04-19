function []= donar_plot_map(donarMat,variable,thefontsize,thelineS)
%donar_plot_map

    if ischar(donarMat)
        disp(['Loading: ',donarMat]);
        donarMat = importdata(donarMat);
    elseif ~isstruct(donarMat)
        error('Unrecognized input type for donarMat')
    end
    
    thefields = fields(donarMat);
    if isempty(thefields(strcmpi(thefields,variable)))
        disp('Variable not found in file.')
        return;
    end
    
    if nargin < 4,         thelineS = colormap;    end
    donarMat.(variable).data(:,4) = donarMat.(variable).data(:,4) + donarMat.(variable).referenceDate;
    
    %%%%%%%%%%%%%%%%%%%%
    % Observations map %
    %%%%%%%%%%%%%%%%%%%%
    plot_map('lonlat','color',[0.5,0.5,0.5]);
    set(gcf,'position',[745   569   375   379])
    set(gcf,'PaperPositionMode','auto')
    hold on
    
    plot_xyColor(donarMat.(variable).data(:,1),donarMat.(variable).data(:,2),donarMat.(variable).data(:,5),20,thelineS);
    h2 = colorbar('south','fontsize',thefontsize);
    
    initpos = get(h2,'Position');
    set(gca,'FontSize',thefontsize);
    set(h2, 'Position',[initpos(1)+0.05, ...
                           initpos(2) - 0.01, ...
                           initpos(3)*0.7, ...
                           initpos(4)*0.2], 'fontsize',8);
end