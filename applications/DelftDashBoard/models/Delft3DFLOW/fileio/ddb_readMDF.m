function handles=ddb_readMDF(handles,filename,id)

MDF=ddb_readMDFText(filename);

%handles.ScreenParameters.CoordinateSystem='Spherical';

handles.Model(md).Input(id).GrdFile=MDF.Filcco;
handles.Model(md).Input(id).Description=MDF.Runtxt;
if isfield(MDF,'Anglat')
    handles.Model(md).Input(id).Latitude=MDF.Anglat;
%    handles.ScreenParameters.CoordinateSystem='Cartesian';
end
handles.Model(md).Input(id).Orientation=MDF.Grdang;
handles.Model(md).Input(id).EncFile=MDF.Filgrd;
handles.Model(md).Input(id).MMax=MDF.MNKmax(1);
handles.Model(md).Input(id).NMax=MDF.MNKmax(2);
handles.Model(md).Input(id).KMax=MDF.MNKmax(3);
handles.Model(md).Input(id).Thick=MDF.Thick;
handles.Model(md).Input(id).DryFile=MDF.Fildry;
handles.Model(md).Input(id).ThdFile=MDF.Filtd;
if isfield(MDF,'Fildep')
    handles.Model(md).Input(id).DepFile=MDF.Fildep;
    handles.Model(md).Input(id).UniformDepth=10.0;
else
    handles.Model(md).Input(id).DepFile='';
    handles.Model(md).Input(id).UniformDepth=10.0;
end;    
handles.Model(md).Input(id).ItDate=datenum(MDF.Itdate,'yyyy-mm-dd');
handles.Model(md).Input(id).ItDateString=datestr(handles.Model(md).Input(id).ItDate,'yyyy mm dd');
handles.Model(md).Input(id).StartTime=handles.Model(md).Input(id).ItDate+MDF.Tstart/1440.0;
handles.Model(md).Input(id).StopTime= handles.Model(md).Input(id).ItDate+MDF.Tstop/1440.0;
% handles.Model(md).Input(id).StartTimeString=datestr(handles.Model(md).Input(id).StartTime,'yyyy mm dd HH MM SS');
% handles.Model(md).Input(id).StopTimeString =datestr(handles.Model(md).Input(id).StopTime, 'yyyy mm dd HH MM SS');
handles.Model(md).Input(id).TimeStep=MDF.Dt;
handles.Model(md).Input(id).TimeZone=MDF.Tzone;
if ~isempty(MDF.Sub1)
    if MDF.Sub1(1)=='S'
        handles.Model(md).Input(id).Salinity.Include=1;
    end
    if MDF.Sub1(2)=='T'
        handles.Model(md).Input(id).Temperature.Include=1;
    end
    if MDF.Sub1(3)=='W'
        handles.Model(md).Input(id).Wind=1;
    end
    if MDF.Sub1(4)=='I'
        handles.Model(md).Input(id).SecondaryFlow=1;
    end
end
if ~isempty(MDF.Sub2)
    if MDF.Sub2(2)=='C'
        handles.Model(md).Input(id).Constituents=1;
    end
    if MDF.Sub2(3)=='W'
        handles.Model(md).Input(id).Waves=1;
    end
end
for i=1:5
    fld=deblank(getfield(MDF,['Namc' num2str(i)]));
    if ~isempty(fld)
        if strcmpi(fld(1:min(8,length(fld))),'sediment')
            handles.Model(md).Input(id).Sediments=1;
            handles.Model(md).Input(id).NrSediments=handles.Model(md).Input(id).NrSediments+1;
            handles.Model(md).Input(id).NrConstituents=handles.Model(md).Input(id).NrConstituents+1;
            k=handles.Model(md).Input(id).NrSediments;
            handles.Model(md).Input(id).Sediment(k).Name=deblank(fld);
        else
            handles.Model(md).Input(id).Tracers=1;
            handles.Model(md).Input(id).NrConstituents=handles.Model(md).Input(id).NrConstituents+1;
            handles.Model(md).Input(id).NrTracers=handles.Model(md).Input(id).NrTracers+1;
            k=handles.Model(md).Input(id).NrTracers;
            handles.Model(md).Input(id).Tracer(k).Name=deblank(fld);
        end
    end
