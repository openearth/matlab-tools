function nangriddata_test
%NANGRIDDATA_TEST  Visual illustration test for nangriddata
%
%See also: NANGRIDDATA

%%
[X,Y,Z] = peaks;

x = X;
y = Y;

%%
subplot(1,5,1)
pcolorcorcen(X,Y,Z,[.5 .5 .5])
title('original full data set')

%nx = 50;
%ny = 50;
%
%[x,y] = meshgrid(linspace(nanmin(X(:)),nanmax(X(:)),nx),...
%                 linspace(nanmin(Y(:)),nanmax(Y(:)),ny));

%%
subplot(1,5,2)
                 
%% area 1
m1       = 30:40;
n1       = 30:40;
text(X(m1(1),n1(1)),Y(m1(1),n1(1)),'X,Y= Nan')
X(m1,n1) = NaN;                 
Y(m1,n1) = NaN;                 

hold on

%% area 2
m2       = 5:15;
n2       = 5:15;
text(X(m2(1),n2(1)),Y(m2(1),n2(1)),'Z= Nan')
Z(m2,n2) = NaN;                 

%% area 3
m3       = 15:15;
n3       = 30:40;
text(X(m3(1),n3(1)),Y(m3(1),n3(1)),'X,Y,Z= Nan')
X(m3,n3) = NaN;                 
Y(m3,n3) = NaN;                 
Z(m3,n3) = NaN;                 

pcolorcorcen(X,Y,Z,[.5 .5 .5])
title('3 types of holes')

%%
subplot(1,5,3)
z = nangriddata('none',X,Y,Z,x,y);

pcolorcorcen(X,Y,z,[.5 .5 .5])
title('nangriddata(''none'',...) (default)')


%%
subplot(1,5,4)
z = nangriddata('filled',X,Y,Z,x,y);

pcolorcorcen(X,Y,z,[.5 .5 .5])
title('nangriddata(''filled'',...)')

%%
subplot(1,5,5)
%z = griddata(X,Y,Z,x,y); % retuls (2008b) in

err= ...
    {'??? Error using ==> cgprechecks at 35',...
 'Data points containing Inf or NaN are not supported.',...
 '',...
 'Error in ==> delaunayn at 48',...
 'cgprechecks(x, nargin, cg_opt);',...
 '',...
 'Error in ==> griddata>linear at 150',...
 '    tri = delaunayn([x y]);',...
 '',...
 'Error in ==> griddata at 119',...
 '    zi = linear(x,y,z,xi,yi,opt);',...
 '',...
 'Error in ==> nangriddata_test at 69',...
 'z = griddata(X,Y,Z,x,y);'};


text(0,0.5,err)