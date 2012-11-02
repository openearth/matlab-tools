% From quickplot to subplot
    clear, close all, clc
    
    thefiles = {'wVel_north_00-0810.fig', ...
                'wVel_north_00-0820.fig', ...
                'wVel_north_00-0940.fig', ...
                'wVel_north_02-0120.fig', ...
                'wVel_north_03-0940.fig'};
    
    thefontsize = 8;
    numplots = length(thefiles)
    h2 = figure;                %create new figure
    
    for iplot = 1:numplots
    
        h = openfig(thefiles{iplot},'reuse'); % open figure
        ax = gca; % get handle to axes of figure
        thetitle = get(get(ax,'Title'),'String')
        
        s(iplot) = subplot(numplots,1,iplot,'parent',h2);        %create and get handle to the subplot axes
        thefig{iplot} = get(ax,'children'); %get handle to all the children in the figure
        copyobj(thefig{iplot},s(iplot)); %copy children to new parent axes i.e. the subplot axes
        
        title(s(iplot),thetitle{2},'fontsize',thefontsize,'fontweight','bold')
        xlim(s(iplot),[100 130])
        if iplot == numplots, xlabel(s(iplot),'x coordinate [m]','fontsize',thefontsize); end
        ylabel(s(iplot),'y coordinate [m]','fontsize',thefontsize)
        set(s(iplot),'fontsize',thefontsize)
    end
     
    print(h2,'-depsc2','velocity_at_boundary')