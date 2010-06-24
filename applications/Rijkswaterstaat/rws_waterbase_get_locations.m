function Station = rws_waterbase_get_locations(Code,CodeName,varargin)
%RWS_WATERBASE_GET_LOCATIONS   reads all avilable location info for 1 DONAR Substance
%
%    Station = rws_waterbase_get_locations(Code,CodeName)
%
% where Code = the Substance code as returned by getWaterbaseData_substances
% e.g. 22 for the following Substance code as returned by getWaterbaseData_substances
% e.g. 22 for :
%
% * FullName, e.g. "Significante golfhoogte uit energiespectrum van 30-500 mhz in cm in oppervlaktewater"
% * CodeName, e.g. 22%7CSignificante+golfhoogte+uit+energiespectrum+van+30-500+mhz+in+cm+in+oppervlaktewater"
% * Code    , e.g. 22
%
% Station struct has fields:
%
% * FullName, e.g. 'Aukfield platform'
% * ID      , e.g. 'AUKFPFM'
%
% See also: <a href="http://live.waterbase.nl">live.waterbase.nl</a>, rijkswaterstaat

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

% 2009 jan 27: removed from getWaterbaseData to separate function [Gerben de Boer]
% 2009 dec 28: adapted to new waterbase.nl html page [Gerben de Boer]
% 2010 jun 24: inserted new url live.waterbase.nl [Gerben de Boer]

   OPT.version  = 2; % 0 = local cache, 1 is before summer 2009, 2 is after mid dec 2009
   OPT.baseurl  = 'http://live.waterbase.nl';

%% load url

   if       OPT.version==0
     url = ['file:///' fileparts(mfilename('fullpath')) filesep 'locations.txt'];
   elseif   OPT.version==1
     url = [OPT.baseurl,'/getGML.cfm?wbwns=' sprintf('%d', Code)];
   elseif   OPT.version==2
     url = [OPT.baseurl,'/index.cfm?page=start.locaties&whichform=1&wbwns1=' sprintf('%s', CodeName) '&wbthemas=&search='];
   end

%% load locations data file   

   [s status] = urlread(url);
   if (status == 0)
       warndlg([OPT.baseurl,' may be offline or you are not connected to the internet','Online source not available']);
       close(h);
       OutputName = [];
       return;
   end
   
%% interpret locations data file   
%  change in html page after relaunch of waterbase.nl dec 2009

   if   OPT.version==1
     exprFullName = '<property typeName="FullName">[^<>]*</property>';
     sFullName    = regexp(s, exprFullName,'match');
     exprID       = '<property typeName="ID">[^<>]*</property>';
     sID = regexp(s, exprID,'match');
   elseif OPT.version==2
     exprFullName = '<option value="[^<>]*">[^<>]*</option>'; %'<property typeName="FullName">[^<>]*</property>';
     sFullName    = regexp(s, exprFullName,'match');
   end
   
   for iStation = 1:length(sFullName)
       sTemp                        = sFullName{iStation};
       if   OPT.version==1
         Station.FullName{iStation} = sTemp(31:end-11);
         sTemp                      = sID{iStation};
         Station.ID{iStation}       = sTemp(25:end-11);
       elseif OPT.version==2
         ind                        = strfind(sTemp,'"');
         Station.ID{iStation}       = sTemp(ind(1)+1:ind(2)-1);
         ind(1)                     = strfind(sTemp,'">');
         ind(2)                     = strfind(sTemp,'</');
         Station.FullName{iStation} = sTemp(ind(1)+2:ind(2)-1);
       end
   end
   
%% EOF
