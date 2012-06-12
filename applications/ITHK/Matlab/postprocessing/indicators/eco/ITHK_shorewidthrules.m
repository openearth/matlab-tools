function ITHK_shorewidthrules
% input: isoort of supplicie
% input: time
% coastline position (x,y,z)
% output: Ps
%for isoort=1:2


%load PRNdata
global S
zminz0 = S.PP.coast.zminz0;                                           % change of coastline since t0
zminz0Rough = S.PP.coast.zminz0Rough;                                           % change of coastline since t0


ShoreWidth = 10000.0;                                                      % initial shoreface width, i.e. 10km.
%ShoreWidthFact = zeros();
% ShoreWidthFact = (ShoreWidth-(zminz0>0))/ShoreWidth;                       % if zminz0 >0, then the shoreface width decrease, then K and P of the species will descrease in a portion.

S.PP.UBmapping.eco(1).ShoreWidthFact = (ShoreWidth-(zminz0>0))/ShoreWidth;
S.PP.GEmapping.eco(1).ShoreWidthFact = (ShoreWidth-(zminz0Rough>0))/ShoreWidth;
%S.P = ShoreWidthFact;

%% PLOT THE POPULATION IN TIME
ITHK_kmlbarplot(S.PP.coast.x0_refgridRough,S.PP.coast.y0_refgridRough,S.PP.GEmapping.eco(1).ShoreWidthFact.*500,str2double(S.settings.indicators.eco.offset));
