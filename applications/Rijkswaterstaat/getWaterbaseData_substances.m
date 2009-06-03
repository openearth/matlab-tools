function Substance = getWaterbaseData_substances(fname)
%GETWATERBASEDATA_SUBSTANCES   reads 'donar_substances.csv'
%
% Substance = getWaterbaseData_substances(<fname.csv>)
%
% where by default <fname.csv> = 'donar_substances.csv'
%
% Substance struct has fields:
%
% * FullName, e.g. "Significante golfhoogte uit energiespectrum van 30-500 mhz in cm in oppervlaktewater"
% * CodeName, e.g. 22%7CSignificante+golfhoogte+uit+energiespectrum+van+30-500+mhz+in+cm+in+oppervlaktewater"
% * Code    , e.g. 22
%
% See also: DONAR_READ, <a href="http://www.waterbase.nl">www.waterbase.nl</a>, GETWATERBASEDATA, GETWATERBASEDATA_LOCATIONS

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

%% load substances data file
   if nargin==0
      fname = 'donar_substances.csv';
   end

   fid = fopen(fname, 'r+');
   s1   = fscanf(fid, '%c', [1 inf]);
   fclose(fid);
   
%% interpret substances data file
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
   
%% EOF   