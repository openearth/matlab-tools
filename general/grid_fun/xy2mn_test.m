%XY2MN_TEST   test for XY2MN
percentage_gaps = 50;
[x,y]=meshgrid(1:50,1:100);

randomindices = round(rand(round(length(x(:)).*percentage_gaps./100),1).*length(x(:)));

x(randomindices) = nan;
y(randomindices) = nan;

pcolorcorcen(x,y,x,[.5 .5 .5])
plot(x(:),y(:),'x','markersize',10)

xv = [1.5 2.5 2  ];
yv = [4.9 4.2 3.1];

xv = [20.4131
      30.4257
      30.6474
      40.5693
      40.3929
      30.6020
      20.5189
      10.6776
      10.3955
      10.2796
      10.5567];

yv = [70.7830
      80.6071
      60.6126
      50.3269
      30.5797
      20.3434
      10.3709
      20.1456
      40.0907
      70.3049
      80.7720];

hold on
plot(xv,yv,'k-o')

%[m,n,mn] = xy2mn(x,y,xv,yv);
S  = xy2mn(x,y,xv,yv);
mn = S.mn;
m  = S.m;
n  = S.n;

%mmax = size(x,1);
%m    = mod((mn)-1,mmax)+1
%n    = (((mn)-m+mmax))/mmax;
disp('x y mn m n x(mn) y(mn)')
[xv yv mn m n x(mn) y(mn)]

plot(x(mn),y(mn),'k--s')

for i=1:length(m)
   plot(x(m(i),n(i)),y(m(i),n(i)),'r.')
   text(x(m(i),n(i)),y(m(i),n(i)),['m = ',num2str(m(i)),' n = ',num2str(n(i))])
end

xlabel('n')
ylabel('m')

legend('(x,y)',...
       'random co-ordinates',...
       'xy2mn > (mn) grid nodes',...
       'xy2mn > (m,n) grid nodes')
