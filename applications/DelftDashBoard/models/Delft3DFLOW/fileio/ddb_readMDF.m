function handles=ddb_readMDF(handles,filename,id)

MDF=ddb_readMDFText(filename);

handles.Model(md).Input(id).grdFile=MDF.Filcco;
handles.Model(md).Input(id).description=MDF.Runtxt;
if isfield(MDF,'Anglat')
    handles.Model(md).Input(id).latitude=MDF.Anglat;
end
handles.Model(md).Input(id).orientation=MDF.Grdang;
handles.Model(md).Input(id).encFile=MDF.Filgrd;
handles.Model(md).Input(id).MMax=MDF.MNKmax(1);
handles.Model(md).Input(id).NMax=MDF.MNKmax(2);
handles.Model(md).Input(id).KMax=MDF.MNKmax(3);
handles.Model(md).Input(id).thick=MDF.Thick;
handles.Model(md).Input(id).dryFile=MDF.Fildry;
handles.Model(md).Input(id).thdFile=MDF.Filtd;
if isfield(MDF,'Fildep')
    handles.Model(md).Input(id).depFile=MDF.Fildep;
    handles.Model(md).Input(id).uniformDepth=10.0;
else
    handles.Model(md).Input(id).depFile='';
    handles.Model(md).Input(id).uniformDepth=10.0;
end;    
handles.Model(md).Input(id).itDate=datenum(MDF.Itdate,'yyyy-mm-dd');
handles.Model(md).Input(id).itDateString=datestr(handles.Model(md).Input(id).itDate,'yyyy mm dd');
handles.Model(md).Input(id).startTime=handles.Model(md).Input(id).itDate+MDF.Tstart/1440.0;
handles.Model(md).Input(id).stopTime= handles.Model(md).Input(id).itDate+MDF.Tstop/1440.0;
% handles.Model(md).Input(id).StartTimeString=datestr(handles.Model(md).Input(id).startTime,'yyyy mm dd HH MM SS');
% handles.Model(md).Input(id).StopTimeString =datestr(handles.Model(md).Input(id).stopTime, 'yyyy mm dd HH MM SS');
handles.Model(md).Input(id).timeStep=MDF.Dt;
handles.Model(md).Input(id).timeZone=MDF.Tzone;
if ~isempty(MDF.Sub1)
    if MDF.Sub1(1)=='S'
        handles.Model(md).Input(id).salinity.include=1;
    end
    if MDF.Sub1(2)=='T'
        handles.Model(md).Input(id).temperature.include=1;
    end
    if MDF.Sub1(3)=='W'
        handles.Model(md).Input(id).wind=1;
    end
    if MDF.Sub1(4)=='I'
        handles.Model(md).Input(id).secondaryFlow=1;
    end
end
if ~isempty(MDF.Sub2)
    if MDF.Sub2(2)=='C'
        handles.Model(md).Input(id).constituents=1;
    end
    if MDF.Sub2(3)=='W'
        handles.Model(md).Input(id).waves=1;
    end
end
for i=1:5
    fld=deblank(getfield(MDF,['Namc' num2str(i)]));
    if ~isempty(fld)
        if strcmpi(fld(1:min(8,length(fld))),'sediment')
            handles.Model(md).Input(id).sediments=1;
            handles.Model(md).Input(id).nrSediments=handles.Model(md).Input(id).nrSediments+1;
            handles.Model(md).Input(id).nrConstituents=handles.Model(md).Input(id).nrConstituents+1;
            k=handles.Model(md).Input(id).nrSediments;
            handles.Model(md).Input(id).sediment(k).name=deblank(fld);
        else
            handles.Model(md).Input(id).tracers=1;
            handles.Model(md).Input(id).nrConstituents=handles.Model(md).Input(id).nrConstituents+1;
            handles.Model(md).Input(id).nrTracers=handles.Model(md).Input(id).nrTracers+1;
            k=handles.Model(md).Input(id).nrTracers;
            handles.Model(md).Input(id).tracer(k).name=deblank(fld);
        end
    end
end

handles.Model(md).Input(id).zeta0=MDF.Zeta0;
handles.Model(md).Input(id).u0=0.0;
handles.Model(md).Input(id).v0=0.0;
handles.Model(md).Input(id).s0=0.0;
handles.Model(md).Input(id).c0=0.0;
handles.Model(md).Input(id).wndFile=MDF.Filwnd;
if MDF.Wnsvwp=='N'
    handles.Model(md).Input(id).windType='Uniform';
else
    handles.Model(md).Input(id).windType='SpaceVarying';
