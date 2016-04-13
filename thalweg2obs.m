function varargout = thalweg2obs(varargin)
%THALWEG2OBS helper for vs_trih2thalweg
%Creates equally spaced kml-line and observation points needed for
%vs_trih2thalweg
%Input: grd = D3D grid
%       kml = kml file containing thalweg
%       dn = spacing for new kml (default = 100 m)
%       kmlout = new equally spaced kml file
%       obs = filename for obs file needed for vs_trih2thalweg
%See also: KML2Coordinates, arbcross, vs_trih2thalweg

OPT.grd    = '';
OPT.kml    = '';
OPT.dn     = 100;
OPT.kmlout = '';
OPT.obs    = '';

if nargin==0
   varargout = {OPT};
   return
end

OPT = setproperty(OPT,varargin);

grd = wlgrid('read',OPT.grd);

% % Convert coordinates from RD to UTM
[grd.lon,grd.lat] = convertCoordinates(grd.X,grd.Y,'CS1.code',28992,'CS2.code',4326);
grd.lon(grd.lon==0) = nan;
grd.lat(grd.lat==0) = nan;

[T.lat,T.lon] = KML2Coordinates(OPT.kml);

[int.x,int.y] = arbcross(grd.lon,grd.lat,T.lon,T.lat); %int is a matrix with intersections with grid and points in KML file

q=1;
for i=1:length(int.x)
    % use only intersections
    pp=find(int.x(i)==T.lon);
    qq=find(int.y(i)==T.lat);
    if isempty(pp) && isempty(qq) && ~isnan(int.x(i))
        T.intx(q) = int.x(i);
        T.inty(q) = int.y(i);

        clear xx vv pp
        for j=1:size(grd.lon,1)
            for k=1:size(grd.lon,2)
                xx(j,k)=((grd.lon(j,k)-T.intx(q)).^2+(grd.lat(j,k)-T.inty(q)).^2);
            end
        end
        vv=min(min(xx));
        [m(q),n(q)]=find(xx==vv);
        q=q+1;
    end
end

%%
[T.x,T.y] = convertCoordinates(T.lon,T.lat,'CS1.code',4326,'CS2.code',28992);

T.cumlength(1)=0;
for t=1:length(T.y)-1
    T.length(t) = sqrt((T.x(t+1)-T.x(t)).^2+(T.y(t+1)-T.y(t)).^2);
    T.cumlength(t+1)=T.cumlength(t)+T.length(t);
end
T.totlength=sum(T.length);

xl=0:OPT.dn:T.totlength;
T.newx(1)=T.x(1);
T.newy(1)=T.y(1);
for t=2:length(xl)
    sect=find(T.cumlength<=xl(t));
    sect=sect(end);
    T.newx(t)=T.x(sect)+((T.x(sect+1)-T.x(sect))/T.length(sect))*(xl(t)-T.cumlength(sect));
    T.newy(t)=T.y(sect)+((T.y(sect+1)-T.y(sect))/T.length(sect))*(xl(t)-T.cumlength(sect));
end
[T.newlon,T.newlat] = convertCoordinates(T.newx,T.newy,'CS1.code',28992,'CS2.code',4326);
KMLline(T.newlat,T.newlon,'fileName',OPT.kmlout,'lineColor',[1 0 0],'lineWidth',1)

mn=unique([m' n'],'rows');

%% write obs file
fid=fopen(OPT.obs,'w');

for l=1:length(mn)
    fprintf(fid,'%s%1.0f\t%1.0f\t%1.0f\n','thalweg',l,mn(l,1),mn(l,2));
end
fclose(fid)
