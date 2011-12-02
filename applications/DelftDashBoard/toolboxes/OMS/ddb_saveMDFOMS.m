function handles = ddb_saveMDFOMS(handles, id)
%DDB_SAVEMDFOMS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_saveMDFOMS(handles, id)
%
%   Input:
%   handles =
%   id      =
%
%   Output:
%   handles =
%
%   Example
%   ddb_saveMDFOMS
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
handles=ddb_countOpenBoundaries(handles,id);

Flow=handles.Model(md).Input(ad);

runid=handles.Toolbox(tb).Runid;

incconst=Flow.Salinity.Include || Flow.Temperature.Include || Flow.sediments.include || Flow.Tracers;

MDF.Ident='Delft3D-FLOW  .03.02 3.39.26';
MDF.Runtxt=Flow.Description;
MDF.Filcco=Flow.GrdFile;
MDF.Fmtcco='FR';
MDF.Runtxt=Flow.Description;
if strcmp(handles.ScreenParameters.CoordinateSystem.Type,'Cartesian')
    MDF.Anglat=Flow.Latitude;
end
MDF.Grdang=Flow.Orientation;
MDF.Filgrd=Flow.EncFile;
MDF.Fmtgrd='FR';
MDF.MNKmax(1)=Flow.MMax;
MDF.MNKmax(2)=Flow.NMax;
MDF.MNKmax(3)=Flow.KMax;
MDF.Thick=Flow.Thick;
if ~isempty(Flow.DepFile)
    MDF.Fildep=Flow.DepFile;
    MDF.Fmtdep= 'FR';
else
    MDF.DepUni=Flow.UniformDepth;
end
if Flow.NrDryPoints>0
    MDF.Fildry=Flow.DryFile;
    MDF.Fmtdry='FR';
end
if Flow.NrThinDams>0
    MDF.Filthd=Flow.ThdFile;
    MDF.Fmtthd='FR';
end
MDF.Itdate=D3DTimeString(Flow.ItDate,'ItDateMDF');
MDF.Tunit='M';
tstart=(Flow.StartTime-Flow.ItDate)*1440.0;
tstop=(Flow.StopTime-Flow.ItDate)*1440.0;
MDF.Tstart=tstart;
MDF.Tstop=tstop;
MDF.Dt=Flow.TimeStep;
MDF.Tzone=0;
MDF.Sub1='    ';
if Flow.Salinity.Include
    MDF.Sub1(1)='S';
end
if Flow.Temperature.Include
    MDF.Sub1(2)='T';
end
if Flow.Wind
    MDF.Sub1(3)='W';
end
if Flow.SecondaryFlow
    MDF.Sub1(4)='I';
end
MDF.Sub2='   ';
if Flow.sediments.include || Flow.Tracers
    MDF.Sub2(2)='C';
end
if Flow.Waves
    MDF.Sub2(3)='W';
end
k=0;
if Flow.sediments.include
    for i=1:Flow.NrSediments
        k=k+1;
        MDF.(['Namc' num2str(k)])=[Flow.Sediment(i).Name repmat(' ',1,20-length(Flow.Sediment(i).Name))];
    end
end
if Flow.Tracers
    for i=1:Flow.NrTracers
        k=k+1;
        MDF.(['Namc' num2str(k)])=[Flow.Tracer(i).Name repmat(' ',1,20-length(Flow.Tracer(i).Name))];
    end
end
MDF.Wnsvwp='N';
MDF.Wndint='Y';
if Flow.Wind
    if ~isempty(Flow.WndFile)
        MDF.Filwnd=Flow.WndFile;
    end
    if ~isempty(Flow.SpwFile)
        MDF.Filweb=Flow.SpwFile;
    end
    %     switch lower(Flow.WindType)
    %         case{'uniform'}
    %         case{'spiderweb'}
    %             MDF.Filweb=Flow.SpwFile;
    %     end
