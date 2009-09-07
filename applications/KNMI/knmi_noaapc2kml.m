function [OPT, Set, Default] =knmi_noaapc2kml(noaapcfile,varargin)
%KNMI_NOAAPC2KML   PRELIMINRARY FUNCTION to save NOAAPC file as tiled kml png (BETA!!!)
%
%   knmi_noaapc2kml(noaapcfile,<keyword,value>)
%
% Note: for surf you must change reversePoly if the grid cells are too 
%       dark during the day, and light during the night.
%
% Example:
%
%    knmi_noaapc2kml('K010590N.SST','clim',[9 16]);
%
%See also: KMLfig2png, knmi_noaapc_read

% TO DO : read netCDF data instead of binary noaapc files
% TO DO : remove hard directory and noaapcfiles-list

tic


   directory   = 'F:\checkouts\OpenEarthRawData\knmi\noaapc\mom\1990_mom\5\';
   OPT.clim    = [9 14]; % same as icons in http://dx.doi.org/10.1016/j.csr.2007.06.011
   OPT.disp    = 1; % toc per image
   noaapcfiles = {'K010590N.SST',... % Do make sure they are in chronological order, 4 images/day
                  'K020590N.SST',... % N =  ~2AM night
                  'K020590M.SST',... % O =  ~6AM morning
                  'K020590A.SST',... % M = ~12AM (after)noon
                  'K030590N.SST',... % A =  ~6PM evening
                  'K030590O.SST',...
                  'K030590M.SST',...
                  'K030590A.SST',...
                  'K040590N.SST',...
                  'K040590O.SST',...
                  'K040590M.SST',...
                  'K040590A.SST',...
                  'K050590N.SST',...
                  'K050590O.SST',...
                  'K050590M.SST',...
                  'K060590N.SST',...
                  'K060590O.SST',...
                  'K060590M.SST',...
                  'K070590N.SST',...
                  'K080590M.SST',...
                  'K080590A.SST'};
   
%   [OPT, Set, Default] =setProperty(OPT,varargin{:});
%   
%   if nargin==0
%      return
%   end

   % read 1st image
   noaapcfile = noaapcfiles{1};
   D = knmi_noaapc_read([directory,filesep,noaapcfile],'landmask',nan);
   
   nfile = length(noaapcfiles);

for ifile=1:nfile

   disp(['Processing ',num2str(ifile),'/',num2str(nfile),' @ ',datestr(D.datenum)])
   
   if ifile==nfile
   NEXT.datenum = D.datenum + 1/24;
   else
   noaapcfile   = noaapcfiles{ifile+1};
   NEXT         = knmi_noaapc_read([directory,filesep,noaapcfile],'landmask',nan);
   end
   
   if NEXT.datenum < D.datenum
      error(['images not in chronological order: #',num2str(ifile +1),' is before #',num2str(ifile)]);
   end
   
   h = pcolorcorcen(D.loncor,D.latcor,D.data);
   caxis(OPT.clim)
   colorbarwithtitle([D.producttex,' [',D.unitstex,']']);
   KMLfig2png(h,'fileName',[filename(D.filename),'.kml'],...
                    'kmlName',[D.product,' [',D.units,'] ',datestr(D.datenum,'yyyy-mmm-dd HH-MM-SS')],...
                     'levels',[-1 2],... % sufficient for 1 km resolution
                     'timeIn',D.datenum,...
                    'timeOut',NEXT.datenum); % stop with next image
                  
   D    = NEXT;

   if OPT.disp
   num2str([ifile toc])
   end

end
   
%% vectgorized inage is bad idea:
%  TOOOOOOOOOOOOOOO BIG (180 MB for one whole North Sea image)
   
   %KMLpcolor(D.loncor,D.latcor,D.data,...
   %          'fileName',[filename(noaapcfile),'.kml'],...
   %       'reversePoly',OPT.reversePoly,...
   %              'clim',OPT.clim,...
   %           'kmlName',[D.product,' [',D.units,']']);

%%EOF

