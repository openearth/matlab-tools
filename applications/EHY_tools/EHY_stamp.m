function EHY_stamp(fileInp,varargin)
%  Adds a small "stamp with the location indication (which Thalweg and where exactly measured) to the current axes
%  First beta version, needs improvement and extension with station locations but you have to start somewhere
%
%% Initialise
fileCrs     = '';
OPT.measLoc = '';
OPT.thalweg = '';
OPT         = setproperty(OPT,varargin);
if ~isempty(OPT.thalweg) fileCrs = OPT.thalweg; end

% Read Stamp settings
Info        = inifile('open'    ,fileInp);
chapters    = inifile('chapters',Info   );

%  Location information
pos_stamp   = eval(inifile('get',Info   ,'Location','Position'));
Xlim        = eval(inifile('get',Info   ,'Location','Xlim'));
Ylim        = eval(inifile('get',Info   ,'Location','Ylim'));

%  Landboundary
fileLdb     = inifile('get',Info,'Landboundary','fileLdb');

%  Measurement section (thalweg, sailed track) if defined
if ~isempty(get_nr(chapters,'Thalweg')) && isempty fileCrs
    fileCrs = inifile('get',Info,'Thalweg','fileCrs');
end

%% set current axes to normalized
currentAxes = gca;
set(gca,'Units','normalized');

%% Define new axis in the existing axes (for some reason retrieving 'Position' directly from gca doe not always work??????)
tmp      = get(gca);
position = tmp.Position;
newAxes  = axes('Units','normalized','Position',[position(1) + pos_stamp(1)*position(3)   position(2) + pos_stamp(2)*position(4)  pos_stamp(3)*position(3)  pos_stamp(4)*position(4)]);

%% Read the landboundary to plot
LDB     = readldb(fileLdb);
LDB.y(LDB.x == 999.999) = NaN;
LDB.x(LDB.x == 999.999) = NaN;

%% Plot the landboundary
plot(LDB.x,LDB.y,'k'); hold on;

%% Sailed path
if ~isempty(fileCrs)
    CRS     = readldb(fileCrs);
    CRS.y(CRS.x == 999.999) = NaN;
    CRS.x(CRS.x == 999.999) = NaN;
    plot(CRS.x     ,CRS.y     ,'r' ,'LineWidth',1.0);hold on
    plot(CRS.x(  1),CRS.y(  1),'r.','MarkerSize',25);hold on
    plot(CRS.x(end),CRS.y(end),'r.','MarkerSize',15);hold on
end

%% Plot the measurement locations
if ~isempty (OPT.measLoc.x)
    plot(OPT.measLoc.x,OPT.measLoc.y,'k.','MarkerSize',7.5);hold on
end

%% Set axis etc
set(gca,'Units','centimeters');
position = get(gca,'Position');
Ylim(2)   = Ylim(1) + (position(4)/position(3))*(Xlim(2) - Xlim(1));
set(gca,'Xlim' ,Xlim,'Ylim' ,Ylim);
set(gca,'Xtick',  [],'Ytick',  [],'Box','on');

%% Restore to original axes
set (gcf,'CurrentAxes',currentAxes);

end

