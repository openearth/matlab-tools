function testresult = pcolorcorcen_test()
%PCOLORCORCEN_TEST   Test script for PCOLOR.

a = rand(3,2)

edgecolor = nan;
edgecolor = [.5 .5 .5];

figure
subplot(1,2,1)
pcolorcorcen([1 2 3],[1 2 3 4],a,edgecolor)
axis([1 3 1 4])
colorbar('horiz')
title('opengl shading flat')

subplot(1,2,2)
pcolorcorcen([1.5 2.5],[1.5 2.5 3.5],a,edgecolor)
axis([1 3 1 4])
colorbar('horiz')
set(gcf,'renderer','opengl')
title('opengl shading interp')


%%%%%%%%%%%%%


figure
subplot(1,2,1)
pcolorcorcen([1 2 3],[1 2 3 4],a,edgecolor)
axis([1 3 1 4])
colorbar('horiz')
title('zbuffer shading flat')

subplot(1,2,2)
pcolorcorcen([1.5 2.5],[1.5 2.5 3.5],a,edgecolor)
axis([1 3 1 4])
colorbar('horiz')
title('zbuffer shading interp')

set(gcf,'renderer','zbuffer')

testresult = nan;