%NANGRIDDATA_TEST  Test script.

%27-9-2006

[X,Y,Z] = PEAKS;

x = X;
y = Y;

subplot(1,4,1)
pcolorcorcen(X,Y,Z,[.5 .5 .5])
title('original full data set')

%nx = 50;
%ny = 50;
%
%[x,y] = meshgrid(linspace(nanmin(X(:)),nanmax(X(:)),nx),...
%                 linspace(nanmin(Y(:)),nanmax(Y(:)),ny));

subplot(1,4,2)
                 
%% area 1
m1       = 30:40;
n1       = 30:40;
text(X(m1(1),n1(1)),Y(m1(1),n1(1)),'X,Y= Nan')
X(m1,n1) = nan;                 
Y(m1,n1) = nan;                 

hold on

%% area 2
m2       = 5:15;
n2       = 5:15;
text(X(m2(1),n2(1)),Y(m2(1),n2(1)),'Z= Nan')
Z(m2,n2) = nan;                 

%% area 3
m3       = 15:15;
n3       = 30:40;
text(X(m3(1),n3(1)),Y(m3(1),n3(1)),'X,Y,Z= Nan')
X(m3,n3) = nan;                 
Y(m3,n3) = nan;                 
Z(m3,n3) = nan;                 

pcolorcorcen(X,Y,Z,[.5 .5 .5])
title('3 types of holes')

subplot(1,4,3)
z = nangriddata('none',X,Y,Z,x,y);

pcolorcorcen(X,Y,z,[.5 .5 .5])
title('nangriddata(''none'',...) (default)')


subplot(1,4,4)
z = nangriddata('filled',X,Y,Z,x,y);

pcolorcorcen(X,Y,z,[.5 .5 .5])
title('nangriddata(''filled'',...)')