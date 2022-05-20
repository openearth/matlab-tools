function demo_ge_point()%% Demo ge_point
 error('%s has been deprecated',mfilename)
% Example usage of the ge_point function.
%   X, Y should be decimal coordinates (WGS84)
%   Z is altitude in meters
% 'help ge_point' for more info.

t = 0:pi/50:10*pi;

iconStr = 'http://maps.google.com/mapfiles/kml/pal3/icon35.png';

kmlStr01 = ge_point(sin(t),cos(t),t*1e6,...
                        'iconURL',iconStr,...
                    'msgToScreen',true,...
                           'name','');

kmlStr02 = ge_point(-8,-5.5,3.56);

kmlFileName = 'demo_ge_point.kml';
kmlTargetDir = [''];%..',filesep,'kml',filesep];
ge_output([kmlTargetDir,kmlFileName],[kmlStr01,kmlStr02],...
                                                  'name',kmlFileName);
