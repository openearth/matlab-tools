function OutputName = rws_waterbase_get_url(varargin);
%RWS_WATERBASE_GET_URL   load data from <a href="http://www.waterbase.nl">www.waterbase.nl</a>
%
% Download data from the <a href="http://www.waterbase.nl">www.waterbase.nl</a> website for one specified
% substance at one or more specified locations during one specified
% year. All available data are written to a specified ASCII file.
%
% Without input arguments a GUI is launched.
%
%    rws_waterbase_get_url(<Code>    ) % or
%    rws_waterbase_get_url(<FullName>) % NOTE: NOT CodeName
%
% where Code or FullName are the unique DONAR numeric or string
% substance identifier respectively (e.g. 22 and 
% 'Significante golfhoogte uit energiespectrum van 30-500 mhz in cm in oppervlaktewater').
%
%    rws_waterbase_get_url( Code     ,<ID>)
%    rws_waterbase_get_url( FullName ,<ID>)
%
% where ID is  the unique DONAR string location identifier (e.g. 'AUKFPFM').
%
%    rws_waterbase_get_url( Code     ,ID,<datenum>)
%    rws_waterbase_get_url( FullName ,ID,<datenum>)
%
% where datenum is a 2 element vector with teh start and end time
% of the query in datenumbers (e.g. datenum([1961 2008],1,1)).
%
%    rws_waterbase_get_url( Code     ,ID,datenum,<FileName>)
%    rws_waterbase_get_url( FullName ,ID,datenum,<FileName>)
%
% where FileName is the name of the output file. When it is a directory
% the FileName will be chosen as DONAR does (with extension '.txt').
%
%    name = rws_waterbase_get_url(...) returns the local filename to which the data was written.
%
% Example:
%
%    rws_waterbase_get_url(22,'AUKFPFM',datenum([1961 2008],1,1),pwd)
%
% See web:  <a href="http://www.waterbase.nl">www.waterbase.nl</a>,
% See also: DONAR_READ, RWS_WATERBASE_GET_SUBSTANCES, RWS_WATERBASE_GET_LOCATIONS
%           RWS_WATERBASE_GET_URL_LOOP

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Y. Friocourt
%
%       yann.friocourt@deltares.nl
%
%       Deltares (former Delft Hydraulics)
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%   --------------------------------------------------------------------

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% 2009 mar 19: allow for selection of multiple years (all years between 1st and last) [Yann Friocourt]

% 2009 jan 27: moved pieces to separate functions getWaterbaseData_locations and getWaterbaseData_substances [Gerben de Boer]
% 2009 jan 27: allow for argument input of all chocie, to allow for batch running [Gerben de Boer]
% 2009 jan 27: use urlwrite for query of one location, as urlwrite often returns status=0 somehow [Gerben de Boer]
% 2009 apr 01: added 'exact' to strmatch to prevent finding more statiosn with similar subnames (e.g. MOOK and MOOKHVN)

%% Substance names

   OPT.strmatch = 'exact';
   OPT.version  = 2; % 1 is before summer 2009, 2 is after mid dec 2009

%% Substance names

   Substance = rws_waterbase_get_substances;
  %Substance = rws_waterbase_get_substances_csv('donar_substances.csv');

%% Select substance name

   if nargin>0
      indSub = varargin{1};
      if    isnumeric(indSub);indSub = find    (indSub==Substance.Code    );
      else ~isnumeric(indSub);indSub = strmatch(indSub, Substance.FullName);
      end
      ok        = 1;
   else
      [indSub, ok] = listdlg('ListString', Substance.FullName, .....
                          'SelectionMode', 'single', ...
                           'PromptString', 'Select the substance to download', ....
                                   'Name', 'Selection of substance',...
                               'ListSize', [500, 300]);
      if (ok == 0);OutputName = [];return;end
   end

   disp(['message: rws_waterbase_get_url: loading Substance # ',num2str(indSub                ,'%0.3d'),': ',...
                                                           num2str(Substance.Code(indSub),'%0.3d'),' "',...
                                                                   Substance.FullName{indSub},'"'])

%% Location names

   Station = rws_waterbase_get_locations(Substance.Code(indSub),Substance.CodeName{indSub});