end
MDF.Filwnd='dummy.wnd';
switch Flow.InitialConditions,
    case{'unif'}
        MDF.Zeta0=Flow.Zeta0;
        MDF.U0=Flow.U0;
        MDF.V0=Flow.V0;
        if Flow.Salinity.Include
            val=zeros(Flow.KMax,1)+Flow.Salinity.ICConst;
            MDF.S0=val;
        end
        if Flow.Temperature.Include
            val=zeros(Flow.KMax,1)+Flow.Temperature.ICConst;
            MDF.T0=val;
        end
        k=0;
        if Flow.sediments.include
            for i=1:Flow.NrSediments
                k=k+1;
                val=zeros(Flow.KMax,1)+Flow.Sediment(i).ICConst;
                MDF.(['C0' num2str(k)])=val;
            end
        end
        if Flow.Tracers
            for i=1:Flow.NrTracers
                k=k+1;
                val=zeros(Flow.KMax,1)+Flow.Tracer(i).ICConst;
                MDF.(['C0' num2str(k)])=val;
            end
        end
    case{'ini'}
        MDF.Filic=Flow.IniFile;
        MDF.Fmtic='FR';
    case{'rst'}
        MDF.Restid=Flow.RstId;
    case{'trim'}
        MDF.Restid=Flow.TrimId;
end
if Flow.NrOpenBoundaries>0
    MDF.Filbnd=Flow.BndFile;
    MDF.Fmtbnd='FR';
end
if Flow.NrHarmo>0
    MDF.FilbcH=Flow.BchFile;
    MDF.FmtbcH='FR';
end
if incconst && Flow.NrOpenBoundaries>0
    MDF.FilbcC=Flow.BccFile;
    MDF.FmtbcC='FR';
end
if Flow.NrTime>0
    MDF.FilbcT=Flow.BctFile;
    MDF.FmtbcT='FR';
end
if Flow.NrAstro>0
    MDF.Filana=Flow.BcaFile;
    MDF.Fmtana='FR';
end
if Flow.NrCor>0
    MDF.Filcor=Flow.CorFile;
    MDF.Fmtcor='FR';
end
if incconst
    for i=1:Flow.NrOpenBoundaries
        MDF.Rettis(i)=Flow.OpenBoundaries(i).THLag(1);
        MDF.Rettib(i)=Flow.OpenBoundaries(i).THLag(2);
    end
end
MDF.Ag=Flow.G;
MDF.Rhow=Flow.RhoW;
MDF.Alph0=[];
MDF.Tempw=Flow.TempW;
MDF.Salw=Flow.SalW;
if Flow.Waves
    MDF.Rouwav=Flow.RouWav;
else
    MDF.Rouwav='    ';
end
MDF.Wstres=Flow.WindStress;
MDF.Rhoa=Flow.RhoAir;
MDF.Betac=Flow.BetaC;
if Flow.Equili==1
    MDF.Equili='N';
else
    MDF.Equili='Y';
end
if Flow.KMax>1
    MDF.Tkemod=[Flow.VerticalTurbulenceModel repmat(' ',1,12-length(Flow.VerticalTurbulenceModel))];
else
    MDF.Tkemod='            ';
end
MDF.Ktemp=Flow.KTemp;
MDF.Fclou=Flow.FClou;
MDF.Sarea=Flow.SArea;
if Flow.Temint==1
    MDF.Temint='N';
else
    MDF.Temint='Y';
end
MDF.Roumet=Flow.RoughnessType;
MDF.Ccofu=Flow.URoughness;
MDF.Ccofv=Flow.VRoughness;
MDF.Xlo=Flow.Xlo;
MDF.Vicouv=Flow.VicoUV;
MDF.Dicouv=Flow.DicoUV;
if Flow.HLES==1
    MDF.Htur2d='Y';
    MDF.Htural=Flow.Htural;
    MDF.Hturnd=Flow.Hturnd;
    MDF.Hturst=Flow.Hturst;
    MDF.Hturlp=Flow.Hturlp;
    MDF.Hturrt=Flow.Hturrt;
    MDF.Hturdm=Flow.Hturdm;
    MDF.Hturel= 'Y';
else
    MDF.Htur2d='N';
end
if Flow.KMax>1
    MDF.Vicoww=Flow.VicoWW;
    MDF.Dicoww=Flow.DicoWW;
end
MDF.Irov=Flow.Irov;
if Flow.Irov==1
    MDF.Z0v=Flow.Z0v;
