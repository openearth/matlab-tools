function handles = ddb_initializeFlowDomain(handles, opt, id, runid)
%DDB_INITIALIZEFLOWDOMAIN  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_initializeFlowDomain(handles, opt, id, runid)
%
%   Input:
%   handles =
%   opt     =
%   id      =
%   runid   =
%
%   Output:
%   handles =
%
%   Example
%   ddb_initializeFlowDomain
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
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%

handles.Model(md).Input(id).runid=runid;

switch lower(opt)
    case{'griddependentinput'}
        handles=ddb_initializeGridDependentInput(handles,id);
    case{'all'}
        handles=ddb_initializeGridDependentInput(handles,id);
        handles=ddb_initializeOtherInput(handles,id,runid);
end

%%
function handles=ddb_initializeGridDependentInput(handles,id)

handles.Model(md).Input(id).grid=[];
handles.Model(md).Input(id).bathy=[];

handles.Model(md).Input(id).nrDischarges=0;

%% Observation points
handles.Model(md).Input(id).nrObservationPoints=0;
handles.Model(md).Input(id).activeObservationPoint=1;
handles.Model(md).Input(id).observationPointNames={''};
handles.Model(md).Input(id).activeObservationPoint=1;
handles.Model(md).Input(id).observationPoints(1).name='';
handles.Model(md).Input(id).observationPoints(1).M=[];
handles.Model(md).Input(id).observationPoints(1).N=[];
handles.Model(md).Input(id).addObservationPoint=0;
handles.Model(md).Input(id).selectObservationPoint=0;
handles.Model(md).Input(id).deleteObservationPoint=0;
handles.Model(md).Input(id).changeObservationPoint=0;

%% Discharges
handles.Model(md).Input(id).nrDischarges=0;
handles.Model(md).Input(id).activeDischarge=1;
handles.Model(md).Input(id).dischargeNames={''};
handles.Model(md).Input(id).discharges(1).name='';
handles.Model(md).Input(id).discharges(1).M=[];
handles.Model(md).Input(id).discharges(1).N=[];
handles.Model(md).Input(id).discharges(1).K=[];
handles.Model(md).Input(id).discharges(1).outM=[];
handles.Model(md).Input(id).discharges(1).outN=[];
handles.Model(md).Input(id).discharges(1).outK=[];
handles.Model(md).Input(id).discharges(1).interpolation='linear';
handles.Model(md).Input(id).discharges(1).type='normal';
handles.Model(md).Input(id).addDischarge=0;
handles.Model(md).Input(id).selectDischarge=0;
handles.Model(md).Input(id).deleteDischarge=0;
handles.Model(md).Input(id).changeDischarge=0;

%% Cross sections
handles.Model(md).Input(id).nrCrossSections=0;
handles.Model(md).Input(id).crossSectionNames={''};
handles.Model(md).Input(id).activeCrossSection=1;
handles.Model(md).Input(id).crossSections(1).name='';
handles.Model(md).Input(id).crossSections(1).M1=[];
handles.Model(md).Input(id).crossSections(1).M2=[];
handles.Model(md).Input(id).crossSections(1).N1=[];
handles.Model(md).Input(id).crossSections(1).N2=[];
handles.Model(md).Input(id).addCrossSection=0;
handles.Model(md).Input(id).selectCrossSection=0;
handles.Model(md).Input(id).deleteCrossSection=0;
handles.Model(md).Input(id).changeCrossSection=0;

%% Dry points
handles.Model(md).Input(id).nrDryPoints=0;
handles.Model(md).Input(id).dryPointNames={''};
handles.Model(md).Input(id).activeDryPoint=1;
handles.Model(md).Input(id).dryPoints(1).M1=[];
handles.Model(md).Input(id).dryPoints(1).M2=[];
handles.Model(md).Input(id).dryPoints(1).N1=[];
handles.Model(md).Input(id).dryPoints(1).N2=[];
handles.Model(md).Input(id).addDryPoint=0;
handles.Model(md).Input(id).selectDryPoint=0;
handles.Model(md).Input(id).deleteDryPoint=0;
handles.Model(md).Input(id).changeDryPoint=0;

