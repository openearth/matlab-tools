function d3dTransData=detran_d3dTrans_mm(type,filename,timeStep,save);
%DETRAN_D3DTRANS_MM Read u,v-transport data from mormerge Delft3D simulation
%
% Calculate averaged or instantaneous sediment transport (u-comp & v-comp) of a Delft3D
% mormerge simulation. The contribution of each condition to the resulting transport is according
% to the weights in the mormerge-file (*.mm).
%
%   Syntax:
%   d3dTransData=detran_d3dTrans_mm(type,filename,timeStep,save);
%
%   Input:
%   type:       'mean' for mean transport or 'instant' for instantaneous transport.
%   filename:   full name (including path) of one of the trim-files, set to []
%               for interactive selection.
%   timeStep:   specify time step, set to 0 for last time step, set to []
%               for interactive selection
%   save        set to 1 for saving output to a mat-file (optional).
%
%   The directory with the simulations results should contain a sub-dir for each
%   condition with the results and a merge-directory where the *.mm file is
%   located. The weight factors in this file will be used.
%
%   NB: only for simulations with constant morfac!
%
%   Ouput:
%   d3dTransData: structure with the followin fields:
%                 xcor    = x-coordinates of model grid
%                 ycor    = y-coordinates of model grid
%                 alfa    = orientation m-axis w.r.t x-axis (degrees)
%                 tsu     = avg. suspended sediment transport in u-direction
%                 tsv     = avg. suspended sediment transport in v-direction
%                 tbu     = avg. bedload sediment transport in u-direction
%                 tbv     = avg. bedload sediment transport in v-direction
%                 tsuPlus = gross positive avg. suspended sediment transport in u-direction
%                 tsuMin  = gross negative avg. suspended sediment transport in u-direction
%                 tsvPlus = gross positive avg. suspended sediment transport in v-direction
%                 tsvMin  = gross negative avg. suspended sediment transport in v-direction
%                 tbuPlus = gross positive avg. bedload sediment transport in u-direction
%                 tbuMin  = gross negative avg. bedload sediment transport in u-direction
%                 tbvPlus = gross positive avg. bedload sediment transport in v-direction
%                 tbvMin  = gross negative avg. bedload sediment transport in v-direction
%
%                 All output transports are in m3/s!
%
%   See also detran, detran_d3dTrans_single, detran_d3dTrans_multi, detran_d3dTransFromHis_mm

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

if nargin<4
    save=0;
end

switch type
    case 'mean'
        series='map-avg-series';
        postfix='A';
    case 'instant'
        series='map-sed-series';
        postfix='';
end

if isempty(filename)
    curDir = pwd;
    patName = uigetdir(pwd,'Please select map with simulation results');
else
    [patName]=fileparts(filename);
end

if patName ==0
    return
else
    cd([patName '\merge']);
end

mergeFile = dir('*.mm');

if length(mergeFile) > 1
    disp('**** ERROR : please verify that only 1 mm-file is present...');
    return
end

fid=fopen(mergeFile.name);
merge2=fread(fid,'char');
lines=find(merge2==10);
if isempty(lines)
    lines=find(merge2==13);
