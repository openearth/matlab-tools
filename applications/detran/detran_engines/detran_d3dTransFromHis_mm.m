function [namtra, xytra, transport, namsed]=avgTransFromHis_mm(type,filename,timeStep);
%DETRAN_D3DTRANSFROMHIS_MM Read transport through cross-sections from history files of mormerge Delft3D simulation
%
% Calculate averaged or instantaneous sediment transport through the cross sections in a history-file
% of a Delft3D mormerge simulation. The contribution of each condition to the resulting transport 
% is according to the weights in the mormerge-file (*.mm).
%
%   Syntax:
%   [crossName, crossXY, transport, namsed]=avgTransFromHis_mm(type,filename,timeStep);
%
%   Input:
%   type:       'mean' for mean transport or 'instant' for instantaneous transport.
%   filename:   full name (including path) of one of the trih-files, set to []
%               for interactive selection.
%   timeStep:   specify time step, set to 0 for last time step, set to []
%               for interactive selection
%
%   The directory with the simulations results should contain a sub-dir for each
%   condition with the results and a merge-directory where the *.mm file is
%   located. The weight factors in this file will be used.
%
%   NB: only for simulations with constant morfac!
%
%   Ouput:
%   crossName:  Char. array with the names of the cross sections
%   crossXY:    X,y-coordinates of the cross sections [M x 4]
%   transport:  Structure with total, bed and suspended transport rates through the cross sections in m3/s
%               Number of transport rates is determined by number of cross sections and number of fractions
%   namsed:     Char. array with names of the available sediment fractions
%
%   See also detran, detran_d3dTransFromHis_single, detran_d3dTransFromHis_multi, detran_d3dTrans_mm

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Arjan Mol
%
%       arjan.mol@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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

if isempty(filename)
    curDir = pwd;
    patName = uigetdir(pwd,'Please select map with simulation results');
else
    [patName]=fileparts(filename);
end

cd([patName '\merge']);
mergeFile = dir('*.mm');

if length(mergeFile) > 1
    disp('**** ERROR : please verify that only 1 mm-file is present...');
    return
end

merge=textread(mergeFile.name,'%s','delimiter','\n','headerlines',9);

weightFac = 0;

for ii= 1 : length(merge)
    [dum, temp]             = strtok(char(merge(ii)),'=');
    [tCondMap, tWeightFac]  = strtok(temp(2:end),':');
    condMap{ii}             = cellstr(tCondMap(~isspace(tCondMap)));
    weightFac(ii)           = str2num(tWeightFac(2:end));
end

weightFac = weightFac / sum (weightFac);

hW = waitbar(0,'Please wait...');

for ii = 1 : length(condMap)
    cd(['..\' char(condMap{ii})]);
    trihFile = dir('trih*.dat');

    for jj = 1 : length(trihFile)
        N = vs_use (trihFile(jj).name,'quiet');
        if ii==1
            if jj==1
                MORFT    = vs_let(N,'his-infsed-serie','MORFT','quiet');
                if nargin<3 | isempty(timeStep)
                    timeStep=str2num(char(inputdlg('Specify which time-step to use',[num2str(length(MORFT)) ' timesteps found, specify required time step:'],1,cellstr(num2str(length(MORFT)))));
                elseif timeStep == 0
                    timeStep = length(MORFT);
                end
                MORFAC    = vs_let(N,'his-infsed-serie',{1},'MORFAC','quiet');
                simLength = MORFT(timeStep)/MORFAC * 24 * 3600;
                morfStart = min (find(MORFT > 0))-1;
                namsed    = vs_get(N,'his-const','NAMSED','quiet');
                MNTRA     = vs_get(N,'his-const','MNTRA','quiet');
                XYTRA     = vs_get(N,'his-const','XYTRA','quiet');
                NAMTRA    = vs_get(N,'his-const','NAMTRA','quiet');
                MNTRA     = vs_get(N,'his-const','MNTRA','quiet');
            end
            transport{jj}.total= 0;
            transport{jj}.bed= 0;
            transport{jj}.suspended= 0;
        end
        if ~isempty(deblank(NAMTRA{jj}))
            switch type
                case 'mean'
                    SBTRC     = vs_let(N,'his-sed-series',{timeStep},'SBTRC','quiet') - vs_let(N,'his-sed-series',{morfStart},'SBTRC','quiet');
                    SSTRC     = vs_let(N,'his-sed-series',{timeStep},'SSTRC','quiet') - vs_let(N,'his-sed-series',{morfStart},'SSTRC','quiet');
                    transport{jj}.total     = squeeze(transport.total {jj} + weightFac(ii) .* (SSTRC + SBTRC) ./ simLength);
                    transport{jj}.bed       = squeeze(transport.bed {jj} + weightFac(ii) .* (SBTRC) ./ simLength);
                    transport{jj}.suspended = squeeze(transport.suspended {jj} + weightFac(ii) .* (SSTRC) ./ simLength);
                case 'instant'
                    SBTR     = vs_let(N,'his-sed-series',{timeStep},'SBTR','quiet');
                    SSTR     = vs_let(N,'his-sed-series',{timeStep},'SSTR','quiet');
                    transport{jj}.total      = squeeze(transport.total {jj} + weightFac(ii) .* (SSTR + SBTR));
                    transport{jj}.bed        = squeeze(transport {jj}.bed + weightFac(ii) .* (SBTR));
                    transport{jj}.suspended  = squeeze(transport {jj}.suspended + weightFac(ii) .* (SSTR));
            end
        end
    end
    waitbar(ii/length(condMap),hW);
end

close(hW);
cd(curDir);

% sign correction (make it independend of grid direction, but dependend to transect direction)
MTRA=MNTRA(1:2:end,:);
NTRA=MNTRA(2:2:end,:);
signCor=repmat([sign(diff(MTRA))-sign(diff(NTRA))]',1,size(transport{1}.total,2)); % check if m1 > m2 or n2 > n1 for certain transect, than change sign of calculated transport

for jj=1:length(transport)
    transport{jj}.total=[signCor.*transport{jj}.total]';
    transport{jj}.bed=[signCor.*transport{jj}.bed]';
    transport{jj}.suspended=[signCor.*transport{jj}.suspended]';
end
