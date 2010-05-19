function hm=ddb_readParameters(hm)

n=1;
hm.Parameters(n).Name='wl';
hm.Parameters(n).LongName='water level';
hm.Parameters(n).Title='Water Level';
hm.Parameters(n).YLabel='water level (m w.r.t. MSL)';
hm.Parameters(n).YLimType='sym';
hm.Parameters(n).CLim=[-2 0.25 2];

% n=n+1;
% hm.Parameters(n).Name='vel';
% hm.Parameters(n).LongName='velocity';
% hm.Parameters(n).Title='Velocity';
% hm.Parameters(n).YLabel='velocity (m/s)';
% hm.Parameters(n).YLimType='sym';

n=n+1;
hm.Parameters(n).Name='hs';
hm.Parameters(n).LongName='significant wave height';
hm.Parameters(n).Title='Significant Wave Height';
hm.Parameters(n).YLabel='significant wave height (m)';
hm.Parameters(n).YLimType='positive';
hm.Parameters(n).CLim=[0 0.5 4];

n=n+1;
hm.Parameters(n).Name='tp';
hm.Parameters(n).LongName='peak wave period';
hm.Parameters(n).Title='Peak Wave Period';
hm.Parameters(n).YLabel='peak period (s)';
hm.Parameters(n).YLimType='positive';
hm.Parameters(n).CLim=[0 2 20];

n=n+1;
hm.Parameters(n).Name='wavdir';
hm.Parameters(n).LongName='wave direction';
hm.Parameters(n).Title='Mean Wave Direction';
hm.Parameters(n).YLabel='wave direction ( \circ)';
hm.Parameters(n).YLimType='angle';
hm.Parameters(n).CLim=[0 30 360];

hm.NrParameters=n;