end

handles.Model(md).Input(id).Zeta0=MDF.Zeta0;
handles.Model(md).Input(id).U0=0.0;
handles.Model(md).Input(id).V0=0.0;
handles.Model(md).Input(id).S0=0.0;
handles.Model(md).Input(id).C0=0.0;
handles.Model(md).Input(id).WndFile=MDF.Filwnd;
if MDF.Wnsvwp=='N'
    handles.Model(md).Input(id).WindType='Uniform';
else
    handles.Model(md).Input(id).WindType='SpaceVarying';
end
if ~isempty(MDF.Filic)
    handles.Model(md).Input(id).IniFile=MDF.Filic;
    handles.Model(md).Input(id).InitialConditions='ini';
else
    handles.Model(md).Input(id).IniFile='';
end
if ~isempty(MDF.Restid)
    handles.Model(md).Input(id).RstId=MDF.Restid;
    handles.Model(md).Input(id).InitialConditions='rst';
else
    handles.Model(md).Input(id).RstId='';
end
% if isfield(MDF,'trim')
%     handles.Model(md).Input(id).RstId=MDF.Restid;
%     handles.Model(md).Input(id).InitialConditions='rst';
% else
%     handles.Model(md).Input(id).RstId='';
% end
handles.Model(md).Input(id).BndFile=MDF.Filbnd;
handles.Model(md).Input(id).BchFile=MDF.FilbcH;
handles.Model(md).Input(id).BctFile=MDF.FilbcT;
handles.Model(md).Input(id).BcaFile=MDF.Filana;
handles.Model(md).Input(id).CorFile=MDF.Filcor;
handles.Model(md).Input(id).BcqFile=MDF.FilbcQ;
if isfield(MDF,'FilbcC')
    handles.Model(md).Input(id).BccFile=MDF.FilbcC;
else
    handles.Model(md).Input(id).BccFile='';
end    
handles.Model(md).Input(id).SrcFile=MDF.Filsrc;
handles.Model(md).Input(id).DisFile=MDF.Fildis;
handles.Model(md).Input(id).G=MDF.Ag;
handles.Model(md).Input(id).RhoW=MDF.Rhow;
%Alph0 = [.]
handles.Model(md).Input(id).TempW=MDF.Tempw;
handles.Model(md).Input(id).SalW=MDF.Salw;
handles.Model(md).Input(id).RouWav=MDF.Rouwav;
handles.Model(md).Input(id).WindStress=MDF.Wstres;
handles.Model(md).Input(id).RhoAir=MDF.Rhoa;
handles.Model(md).Input(id).BetaC=MDF.Betac;
if MDF.Equili(1)=='N'
    handles.Model(md).Input(id).Equili=0;
else
    handles.Model(md).Input(id).Equili=1;
end
if isempty(deblank(MDF.Tkemod))
    handles.Model(md).Input(id).VerticalTurbulenceModel='K-epsilon   ';
else
    handles.Model(md).Input(id).VerticalTurbulenceModel=MDF.Tkemod;
end
handles.Model(md).Input(id).KTemp=MDF.Ktemp;
handles.Model(md).Input(id).FClou=MDF.Fclou;
handles.Model(md).Input(id).SArea=MDF.Sarea;
if MDF.Temint(1)=='N'
    handles.Model(md).Input(id).Temint=0;
else
    handles.Model(md).Input(id).Temint=1;
end
handles.Model(md).Input(id).RoughnessType=MDF.Roumet;
handles.Model(md).Input(id).URoughness=MDF.Ccofu;
handles.Model(md).Input(id).VRoughness=MDF.Ccofv;
handles.Model(md).Input(id).Xlo=MDF.Xlo;
handles.Model(md).Input(id).VicoUV=MDF.Vicouv;
handles.Model(md).Input(id).DicoUV=MDF.Dicouv;
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
    handles.Model(md).Input(id).VicoWW=MDF.Vicoww;
    handles.Model(md).Input(id).DicoWW=MDF.Dicoww;
end
handles.Model(md).Input(id).Irov=MDF.Irov;
if isfield(MDF,'Filsed')
    handles.Model(md).Input(id).SedFile=MDF.Filsed;
