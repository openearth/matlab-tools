function writeMDF(hm,m,fname)

Model=hm.Models(m);

fid=fopen(fname,'wt');

inpdir=[Model.Dir 'input' filesep];

itdate=D3DTimeString(Model.RefTime,'itdatemdf');
tstart=num2str((Model.TFlowStart-Model.RefTime)*1440);
tstop =num2str((Model.TStop-Model.RefTime)*1440);
tout  =num2str((Model.TOutputStart-Model.RefTime)*1440);
twav  =num2str((Model.TWaveStart-Model.RefTime)*1440);
dt=num2str(Model.TimeStep);

dtmap=num2str(Model.MapTimeStep);
dtcom=num2str(Model.ComTimeStep);
dthis=num2str(Model.HisTimeStep);
%dtrst=num2str(Model.RstInterval);
dtrst=num2str(720);

grd=wlgrid('read',[inpdir Model.Name '.grd']);
mmax=size(grd.X,1)+1;
nmax=size(grd.X,2)+1;
kmax=Model.KMax;

fprintf(fid,'%s\n','Ident = #Delft3D-FLOW  .03.02 3.39.26#');
fprintf(fid,'%s\n','Runtxt= #                              #');
fprintf(fid,'%s\n',['Filcco= #' Model.Name '.grd#']);
fprintf(fid,'%s\n','Fmtcco= #FR#');
fprintf(fid,'%s\n','Grdang= 0.0000000e+000');
if ~strcmpi(Model.CoordinateSystemType,'geographic')
    [lon,lat]=convertCoordinates(Model.WebSite(1).Location(1),Model.WebSite(1).Location(2),'persistent','CS1.name',Model.CoordinateSystem,'CS1.type',Model.CoordinateSystemType,'CS2.name','WGS 84','CS2.type','geographic');
    fprintf(fid,'%s\n',['Anglat= ' num2str(lat)]);
end
fprintf(fid,'%s\n',['Filgrd= #' Model.Name '.enc#']);
fprintf(fid,'%s\n','Fmtgrd= #FR#');
fprintf(fid,'%s\n',['MNKmax= ' num2str(mmax) ' ' num2str(nmax) '   ' num2str(kmax)]);
%fprintf(fid,'%s\n','Thick = 1.0000000e+002');
fprintf(fid,'%s\n',['Thick = ' num2str(Model.thick(1))]);
for k=2:kmax
    fprintf(fid,'%s\n',['        ' num2str(Model.thick(k))]);
end
fprintf(fid,'%s\n',['Fildep= #' Model.Name '.dep#']);
fprintf(fid,'%s\n','Fmtdep= #FR#');
if exist([inpdir Model.Name '.thd'],'file')
    fprintf(fid,'%s\n',['Filtd = #' Model.Name '.thd#']);
    fprintf(fid,'%s\n','Fmttd = #FR#');
end
if exist([inpdir Model.Name '.dry'],'file')
    fprintf(fid,'%s\n',['Fildry= #' Model.Name '.dry#']);
    fprintf(fid,'%s\n','Fmtdry= #FR#');
end
fprintf(fid,'%s\n',['Itdate= #' itdate '#']);
fprintf(fid,'%s\n','Tunit = #M#');
fprintf(fid,'%s\n',['Tstart= ' tstart]);
fprintf(fid,'%s\n',['Tstop = ' tstop]);
fprintf(fid,'%s\n',['Dt    = ' dt]);
fprintf(fid,'%s\n','Tzone = 0');

sub1='  W ';
if Model.includeSalinity
    sub1(1)='S';
end
if Model.includeTemperature
    sub1(2)='T';
end
fprintf(fid,'%s\n',['Sub1  = #' sub1 '#']);

sub2='   ';
if ~isempty(Model.tracer)
    sub2(2)='C';
end
if strcmpi(Model.Type,'Delft3DFLOWWAVE')
    sub2(3)='W';
end
fprintf(fid,'%s\n',['Sub2  = #' sub2 '#']);

