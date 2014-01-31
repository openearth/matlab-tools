function handles = ddb_readMDF(handles, filename, id)
%DDB_READMDF  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_readMDF(handles, filename, id)
%
%   Input:
%   handles  =
%   filename =
%   id       =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_readMDF
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
MDF=ddb_readMDFText(filename);

%% Grid and bathymetry
handles.Model(md).Input(id).grdFile=MDF.filcco;
handles.Model(md).Input(id).description=MDF.runtxt;
if isfield(MDF,'anglat')
    handles.Model(md).Input(id).latitude=MDF.anglat;
end
handles.Model(md).Input(id).orientation=MDF.grdang;
handles.Model(md).Input(id).encFile=MDF.filgrd;
handles.Model(md).Input(id).MMax=MDF.mnkmax(1);
handles.Model(md).Input(id).NMax=MDF.mnkmax(2);
handles.Model(md).Input(id).KMax=MDF.mnkmax(3);
handles.Model(md).Input(id).lastKMax=handles.Model(md).Input(id).KMax;
handles.Model(md).Input(id).thick=MDF.thick;
handles.Model(md).Input(id).dryFile=MDF.fildry;
handles.Model(md).Input(id).thdFile=MDF.filtd;
handles.Model(md).Input(id).w2dFile=MDF.fil2dw;
if isfield(MDF,'fildep')
    handles.Model(md).Input(id).depFile=MDF.fildep;
    handles.Model(md).Input(id).uniformDepth=10.0;
    handles.Model(md).Input(ad).depthSource='file';
else
    handles.Model(md).Input(id).depFile='';
    handles.Model(md).Input(id).uniformDepth=10.0;
    handles.Model(md).Input(ad).depthSource='uniform';
end;

%% Time frame
handles.Model(md).Input(id).itDate=datenum(MDF.itdate,'yyyy-mm-dd');
handles.Model(md).Input(id).itDateString=datestr(handles.Model(md).Input(id).itDate,'yyyy mm dd');
handles.Model(md).Input(id).startTime=handles.Model(md).Input(id).itDate+MDF.tstart/1440.0;
handles.Model(md).Input(id).stopTime= handles.Model(md).Input(id).itDate+MDF.tstop/1440.0;
handles.Model(md).Input(id).timeStep=MDF.dt;
handles.Model(md).Input(id).timeZone=MDF.tzone;

%% Constituents and processes
if ~isempty(MDF.sub1)
    if MDF.sub1(1)=='S'
        handles.Model(md).Input(id).salinity.include=1;
        handles.Model(md).Input(id).constituents=1;
    end
    if MDF.sub1(2)=='T'
        handles.Model(md).Input(id).temperature.include=1;
        handles.Model(md).Input(id).constituents=1;
    end
    if MDF.sub1(3)=='W'
        handles.Model(md).Input(id).wind=1;
    end
    if MDF.sub1(4)=='I'
        handles.Model(md).Input(id).secondaryFlow=1;
    end
end
if ~isempty(MDF.sub2)
    if MDF.sub2(2)=='C'
        handles.Model(md).Input(id).constituents=1;
    end
    if MDF.sub2(3)=='W'
        handles.Model(md).Input(id).waves=1;
    end
end
for i=1:5
    fld=deblank(getfield(MDF,['namc' num2str(i)]));
    if ~isempty(fld)
        if strcmpi(fld(1:min(8,length(fld))),'sediment')
            handles.Model(md).Input(id).sediments.include=1;
            handles.Model(md).Input(id).nrSediments=handles.Model(md).Input(id).nrSediments+1;
            handles.Model(md).Input(id).nrConstituents=handles.Model(md).Input(id).nrConstituents+1;
            k=handles.Model(md).Input(id).nrSediments;
            handles.Model(md).Input(id).sediment(k).name=deblank(fld);
            handles.Model(md).Input(id).sediment(k).type='non-cohesive';
            handles.Model(md).Input(id).sediments.sedimentNames{k}=deblank(fld);
        else
            handles.Model(md).Input(id).tracers=1;
            handles.Model(md).Input(id).nrConstituents=handles.Model(md).Input(id).nrConstituents+1;
            handles.Model(md).Input(id).nrTracers=handles.Model(md).Input(id).nrTracers+1;
            k=handles.Model(md).Input(id).nrTracers;
            handles.Model(md).Input(id).tracer(k).name=deblank(fld);
        end
    end
end


%% Wind
handles.Model(md).Input(id).wndFile=MDF.filwnd;
if MDF.wnsvwp=='N'
    handles.Model(md).Input(id).windType='uniform';
