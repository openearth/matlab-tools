for nump = 1:40, 
    close all; 
     subplot(1,3,1); 
     pcolor(reshape(patterns_nice.vectors(:,nump),52,65));
     clim([-0.25 0.2]); 

     subplot(1,3,2); 
     pcolor(reshape(u(:,nump),52,65));
     clim([-0.25 0.2]); 

    subplot(1,3,3); 
    pcolor(reshape(patterns_fixed.vectors(:,nump),52,65));
    clim([-0.25 0.2]); 

%     subplot(1,3,3); 
%     pcolor(reshape(patterns_fixed2.vectors(:,nump),52,65));
%     clim([-0.25 0.2]); 
    
    set(gcf,'position',[56 278 1131 420]); 
    pause; 
end