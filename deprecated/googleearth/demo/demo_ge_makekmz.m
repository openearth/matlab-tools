function demo_ge_makekmz()
 error('%s has been deprecated',mfilename)

rLinkStr = ['barbs',filesep];

kmlStr = ge_windbarb(10,20,300,10,0,...
    'arrowScale',1e5,...
    'rLink',rLinkStr);

ge_output('barbs.kml',kmlStr)

sources = {fullfile(googleearthroot,'data','barbdaes');
            'barbs.kml'};

destinations = {rLinkStr;
                   'barbs.kml'};

ge_makekmz('barbs.kmz','sources',sources,...
                  'destinations',destinations)

