%% Thin dams
handles.Model(md).Input(id).nrThinDams=0;
handles.Model(md).Input(id).thinDamNames={''};
handles.Model(md).Input(id).activeThinDam=1;
handles.Model(md).Input(id).thinDams(1).M1=[];
handles.Model(md).Input(id).thinDams(1).M2=[];
handles.Model(md).Input(id).thinDams(1).N1=[];
handles.Model(md).Input(id).thinDams(1).N2=[];
handles.Model(md).Input(id).thinDams(1).UV='U';
handles.Model(md).Input(id).addThinDam=0;
handles.Model(md).Input(id).selectThinDam=0;
handles.Model(md).Input(id).deleteThinDam=0;
handles.Model(md).Input(id).changeThinDam=0;

%% 2D weirs
handles.Model(md).Input(id).nrWeirs2D=0;
handles.Model(md).Input(id).weir2DNames={''};
handles.Model(md).Input(id).activeWeir2D=1;
handles.Model(md).Input(id).weirs2D(1).M1=[];
handles.Model(md).Input(id).weirs2D(1).M2=[];
handles.Model(md).Input(id).weirs2D(1).N1=[];
handles.Model(md).Input(id).weirs2D(1).N2=[];
handles.Model(md).Input(id).weirs2D(1).UV='U';
handles.Model(md).Input(id).weirs2D(1).frictionCoefficient=1.0;
handles.Model(md).Input(id).weirs2D(1).crestHeight=0.0;
handles.Model(md).Input(id).addWeir2D=0;
handles.Model(md).Input(id).selectWeir2D=0;
handles.Model(md).Input(id).deleteWeir2D=0;
handles.Model(md).Input(id).changeWeir2D=0;

%% Open boundaries
handles.Model(md).Input(id).nrOpenBoundaries=0;
handles.Model(md).Input(id).openBoundaries=[];
handles.Model(md).Input(id).openBoundaryNames={''};
handles.Model(md).Input(id).openBoundaries(1).M1=[];
handles.Model(md).Input(id).openBoundaries(1).M2=[];
handles.Model(md).Input(id).openBoundaries(1).N1=[];
handles.Model(md).Input(id).openBoundaries(1).N2=[];
handles.Model(md).Input(id).openBoundaries(1).name='';
handles.Model(md).Input(id).openBoundaries(1).type='Z';
handles.Model(md).Input(id).openBoundaries(1).forcing='A';
handles.Model(md).Input(id).openBoundaries(1).profile='uniform';
handles.Model(md).Input(id).openBoundaries(1).alpha=0;
handles.Model(md).Input(id).activeOpenBoundary=1;
handles.Model(md).Input(id).activeOpenBoundaries=1;
handles.Model(md).Input(id).profileTexts={'Uniform','Logarithmic','Per Layer'};
handles.Model(md).Input(id).profileOptions={'uniform','logarithmic','3d-profile'};
handles.Model(md).Input(id).addOpenBoundary=0;
handles.Model(md).Input(id).selectOpenBoundary=0;
handles.Model(md).Input(id).deleteOpenBoundary=0;
handles.Model(md).Input(id).changeOpenBoundary=0;

% handles.Model(md).Input(id).bctFileLoaded=1;

handles.Model(md).Input(id).nrAstro=0;
handles.Model(md).Input(id).nrHarmo=0;
handles.Model(md).Input(id).nrTime=0;
handles.Model(md).Input(id).nrCor=0;

%% Drogues
handles.Model(md).Input(id).nrDrogues=0;
handles.Model(md).Input(id).activeDrogue=1;
handles.Model(md).Input(id).drogueNames={''};
handles.Model(md).Input(id).activeDrogue=1;
handles.Model(md).Input(id).drogues(1).name='';
handles.Model(md).Input(id).drogues(1).M=[];
handles.Model(md).Input(id).drogues(1).N=[];
handles.Model(md).Input(id).drogues(1).releaseTime=floor(now);
handles.Model(md).Input(id).drogues(1).recoveryTime=floor(now)+2;
handles.Model(md).Input(id).addDrogue=0;
handles.Model(md).Input(id).selectDrogue=0;
handles.Model(md).Input(id).deleteDrogue=0;
handles.Model(md).Input(id).changeDrogue=0;

