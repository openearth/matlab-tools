function OutputName = getWaterbaseData(varargin);
% GETWATERBASEDATA   load data from www.waterbase.nl
%
% Download data from the www.waterbase.nl website for one specified 
% substance at one or more specified locations during one specified 
% year. All available data are written in a specified ascii file.
%
% See also: DONAR_READ, www.waterbase.nl

% Version 1.0 October 2008
%
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

%% Substance names
%% ------------------------------------
   fid = fopen('donar_substances.csv', 'r+');
   s1   = fscanf(fid, '%c', [1 inf]);
   fclose(fid);
   IndLine               = regexp(s1, '\n');
   nSub                  = length(IndLine);
   IndSubs               =  regexp(s1(        1:IndLine(1)-1), ';');
   Substance.FullName{1} =         s1(        2:IndSubs   -2);
   Substance.CodeName{1} =         s1(IndSubs+2:IndLine(1)-2);
   IndCode               =  regexp(s1(IndSubs+1:IndLine(1)-1), '%');
   Substance.Code(1)     = str2num(s1(IndSubs+2:IndSubs+IndCode(1)-1));
   for iSub = 1:nSub-1
       IndSubs                    =  regexp(s1(IndLine(iSub)+1        :IndLine(iSub+1)                   -1), ';');
       Substance.FullName{iSub+1} =         s1(IndLine(iSub)+2        :IndLine(iSub  )+IndSubs           -2);
       Substance.CodeName{iSub+1} =         s1(IndLine(iSub)+IndSubs+2:IndLine(iSub+1)                   -2);
       IndCode                    =  regexp(s1(IndLine(iSub)+IndSubs+1:IndLine(iSub+1)                   -1), '%');
       Substance.Code(iSub+1)     = str2num(s1(IndLine(iSub)+IndSubs+2:IndLine(iSub  )+IndSubs+IndCode(1)-1));
   end

%% Select substance name
%% ------------------------------------
   if nargin>1
      indSub = varargin{1}; 
      ok     = 1;
   else
      [indSub, ok] = listdlg('ListString', Substance.FullName, .....
                          'SelectionMode', 'single', ...
                           'PromptString', 'Select the substance to download', ....
                                   'Name', 'Selection of substance',...
                               'ListSize', [500, 300]);
      
      if (ok == 0) 
          return;
      end
   end

%% Location names
%% ------------------------------------
   [s status] = urlread(['http://www.waterbase.nl/getGML.cfm?wbwns=' ...
       sprintf('%d', Substance.Code(indSub))]);
   if (status == 0)
       warndlg('www.waterbase.nl may be offline or you are not connected to the internet','Online source not available');
       close(h);
       return;
   end
   exprFullName = '<property typeName="FullName">[^<>]*</property>';
   sFullName    = regexp(s, exprFullName,'match');
   exprID       = '<property typeName="ID">[^<>]*</property>';
   sID = regexp(s, exprID,'match');
   for iStation = 1:length(sFullName)
       sTemp                      = sFullName{iStation};
       Station.FullName{iStation} = sTemp(31:end-11);
       sTemp                      = sID{iStation};
       Station.ID{iStation}       = sTemp(25:end-11);
   end

%% Select Location names
%% ------------------------------------
   if nargin>2
      indLoc = varargin{2}; 
      ok     = 1;
   else
      [indLoc, ok] = listdlg('ListString', Station.FullName, ...
                          'SelectionMode', 'multiple', ...
                           'InitialValue', [1:length(Station.FullName)], ...
                           'PromptString', 'Select the locations', ....
                                   'Name', 'Selection of locations');
      
      if (ok == 0) 
          return;
      end
   end
   
   %% Times
   %% ------------------------------------
   ListYear = '1961';
   for iYear = 1962:str2num(datestr(date,'yyyy'))
       ListYear = strvcat(ListYear, sprintf('%d', iYear));
   end
   ListYear = cellstr(ListYear);

%% Select Times
%% ------------------------------------
   if nargin>3
      indDate = varargin{3};
      ok     = 1;
   else
      [indDate, ok] = listdlg('ListString', ListYear, ...
                           'SelectionMode', 'single', ...
                            'InitialValue', [length(ListYear)], ...
                            'PromptString', 'Select the year', ....
                                    'Name', 'Selection of year');
      
      if (ok == 0) 
          return;
      end
   end
   
   startdate = [ListYear{indDate} '01010000'];
   enddate   = [ListYear{indDate} '12312359'];
   
   [FileName, FilePath] = uiputfile('*.txt','Save data');
   if (isequal(FileName, 0))
       return;
   end
   
   h = waitbar(0,'Downloading data...');

%% get data = f(Substance.Code, Station.ID, startdate, enddate
%% ------------------------------------
   fid = fopen([FilePath FileName], 'w+');
   for iLoc = 1:length(indLoc)
          [s status] = urlread(['http://www.waterbase.nl/Sites/waterbase/wbGETDATA.xitng?ggt=id' ...
              sprintf('%d', Substance.Code(indSub)) '&site=MIV&lang=nl&a=getData&gaverder=GaVerder&from=' ...
              startdate '&loc=' Station.ID{indLoc(iLoc)} '&to=' enddate '&fmt=text']);
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
      close  (h)
      fprintf(fid, '\n');
      fclose (fid);
   end
