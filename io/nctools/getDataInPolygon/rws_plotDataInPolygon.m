function rws_plotDataInPolygon(X, Y, Z, Ztime, OPT)
%RWS_PLOTDATAINPOLYGON
%
%See also: 

%% Step 1: plot resulting X, Y and Z grid
%-----------------
figure(2);clf;

% plot
pcolorcorcen(X(1:OPT.datathinning:end,1:OPT.datathinning:end),...
             Y(1:OPT.datathinning:end,1:OPT.datathinning:end),...
             Z(1:OPT.datathinning:end,1:OPT.datathinning:end));
hold on; ph = plot(OPT.polygon(:,1), OPT.polygon(:,2),'g'); set(ph,'linewidth',2)

% layout
colorbar;

axis    equal
axis    tight
box     on

title   ('z-values available in polygon')
tickmap ('xy','texttype','text','format','%0.1f')

%% Step 2: plot X, Y and Ztime
%-----------------
figure(3); clf; 

% find unqiue date values
v = unique(Ztime(find(~isnan(Ztime)))); %#ok<*FNDSB>
if length(v)==1
    v=[v(1) - 1 v];
end
nv = length(v);

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
hold on; ph = plot(OPT.polygon(:,1), OPT.polygon(:,2),'g'); set(ph,'linewidth', 2)

% layout
caxis   ([1-.5 nv+.5])
colormap(jet(nv));
[ax,c1] =  colorbarwithtitle('',1:nv+1); %#ok<NASGU>
set(ax,'yticklabel',datestr(v,1))

axis    equal
axis    tight
box     on

title   ('timestamps of z-values available in polygon')
tickmap ('xy','texttype','text','format','%0.1f')

