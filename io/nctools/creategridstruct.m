function d = creategridstruct()
%CREATEGRIDSTRUCT  Create an empty gridstructure
%   d = creategridstruct()
%
%   Example
%   creategridstruct
%
%   See also

% $Id$


% example struct
%  seq: 2015
%          datatypeinfo: 'Kaartblad Vaklodingen'
%              datatype: 1
%             datatheme: 'bathymetry'
%                  name: 'KB115.4140'
%                  year: '1999'
%            soundingID: '0414'
%             xllcorner: 41860
%             yllcorner: 425000
%              cellsize: 20
%               contour: [5x2 double]
%           contourunit: 'm'
%     contourprojection: 'Rijksdriehoek'
%      contourreference: 'origin'
%          ls_fielddata: 'parentSeq'
%             timestamp: 0
%             fielddata: [1x1 struct]
%                     X: [625x407 double]
%                     Y: [625x407 double]
%                     Z: [625x407 double]

d.seq = 0;
d.datatypeinfo = 'Kaartblad Vaklodingen';
d.datatheme ='bathymetry';
d.name = '';
d.year = '';
d.soundingID = '';
d.xllcorner = 0;
d.yllcorner = 0;
d.cellsize = 0;
d.contour = zeros(5,2);
d.contourunit = 'm';
d.contourprojection = 'Rijksdriehoek';
d.contourreference = 'origin';
d.ls_fielddata = 'parentSeq';
d.timestamp = 0;
d.fielddata = struct;
d.X = zeros(1,1)*NaN;
d.Y = zeros(1,1)*NaN;
d.Z = zeros(1,1)*NaN;

