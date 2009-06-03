function Station = getWaterbaseData_locations(Code)
%GETWATERBASEDATA_LOCATIONS   reads all avilable location info for 1 DONAR Substance
%
% Station = getWaterbaseData_locations(Code)
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
% See also: DONAR_READ, <a href="http://www.waterbase.nl">www.waterbase.nl</a>, GETWATERBASEDATA, GETWATERBASEDATA_SUBSTANCES

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

%% load locations data file   
   [s status] = urlread(['http://www.waterbase.nl/getGML.cfm?wbwns=' ...
       sprintf('%d', Code)]);
   if (status == 0)
       warndlg('www.waterbase.nl may be offline or you are not connected to the internet','Online source not available');
       close(h);
       OutputName = [];
       return;
   end
   
%% interpret locations data file   
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
   
%% EOF   