for j=1:length(Model.tracer)
    cstr=[Model.tracer(j).name repmat(' ',1,20-length(Model.tracer(j).name))];
    fprintf(fid,'%s\n',['Namc' num2str(j) ' = #' cstr '#']);
end

fprintf(fid,'%s\n','Commnt=               ');
fprintf(fid,'%s\n','Wnsvwp= #N#');
fprintf(fid,'%s\n','Filwnd= #dummy.wnd#');
fprintf(fid,'%s\n','Fmtwnd= #FR#');
fprintf(fid,'%s\n','Wndint= #Y#');
if ~isempty(Model.FlowRstFile)
    % Using a restart file
    fprintf(fid,'%s\n','Restid= #rst#');
elseif Model.makeIniFile
    % Using an ini file
    fprintf(fid,'%s\n',['Filic = #' Model.Name '.ini#']);    
    fprintf(fid,'%s\n','Fmtic = #FR#');
else
    % Uniform initial conditions
    fprintf(fid,'%s\n','Restid= ##');
    fprintf(fid,'%s\n',['Zeta0 = ' num2str(Model.Zeta0)]);
end
fprintf(fid,'%s\n',['Filbnd= #' Model.Name '.bnd#']);
fprintf(fid,'%s\n','Fmtbnd= #FR#');
if exist([inpdir Model.Name '.bct'],'file') || Model.FlowNested || strcmpi(Model.FlowNestType,'oceanmodel')
    fprintf(fid,'%s\n',['FilbcT= #' Model.Name '.bct#']);
    fprintf(fid,'%s\n','FmtbcT= #FR#');
end
if exist([inpdir Model.Name '.bca'],'file')
    fprintf(fid,'%s\n',['Filana= #' Model.Name '.bca#']);
    fprintf(fid,'%s\n','Fmtana= #FR#');
end
if exist([inpdir Model.Name '.bch'],'file')
    fprintf(fid,'%s\n',['FilbcH= #' Model.Name '.bch#']);
    fprintf(fid,'%s\n','FmtbcH= #FR#');
end
if Model.includeSalinity || Model.includeTemperature || ~isempty(Model.discharge)
    fprintf(fid,'%s\n',['Filbcc= #' Model.Name '.bcc#']);
    fprintf(fid,'%s\n','Fmtbcc= #FR#');
end

if ~isempty(Model.discharge)
    fprintf(fid,'%s\n',['Filsrc= #' Model.Name '.src#']);
    fprintf(fid,'%s\n','Fmtsrc= #FR#');
    fprintf(fid,'%s\n',['Fildis= #' Model.Name '.dis#']);
    fprintf(fid,'%s\n','Fmtdis= #FR#');
end

fprintf(fid,'%s\n','Ag    = 9.8100000e+000');
fprintf(fid,'%s\n','Rhow  = 1.0240000e+003');
fprintf(fid,'%s\n','Alph0 = [.]');
fprintf(fid,'%s\n','Tempw = 1.5000000e+001');
fprintf(fid,'%s\n','Salw  = 3.1000000e+001');
fprintf(fid,'%s\n','Rouwav= #FR84#');

fprintf(fid,'%s\n',['Wstres= ' num2str(Model.windStress(1)) '  ' num2str(Model.windStress(2)) '  ' num2str(Model.windStress(3)) '  ' num2str(Model.windStress(4))]);

fprintf(fid,'%s\n','Rhoa  = 1.0000000e+000');
fprintf(fid,'%s\n','Betac = 5.0000000e-001');
fprintf(fid,'%s\n','Equili= #Y#');
if kmax>1
    fprintf(fid,'%s\n','Tkemod= #K-epsilon   #');
else
    fprintf(fid,'%s\n','Tkemod= #            #');
