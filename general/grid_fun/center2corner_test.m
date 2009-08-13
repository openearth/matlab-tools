%CENTER2CORNER_TEST   visual test for center2corner
%
%See also: center2corner, corner2center_test

%% ----------------------

g.xcen = [0 1 2   3 4 5;
          0 1 nan 3 4 5;
          0 1 2   3 4 5;
          0 1 2   3 4 5;
          0 1 2   3 4 5;
          0 1 2   3 4 5];

g.ycen = [0 0 0   0   0 0;
          1 1 nan nan 1 1;
          2 2 nan nan 2 2;
          3 3 3   3   3 3;
          4 4 4   4   4 4;
          5 5 5   5   5 5];

figure('name','center2corner')
g.xcor = center2corner(g.xcen);
g.ycor = center2corner(g.ycen);
grid_plot(g.xcen,g.ycen,'sg-')
hold on
grid_plot(g.xcor,g.ycor,'ob-')
title('center2corner: g center -- b corner')
axis([-1 6 -1 6])

figure('name','center2cornernan')
g.xcor = center2cornernan(g.xcen);
g.ycor = center2cornernan(g.ycen);
grid_plot(g.xcen,g.ycen,'sg-')
hold on
grid_plot(g.xcor,g.ycor,'ob-')
title('center2cornernan: g center -- b corner')
axis([-1 6 -1 6])

%% ----------------------

g.xcen = [...
     0     1     2     3     4     5
     0     1     nan   3     4     5
     0     1     2     3     4     5
     0     1     2     3     nan   nan
     0     1     2     3     nan   nan];


g.ycen = [...
     1     1     1     1     1     1
     2     2     2     2     2     2
     3     3     3     3     3     3
     4     4     4     4     4     4
     5     5     5     5     5     5];


figure('name','center2corner')
g.xcor          = center2corner(g.xcen);
g.ycor          = center2corner(g.ycen);
grid_plot(g.xcen,g.ycen,'sg-')
hold on
grid_plot(g.xcor,g.ycor,'ob-')
title('center2corner: g center -- b corner')
axis([-1 6 -1 6])

figure('name','center2cornernan')
g.xcor          = center2cornernan(g.xcen);
g.ycor          = center2cornernan(g.ycen);
grid_plot(g.xcen,g.ycen,'sg-')
hold on
grid_plot(g.xcor,g.ycor,'ob-')
title('center2cornernan: g center -- b corner')
axis([-1 6 -1 6])