else
    handles.Model(md).Input(id).windType='curvilinear';
end

%% Initial conditions
handles.Model(md).Input(id).zeta0=MDF.zeta0;
handles.Model(md).Input(id).u0=0.0;
handles.Model(md).Input(id).v0=0.0;
handles.Model(md).Input(id).s0=0.0;
handles.Model(md).Input(id).c0=0.0;

if ~isempty(MDF.filic)
    handles.Model(md).Input(id).iniFile=MDF.filic;
    handles.Model(md).Input(id).initialConditions='ini';
else
    handles.Model(md).Input(id).iniFile='';
end
if ~isempty(MDF.restid)
    handles.Model(md).Input(id).rstId=MDF.restid;
    handles.Model(md).Input(id).initialConditions='rst';
else
    handles.Model(md).Input(id).rstId='';
end
% if isfield(MDF,'trim')
%     handles.Model(md).Input(id).RstId=MDF.restid;
%     handles.Model(md).Input(id).InitialConditions='rst';
% else
%     handles.Model(md).Input(id).RstId='';
% end

%% Boundaries
handles.Model(md).Input(id).bndFile=MDF.filbnd;
handles.Model(md).Input(id).bchFile=MDF.filbch;
handles.Model(md).Input(id).bctFile=MDF.filbct;
handles.Model(md).Input(id).bcaFile=MDF.filana;
handles.Model(md).Input(id).corFile=MDF.filcor;
handles.Model(md).Input(id).bcqFile=MDF.filbcq;
if isfield(MDF,'filbcc')
    handles.Model(md).Input(id).bccFile=MDF.filbcc;
else
    handles.Model(md).Input(id).bccFile='';
end

%% Sources and sinks
handles.Model(md).Input(id).srcFile=MDF.filsrc;
handles.Model(md).Input(id).disFile=MDF.fildis;

%% Constants
handles.Model(md).Input(id).g=MDF.ag;
handles.Model(md).Input(id).rhoW=MDF.rhow;
%Alph0 = [.]
handles.Model(md).Input(id).tempW=MDF.tempw;
handles.Model(md).Input(id).salW=MDF.salw;
if ~isempty(deblank(MDF.rouwav))
    handles.Model(md).Input(id).rouWav=MDF.rouwav;
end
handles.Model(md).Input(id).nrWindStressBreakpoints=length(MDF.wstres)/2;
% if handles.Model(md).Input(id).nrWindStressBreakpoints==2
%     handles.Model(md).Input(id).windStressCoefficients=[MDF.wstres(1) MDF.wstres(3)];
%     handles.Model(md).Input(id).windStressSpeeds=[MDF.wstres(2) MDF.wstres(4)];
% else
%     handles.Model(md).Input(id).windStressCoefficients=[MDF.wstres(1) MDF.wstres(3) MDF.wstres(5)];
%     handles.Model(md).Input(id).windStressSpeeds=[MDF.wstres(2) MDF.wstres(4) MDF.wstres(6)];
% end
handles.Model(md).Input(id).windStressCoefficients=MDF.wstres(1:2:end);
handles.Model(md).Input(id).windStressSpeeds=MDF.wstres(2:2:end);

%% Heat model
handles.Model(md).Input(id).rhoAir=MDF.rhoa;
handles.Model(md).Input(id).betaC=MDF.betac;
handles.Model(md).Input(id).kTemp=MDF.ktemp;
handles.Model(md).Input(id).fClou=MDF.fclou;
handles.Model(md).Input(id).sArea=MDF.sarea;
handles.Model(md).Input(id).secchi=MDF.secchi;
handles.Model(md).Input(id).stantn=MDF.stantn;
handles.Model(md).Input(id).dalton=MDF.dalton;

if isfield(MDF,'filtmp')
    if ~isempty(MDF.filtmp)
        handles.Model(md).Input(id).tmpFile=MDF.filtmp;
    end
end

if MDF.temint(1)=='N'
    handles.Model(md).Input(id).temint=0;
else
    handles.Model(md).Input(id).temint=1;
end

%% Tidal forces
if ~isempty(MDF.tidfor)
    handles.Model(md).Input(id).tidalForces=1;
    for i=1:3
        line1=MDF.tidfor{i};
        for j=1:4
            str=line1((j-1)*3+1:(j-1)*3+3);
            if ~strcmpi(str,'---')
                handles.Model(md).Input(id).tidalForce.(deblank(str))=1;
            end
        end
    end
end

