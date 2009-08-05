function rws_plotDataInPolygon(X, Y, Z, Ztime, varargin)
%RWS_PLOTDATAINPOLYGON
%
%   rws_plotDataInPolygon(X, Y, Z, Ztime, <keyword,value>)
%
%See also: 

OPT.polygon      = [];
OPT.datathinning = 1;
OPT.ldburl       = []; % x of coastline

OPT = setProperty(OPT,varargin{:});

if ~isempty(OPT.ldburl)
    OPT.x = nc_varget(OPT.ldburl, lookupVarnameInNetCDF('ncfile', OPT.ldburl, 'attributename', 'standard_name', 'attributevalue', 'projection_x_coordinate'));
    OPT.y = nc_varget(OPT.ldburl, lookupVarnameInNetCDF('ncfile', OPT.ldburl, 'attributename', 'standard_name', 'attributevalue', 'projection_y_coordinate'));
end

%% find unqiue date values
%-----------------
v = unique(Ztime(find(~isnan(Ztime)))); %#ok<*FNDSB>
if length(v)==1
    v=[v(1) - 1 v];
end
nv = length(v);

if nv == 0
   warning('no data found: only selection polygon plotted')
end

%% Step 1: plot resulting X, Y and Z grid
%-----------------
figure(2);clf;

% plot
   pcolorcorcen(X(1:OPT.datathinning:end,1:OPT.datathinning:end),...
                Y(1:OPT.datathinning:end,1:OPT.datathinning:end),...
                Z(1:OPT.datathinning:end,1:OPT.datathinning:end));
   hold on; 
   plot(OPT.polygon(:,1), OPT.polygon(:,2),'g','linewidth',2)

   % layout
   if nv > 0
   colorbar;
   end

   axis    equal
   axis    tight
   box     on
   
   title   ('z-values available in polygon')
   tickmap ('xy','texttype','text','format','%0.1f','dellast',1)
   plot    (OPT.x,OPT.y,'k', 'linewidth', 2)

%% Step 2: plot X, Y and Ztime
%-----------------
figure(3); clf; 


   % make matrix so you can plot index of unique values
   V=Ztime;
   for iv=1:nv
       mask = (Ztime==v(iv));
       V(mask)=iv;
   end
   
   % plot
   pcolorcorcen(X(1:OPT.datathinning:end,1:OPT.datathinning:end),...
                Y(1:OPT.datathinning:end,1:OPT.datathinning:end),...
                V(1:OPT.datathinning:end,1:OPT.datathinning:end));
   hold on; 
   plot(OPT.polygon(:,1), OPT.polygon(:,2),'g','linewidth', 2)
   
   % layout
   if nv > 0
   caxis   ([1-.5 nv+.5])
   colormap(jet(nv));
   [ax,c1] =  colorbarwithtitle('',1:nv+1); %#ok<NASGU>
   set(ax,'yticklabel',datestr(v,1))
   end
   
   axis    equal
   axis    tight
   box     on
   
   title   ('timestamps of z-values available in polygon')
   tickmap ('xy','texttype','text','format','%0.1f','dellast',1)
   plot    (OPT.x,OPT.y,'k', 'linewidth', 2)