else
    handles.Model(md).Input(id).SedFile='';
end
if isfield(MDF,'Filmor')
    handles.Model(md).Input(id).MorFile=MDF.Filmor;
else
    handles.Model(md).Input(id).MorFile='';
end
handles.Model(md).Input(id).Iter=MDF.Iter;
if strcmpi(MDF.Dryflp(1),'n')
    handles.Model(md).Input(id).DryFlp=0;
else
    handles.Model(md).Input(id).DryFlp=1;
end
handles.Model(md).Input(id).DpsOpt=MDF.Dpsopt;
handles.Model(md).Input(id).DpuOpt=MDF.Dpuopt;
handles.Model(md).Input(id).DryFlc=MDF.Dryflc;
handles.Model(md).Input(id).Dco=MDF.Dco;
handles.Model(md).Input(id).SmoothingTime=MDF.Tlfsmo;
handles.Model(md).Input(id).ThetQH=MDF.ThetQH;
if MDF.Forfuv(1)=='N'
    handles.Model(md).Input(id).ForresterHor=0;
else
    handles.Model(md).Input(id).ForresterHor=1;
end
if MDF.Forfww(1)=='N'
    handles.Model(md).Input(id).ForresterVer=0;
else
    handles.Model(md).Input(id).ForresterVer=1;
end
if strcmpi(MDF.Sigcor(1),'n')
    handles.Model(md).Input(id).SigmaCorrection=0;
else
    handles.Model(md).Input(id).SigmaCorrection=1;
end
handles.Model(md).Input(id).TraSol=MDF.Trasol;
handles.Model(md).Input(id).MomSol=MDF.Momsol;
handles.Model(md).Input(id).ObsFile=MDF.Filsta;
handles.Model(md).Input(id).CrsFile=MDF.Filcrs;
handles.Model(md).Input(id).DroFile=MDF.Filpar;
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
    handles.Model(md).Input(id).OnlineVisualisation=0;
else
    handles.Model(md).Input(id).OnlineVisualisation=1;
end
if isfield(MDF,'Waqmod')
    if MDF.Waqmod(1)=='N'
        handles.Model(md).Input(id).WaqMod=0;
    else
        handles.Model(md).Input(id).WaqMod=1;
    end
end
if isfield(MDF,'WaveOL')
    if MDF.WaveOL(1)=='N'
        handles.Model(md).Input(id).WaveOnline=0;
    else
        handles.Model(md).Input(id).WaveOnline=1;
    end
end
handles.Model(md).Input(id).PrHis=MDF.Prhis;
handles.Model(md).Input(id).MapStartTime=handles.Model(md).Input(id).ItDate+MDF.Flmap(1)/1440;
handles.Model(md).Input(id).MapInterval=MDF.Flmap(2);
handles.Model(md).Input(id).MapStopTime=handles.Model(md).Input(id).ItDate+MDF.Flmap(3)/1440;
handles.Model(md).Input(id).HisInterval=MDF.Flhis(2);
handles.Model(md).Input(id).ComStartTime=handles.Model(md).Input(id).ItDate+MDF.Flpp(1)/1440;
handles.Model(md).Input(id).ComInterval=MDF.Flpp(2);
handles.Model(md).Input(id).ComStopTime=handles.Model(md).Input(id).ItDate+MDF.Flpp(3)/1440;
handles.Model(md).Input(id).RestartInterval=MDF.Flrst;

handles.Model(md).Input(id).Filwp=MDF.Filwp;
handles.Model(md).Input(id).Filwu=MDF.Filwu;
handles.Model(md).Input(id).Filwv=MDF.Filwv;
handles.Model(md).Input(id).Wndgrd=MDF.Wndgrd;
handles.Model(md).Input(id).MNmaxw=MDF.MNmaxw;

if isfield(MDF,'Zmodel')
    if strcmpi(MDF.Zmodel,'y')
        handles.Model(md).Input(id).LayerType='z';
    end
end
if isfield(MDF,'Zbot')
    handles.Model(md).Input(id).ZBot=MDF.Zbot;
end
if isfield(MDF,'Ztop')
    handles.Model(md).Input(id).ZTop=MDF.Ztop;
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
