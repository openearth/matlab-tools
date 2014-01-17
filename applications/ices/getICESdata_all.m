function getICESdata_all
%getICESdata_all loop for getICESdata
%
%See also: getICESdata

codes = getICESparameters;

for icode=1:length(codes)
   kmlfiles = {};
   for yyyy=2011:year(now)

   code = codes{icode};
   
   kmlfiles{end+1} = [code,'_',num2str(yyyy),'.kml'];

   [D,A] = getICESdata('ParameterCode',codes{icode},...
                't0',datenum(yyyy  ,1,1),...
                't1',datenum(yyyy  ,1,1),...
               'lon',[-180 180],... % bounding box longitude 
               'lat',[ -90  90],... % bounding box latitude
                 'p',[   0 1e6],... % bounding box depth (pressure)
           'kmlname',num2str(yyyy),...
          'fileName',kmlfiles{end});
   end

   KMLmerge_files('sourceFiles',kmlfiles,'fileName',[code,'_all.kml']);
% 'open',1,...
% 'kmlname',,...
% 'snippet',,...
% 'kmlname',,...
end