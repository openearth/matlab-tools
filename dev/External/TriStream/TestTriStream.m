% Demonstration of TRISTREAM and PLOTTRISTREAM functions.

Npts=5;

% Example: Cavity Driven Flow
% Data from Darren Engwirda (tricontour example)
% http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=10408&objectType=FILE
load CavityFlow;

triplot(tri,x,y,'Color',[1,1,1]*0.75);
hold on; quiver(x,y,u,v,2,'k'); hold off;
xlim([min(x),max(x)]); ylim([min(y),max(y)]);
daspect([1,1,1]); title('Cavity Driven Flow');

disp('Cavity Driven Flow: Velocity Field');
disp(['Pick ',num2str(Npts),' seed points . . .']);

p0=ginput(Npts); 
x0=p0(:,1); y0=p0(:,2);

disp('Computing streamlines . . .');
FlowP=TriStream(tri,x,y,u,v,x0,y0);
PlotTriStream(FlowP,'r');
hold on; plot(x0,y0,'r.'); hold off;

disp(' ');
disp('press any key to continue . . .');
pause;

% Example: Groundwater flow
% Data from Matthew Wolinsky (unpublished research)
% http://www.krellinst.org/csgf/conf/2005/presentations/wolinsky.shtml

load GroundWater;

triplot(tri,x,y,'Color',[1,1,1]*0.75);
hold on; quiver(x,y,u,v,25,'k'); hold off;
xlim([min(x),max(x)]); ylim([min(y),max(y)]);
daspect([1,1,1]); title('Groundwater Flow');

disp('Groundwater Flow: Velocity Field');
disp(['Pick ',num2str(Npts),' seed points . . .']);

p0=ginput(Npts); 
x0=p0(:,1); y0=p0(:,2);

disp('Computing streamlines . . .');
FlowP=TriStream(tri,x,y,u,v,x0,y0);
PlotTriStream(FlowP,'r');
hold on; plot(x0,y0,'r.'); hold off;