%% Files
handles.Model(md).Input(id).grdFile='';
handles.Model(md).Input(id).encFile='';
handles.Model(md).Input(id).depFile='';
handles.Model(md).Input(id).dryFile='';
handles.Model(md).Input(id).thdFile='';
handles.Model(md).Input(id).crsFile='';
handles.Model(md).Input(id).droFile='';
handles.Model(md).Input(id).iniFile='';
handles.Model(md).Input(id).rstId='';
handles.Model(md).Input(id).trimId='';
handles.Model(md).Input(id).bndFile='';
handles.Model(md).Input(id).bchFile='';
handles.Model(md).Input(id).bctFile='';
handles.Model(md).Input(id).bcqFile='';
handles.Model(md).Input(id).bccFile='';
handles.Model(md).Input(id).bcaFile='';
handles.Model(md).Input(id).corFile='';
handles.Model(md).Input(id).obsFile='';
handles.Model(md).Input(id).crsFile='';
handles.Model(md).Input(id).rghFile='';
handles.Model(md).Input(id).edyFile='';
handles.Model(md).Input(id).srcFile='';
handles.Model(md).Input(id).disFile='';
handles.Model(md).Input(id).w2dFile='';

handles.Model(md).Input(id).MMax=0;
handles.Model(md).Input(id).NMax=0;
handles.Model(md).Input(id).lastKMax=1;
handles.Model(md).Input(id).KMax=1;
handles.Model(md).Input(id).depth=[];
handles.Model(md).Input(id).gridX=[];
handles.Model(md).Input(id).gridY=[];
handles.Model(md).Input(id).gridY=[];
handles.Model(md).Input(id).coordinateSystemType=handles.screenParameters.coordinateSystem.type;

handles.Model(md).Input(id).layerType='sigma';
handles.Model(md).Input(id).zBot=0;
handles.Model(md).Input(id).zTop=0;

handles.Model(md).Input(id).initialConditions='unif';
handles.Model(md).Input(id).initialConditionsFile='';

%%
function handles=ddb_initializeOtherInput(handles,id,runid)

handles.Model(md).Input(id).runid=runid;
handles.Model(md).Input(id).mdfFile=[runid '.mdf'];
handles.Model(md).Input(id).attName=handles.Model(md).Input(id).runid;

handles.Model(md).Input(id).nrAstronomicComponentSets=0;

handles.Model(md).Input(id).nrHarmonicComponents=2;
handles.Model(md).Input(id).harmonicComponents=[0.0 30.0];

handles.Model(md).Input(id).description='';

handles.Model(md).Input(id).uniformDepth=10;
handles.Model(md).Input(id).depthSource='uniform';

handles.Model(md).Input(id).fouFile='';
handles.Model(md).Input(id).sedFile='';
handles.Model(md).Input(id).morFile='';
handles.Model(md).Input(id).wndFile='';
handles.Model(md).Input(id).spwFile='';
handles.Model(md).Input(id).amuFile='';
handles.Model(md).Input(id).amvFile='';
handles.Model(md).Input(id).ampFile='';
handles.Model(md).Input(id).amtFile='';
handles.Model(md).Input(id).amcFile='';
handles.Model(md).Input(id).amrFile='';
handles.Model(md).Input(id).w2dFile='';
handles.Model(md).Input(id).wndgrd='';
handles.Model(md).Input(id).MNmaxw=[];

handles.Model(md).Input(id).nrTracers=0;
handles.Model(md).Input(id).nrConstituents=0;

handles.Model(md).Input(id).latitude=0.0;
handles.Model(md).Input(id).orientation=0.0;
handles.Model(md).Input(id).thick=100;
handles.Model(md).Input(id).sumLayers=100;
handles.Model(md).Input(id).uniformRoughness=1;
handles.Model(md).Input(id).uniformViscosity=1;