end
if Flow.NrSediments>0
    MDF.Filsed=Flow.SedFile;
    MDF.Filmor=Flow.MorFile;
end
MDF.Iter=Flow.Iter;
if Flow.DryFlp
    MDF.Dryflp='YES';
else
    MDF.Dryflp='NO';
end
MDF.Dpsopt=Flow.DpsOpt;
MDF.Dpuopt=Flow.DpuOpt;
MDF.Dryflc=Flow.DryFlc;
MDF.Dco=Flow.Dco;
MDF.Tlfsmo=Flow.SmoothingTime;
MDF.ThetQH=Flow.ThetQH;
if Flow.ForresterHor==1
    MDF.Forfuv='Y';
else
    MDF.Forfuv='N';
end
if Flow.ForresterVer==1
    MDF.Forfww='Y';
else
    MDF.Forfww='N';
end
if Flow.SigmaCorrection
    MDF.Sigcor='Y';
else
    MDF.Sigcor='N';
end
MDF.Trasol=Flow.TraSol;
MDF.Momsol=Flow.MomSol;

if Flow.NrDischarges>0
    MDF.Filsrc=Flow.SrcFile;
    MDF.Fmtsrc='FR';
    MDF.Fildis=Flow.DisFile;
    MDF.Fmtdis='FR';
end

if Flow.NrObservationPoints>0
    MDF.Filsta=Flow.ObsFile;
    MDF.Fmtsta='FR';
end
if Flow.NrCrossSections>0
    MDF.Filcrs=Flow.CrsFile;
    MDF.Fmtcrs='FR';
end

MDF.SMhydr= 'YYYYY';
MDF.SMderv= 'YYYYYY';
MDF.SMproc= 'YYYYYYYYYY';
MDF.PMhydr= 'YYYYYY';
MDF.PMderv= 'YYY';
MDF.PMproc= 'YYYYYYYYYY';
MDF.SHhydr= 'YYYY';
MDF.SHderv= 'YYYYY';
MDF.SHproc= 'YYYYYYYYYY';
MDF.SHflux= 'YYYY';
MDF.PHhydr= 'YYYYYY';
MDF.PHderv= 'YYY';
MDF.PHproc= 'YYYYYYYYYY';
MDF.PHflux= 'YYYY';
if Flow.OnlineVisualisation
    MDF.Online='Y';
else
    MDF.Online='N';
end
if Flow.OnlineCoupling
    MDF.Waqmod='Y';
else
    MDF.Waqmod='N';
end
if Flow.OnlineWave
    MDF.WaveOL='Y';
else
    MDF.WaveOL='N';
end
MDF.Prhis=[0 0 0];
tstart=(Flow.MapStartTime-Flow.ItDate)*1440.0;
tstop=(Flow.MapStopTime-Flow.ItDate)*1440.0;
tint=Flow.MapInterval;
MDF.Flmap=[tstart tint tstop];
tstart=(Flow.StartTime-Flow.ItDate)*1440.0;
tstop=(Flow.StopTime-Flow.ItDate)*1440.0;
if Flow.NrObservationPoints>0
    MDF.Flhis=[tstart Flow.HisInterval tstop];
else
    MDF.Flhis=[tstart 0.0 tstop];
end
tstart=(Flow.ComStartTime-Flow.ItDate)*1440.0;
tstop=(Flow.ComStopTime-Flow.ItDate)*1440.0;
tint=Flow.ComInterval;
MDF.Flpp =[tstart tint tstop];
MDF.Flrst=Flow.RstInterval;

met=0;
if ~isempty(Flow.Filwp)
    MDF.Filwp=Flow.Filwp;
    met=1;
end
if ~isempty(Flow.Filwu)
    MDF.Filwu=Flow.Filwu;
    met=1;
end
if ~isempty(Flow.Filwv)
    MDF.Filwv=Flow.Filwv;
    met=1;
end
if met
    MDF.Wndgrd=Flow.Wndgrd;
    MDF.MNmaxw=Flow.MNmaxw;
end

%%
fname=[runid '.mdf'];

fid=fopen(fname,'w');

Names = fieldnames(MDF);

