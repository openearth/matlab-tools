function opt=muppet_setDefaultAxisProperties(varargin)

opt.type='unknown';
opt.position=[0 0 1 1];
opt.name='subplot';

if ~isempty(varargin)
    opt=varargin{1};
end

% Misc
opt.drawbox=1;
opt.axesequal=0;
opt.rightaxis=0;
opt.adddate=0;
opt.adjustaxes=0;
opt.text{1}='';
opt.numbertextlines=0;
opt.horizontalalignment='left';
opt.verticalalignment='top';
opt.backgroundcolor='white';
opt.nrdatasets=0;
opt.nrfreetext=0;
opt.activedataset=1;

% X Axis
opt.xmin=[];
opt.xmax=[];
opt.xtick=[];
opt.xgrid=0;
opt.xdecimals=-1;
opt.xscale='linear';
opt.xtickmultiply=1.0;
opt.xtickadd=0.0;
opt.xticklabels=[];

% Y Axis
opt.ymin=[];
opt.ymax=[];
opt.ytick=[];
opt.yminright=0.0;
opt.ymaxright=1.0;
opt.ytickright=0.1;
opt.ygrid=0;
opt.ygridright=0;
opt.ydecimals=-1;
opt.ydecimalsright=-1;
opt.yscale='linear';
opt.ytickmultiply=1.0;
opt.ytickadd=0.0;
opt.yticklabels=[];

% Scale
opt.scale=[];

% Z Axis
opt.zmin=0.0;
opt.zmax=1.0;
opt.ztick=-999.0;
opt.zgrid=0;
opt.zdecimals=-1;

% Color settings
opt.colormap='jet';
opt.cmin=0.0;
opt.cstep=0.1;
opt.cmax=1.0;
opt.contours=0;
opt.contourtype='limits';
opt.customcolorlimits=0;

% Time axis
opt.datetickformat='HH:MM:SS';
opt.yearmin=[];
opt.monthmin=[];
opt.daymin=[];
opt.hourmin=[];
opt.minutemin=[];
opt.secondmin=[];
opt.yearmax=[];
opt.monthmax=[];
opt.daymax=[];
opt.hourmax=[];
opt.minutemax=[];
opt.secondmax=[];
opt.yeartick=[];
opt.monthtick=[];
opt.daytick=[];
opt.hourtick=[];
opt.minutetick=[];
opt.secondtick=[];
opt.timegrid=0;

% X Label
opt.xlabel.text='';
opt.xlabel.font.name='Helvetica';
opt.xlabel.font.size=8;
opt.xlabel.font.angle='normal';
opt.xlabel.font.weight='normal';
opt.xlabel.font.color='black';

% Y Label
opt.ylabel.text='';
opt.ylabel.font.name='Helvetica';
opt.ylabel.font.size=8;
opt.ylabel.font.angle='normal';
opt.ylabel.font.weight='normal';
opt.ylabel.font.color='black';
opt.ylabelright.text='';
opt.ylabelright.font.name='Helvetica';
opt.ylabelright.font.size=8;
opt.ylabelright.font.angle='normal';
opt.ylabelright.font.weight='normal';
opt.ylabelright.font.color='black';

% Title
opt.title.text='';
opt.title.font.name='Helvetica';
opt.title.font.size=10;
opt.title.font.angle='normal';
opt.title.font.weight='normal';
opt.title.font.color='black';

% Axes font
opt.axes.font.name='Helvetica';
opt.axes.font.size=8;
opt.axes.font.angle='normal';
opt.axes.font.weight='normal';
opt.axes.font.color='black';
opt.font.name='Helvetica';
opt.font.size=8;
opt.font.angle='normal';
opt.font.weight='normal';
opt.font.color='black';

% Legend
opt.plotlegend=0;
opt.legend.border=1;
opt.legend.position='NorthEast';
opt.legend.orientation='Vertical';
opt.legend.font.name='Helvetica';
opt.legend.font.size=8;
opt.legend.font.angle='normal';
opt.legend.font.weight='normal';
opt.legend.font.color='black';
opt.legend.color='white';
opt.legend.changed=0;

% North Arrow
opt.plotnortharrow=0;
opt.northarrow.position=[];
opt.northarrow.changed=0;

% Scale Bar
opt.plotscalebar=0;
opt.scalebar.position=[];
opt.scalebar.text='';
opt.scalebar.changed=0;

% Vector Legend
opt.plotvectorlegend=0;
opt.vectorlegend.position=[0 0];
opt.vectorlegend.font.name='Helvetica';
opt.vectorlegend.font.size=8;
opt.vectorlegend.font.angle='normal';
opt.vectorlegend.font.weight='normal';
opt.vectorlegend.font.color='black';
opt.vectorlegend.changed=0;

% Color Bar
opt.plotcolorbar=0;
opt.shadesbar=0;
opt.colorbar.position=[];
opt.colorbar.decimals=-1;
opt.colorbar.type=1;
opt.colorbar.label='';
opt.colorbar.labelposition='top';
opt.colorbar.unit='';
opt.colorbar.labelincrement=1;
opt.colorbar.font.name='Helvetica';
opt.colorbar.font.size=8;
opt.colorbar.font.angle='normal';
opt.colorbar.font.weight='normal';
opt.colorbar.font.color='black';
opt.colorbar.changed=0;

% 3D options
opt.cameratarget=[0 0 0];
opt.cameraangle=[0 0];
opt.cameraviewangle=10;
opt.dataaspectratio=[100 100 1];
opt.lightstrength=0.4;
opt.lightazimuth=0;
opt.lightelevation=55;
opt.perspective=1;

% Coordinate system
opt.coordinatesystem.name='unspecified';
opt.coordinatesystem.type='projected';
opt.coordinatesystem.text='unspecified - projected';
opt.projection='equirectangular';

