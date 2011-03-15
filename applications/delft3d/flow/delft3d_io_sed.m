function varargout = delft3d_io_sed(fname)
%DELFT3D_IO_SED   load delft3d online sed *.sed keyword file 
%
%  D   = DELFT3D_IO_SED(fname)
% 
% loads contents of *.sed file into struct D
%
%  [D,U]   = DELFT3D_IO_SED(fname)
%  [D,U,M] = DELFT3D_IO_SED(fname)
%
% optionally loads units and meta-info into structs U and M.
%
%See also: delft3d, inivalue

%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Gerben de Boer
%
%       <g.j.deboer@deltares.nl>
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

OPT.commentchar = '*';

INI = inivalue(fname,OPT);

Chapters = fieldnames(INI);
nChapter = length(Chapters);

for iChapter = 1:nChapter

   Chapter  = Chapters{iChapter};
   Keywords = fieldnames(INI.(Chapter));
   nKeyword = length(Keywords);
   
   for iKeyword = 1:nKeyword
      Keyword   = Keywords{iKeyword};
      ValueLine = INI.(Chapter).(Keyword);
      if ischar(ValueLine)
      ValueLine    = strtrim(ValueLine);
      end
      
      if strcmpi(Chapter,'SedimentFileInformation');
         Value   = ValueLine;
         Comment = '';
      else
        [Value,Comment] = strtok(ValueLine);
        
         Value = strtrim(Value);
         
         if strcmp(Value(1),'#')
            ind = strfind(Value,'#');
            if length(ind)==2
             Value = Value(ind(1)+1:ind(2)-1);
            else
             error('string contains not two #')
            end
         else
            if ~isempty(str2num(Value))
              Value = str2num(Value);
            end
         end
      end
      
      i0 = strfind(Comment,'[');
      i1 = strfind(Comment,']');
     
         unit    = '';
      if length(i0)>0 & length(i1)>0 
         unit    = Comment(i0(1)+1:i1(1)-1);
         Comment = Comment(i1(1)+1:end);
      end
      
      DATA.(Chapter).(Keyword) = Value;
      UNIT.(Chapter).(Keyword) = unit;
      META.(Chapter).(Keyword) = strtrim(Comment);
      
   end
   
end

if nargout==1
   varargout = {DATA};
elseif nargout==2
   varargout = {DATA,UNIT};
else
   varargout = {DATA,UNIT,META};
end

%[SedimentFileInformation]
%   FileCreatedBy    = Delft3D-FLOW-GUI, Version: 3.39.15.00         
%   FileCreationDate = Mon Nov 06 2006, 13:45:07         
%   FileVersion      = 02.00                        
%[SedimentOverall]
%   Cref             = 1.6000000e+003       [kg/m3]  CSoil Reference density for hindered settling calculations
%   IopSus           = 0                             Suspended sediment size is Y/N calculated dependent on d50         
%[Sediment]
%   Name             = #Sediment1#                   Name as specified in NamC in md-file
%   SedTyp           = mud                           Must be "sand", "mud" or "bedload"
%   RhoSol           = 2.6500000e+003       [kg/m3]  Density
%   SedDia           = 1.9999999e-004       [m]      Median sediment diameter (D50)
%   CDryB            = 5.0000000e+002       [kg/m3]  Dry bed density
%   SdBUni           = 0.0000000e+000       [kg/m2]  Initial sediment mass at bed per unit area  (uniform value or file name)
%   FacDSS           = 1.0000000e+000       [-]      FacDss * SedDia = Initial suspended sediment diameter. range [0.6 - 1.0]
%   SalMax           = 0.0000000e+000       [ppt]    Salinity for saline settling velocity
%   WS0              = 3.0000000e-005       [m/s]    Settling velocity fresh water
%   WSM              = 3.0000000e-005       [m/s]    Settling velocity saline water
%   TcrSed           = 9.9999997e-006       [N/m2]   Critical stress for sedimentation (uniform value or file name)
%   TcrEro           = 1.0000000e+002       [N/m2]   Critical stress for erosion       (uniform value or file name)
%   EroPar           = 9.9999997e-005       [kg/m2s] Erosion parameter                 (uniform value or file name)
