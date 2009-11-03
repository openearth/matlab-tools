
%% first put polygons in a directory called polygons, or load like this:

% OPT.polygon = [110408.287818882,543577.467188487;104543.995635158,545097.839236119;105955.769679388,552373.905464074;111059.875839296,552265.307460671;110408.287818882,543577.467188487;]

%% then run sand balance
OPT.datatype        = 'vaklodingen';
OPT.thinning        = 1;
OPT.timewindow      = 24;
OPT.inputyears      = [1925:2007];
OPT.min_coverage    = 50;

UCIT_getSandBalance(OPT)