handles.Model(md).Input(id).zeta0=0.0;
handles.Model(md).Input(id).u0=0.0;
handles.Model(md).Input(id).v0=0.0;

handles.Model(md).Input(id).itDate=floor(now);
handles.Model(md).Input(id).startTime=floor(now);
handles.Model(md).Input(id).stopTime=floor(now)+2;
handles.Model(md).Input(id).timeStep=1.0;
handles.Model(md).Input(id).timeZone=0;
handles.Model(md).Input(id).mapStartTime=handles.Model(md).Input(id).startTime;
handles.Model(md).Input(id).mapStopTime=handles.Model(md).Input(id).stopTime;
handles.Model(md).Input(id).mapInterval=60;
handles.Model(md).Input(id).comStartTime=handles.Model(md).Input(id).startTime;
handles.Model(md).Input(id).comStopTime=handles.Model(md).Input(id).startTime;
handles.Model(md).Input(id).comInterval=0;
handles.Model(md).Input(id).hisInterval=10*handles.Model(md).Input(id).timeStep;
handles.Model(md).Input(id).rstInterval=0;
handles.Model(md).Input(id).onlineVisualisation=0;
handles.Model(md).Input(id).onlineCoupling=0;
handles.Model(md).Input(id).fourierAnalysis=0;
handles.Model(md).Input(id).airOut=0;
handles.Model(md).Input(id).heatOut=0;

handles.Model(md).Input(id).salinity.include=0;
handles.Model(md).Input(id).temperature.include=0;
handles.Model(md).Input(id).tracers=0;
handles.Model(md).Input(id).wind=0;
handles.Model(md).Input(id).waves=0;
handles.Model(md).Input(id).onlineWave=0;
handles.Model(md).Input(id).waqmod=0;
handles.Model(md).Input(id).roller.include=0;
handles.Model(md).Input(id).secondaryFlow=0;
handles.Model(md).Input(id).tidalForces=0;
handles.Model(md).Input(id).dredging=0;
handles.Model(md).Input(id).constituents=0;

%% Tidal forces
handles.Model(md).Input(id).tidalForce.M2=0;
handles.Model(md).Input(id).tidalForce.S2=0;
handles.Model(md).Input(id).tidalForce.N2=0;
handles.Model(md).Input(id).tidalForce.K2=0;
handles.Model(md).Input(id).tidalForce.K1=0;
handles.Model(md).Input(id).tidalForce.O1=0;
handles.Model(md).Input(id).tidalForce.P1=0;
handles.Model(md).Input(id).tidalForce.Q1=0;
handles.Model(md).Input(id).tidalForce.MF=0;
handles.Model(md).Input(id).tidalForce.MM=0;
handles.Model(md).Input(id).tidalForce.SSA=0;

