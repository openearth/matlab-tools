%SURFCORCEN_TEST   test for SURFCORCEN
%
%See also: SURFCORCEN, PCOLORCORCEN

   [xcor,ycor] = meshgrid(1:3,5:8);
   zcor        = xcor + ycor; %rand(size(xcor));
   
   [xcen,ycen,zcen] = corner2center(xcor,ycor,zcor);
   
   ccen        = zcen;
   ccor        = zcor;
   
   clims = [min(ccor(:)) max(ccor(:))];
   
   ny = 3;
   
   subplot(ny,5,1)
   surfcorcen(zcor)
   caxis(clims)
   title('surfcorcen(zcor)')
   
   subplot(ny,5,2)
   surfcorcen(zcor,'r')
   caxis(clims)
   title('surfcorcen(zcor,''r'')')
   
   subplot(ny,5,3)
   surfcorcen(zcor,[.5 .5 .5])
   caxis(clims)
   title('surfcorcen(zcor,[.5 .5 .5])')
   
   subplot(ny,5,4)
   surfcorcen(zcor,ccor)
   caxis(clims)
   title('surfcorcen(zcor,ccor)')
   
   subplot(ny,5,5)
   surfcorcen(zcor,ccen)
   caxis(clims)
   title('surfcorcen(zcor,ccen)')
   
   %% not possible
   %surfcorcen(zcen,ccor);
   %pausedisp
   
   %%-------------
   
   subplot(ny,5,6)
   surfcorcen(zcor,ccor,'r')
   caxis(clims)
   title('surfcorcen(zcor,ccor,''r'')')
   
   subplot(ny,5,7)
   surfcorcen(zcor,ccor,[.5 .5 .5])
   caxis(clims)
   title('surfcorcen(zcor,ccor,[.5 .5 .5])')
   
   subplot(ny,5,8)
   surfcorcen(zcor,ccen,'r')
   caxis(clims)
   title('surfcorcen(zcor,ccen,''r'')')
   
   subplot(ny,5,9)
   surfcorcen(zcor,ccen,[.5 .5 .5])
   caxis(clims)
   title('surfcorcen(zcor,ccen,[.5 .5 .5])')
   
   %%-------------
   
   subplot(ny,5,11)
   surfcorcen(xcor,ycor,zcor,ccor,'r')
   caxis(clims)
   title('surfcorcen(xcor,ycor,zcor,ccor,''r'')')
   
   subplot(ny,5,12)
   surfcorcen(xcor,ycor,zcor,ccor,[.5 .5 .5])
   caxis(clims)
   title('surfcorcen(xcor,ycor,zcor,ccor,[.5 .5 .5])')
   
   subplot(ny,5,13)
   surfcorcen(xcor,ycor,zcor,ccen,'r')
   caxis(clims)
   title('surfcorcen(xcor,ycor,zcor,ccen,''r'')')
   
   subplot(ny,5,14)
   surfcorcen(xcor,ycor,zcor,ccen,[.5 .5 .5])
   caxis(clims)
   title('surfcorcen(xcor,ycor,zcor,ccen,[.5 .5 .5])')

%% EOF