for i=1:length(Names)
    switch lower(Names{i})
        case{'runtxt'}
            if size(MDF.Runtxt,1)==0
                MDF.Runtxt=' ';
            end
            rtxt=deblank(MDF.Runtxt(1,:));
            str=[Names{i} repmat(' ',1,6-length(Names{i})) '= #' rtxt repmat(' ',1,30-length(rtxt)) '#'];
            fprintf(fid,'%s\n',str);
            n=size(MDF.Runtxt,1);
            for j=2:min(n,10)
                str=['        #' deblank(MDF.Runtxt(j,:)) repmat(' ',1,30-length(deblank(MDF.Runtxt(j,:)))) '#'];
                fprintf(fid,'%s\n',str);
            end
        case{'mnkmax','tzone','ktemp','irov','iter','hturnd','mnmaxw'}
            % integers
            n=length(getfield(MDF,Names{i}));
            fmt=[repmat(' %3i',1,n)];
            str=[Names{i} repmat(' ',1,6-length(Names{i})) '= ' num2str(getfield(MDF,Names{i}),fmt) ];
            fprintf(fid,'%s\n',str);
        case{'alph0','u0','v0'}
            str=[Names{i} repmat(' ',1,6-length(Names{i})) '= [.]' ];
            fprintf(fid,'%s\n',str);
        case{'thick','rettis','rettib','s0','t0','c01','c02','c03','c04','c05','c06','c07','c08','c09'}
            par=getfield(MDF,Names{i});
            sz=length(par);
            str=[Names{i} repmat(' ',1,6-length(Names{i})) '= ' num2str(par(1),'%16.7e')];
            fprintf(fid,'%s\n',str);
            if sz>1
                for j=2:sz
                    str=[repmat(' ',1,8) num2str(par(j),'%16.7e')];
                    fprintf(fid,'%s\n',str);
                end
            end
        case{'tidfor'}
            if size(getfield(MDF,Names{i}))>0
                str='Tidfor= #M2 S2 N2 K2 #';
                fprintf(fid,'%s\n',str);
                str='        #K1 O1 P1 Q1 #';
                fprintf(fid,'%s\n',str);
                str='        #MF MM SSA---#';
                fprintf(fid,'%s\n',str);
            end
        case{'itdate'}
            str='Itdate= #ITDATEKEY#';
            fprintf(fid,'%s\n',str);
        case{'tstart'}
            str='Tstart= TSTARTKEY';
            fprintf(fid,'%s\n',str);
        case{'tstop'}
            str='Tstop = TSTOPKEY';
            fprintf(fid,'%s\n',str);
        case{'dt'}
            str='Dt    = DTKEY';
            fprintf(fid,'%s\n',str);
        case{'restid'}
            str='Restid= RESTIDKEY';
            fprintf(fid,'%s\n',str);
        case{'flmap'}
            str='Flmap = TMAPSTARTKEY   DTMAPKEY  TSTOPKEY';
            fprintf(fid,'%s\n',str);
        case{'flhis'}
            str='Flhis = TSTARTKEY   DTHISKEY  TSTOPKEY';
            fprintf(fid,'%s\n',str);
        case{'flpp'}
            str='Flpp  = TCOMSTARTKEY   DTCOMKEY  TSTOPKEY';
            fprintf(fid,'%s\n',str);
        case{'flrst'}
            str='Flrst = DTRSTKEY';
            fprintf(fid,'%s\n',str);
        otherwise
            if ischar(getfield(MDF,Names{i}))
                % string
                str=[Names{i} repmat(' ',1,6-length(Names{i})) '= #' getfield(MDF,Names{i}) '#'];
            else
                % scientific
                n=length(getfield(MDF,Names{i}));
                fmt=[repmat(' %15.7e',1,n)];
                str=[Names{i} repmat(' ',1,6-length(Names{i})) '= ' num2str(getfield(MDF,Names{i}),fmt) ];
            end
            fprintf(fid,'%s\n',str);
    end
end
str='METEO1KEY';
fprintf(fid,'%s\n',str);
str='METEO2KEY';
fprintf(fid,'%s\n',str);
str='METEO3KEY';
fprintf(fid,'%s\n',str);
str='METEO4KEY';
fprintf(fid,'%s\n',str);
str='METEO5KEY';
fprintf(fid,'%s\n',str);

fclose(fid);