end
if Model.includeTemperature
    fprintf(fid,'%s\n','Ktemp = 5');
    fprintf(fid,'%s\n','Fclou =  0.0000000e+000');
    fprintf(fid,'%s\n','Sarea =  6.0000000e+009');
    fprintf(fid,'%s\n','Secchi=  3.0000000e+000');
    fprintf(fid,'%s\n','Stantn=  1.4500000e-003');
    fprintf(fid,'%s\n','Dalton=  1.2000000e-003');
    fprintf(fid,'%s\n','Filtmp= #dummy.tem#');
    fprintf(fid,'%s\n','Fmttmp= #FR#');
else
    fprintf(fid,'%s\n','Ktemp = 0');
    fprintf(fid,'%s\n','Fclou = 0.0000000e+000');
    fprintf(fid,'%s\n','Sarea = 0.0000000e+000');
end
fprintf(fid,'%s\n','Temint= #Y#');
if Model.useTidalForces
    fprintf(fid,'%s\n','Tidfor= #M2 S2 N2 K2 #');
    fprintf(fid,'%s\n','        #K1 O1 P1 Q1 #');
    fprintf(fid,'%s\n','        #MF MM SSA---#');
end
fprintf(fid,'%s\n',['Roumet= #' Model.RouMet '#']);
if exist([inpdir Model.Name '.rgh'],'file')
    fprintf(fid,'%s\n',['Filrgh= #' Model.Name '.rgh#']);
    fprintf(fid,'%s\n','Fmtrgh= #FR#');
else
    fprintf(fid,'%s\n',['Ccofu = ' num2str(Model.Ccofu)]);
    fprintf(fid,'%s\n',['Ccofv = ' num2str(Model.Ccofu)]);
end
fprintf(fid,'%s\n',['Vicouv= ' num2str(Model.VicoUV)]);
fprintf(fid,'%s\n','Dicouv= 1.0000000e+000');
fprintf(fid,'%s\n','Htur2d= #N#');
fprintf(fid,'%s\n','Irov  = 0');
fprintf(fid,'%s\n','Iter  = 2');
fprintf(fid,'%s\n','Dryflp= #YES#');
fprintf(fid,'%s\n',['Dpsopt= #' Model.DpsOpt '#']);
if strcmpi(Model.layerType,'z')
    fprintf(fid,'%s\n','Dpuopt= #MIN#');
else
    fprintf(fid,'%s\n','Dpuopt= #MEAN#');
end
fprintf(fid,'%s\n','Dryflc= 1.0000000e-001');
fprintf(fid,'%s\n','Dco   = -9.9900000e+002');
if ~isempty(Model.FlowRstFile)
    fprintf(fid,'%s\n','Tlfsmo= 0.0000000e+000');
else
    fprintf(fid,'%s\n','Tlfsmo= 1.2000000e+002');
end
fprintf(fid,'%s\n','ThetQH= 0.0000000e+000');
fprintf(fid,'%s\n','Forfuv= #N#');
fprintf(fid,'%s\n','Forfww= #N#');
fprintf(fid,'%s\n','Sigcor= #N#');
fprintf(fid,'%s\n','Trasol= #Cyclic-method#');
fprintf(fid,'%s\n',['Momsol= #' Model.MomSol '#']);
fprintf(fid,'%s\n',['Filsta= #' Model.Name '.obs#']);
fprintf(fid,'%s\n','Fmtsta= #FR#');
fprintf(fid,'%s\n','SMhydr= #YYYYY#');
fprintf(fid,'%s\n','SMderv= #NNNNNN#');
fprintf(fid,'%s\n','SMproc= #YYYYYYYYYY#');
fprintf(fid,'%s\n','PMhydr= #YYYYYY#');
fprintf(fid,'%s\n','PMderv= #NNN#');
fprintf(fid,'%s\n','PMproc= #YYYYYYYYYY#');
fprintf(fid,'%s\n','SHhydr= #YYYY#');
fprintf(fid,'%s\n','SHderv= #NNNNN#');
fprintf(fid,'%s\n','SHproc= #YYYYYYYYYY#');
fprintf(fid,'%s\n','SHflux= #NNNN#');
fprintf(fid,'%s\n','PHhydr= #YYYYYY#');
fprintf(fid,'%s\n','PHderv= #NNN#');
fprintf(fid,'%s\n','PHproc= #YYYYYYYYYY#');
fprintf(fid,'%s\n','PHflux= #NNNN#');
fprintf(fid,'%s\n','Online= #N#');
fprintf(fid,'%s\n','Waqmod= #N#');
if strcmpi(Model.Type,'Delft3DFLOWWAVE')
    fprintf(fid,'%s\n','WaveOL= #Y#');
    fprintf(fid,'%s\n','TpsCom= #Y#');
