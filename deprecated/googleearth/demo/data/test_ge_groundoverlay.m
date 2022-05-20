N = 66;
E = 38;
S = 2;
W = -23;

kmlStr = ge_groundoverlay(N,E,S,W,...
                       'imageURL','map.bmp');

ge_output('example_ge_groundoverlay.kml',kmlStr);