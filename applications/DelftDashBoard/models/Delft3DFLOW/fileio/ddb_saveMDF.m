function handles=ddb_saveMDF(handles,id)

handles=ddb_countOpenBoundaries(handles,id);

Flow=handles.Model(md).Input(id);

runid=handles.Model(md).Input(id).Runid;

incconst=Flow.Salinity.Include || Flow.Temperature.Include || Flow.Sediments || Flow.Tracers;

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
if Flow.nrDryPoints>0
    MDF.Fildry=Flow.DryFile;
    MDF.Fmtdry='FR';
end
if Flow.NrThinDams>0
    MDF.Filtd=Flow.ThdFile;
    MDF.Fmttd='FR';
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
if Flow.NrDrogues>0
    MDF.Sub2(1)='P';
end
if Flow.Sediments || Flow.Tracers
    MDF.Sub2(2)='C';
end
if Flow.Waves
    MDF.Sub2(3)='W';
end
k=0;
if Flow.Sediments
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
switch Flow.WindType
    case 'Uniform'
        MDF.Wnsvwp='N';
    case 'SpaceVarying'
        MDF.Wnsvwp='Y';
end
MDF.Wndint=Flow.WndInt;
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
        if Flow.Sediments
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
if Flow.NrDrogues>0
    MDF.Filpar=Flow.DroFile;
    MDF.Fmtpar='FR';
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

if Flow.KMax>1
    if strcmpi(Flow.LayerType,'z')
        MDF.Zmodel='Y';
        MDF.Zbot=Flow.ZBot;
        MDF.Ztop=Flow.ZTop;
    end
end

%%
fname=[handles.Model(md).Input(id).Runid '.mdf'];

fid=fopen(fname,'w');

Names = fieldnames(MDF);

for i=1:length(Names)
    switch lower(Names{i})
        case{'runtxt'}
            Runtxt=strvcat(MDF.Runtxt);
            if size(Runtxt,1)==0
                Runtxt=' ';
            end
            rtxt=deblank(Runtxt(1,:));
            str=[Names{i} repmat(' ',1,6-length(Names{i})) '= #' rtxt repmat(' ',1,30-length(rtxt)) '#'];
            fprintf(fid,'%s\n',str);
            n=size(Runtxt,1);
            for j=2:min(n,10)
                str=['        #' deblank(Runtxt(j,:)) repmat(' ',1,30-length(deblank(Runtxt(j,:)))) '#'];
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
fclose(fid);

ddb_writeBatchFile(runid);