end
fprintf(fid,'%s\n','Prhis = 0.0000000e+000  0.0000000e+000  0.0000000e+000');
fprintf(fid,'%s\n',['Flmap = ' tout '   ' dtmap '  ' tstop]);
fprintf(fid,'%s\n',['Flhis = ' tout '  ' dthis '  ' tstop]);
fprintf(fid,'%s\n',['Flpp  = ' twav '   ' dtcom '  ' tstop]);
fprintf(fid,'%s\n',['Flrst = ' dtrst]);
if ~strcmpi(Model.UseMeteo,'none')
    fprintf(fid,'%s\n','Filwp = #meteo.amp#');
    fprintf(fid,'%s\n','Filwu = #meteo.amu#');
    fprintf(fid,'%s\n','Filwv = #meteo.amv#');
    fprintf(fid,'%s\n','Wndgrd= #A#');
    if ~Model.FlowNested && ~strcmpi(Model.FlowNestType,'oceanmodel')
        fprintf(fid,'%s\n',['Pavbnd = ' num2str(Model.PrCorr)]);
    end
    fprintf(fid,'%s\n','AirOut= #YES#');
end
if Model.includeTemperature
    fprintf(fid,'%s\n','Filwr = #meteo.amr#');
    fprintf(fid,'%s\n','Filwt = #meteo.amt#');
    fprintf(fid,'%s\n','Filwc = #meteo.amc#');
    fprintf(fid,'%s\n','HeaOut= #YES#');
    if ~isempty(Model.TmzRad)
        fprintf(fid,'%s\n',['TmZRad= ' num2str(Model.TmzRad)]);
    end
end

if strcmpi(Model.SMVelo,'GLM')
    fprintf(fid,'%s\n','SMVelo = #GLM#');
end
if Model.CstBnd
    fprintf(fid,'%s\n','CstBnd= #YES#');
end

% Z-layers
if strcmpi(Model.layerType,'z')
    fprintf(fid,'%s\n','Zmodel= #YES#');
    fprintf(fid,'%s\n',['ZTop  = ' num2str(Model.zTop)]);
    fprintf(fid,'%s\n',['ZBot  = ' num2str(Model.zBot)]);
end

if ~isempty(Model.TmzRad)
    fprintf(fid,'%s\n',['TmzRad= ' num2str(Model.TmzRad)]);
end

if strcmpi(Model.FlowNestType,'oceanmodel') || Model.nudge
    fprintf(fid,'%s\n','Nudge = #Y#');
    fprintf(fid,'%s\n','NudVic= 50.0');
end

if ~isempty(Model.tracer)
    for i=1:length(Model.tracer)
        if Model.tracer(i).decay>0
            fprintf(fid,'%s\n',['Decay' num2str(i) '= ' num2str(Model.tracer(i).decay)]);
        end
    end
end

% %% WAQ output
% switch(lower(Model.Type))
%     case{'delft3dflowpart','delft3dflowwavepart'}
%         fprintf(fid,'%s\n',['Flwq  = ' twav '   ' dtcom '  ' tstop]);
%         aggrstr=repmat(' 1',1,kmax);
%         fprintf(fid,'%s\n',['ilAggr=' aggrstr]);
%         fprintf(fid,'%s\n','WaqAgg= ##');        
% end

fclose(fid);