%% Select Location names

   if nargin>1
      indLoc = varargin{2};
      if   ~isnumeric(indLoc);indLoc = strmatch(indLoc, Station.ID,OPT.strmatch);
      end
      ok     = 1;
   else
      [indLoc, ok] = listdlg('ListString', Station.FullName, ...
                          'SelectionMode', 'multiple', ...
                           'InitialValue', [1:length(Station.FullName)], ...
                           'PromptString', 'Select the locations', ....
                                   'Name', 'Selection of locations')
      if (ok == 0);OutputName = [];return;end
   end

   if length(indLoc)>1
   disp(['message: rws_waterbase_get_url: loading Location    ',num2str(length(indLoc),'%0.3d'),'x: #',num2str(indLoc(:)','%0.3d,')])
   else
   disp(['message: rws_waterbase_get_url: loading Location  # ',num2str(indLoc,'%0.3d'),': ',Station.ID{indLoc},' "',Station.FullName{indLoc},'"'])
   end

%% Times

   if nargin>2
      indDate   = varargin{3};
      startdate = [datestr(indDate(1),'yyyymmddHHMM')]; %,'01010000'];
      enddate   = [datestr(indDate(2),'yyyymmddHHMM')]; %,'12312359'];
      ok        = 1;
   else
      ListYear  = '1961';
      for iYear = 1962:str2num(datestr(date,'yyyy'))
          ListYear = strvcat(ListYear, sprintf('%d', iYear));
      end
      ListYear  = cellstr(ListYear);

      [indDate, ok] = listdlg('ListString', ListYear, ...
                           'SelectionMode', 'multiple', ...
                            'InitialValue', [length(ListYear)], ...
                            'PromptString', 'Select the year', ....
                                    'Name', 'Selection of year');

      if (ok == 0)
         OutputName = [];
         return;
      end
      startdate = [ListYear{min(indDate)} '01010000'];
      enddate   = [ListYear{max(indDate)} '12312359'];
   end

   disp(['message: rws_waterbase_get_url: loading startdate        ',startdate]);
   disp(['message: rws_waterbase_get_url: loading enddate          ',enddate]);

%% Select Times

   if nargin>3
      indName  = varargin{4};
      if exist(indName)==7
         FilePath = indName;
         FileName = ['id',num2str(Substance.Code(indSub)),'-',Station.ID{indLoc(1)},'-',startdate,'-',enddate,'.txt'];
      else
         [FilePath,FileName,EXT,VERSN] = fileparts(indName);
      end
   else
      [FileName, FilePath] = uiputfile('*.txt','Save data');
      if (isequal(FileName, 0));return;OutputName = [];end
   end

   disp(['message: rws_waterbase_get_url: loading file             ',fullfile(FilePath,FileName)]);
   
%% get data = f(Substance.Code, Station.ID, startdate, enddate

   OutputName = fullfile(FilePath,FileName);

%% Directly write file returned for one location

   if length(indLoc)==1

      iLoc = 1;

      if OPT.version==1
      urlName = ['http://www.waterbase.nl/Sites/waterbase/wbGETDATA.xitng?ggt=id' ...
             sprintf('%d', Substance.Code(indSub)) '&site=MIV&lang=nl&a=getData&gaverder=GaVerder&from=' ...
          startdate '&loc=' Station.ID{indLoc(iLoc)} '&to=' enddate '&fmt=text'];
          
      elseif OPT.version==2

      urlName = ['http://www.waterbase.nl/wswaterbase/cgi-bin/wbGETDATA?ggt=id' ...
             sprintf('%d', Substance.Code(indSub)) '&site=MIV&lang=nl&a=getData&gaverder=GaVerder&from=' ...
          startdate '&loc=' Station.ID{indLoc(iLoc)} '&to=' enddate '&fmt=text'];

     end

      %disp(urlName)

      [s status] = urlwrite([urlName],OutputName);

      if (status == 0)
        warndlg('www.waterbase.nl may be offline or you are not connected to the internet','Online source not available');
        close(h);

        return;
      end

   else

%% Pad multiple files returned for multiplelocations

      h = waitbar(0,'Downloading data...');

      fid = fopen(OutputName, 'w+');
      for iLoc = 1:length(indLoc)

            urlName = ['http://www.waterbase.nl/Sites/waterbase/wbGETDATA.xitng?ggt=id' ...
                   sprintf('%d', Substance.Code(indSub)) '&site=MIV&lang=nl&a=getData&gaverder=GaVerder&from=' ...
                startdate '&loc=' Station.ID{indLoc(iLoc)} '&to=' enddate '&fmt=text'];

            disp(urlName)

            [s status] = urlread([urlName]);
            if (status == 0)
              warndlg('www.waterbase.nl may be offline or you are not connected to the internet','Online source not available');
              close(h);

              return;
            end
            ind    = regexp(s, '\n');
            nLines = length(ind);
            if (iLoc == 1)
             for iLine = 1:6
              fprintf(fid, '%s', s(ind(iLine):ind(iLine+1)-1));
             end
            end
            if (length(regexp(s, 'Geen data beschikbaar')) == 0)
              for iLine = 7:nLines-1
                if (length(s(ind(iLine):ind(iLine+1)-1)) > 5)
                        fprintf(fid, '%s', s(ind(iLine):ind(iLine+1)-1));
                end
              end
            end

            waitbar(iLoc/length(indLoc),h)
         end
         close(h);

   end

%% EOF
