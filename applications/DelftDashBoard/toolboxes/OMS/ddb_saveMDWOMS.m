function ddb_saveMDWOMS(handles)
%DDB_SAVEMDWOMS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_saveMDWOMS(handles)
%
%   Input:
%   handles =
%
%
%
%
%   Example
%   ddb_saveMDWOMS
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
runid=handles.Toolbox(tb).Runid;

fid=fopen([runid '.mdw'],'wt');

fprintf(fid,'%s\n','[WaveFileInformation]');
fprintf(fid,'%s\n','   FileVersion = 02.00');
fprintf(fid,'%s\n','[General]');
fprintf(fid,'%s\n','   ProjectName      = ');
fprintf(fid,'%s\n','   ProjectNr        = ');
fprintf(fid,'%s\n','   Description1     = ');
fprintf(fid,'%s\n','   Description2     = ');
fprintf(fid,'%s\n','   Description3     = ');
fprintf(fid,'%s\n','   ReferenceDate    = ITDATEKEY');
fprintf(fid,'%s\n','   DirConvention    = nautical');
fprintf(fid,'%s\n','   SimMode          = non-stationary');
fprintf(fid,'%s\n','   TimeStep         = 30');
fprintf(fid,'%s\n','   OnlyInputVerify  = false');
fprintf(fid,'%s\n','   DirSpace         = circle');
fprintf(fid,'%s\n','   NDir             = 36');
fprintf(fid,'%s\n','   FreqMin          = 5.0000001e-002');
fprintf(fid,'%s\n','   FreqMax          = 1.0000000e+000');
fprintf(fid,'%s\n','   NFreq            = 24');
fprintf(fid,'%s\n','   TimePoint        = 0.0000000e+000');
fprintf(fid,'%s\n','   WaterLevel       = 0.0000000e+000');
fprintf(fid,'%s\n','   XVeloc           = 0.0000000e+000');
fprintf(fid,'%s\n','   YVeloc           = 0.0000000e+000');
fprintf(fid,'%s\n','   WindSpeed        = 6.0000000e+000');
fprintf(fid,'%s\n','   WindDir          = 3.3000000e+002');
fprintf(fid,'%s\n','   HotFileID        = HOTFILEKEY');
fprintf(fid,'%s\n','[Constants]');
fprintf(fid,'%s\n','   Gravity          = 9.8100004e+000');
fprintf(fid,'%s\n','   WaterDensity     = 1.0250000e+003');
fprintf(fid,'%s\n','   NorthDir         = 9.0000000e+001');
fprintf(fid,'%s\n','   MinimumDepth     = 5.0000001e-002');
fprintf(fid,'%s\n','[Processes]');
fprintf(fid,'%s\n','   GenModePhys      = 3');
fprintf(fid,'%s\n','   WaveSetup        = false');
fprintf(fid,'%s\n','   WaveForces       = dissipation');
fprintf(fid,'%s\n','   Breaking         = true');
fprintf(fid,'%s\n','   BreakAlpha       = 1.0000000e+000');
fprintf(fid,'%s\n','   BreakGamma       = 7.3000002e-001');
fprintf(fid,'%s\n','   BedFriction      = jonswap');
fprintf(fid,'%s\n','   BedFricCoeff     = 6.7000002e-002');
fprintf(fid,'%s\n','   Triads           = false');
fprintf(fid,'%s\n','   Diffraction      = false');
fprintf(fid,'%s\n','   WindGrowth       = true');
fprintf(fid,'%s\n','   WhiteCapping     = 2 <------- 0: off, 1: on, 2: WESTHuysen variant of GenModePhys=3');
fprintf(fid,'%s\n','   Quadruplets      = true');
fprintf(fid,'%s\n','   Refraction       = true');
fprintf(fid,'%s\n','   FreqShift        = true');
fprintf(fid,'%s\n','[Numerics]');
fprintf(fid,'%s\n','   DirSpaceCDD      = 5.0000000e-001');
fprintf(fid,'%s\n','   FreqSpaceCSS     = 5.0000000e-001');
fprintf(fid,'%s\n','   RChHsTm01        = 2.0000000e-002');
fprintf(fid,'%s\n','   RChMeanHs        = 2.0000000e-002');
fprintf(fid,'%s\n','   RChMeanTm01      = 2.0000000e-002');
fprintf(fid,'%s\n','   PercWet          = 9.8000000e+001');
fprintf(fid,'%s\n','   MaxIter          = 1');
fprintf(fid,'%s\n','[Output]');
fprintf(fid,'%s\n','   TestOutputLevel  = 0');
fprintf(fid,'%s\n','   TraceCalls       = false');
fprintf(fid,'%s\n','   UseHotFile       = true');
fprintf(fid,'%s\n','   MapWriteInterval = DTCOMKEY');
fprintf(fid,'%s\n','   WriteCOM         = true');
fprintf(fid,'%s\n','   COMWriteInterval = DTCOMKEY');
fprintf(fid,'%s\n','   Int2KeepHotfile  = HOTINTKEY');
fprintf(fid,'%s\n',['   FlowGrid         = ' handles.Toolbox(tb).ShortName '.grd']);
fprintf(fid,'%s\n','   LocationFile     = LOC001KEY');
fprintf(fid,'%s\n','   LocationFile     = LOC002KEY');
fprintf(fid,'%s\n','   LocationFile     = LOC003KEY');
fprintf(fid,'%s\n','   LocationFile     = LOC004KEY');
fprintf(fid,'%s\n','   LocationFile     = LOC005KEY');
fprintf(fid,'%s\n','   LocationFile     = LOC006KEY');
fprintf(fid,'%s\n','   WriteSpec1D      = true');
fprintf(fid,'%s\n','   WriteSpec2D      = true');
fprintf(fid,'%s\n','[Domain]');
fprintf(fid,'%s\n',['   Grid             = ' handles.Toolbox(tb).ShortName '_swn.grd']);
fprintf(fid,'%s\n',['   BedLevel         = ' handles.Toolbox(tb).ShortName '_swn.dep']);
fprintf(fid,'%s\n','   FlowWaterLevel   = 1');
fprintf(fid,'%s\n','   FlowBedLevel     = 1');
fprintf(fid,'%s\n','   FlowWind         = 1');
fprintf(fid,'%s\n','[Boundary]');
fprintf(fid,'%s\n','   Definition       = fromsp2file');
fprintf(fid,'%s\n',['   OverallSpecFile  = ' handles.Toolbox(tb).ShortName '.sp2']);

fclose(fid);

