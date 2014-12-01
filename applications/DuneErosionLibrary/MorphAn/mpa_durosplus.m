function result = mpa_durosplus(varargin)
%MPA_DUROSPLUS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = mpa_durosplus(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   mpa_durosplus
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       P.O. 177
%       2600 MH Delft
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 04 Mar 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% TODO
% implement:
%
% OutputFlagWaterLevelAboveProfile: 0
% OutputFlagNotEnoughProfileInformationLandward: 0
% OutputFlagNotEnoughProfileInformationSeaward: 0
% OutputFlagNoErosion: 0
% OutputFlagNoAdditionalErosion: 0
% OutputFlagDuneBreach: 0
% OutputFlagCorrectedForLandwardTransport: 0
% OutputFlagSolutionInfluencedByChannelSlope: 0
% OutputFlagPrecisionNotMet: 0
% OutputFlagNoSolutionPossible: 0

%% Initiate variables
% In this step the input is verified. If one of the input arguments is not
% defined, a default value is used:
% 
% # xInitial    - The x-coordinates of the reference profile of the Dutch
%                   coast.
% # zInitial    - The z-coordinates of the reference profile of the Dutch
%                   coast.
% # D50         - The grain diameter. (default 225 [mu])
% # WL_t        - The water level (default 5 [m])
% # Hsig_t      - The significant wave height (default 9 [m])
% # Tp_t        - The peak wave period (default 12 [s])
%
% Next to the input parameters also some settings are obtained from
% _DuneErosionSettings_.
%

if isempty(getappdata(0,'MorphAnCSharpLibInitialized'))
    mpa_loadcsharp;
end

%% check and inventorise input
OPT = struct(...
    'xInitial', [-250 -24.375 5.625 55.725 230.625 1950]',...
    'zInitial', [15 15 3 0 -3 -14.4625]',...
    'D50', 225e-6,...
    'WL_t', 5,...
    'Hsig_t', 9,...
    'Tp_t', 12);

[xInitial zInitial D50 WL_t Hsig_t Tp_t] = parseDUROSinput(OPT, varargin{:});

%% Run MorphAn
morphAnInput = DeltaShell.Plugins.MorphAn.TRDA.Calculators.TRDAInputParameters;
morphAnInput.D50 = D50;
morphAnInput.SignificantWaveHeight = Hsig_t;
morphAnInput.PeakPeriod = Tp_t;
morphAnInput.MaximumStormSurgeLevel = WL_t;
morphAnInput.G0 = getG0(DuneErosionSettings('get','Bend')); % To work similar to the matlab implementation
morphAnInput.MaximumRetreatDistance = DuneErosionSettings('get','maxRetreat'); % To work similar to the matlab implementation
morphAnInput.UsePeakPeriod = true;
morphAnInput.AutoCorrectPeakPeriod = DuneErosionSettings('get','TP12slimiter');
morphAnInput.MaximumNumberOfIterations = DuneErosionSettings('get','maxiter');

morphAnInput.DurosMethod = DeltaShell.Plugins.MorphAn.TRDA.Calculators.DurosMethod.DurosPlus;

% This takes some time. To optimize probabilistics do this once...
morphAnInput.InputProfile = DeltaShell.Plugins.MorphAn.Domain.Transect(...
    NET.convertArray(xInitial, 'System.Double'),...
    NET.convertArray(zInitial, 'System.Double'));

TVolumeFunction = DuneErosionSettings('get','AdditionalVolume'); % function should accept a double as input (A volume) and a double (T volume) as output

if ~ischar(TVolumeFunction)
    morphAnResult = DeltaShell.Plugins.MorphAn.TRDA.CoastalSafetyAssessment.AssessDuneProfile(morphAnInput,TVolumeFunction);
else
    % assume default and use default factor. It is also possible to
    % specify a factor that differs from 0.25. Use the input property
    % TargetVolumeCalculationFactor for that purpose
    morphAnResult = DeltaShell.Plugins.MorphAn.TRDA.CoastalSafetyAssessment.AssessDuneProfile(morphAnInput);
end

%% Step 1
result = fillresultwithprofile(createEmptyDUROSResult,...
    morphAnResult.OutputDurosPreProfile,...
    morphAnResult.OutputDurosProfile,...
    xInitial,zInitial);

result.VTVinfo.Xr = morphAnResult.OutputPointRDuros.X;
result.VTVinfo.Zr = morphAnResult.OutputPointRDuros.Z;
result.VTVinfo.Xp = morphAnResult.OutputPointPDuros.X;
result.VTVinfo.Zp = morphAnResult.OutputPointPDuros.Z;
result.Volumes.Volume = morphAnResult.OutputTotalErosionVolume;%????
result.info.ID = 'MorphAn DUROS+';
result.info.iter = morphAnResult.OutputDurosNrIterations;
result.info.precision = morphAnResult.OutputDurosCalculationPrecision;
result.info.x0 = result.VTVinfo.Xp;

result.info.input = struct(...
    'D50', morphAnInput.D50,...
    'WL_t', morphAnInput.MaximumStormSurgeLevel,...
    'Hsig_t', morphAnInput.SignificantWaveHeight,...
    'Tp_t', morphAnInput.PeakPeriod,...
    'Bend', []); % morphAnInput.G0

%% Step 2 (Erosion above storm surge level)
result(end+1) = fillresultwithprofile(createEmptyDUROSResult,...
    morphAnResult.OutputAVolumePreProfile,...
    morphAnResult.OutputAVolumeProfile,...
    xInitial,zInitial);
result(end).VTVinfo.AVolume = morphAnResult.OutputErosionVolumeAboveStormSurgeLevel;
result(end).Volumes.Erosion = morphAnResult.OutputErosionVolumeAboveStormSurgeLevel;
result(end).Volumes.Accretion = 0;
result(end).Volumes.Volume = morphAnResult.OutputErosionVolumeAboveStormSurgeLevel;
result(end).info.ID = 'DUROS-plus Erosion above SSL';
result(end).info.resultinboundaries = true;

%% Step 3 (Erosion due to coastal bend)
if ~isempty(morphAnResult.OutputBendErosionProfile)
    result(end+1) = fillresultwithprofile(createEmptyDUROSResult,...
        morphAnResult.OutputBendErosionPreProfile,...
        morphAnResult.OutputBendErosionProfile,...
        xInitial,zInitial);

    result(end).VTVinfo.Xr = morphAnResult.OutputPointRBendErosion.X;
    result(end).VTVinfo.Zr = morphAnResult.OutputPointRBendErosion.Z;
    result(end).VTVinfo.Xp = morphAnResult.OutputPointPBendErosion.X;
    result(end).VTVinfo.Zp = morphAnResult.OutputPointPBendErosion.Z;
    result(end).VTVinfo.G = morphAnResult.OutputBendErosionVolume;
end

%% Step 4 (Additional erosion)
result(end+1) = fillresultwithprofile(createEmptyDUROSResult,...
    morphAnResult.OutputAdditionalErosionPreProfile,...
    morphAnResult.OutputAdditionalErosionProfile,...
    xInitial,zInitial);

result(end).VTVinfo.Xr = morphAnResult.OutputPointR.X;
result(end).VTVinfo.Zr = morphAnResult.OutputPointR.Z;
result(end).VTVinfo.Xp = morphAnResult.OutputPointP.X;
result(end).VTVinfo.Zp = morphAnResult.OutputPointP.Z;
result(end).VTVinfo.TVolume = morphAnResult.OutputAdditionalErosionVolume;
result(end).Volumes.Erosion = morphAnResult.OutputAdditionalErosionVolume;
result(end).Volumes.Volume = morphAnResult.OutputAdditionalErosionVolume;
result(end).info.ID = 'Additional Erosion';

%% Step 5 (Boundary profile)
% result(end+1) = fillresultwithprofile(createEmptyDUROSResult,...
%     morphAnResult.OutputBoundaryPreProfile,...
%     morphAnResult.OutputBoundaryProfile,...
%     xInitial,zInitial);
% 
% result(end).Volumes.Volume = morphAnResult.OutputBoundaryProfileVolume;
% result(end).info.ID = 'Boundary Profile';

end


function result = fillresultwithprofile(result,morphAnPreProfile,morpAnProfile,xInitial,zInitial)
profile = crossshoreprofile2matlabprofile(morpAnProfile);
preProfile = crossshoreprofile2matlabprofile(morphAnPreProfile);



result.xActive = unique([profile(:,1);preProfile(:,1)]);
result.z2Active = interp1(profile(:,1),profile(:,2),result.xActive );
result.zActive = interp1(preProfile(:,1),preProfile(:,2),result.xActive );

result.xLand = xInitial(xInitial < min(result.xActive));
result.zLand = zInitial(xInitial < min(result.xActive));
result.xSea = xInitial(xInitial > max(result.xActive));
result.zSea = zInitial(xInitial > max(result.xActive));
end

function profile = crossshoreprofile2matlabprofile(morphAnProfile)
x = double(morphAnProfile.XCoordinates)';
z = double(morphAnProfile.ZCoordinates)';
profile = [x,z];
end