end
if ~isempty(MDF.Filic)
    handles.Model(md).Input(id).iniFile=MDF.Filic;
    handles.Model(md).Input(id).initialConditions='ini';
else
    handles.Model(md).Input(id).iniFile='';
end
if ~isempty(MDF.Restid)
    handles.Model(md).Input(id).rstId=MDF.Restid;
    handles.Model(md).Input(id).initialConditions='rst';
else
    handles.Model(md).Input(id).rstId='';
end
% if isfield(MDF,'trim')
%     handles.Model(md).Input(id).RstId=MDF.Restid;
%     handles.Model(md).Input(id).InitialConditions='rst';
% else
%     handles.Model(md).Input(id).RstId='';
% end
handles.Model(md).Input(id).bndFile=MDF.Filbnd;
handles.Model(md).Input(id).bchFile=MDF.FilbcH;
handles.Model(md).Input(id).bctFile=MDF.FilbcT;
handles.Model(md).Input(id).bcaFile=MDF.Filana;
handles.Model(md).Input(id).corFile=MDF.Filcor;
handles.Model(md).Input(id).bcqFile=MDF.FilbcQ;
if isfield(MDF,'FilbcC')
    handles.Model(md).Input(id).bccFile=MDF.FilbcC;
else
    handles.Model(md).Input(id).bccFile='';
end    
handles.Model(md).Input(id).srcFile=MDF.Filsrc;
handles.Model(md).Input(id).disFile=MDF.Fildis;
handles.Model(md).Input(id).g=MDF.Ag;
handles.Model(md).Input(id).rhoW=MDF.Rhow;
%Alph0 = [.]
handles.Model(md).Input(id).tempW=MDF.Tempw;
handles.Model(md).Input(id).salW=MDF.Salw;
handles.Model(md).Input(id).rouWav=MDF.Rouwav;
handles.Model(md).Input(id).windStress=MDF.Wstres;
handles.Model(md).Input(id).rhoAir=MDF.Rhoa;
handles.Model(md).Input(id).betaC=MDF.Betac;
if MDF.Equili(1)=='N'
    handles.Model(md).Input(id).equili=0;
else
    handles.Model(md).Input(id).equili=1;
end
if isempty(deblank(MDF.Tkemod))
    handles.Model(md).Input(id).verticalTurbulenceModel='K-epsilon   ';
else
    handles.Model(md).Input(id).verticalTurbulenceModel=MDF.Tkemod;
end
handles.Model(md).Input(id).kTemp=MDF.Ktemp;
handles.Model(md).Input(id).fClou=MDF.Fclou;
handles.Model(md).Input(id).sArea=MDF.Sarea;
if MDF.Temint(1)=='N'
    handles.Model(md).Input(id).temint=0;
else
    handles.Model(md).Input(id).temint=1;
end
handles.Model(md).Input(id).roughnessType=MDF.Roumet;
handles.Model(md).Input(id).uRoughness=MDF.Ccofu;
handles.Model(md).Input(id).vRoughness=MDF.Ccofv;
handles.Model(md).Input(id).xlo=MDF.Xlo;
handles.Model(md).Input(id).vicoUV=MDF.Vicouv;
handles.Model(md).Input(id).dicoUV=MDF.Dicouv;
if MDF.Htur2d(1)=='N'
    handles.Model(md).Input(id).HLES=0;
else
    handles.Model(md).Input(id).HLES=1;
    handles.Model(md).Input(id).Htural=MDF.Htural;
    handles.Model(md).Input(id).Hturnd=MDF.Hturnd;
    handles.Model(md).Input(id).Hturst=MDF.Hturst;
    handles.Model(md).Input(id).Hturlp=MDF.Hturlp;
    handles.Model(md).Input(id).Hturrt=MDF.Hturrt;
    handles.Model(md).Input(id).Hturdm=MDF.Hturdm;
    handles.Model(md).Input(id).Hturel=1;
end
if isfield(MDF,'Vicoww')
    handles.Model(md).Input(id).vicoWW=MDF.Vicoww;
    handles.Model(md).Input(id).vicoWW=MDF.Dicoww;
end
handles.Model(md).Input(id).irov=MDF.Irov;
if isfield(MDF,'Filsed')
    handles.Model(md).Input(id).sedFile=MDF.Filsed;
else
    handles.Model(md).Input(id).sedFile='';
end
if isfield(MDF,'Filmor')
    handles.Model(md).Input(id).morFile=MDF.Filmor;
else
    handles.Model(md).Input(id).morFile='';
end
handles.Model(md).Input(id).iter=MDF.Iter;
if strcmpi(MDF.Dryflp(1),'n')
    handles.Model(md).Input(id).dryFlp=0;
else
    handles.Model(md).Input(id).dryFlp=1;