end
firstLine=findstr(char(merge2'),'condition:');
headerLines=max(find(firstLine(1)>lines));
merge=textread(mergeFile.name,'%s','delimiter','\n','headerlines',headerLines);

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
    trimFile = dir('trim*.dat');
    
    for jj = 1 : length(trimFile)
        N = vs_use (trimFile(jj).name,'quiet');
        grpDatNr=find(strcmp({N.GrpDat.Name},series));
        if ii==1&jj==1
            if timeStep == 0;
                lastTimeStep = N.GrpDat(grpDatNr).SizeDim;
            elseif isempty(timeStep)
                lastTimeStep=str2num(char(inputdlg('Specify which time-step to use',[num2str(N.GrpDat(grpDatNr).SizeDim) ' timesteps found, specify required time step:'],1,cellstr(num2str(N.GrpDat(grpDatNr).SizeDim)))));
                if isempty(lastTimeStep)
                    return
                end
            else
                lastTimeStep = timeStep;
            end
        end
        sbuua = weightFac(ii) * vs_get(N,series,{lastTimeStep},['SBUU' postfix],'quiet');
        sbvva = weightFac(ii) * vs_get(N,series,{lastTimeStep},['SBVV' postfix],'quiet');
        ssuua = weightFac(ii) * vs_get(N,series,{lastTimeStep},['SSUU' postfix],'quiet');
        ssvva = weightFac(ii) * vs_get(N,series,{lastTimeStep},['SSVV' postfix],'quiet');
        
        if ii == 1
            d3dTransData.namSed {jj} = vs_get(N,'map-const','NAMSED','quiet');
            d3dTransData.xcor   {jj} = vs_get(N,'map-const','XCOR','quiet');
            d3dTransData.ycor   {jj} = vs_get(N,'map-const','YCOR','quiet');
            d3dTransData.alfa   {jj} = vs_get(N,'map-const','ALFAS','quiet');
            d3dTransData.tsu    {jj}= 0;
            d3dTransData.tsv    {jj}= 0;
            d3dTransData.tbu    {jj}= 0;
            d3dTransData.tbv    {jj}= 0;
            d3dTransData.tsuPlus{jj} = zeros(size(d3dTransData.xcor{jj}));
            d3dTransData.tsuMin {jj} = zeros(size(d3dTransData.xcor{jj}));
            d3dTransData.tsvPlus{jj} = zeros(size(d3dTransData.xcor{jj}));
            d3dTransData.tsvMin {jj} = zeros(size(d3dTransData.xcor{jj}));
            d3dTransData.tbuPlus{jj} = zeros(size(d3dTransData.xcor{jj}));
            d3dTransData.tbuMin {jj} = zeros(size(d3dTransData.xcor{jj}));
            d3dTransData.tbvPlus{jj} = zeros(size(d3dTransData.xcor{jj}));
            d3dTransData.tbvMin {jj} = zeros(size(d3dTransData.xcor{jj}));
        end
        
        d3dTransData.tsu {jj} = d3dTransData.tsu {jj} + ssuua;
        d3dTransData.tsv {jj} = d3dTransData.tsv {jj} + ssvva;
        d3dTransData.tbu {jj} = d3dTransData.tbu {jj} + sbuua;
        d3dTransData.tbv {jj} = d3dTransData.tbv {jj} + sbvva;
        
        d3dTransData.tbuPlus{jj}(sbuua > 0) = d3dTransData.tbuPlus{jj}(sbuua > 0) + sbuua(sbuua > 0);
        d3dTransData.tbuMin {jj}(sbuua < 0) = d3dTransData.tbuMin {jj}(sbuua < 0) + sbuua(sbuua < 0);
        d3dTransData.tsuPlus{jj}(ssuua > 0) = d3dTransData.tsuPlus{jj}(ssuua > 0) + ssuua(ssuua > 0);
        d3dTransData.tsuMin {jj}(ssuua < 0) = d3dTransData.tsuMin {jj}(ssuua < 0) + ssuua(ssuua < 0);
        d3dTransData.tbvPlus{jj}(sbvva > 0) = d3dTransData.tbvPlus{jj}(sbvva > 0) + sbvva(sbvva > 0);
        d3dTransData.tbvMin {jj}(sbvva < 0) = d3dTransData.tbvMin {jj}(sbvva < 0) + sbvva(sbvva < 0);
        d3dTransData.tsvPlus{jj}(ssvva > 0) = d3dTransData.tsvPlus{jj}(ssvva > 0) + ssvva(ssvva > 0);
        d3dTransData.tsvMin {jj}(ssvva < 0) = d3dTransData.tsvMin {jj}(ssvva < 0) + ssvva(ssvva < 0);
        
    end
    waitbar(ii/length(condMap),hW);
end

close(hW);

if isempty(filename)
    d3dTransData.runID = condMap;
else
    d3dTransData.runID = filename;
end

cd(curDir);

if save==1
    [nam pat]=uiputfile('d3dTrans.mat','Save file as');
    save([pat nam],'d3dTransData');
end