handles.Model(md).Input(id).latitude=0.0;
handles.Model(md).Input(id).orientation=0.0;
handles.Model(md).Input(id).g=9.81;
handles.Model(md).Input(id).rhoW=1000.0;
%Alph0 = [.]
handles.Model(md).Input(id).tempW=15;
handles.Model(md).Input(id).salW=31;
handles.Model(md).Input(id).rouWav='FR84';
handles.Model(md).Input(id).windStressCoefficients=[1.0000000e-003;3.0000000e-003];
handles.Model(md).Input(id).windStressSpeeds=[0.0000000e+000;2.5000000e+001];
handles.Model(md).Input(id).nrWindStressBreakpoints=2;
handles.Model(md).Input(id).windType='uniform';
handles.Model(md).Input(id).wndInt='Y';
handles.Model(md).Input(id).rhoAir=1.0;
handles.Model(md).Input(id).betaC=0.5;
handles.Model(md).Input(id).equili=0;
handles.Model(md).Input(id).verticalTurbulenceModel='K-epsilon';
handles.Model(md).Input(id).temint=1;
handles.Model(md).Input(id).roughnessType='M';
handles.Model(md).Input(id).uRoughness=0.02;
handles.Model(md).Input(id).vRoughness=0.02;
handles.Model(md).Input(id).xlo=0;
handles.Model(md).Input(id).vicoUV=1;
handles.Model(md).Input(id).dicoUV=1;
handles.Model(md).Input(id).HLES=0;
handles.Model(md).Input(id).vicoWW=1.0e-6;
handles.Model(md).Input(id).dicoWW=1.0e-6;
handles.Model(md).Input(id).irov=0;
handles.Model(md).Input(id).z0v=0.0;
handles.Model(md).Input(id).sedFile='';
handles.Model(md).Input(id).morFile='';
handles.Model(md).Input(id).iter=2;
handles.Model(md).Input(id).dryFlp=1;
handles.Model(md).Input(id).dpsOpt='MAX';
handles.Model(md).Input(id).dpuOpt='MEAN';
handles.Model(md).Input(id).dpuOptions={'MEAN','MIN','UPW','MOR'};
handles.Model(md).Input(id).dryFlc=0.1;
handles.Model(md).Input(id).dco=-999.0;
handles.Model(md).Input(id).dgcuni=1000.0;
handles.Model(md).Input(id).smoothingTime=60.0;
handles.Model(md).Input(id).thetQH=0;
handles.Model(md).Input(id).forresterHor=0;
handles.Model(md).Input(id).forresterVer=0;
handles.Model(md).Input(id).sigmaCorrection=0;
handles.Model(md).Input(id).traSol='Cyclic-method';
handles.Model(md).Input(id).momSol='Cyclic';
handles.Model(md).Input(id).onlineVisualisation=0;
handles.Model(md).Input(id).onlineWave=0;
handles.Model(md).Input(id).nudge=0;

% Heat model
handles.Model(md).Input(id).kTemp=0;
handles.Model(md).Input(id).fClou=0;
handles.Model(md).Input(id).sArea=0;
handles.Model(md).Input(id).timeZoneSolarRadiation=0;
handles.Model(md).Input(id).secchi=3;
handles.Model(md).Input(id).stanton=0.0013;
handles.Model(md).Input(id).dalton=0.0013;

% HLES stuff
handles.Model(md).Input(id).Htural=1.6666660e+000;
handles.Model(md).Input(id).Hturnd=2;
handles.Model(md).Input(id).Hturst=7.0000000e-001;
handles.Model(md).Input(id).Hturlp=3.3333330e-001;
handles.Model(md).Input(id).Hturrt=6.0000000e+001;
handles.Model(md).Input(id).Hturdm=0.0000000e+000;
handles.Model(md).Input(id).Hturel=1;

% Initial Condition Options
handles.Model(md).Input(id).waterLevel.ICOpt='unif';
handles.Model(md).Input(id).waterLevel.ICConst=0;
handles.Model(md).Input(id).waterLevel.ICPar=0;
handles.Model(md).Input(id).velocity.ICOpt='Constant';
handles.Model(md).Input(id).velocity.ICPar=[0 0 ; 100 0];
handles.Model(md).Input(id).velocity.ICConst=0;

% Wind
handles=ddb_initializeWind(handles,id);
handles.Model(md).Input(id).pAvBnd=-999;

% Constituents
handles=ddb_initializeSalinity(handles,id);
handles=ddb_initializeTemperature(handles,id);

handles.Model(md).Input(id).tracer=[];
%for i=1:handles.Model(md).Input(id).nrTracers
for ii=1:5
    handles.Model(md).Input(id).tracer(ii).name=['Tracer ' num2str(ii)];
    handles=ddb_initializeTracer(handles,id,ii);
end
handles.Model(md).Input(id).cstBnd=0;

%% Morphology
handles=ddb_Delft3DFLOW_initializeMorphology(handles,id);

