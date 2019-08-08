function demo_ge_groundoverlay()
 error('%s has been deprecated',mfilename)

N = 66;
E = 38;
S = 2;
W = -23;

url = ['data',filesep,'map.bmp'];

kmlStr = ge_groundoverlay(N,E,S,W,...
                       'imageURL',url,...
                    'viewBoundScale',1e3);
                
FN = 'demo_ge_groundoverlay';
kmlFileName = [FN,'.kml'];
kmzFileName = [FN,'.kmz'];
%kmzTargetDir = ['..',filesep,'kml',filesep];

ge_kml(kmlFileName,kmlStr)
ge_kmz(kmzFileName,...
        'resourceURLs',{url,kmlFileName});%,...
           %'kmzTargetDir',kmzTargetDir);
           
%now remove temporary kml file
if ispc
    system(['del ' kmlFileName]);
else
    system(['rm -f ' kmlFileName]); 
end