end
handles.Model(md).Input(id).dpsOpt=MDF.Dpsopt;
handles.Model(md).Input(id).dpuOpt=MDF.Dpuopt;
handles.Model(md).Input(id).dryFlc=MDF.Dryflc;
handles.Model(md).Input(id).dco=MDF.Dco;
handles.Model(md).Input(id).smoothingTime=MDF.Tlfsmo;
handles.Model(md).Input(id).thetQH=MDF.ThetQH;
if MDF.Forfuv(1)=='N'
    handles.Model(md).Input(id).forresterHor=0;
else
    handles.Model(md).Input(id).forresterHor=1;
end
if MDF.Forfww(1)=='N'
    handles.Model(md).Input(id).forresterVer=0;
else
    handles.Model(md).Input(id).forresterVer=1;
end
if strcmpi(MDF.Sigcor(1),'n')
    handles.Model(md).Input(id).sigmaCorrection=0;
else
    handles.Model(md).Input(id).sigmaCorrection=1;
end
handles.Model(md).Input(id).traSol=MDF.Trasol;
handles.Model(md).Input(id).momSol=MDF.Momsol;
handles.Model(md).Input(id).obsFile=MDF.Filsta;
handles.Model(md).Input(id).crsFile=MDF.Filcrs;
handles.Model(md).Input(id).droFile=MDF.Filpar;
% SMhydr= #YYYYY#
% SMderv= #YYYYYY#
% SMproc= #YYYYYYYYYY#
% PMhydr= #YYYYYY#
% PMderv= #YYY#
% PMproc= #YYYYYYYYYY#
% SHhydr= #YYYY#
% SHderv= #YYYYY#
% SHproc= #YYYYYYYYYY#
% SHflux= #YYYY#
% PHhydr= #YYYYYY#
% PHderv= #YYY#
% PHproc= #YYYYYYYYYY#
% PHflux= #YYYY#
if MDF.Online(1)=='N'
    handles.Model(md).Input(id).onlineVisualisation=0;
else
    handles.Model(md).Input(id).onlineVisualisation=1;
end
if isfield(MDF,'Waqmod')
    if MDF.Waqmod(1)=='N'
        handles.Model(md).Input(id).waqMod=0;
    else
        handles.Model(md).Input(id).waqMod=1;
    end
end
if isfield(MDF,'WaveOL')
    if MDF.WaveOL(1)=='N'
        handles.Model(md).Input(id).waveOnline=0;
    else
        handles.Model(md).Input(id).waveOnline=1;
    end
end
handles.Model(md).Input(id).prHis=MDF.Prhis;
handles.Model(md).Input(id).mapStartTime=handles.Model(md).Input(id).itDate+MDF.Flmap(1)/1440;
handles.Model(md).Input(id).mapInterval=MDF.Flmap(2);
handles.Model(md).Input(id).mapStopTime=handles.Model(md).Input(id).itDate+MDF.Flmap(3)/1440;
handles.Model(md).Input(id).hisInterval=MDF.Flhis(2);
handles.Model(md).Input(id).comStartTime=handles.Model(md).Input(id).itDate+MDF.Flpp(1)/1440;
handles.Model(md).Input(id).comInterval=MDF.Flpp(2);
handles.Model(md).Input(id).comStopTime=handles.Model(md).Input(id).itDate+MDF.Flpp(3)/1440;
handles.Model(md).Input(id).restartInterval=MDF.Flrst;

handles.Model(md).Input(id).filwp=MDF.Filwp;
handles.Model(md).Input(id).filwu=MDF.Filwu;
handles.Model(md).Input(id).filwv=MDF.Filwv;
handles.Model(md).Input(id).wndgrd=MDF.Wndgrd;
handles.Model(md).Input(id).MNmaxw=MDF.MNmaxw;

if isfield(MDF,'Zmodel')
    if strcmpi(MDF.Zmodel,'y')
        handles.Model(md).Input(id).layerType='z';
    end
end
if isfield(MDF,'Zbot')
    handles.Model(md).Input(id).zBot=MDF.Zbot;
end
if isfield(MDF,'Ztop')
    handles.Model(md).Input(id).zTop=MDF.Ztop;
end

% snelli= #no#
% Cstbnd= #yes#
% Roller= #yes#
% Commnt=
% Gamdis= 0.7
% betaro= 0.05
% F_lam = -2.0
% Thr   = 0.01
% TraFrm= #vrijn2004.frm#
% Trtrou= #Y#
% Trtdef= #vrijn04.trt#
% Trtu  = #trtuv.inp#
% Trtv  = #trtuv.inp#
% TrtDt = 2.