%% Sediments
handles.Model(md).Input(id).nrSediments=0;
handles.Model(md).Input(id).sediment=[];
% handles.Model(md).Input(id).sediment(1).name='Sediment sand';
% handles.Model(md).Input(id).sediment(1).type='non-cohesive';
handles.Model(md).Input(id).sediments=[];
handles.Model(md).Input(id).sediments.include=0;
handles.Model(md).Input(id).sediments.cRef=1600;
handles.Model(md).Input(id).sediments.iOpSus=0;
handles.Model(md).Input(id).sediments.sedimentNames={''};
handles.Model(md).Input(id).sediments.activeSediment=1;
for ii=1:5
    handles.Model(md).Input(id).sediment(ii).name=['Sediment ' num2str(ii)];
    handles.Model(md).Input(id).sediment(ii).type='non-cohesive';
    handles=ddb_initializeSediment(handles,id,ii);
end

%% Roller Model
handles.Model(md).Input(id).roller.snellius=0;
handles.Model(md).Input(id).roller.gamDis=0.7;
handles.Model(md).Input(id).roller.betaRo=0.05;
handles.Model(md).Input(id).roller.fLam=-2;
handles.Model(md).Input(id).roller.thr=0.01;

%% Trachytopes
handles.Model(md).Input(id).trachy.traFrm='';
handles.Model(md).Input(id).trachy.trtrou=0;
handles.Model(md).Input(id).trachy.trtdef='';
handles.Model(md).Input(id).trachy.trtu='';
handles.Model(md).Input(id).trachy.trtv='';
handles.Model(md).Input(id).trachy.trtDt=0;

%% Fourier analysis
handles.Model(md).Input(id).fourier.parameterList={'water level','velocity','discharge'};
handles.Model(md).Input(id).fourier.pList={'wl','uv','qf'};
handles.Model(md).Input(id).fourier.optionList={'fourier','max','min','ellipse'};
handles.Model(md).Input(id).fourier.tableOption='generate';
handles.Model(md).Input(id).fourier.include=0;
handles.Model(md).Input(id).fourier.fouFile='';

% Edit table
handles.Model(md).Input(id).fourier.editTable.parameterNumber=1;
handles.Model(md).Input(id).fourier.editTable.startTime=floor(now);
handles.Model(md).Input(id).fourier.editTable.stopTime=floor(now)+1;
handles.Model(md).Input(id).fourier.editTable.nrCycles=1;
handles.Model(md).Input(id).fourier.editTable.nodalAmplificationFactor=1;
handles.Model(md).Input(id).fourier.editTable.astronomicalArgument=0;
handles.Model(md).Input(id).fourier.editTable.layer=1;
handles.Model(md).Input(id).fourier.editTable.max=0;
handles.Model(md).Input(id).fourier.editTable.min=0;
handles.Model(md).Input(id).fourier.editTable.ellipse=0;
handles.Model(md).Input(id).fourier.editTable.option=1;

handles.Model(md).Input(id).fourier.generateTable.parameterNumber=1;
handles.Model(md).Input(id).fourier.generateTable.astronomicalComponents='M2';
handles.Model(md).Input(id).fourier.generateTable.componentNumber=1;
handles.Model(md).Input(id).fourier.generateTable.layer=1;
handles.Model(md).Input(id).fourier.generateTable.fourier=1;
handles.Model(md).Input(id).fourier.generateTable.max=0;
handles.Model(md).Input(id).fourier.generateTable.min=0;
handles.Model(md).Input(id).fourier.generateTable.ellipse=0;

handles.Model(md).Input(id).fourier.layerList{1}='1';
handles.Model(md).Input(id).fourier.spinUpTime=1440;

tt=t_getconsts;
handles.Model(md).Input(id).fourier.astronomicalComponents=[];
for i=1:size(tt.name,1)
    handles.Model(md).Input(id).fourier.astronomicalComponents{i}=deblank(tt.name(i,:));
end

handles.Model(md).Input(id).thickTop=2;
handles.Model(md).Input(id).thickBot=2;
handles.Model(md).Input(id).layerOption=1;

%% WAQ input
handles.Model(md).Input(id).WAQcomStartTime=handles.Model(md).Input(id).startTime;
handles.Model(md).Input(id).WAQcomStopTime=handles.Model(md).Input(id).startTime;
handles.Model(md).Input(id).WAQcomInterval=0;
handles.Model(md).Input(id).ilAggr = {'1'};
handles.Model(md).Input(id).WaqAgg= 'active only';


