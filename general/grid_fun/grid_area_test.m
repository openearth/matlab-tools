%GRID_AREA_TEST   test for GRID_AREA
%
%See also: GRID_AREA_TEST

   [Xcorner,Ycorner]=meshgrid(1:3,1:4);

   Xcorner  = [-3  0  2  3;-1   0 2  3     ;-1 0 2 4;];
   Ycorner  = [-1 -1 -2 -2;-0.5 0 1 -2+1e-6; 1 1 2 2;];

%% OK

   subplot(2,1,1)
   
   plot(Xcorner,Ycorner,'-o')
   hold on
   plot(Xcorner',Ycorner',':+')
   
   set(gca,'xtick',[-10:1:10])
   set(gca,'ytick',[-10:1:10])
   grid on
   
   xlims = get(gca,'xlim');
   ylims = get(gca,'ylim');

   Area = grid_area(Xcorner,Ycorner);

  [Xcenter,...
   Ycenter] = corner2center(Xcorner,Ycorner) ;
   for i=1:length(Area(:))
      text(Xcenter(i),Ycenter(i),['* A = ',num2str(Area(i))])
   end
   
   title('Ok for non-convex')   

%% WRONG

   subplot(2,1,2)
   plot(Xcorner,Ycorner,'-o')
   hold on
   plot(Xcorner',Ycorner',':+')
   
   set(gca,'xtick',[-10:1:10])
   set(gca,'ytick',[-10:1:10])
   grid on
   
   xlims = get(gca,'xlim');
   ylims = get(gca,'ylim');

   Area = grid_area(Xcorner,Ycorner,'convex',1);

  [Xcenter,...
   Ycenter] = corner2center(Xcorner,Ycorner) ;
   for i=1:length(Area(:))
      text(Xcenter(i),Ycenter(i),['* A = ',num2str(Area(i))])
   end
   
   title('wrong for non-convex')