%% Roughness
handles.Model(md).Input(id).roughnessType=MDF.roumet;
handles.Model(md).Input(id).uRoughness=MDF.ccofu;
handles.Model(md).Input(id).vRoughness=MDF.ccofv;
handles.Model(md).Input(id).xlo=MDF.xlo;
handles.Model(md).Input(id).irov=MDF.irov;
handles.Model(md).Input(id).rghFile='';
handles.Model(md).Input(id).uniformRoughness=1;
if isfield(MDF,'filrgh')
    if ~isempty(MDF.filrgh)
        handles.Model(md).Input(id).rghFile=MDF.filrgh;
        handles.Model(md).Input(id).uniformRoughness=0;
    end
end

%% Viscosity
handles.Model(md).Input(id).vicoUV=MDF.vicouv;
handles.Model(md).Input(id).dicoUV=MDF.dicouv;
if MDF.htur2d(1)=='N'
    handles.Model(md).Input(id).HLES=0;
else
    handles.Model(md).Input(id).HLES=1;
    handles.Model(md).Input(id).Htural=MDF.htural;
    handles.Model(md).Input(id).Hturnd=MDF.hturnd;
    handles.Model(md).Input(id).Hturst=MDF.hturst;
    handles.Model(md).Input(id).Hturlp=MDF.hturlp;
    handles.Model(md).Input(id).Hturrt=MDF.hturrt;
    handles.Model(md).Input(id).Hturdm=MDF.hturdm;
    handles.Model(md).Input(id).Hturel=1;
end
if isfield(MDF,'vicoww')
    handles.Model(md).Input(id).vicoWW=MDF.vicoww;
    handles.Model(md).Input(id).vicoWW=MDF.dicoww;
end
if MDF.equili(1)=='N'
    handles.Model(md).Input(id).equili=0;
else
    handles.Model(md).Input(id).equili=1;
end
if isempty(deblank(MDF.tkemod))
    handles.Model(md).Input(id).verticalTurbulenceModel='K-epsilon   ';
else
    handles.Model(md).Input(id).verticalTurbulenceModel=MDF.tkemod;
end

%% Morphology
if isfield(MDF,'filsed')
    handles.Model(md).Input(id).sedFile=MDF.filsed;
else
    handles.Model(md).Input(id).sedFile='';
end
if isfield(MDF,'filmor')
    handles.Model(md).Input(id).morFile=MDF.filmor;
else
    handles.Model(md).Input(id).morFile='';
end

%% Numerical
handles.Model(md).Input(id).iter=MDF.iter;
if strcmpi(MDF.dryflp(1),'n')
    handles.Model(md).Input(id).dryFlp=0;
else
    handles.Model(md).Input(id).dryFlp=1;
end
handles.Model(md).Input(id).dpsOpt=MDF.dpsopt;
handles.Model(md).Input(id).dpuOpt=MDF.dpuopt;
handles.Model(md).Input(id).dryFlc=MDF.dryflc;
handles.Model(md).Input(id).dco=MDF.dco;
handles.Model(md).Input(id).smoothingTime=MDF.tlfsmo;
handles.Model(md).Input(id).thetQH=MDF.thetqh;

if strcmpi(MDF.forfuv(1),'n')
    handles.Model(md).Input(id).forresterHor=0;
else
    handles.Model(md).Input(id).forresterHor=1;
end
if strcmpi(MDF.forfww(1),'n')
    handles.Model(md).Input(id).forresterVer=0;
else
    handles.Model(md).Input(id).forresterVer=1;
end
if strcmpi(MDF.sigcor(1),'n')
    handles.Model(md).Input(id).sigmaCorrection=0;
else
    handles.Model(md).Input(id).sigmaCorrection=1;
end
handles.Model(md).Input(id).traSol=MDF.trasol;
handles.Model(md).Input(id).momSol=MDF.momsol;

%% Observations
handles.Model(md).Input(id).obsFile=MDF.filsta;
handles.Model(md).Input(id).crsFile=MDF.filcrs;
handles.Model(md).Input(id).droFile=MDF.filpar;

%% Coupling
if strcmpi(MDF.online(1),'n')
    handles.Model(md).Input(id).onlineVisualisation=0;
else
    handles.Model(md).Input(id).onlineVisualisation=1;
end
if isfield(MDF,'waqmod')
    if strcmpi(MDF.waqmod(1),'n')
        handles.Model(md).Input(id).waqMod=0;
    else
        handles.Model(md).Input(id).waqMod=1;
    end
end

%% Wave online
if isfield(MDF,'waveol')
    if strcmpi(MDF.waveol(1),'n')
        handles.Model(md).Input(id).onlineWave=0;
    else
        handles.Model(md).Input(id).onlineWave=1;
    end
