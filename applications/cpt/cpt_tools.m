
[X, map] = imread('cpt_sbt_colors.png');

hi = image(X);
xlabel('friction ratio (%)')
ylabel('Cone resistance q_t (MPa)')

set(gca,'YTick',[1 200 400 600])
set(gca,'YTickLabel',{'100','10','1','0.1'})
set(gca,'XTick',[1 100:100:800])
set(gca,'xTickLabel',{'0','1','2','3','4','5','6','7','8'})

hold on
fr = 4;
qt = 10;


qt0 = log10(0.1);

% 0.1 = 600 -1
% 1   = 400  0
% 10  = 200  2
% 100 = 000  3

qt = [linspace(0.1,10,50) linspace(10,100,50)];
fr = linspace(0,8,100);



qt0 = round(max(min((2-log10(qt))*200,600),1));
fr0 = round(max(min(fr*100,800),1));
colormap(gray(12))

plotc(fr0,qt0,X(sub2ind(size(X),qt0,fr0)))
colormap(jet)
plotc(fr0,qt0,-X(sub2ind(size(X),qt0,fr0)),'o')





