function pdf_Term_plots(termination,dir,ldbplotfile,xg,yg)
ldb=landboundary('read',ldbplotfile);
xldb=squeeze(ldb(:,1));
yldb=squeeze(ldb(:,2));
xxx=0;
A={'<40kt,<80hrs','>40kt,<80hrs';'<40kt,<160hrs','>40kt,<160hrs';'<40kt,<240hrs','>40kt,<240hrs';'<40kt,>240hrs','>40kt,>240hrs'};
for i=1:4
    for j=1:2
        xxx=xxx+1;
        
        cmp = jet;
        cmp(1,:) = [1 1 1];
        Yfig = 29.7/2;   XFig = 21.0;
        xSize = XFig - 2*0.5;   ySize = Yfig - 2*0.5; % figure size on paper (width & height)
        hFig = figure('visible','off');; hold on;
        set(hFig, 'PaperUnits','centimeters');
        set(hFig, 'PaperSize',[XFig Yfig]);
        set(hFig, 'PaperPosition',[0.5 0.5 xSize ySize]);
        set(hFig, 'PaperOrientation','portrait');
        ylabel('latitude [°]')
        xlabel('longitude [°]')
        term_p_plot = termination.term(i,j).p; term_p_plot(termination.term(i,j).p==0)=NaN;
        pcolor(xg,yg,term_p_plot);shading flat; colorbar;colormap(cmp); hold on;plot(xldb,yldb,'k')
        title(A{i,j})
        axis equal
        xlim([min(min(xg)) max(max(xg))]);
        ylim([min(min(yg)) max(max(yg))]);
		mkdir([dir, 'TermPDF']); 
        print([dir 'TermPDF/Figure' num2str(xxx)],'-dpng'  ,'-r288');
        
    end
end