end

%% Output
handles.Model(md).Input(id).prHis=MDF.prhis;
handles.Model(md).Input(id).mapStartTime=handles.Model(md).Input(id).itDate+MDF.flmap(1)/1440;
handles.Model(md).Input(id).mapInterval=MDF.flmap(2);
handles.Model(md).Input(id).mapStopTime=handles.Model(md).Input(id).itDate+MDF.flmap(3)/1440;
handles.Model(md).Input(id).hisInterval=MDF.flhis(2);
handles.Model(md).Input(id).comStartTime=handles.Model(md).Input(id).itDate+MDF.flpp(1)/1440;
handles.Model(md).Input(id).comInterval=MDF.flpp(2);
handles.Model(md).Input(id).comStopTime=handles.Model(md).Input(id).itDate+MDF.flpp(3)/1440;
handles.Model(md).Input(id).rstInterval=MDF.flrst;

%% Meteo data on equidistant grid
handles.Model(md).Input(id).ampFile=MDF.filwp;
handles.Model(md).Input(id).amuFile=MDF.filwu;
handles.Model(md).Input(id).amvFile=MDF.filwv;
handles.Model(md).Input(id).wndgrd=MDF.wndgrd;
handles.Model(md).Input(id).MNmaxw=MDF.mnmaxw;

handles.Model(md).Input(id).amtFile=MDF.filwt;
handles.Model(md).Input(id).amcFile=MDF.filwc;
handles.Model(md).Input(id).amrFile=MDF.filwr;

handles.Model(md).Input(id).spwFile=MDF.filweb;
if ~isempty(handles.Model(md).Input(id).spwFile)
    handles.Model(md).Input(id).windType='spiderweb';
end

if ~isempty(handles.Model(md).Input(id).amuFile)
    handles.Model(md).Input(id).windType='equidistant';
end

if isfield(MDF,'pavbnd')
    handles.Model(md).Input(id).pAvBnd=MDF.pavbnd;
end

if isfield(MDF,'nudge')
    if MDF.nudge(1)=='Y'
        handles.Model(md).Input(id).nudge=1;
    end
end

%% Z-layers
if isfield(MDF,'zmodel')
    if strcmpi(MDF.zmodel(1),'y')
        handles.Model(md).Input(id).layerType='z';
    end
end
if isfield(MDF,'zbot')
    handles.Model(md).Input(id).zBot=MDF.zbot;
end
if isfield(MDF,'ztop')
    handles.Model(md).Input(id).zTop=MDF.ztop;
end

%% Roller model
if isfield(MDF,'roller')
    if strcmpi(MDF.roller(1),'y')
        handles.Model(md).Input(id).roller.include=1;
    end
end
if isfield(MDF,'snelli')
    if strcmpi(MDF.snelli(1),'y')
        handles.Model(md).Input(id).roller.snellius=1;
    end
end
if isfield(MDF,'gamdis')
    handles.Model(md).Input(id).roller.gamDis=MDF.gamdis;
end
if isfield(MDF,'betaro')
    handles.Model(md).Input(id).roller.betaRo=MDF.betaro;
end
if isfield(MDF,'f_lam')
    handles.Model(md).Input(id).roller.flam=MDF.f_lam;
end
if isfield(MDF,'thr')
    handles.Model(md).Input(id).roller.thr=MDF.thr;
end

if isfield(MDF,'cstbnd')
    if strcmpi(MDF.cstbnd(1),'y')
        handles.Model(md).Input(id).cstBnd=1;
    end
end

if isfield(MDF,'airout')
    if strcmpi(MDF.airout(1),'y')
        handles.Model(md).Input(id).airOut=1;
    end
end

if isfield(MDF,'heaout')
    if strcmpi(MDF.heaout(1),'y')
        handles.Model(md).Input(id).heatOut=1;
    end
end

if isfield(MDF,'filfou')
    if ~isempty(MDF.filfou)
        handles.Model(md).Input(id).fouFile=MDF.filfou;
        handles.Model(md).Input(id).fourier.include=1;
    end
end

if isfield(MDF,'tmzrad')
    handles.Model(md).Input(id).timeZoneSolarRadiation=MDF.tmzrad;
end

% Cstbnd= #yes#
% TraFrm= #vrijn2004.frm#
% Trtrou= #Y#
% Trtdef= #vrijn04.trt#
% Trtu  = #trtuv.inp#
% Trtv  = #trtuv.inp#
% TrtDt = 2.

