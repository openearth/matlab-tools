%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%mdf creation

%INPUT:
%   -dire_out = full path to the output folder [string] e.g. 'd:\victorchavarri\SURFdrive\projects\ellipticity\D3D\runs\1D\998'
%   -simdef.runid.serie = run serie [string] e.g. 'A'
%   -simdef.runid.number = run identification number [integer(1,1)] e.g. 36
%   -simdef.grd.M = number of nodes in the domain [-] [integer(1,1)] e.g. [1002]
%   -simdef.mdf.Tstop = simulation time [s] [double(1,1)] e.g. [48000]
%   -simdef.mdf.Dt = time step [s]
%   -simdef.mdf.C = Chezy friction coefficient [m/s^(1/2)] [double(1,1)] e.g. [25.5]
%   -simdef.mdf.Flmap_dt = printing map-file interval time [s] [double(1,1)] e.g. [60]
%
%OUTPUT:
%   -a .mdf file compatible with D3D is created in folder_out
%
%150717->150728
%   -Introduction of runid flag as input
%
%150728->151119
%   -Introductuion of friction as input
%   -Introduction of map print time as input

function D3D_mdf(simdef,varargin)

%% PARSE

parin=inputParser;

inp.check_existing.default=true;
addOptional(parin,'check_existing',inp.check_existing.default)

parse(parin,varargin{:})

check_existing=parin.Results.check_existing;

%% RENAME

% dire_sim=simdef.D3D.dire_sim;

% runid_serie=simdef.runid.serie;
% runid_number=simdef.runid.number;

file_name=simdef.file.mdf;

% path_grd=fullfile(dire_sim,'grd.grd');
path_grd=simdef.file.grd;

%only straight flume!
% M=simdef.grd.M;
% N=simdef.grd.N;

%read grid
grd=wlgrid('read',path_grd);
M=size(grd.X,1)+1;
N=size(grd.X,2)+1;

if isfield(simdef, 'grd')
    K=simdef.grd.K;
else
    K = 0;
end
restart=simdef.mdf.restart;
Tstart=simdef.mdf.Tstart;
Tunit=simdef.mdf.Tunit;
Tfact=simdef.mdf.Tfact;
Tstop=simdef.mdf.Tstop;
Dt=simdef.mdf.Dt;   
C=simdef.mdf.C;
Flmap_dt=simdef.mdf.Flmap_dt;
Flhis_dt=simdef.mdf.Flhis_dt;

Dpsopt=simdef.mdf.Dpsopt;
Dpuopt=simdef.mdf.Dpuopt;
secflow=simdef.mdf.secflow;

wall_rough=simdef.mdf.wall_rough;
wall_ks=simdef.mdf.wall_ks;

Vicouv=simdef.mdf.Vicouv;
Dicouv=simdef.mdf.Dicouv;
Vicoww=simdef.mdf.Vicoww;
Dicoww=simdef.mdf.Dicoww;

AddTim='';
if isfield(simdef.mdf, 'AddTim')
   AddTim=simdef.mdf.AddTim;
end

nf=numel(simdef.sed.dk);

if K>1
    Thick=[simdef.grd.Thick,100-sum(simdef.grd.Thick)];
else
    Thick=100;
end
    
%% FILE

[fid,fname_local]=write_local_and_copy('open',file_name,'overwrite',~check_existing);
fprintf(fid,'%s\r\n','Ident  = #Delft3D-FLOW 3.56.29165#');
fprintf(fid,'%s\r\n','Commnt =                  ');
fprintf(fid,'%s\r\n','Filcco = #grd.grd#');
fprintf(fid,'%s\r\n','Anglat =  0.0000000e+000');
fprintf(fid,'%s\r\n','Grdang =  0.0000000e+000');
fprintf(fid,'%s\r\n','Filgrd = #enc.enc#');
fprintf(fid,'%s\r\n',sprintf('MNKmax = %d %d %d',M,N,K));
fprintf(fid,'%s\r\n',sprintf('Thick  = %0.7E',Thick(1)));
for cl=1:numel(Thick)-1
    fprintf(fid,'%s\r\n',sprintf('         %0.7E',Thick(cl+1)));
end
fprintf(fid,'%s\r\n','Commnt =                  ');
fprintf(fid,'%s\r\n','Fildep = #dep.dep#');
fprintf(fid,'%s\r\n','Commnt =                  ');
fprintf(fid,'%s\r\n','Commnt =                 no. dry points: 0');
fprintf(fid,'%s\r\n','Commnt =                 no. thin dams: 0');
fprintf(fid,'%s\r\n','Commnt =                  ');
fprintf(fid,'%s\r\n','Itdate = #2000-01-01#');
fprintf(fid,'%s\r\n',sprintf('Tunit  = #%s#',Tunit));
fprintf(fid,'%s\r\n',sprintf('Tstart = %0.12E',Tstart*Tfact));
fprintf(fid,'%s\r\n',sprintf('Tstop  = %0.12E',Tstop*Tfact));
fprintf(fid,'%s\r\n',sprintf('Dt     = %0.12E',Dt*Tfact));
if restart==1
    fprintf(fid,'%s\r\n','Restid  = #trim-restart#');
% data{kl,1}=        'Restid_timeindex  = 1'; kl=kl+1; % Index in the map-file for restarting. Either this or the time must match. 
%for restarting from a map-file, set `restid` to the map-file (in the same
%folder as the new mdf-file) and set the right index with
%`restid_timeindex`. You also have to set the right time in `Tstart`
%E.g.:
% Restid = trim-r036r
% Restid_timeindex = 41
end
fprintf(fid,'%s\r\n','Tzone  = 0');
[~,fname,fext]=fileparts(simdef.file.thd);
fprintf(fid,'%s\r\n',sprintf('Filtd  = #%s#',sprintf('%s%s',fname,fext))); %thin dams
fprintf(fid,'%s\r\n','Commnt =                  ');
%Sub1 = #STWI# %'S'alinity, 'T'emperaure, 'I'secondary flow and 'W'ind
%Sub2 = #PCW#  %'P'articles, 'W'ave, 'C'onstituents
if secflow==1
    fprintf(fid,'%s\r\n','Sub1   = #   I#'); %with computation of advection-diffusion of secondary flow intensity
else
    fprintf(fid,'%s\r\n','Sub1   = #    #'); %without computation of advection-diffusion of secondary flow intensity
end
Sub2='   ';
if any(simdef.tra.SedTyp~=3)
    Sub2(3)='C';
end
fprintf(fid,'%s\r\n',sprintf('Sub2   = #%s#',Sub2));
for kf=1:nf
    if simdef.tra.SedTyp(kf)~=3
        fprintf(fid,'%s\r\n',sprintf('Namc%d = #Sediment%d#   ',kf,kf));
    end %sedtyp
end %kf
fprintf(fid,'%s\r\n','Commnt =                  ');
fprintf(fid,'%s\r\n','Wnsvwp = #N#');
fprintf(fid,'%s\r\n','Wndint = #Y#');
fprintf(fid,'%s\r\n','Commnt =                 initial conditions from initial conditions file');
fprintf(fid,'%s\r\n','Filic  = #fini.ini#                 ');
fprintf(fid,'%s\r\n','Commnt =                  ');
fprintf(fid,'%s\r\n','Commnt =                 no. open boundaries: 2');
fprintf(fid,'%s\r\n','Filbnd = #bnd.bnd#');
fprintf(fid,'%s\r\n','FilbcT = #bct.bct#');
if ~isempty(simdef.file.bcc)
    fprintf(fid,'%s\r\n','Filbcc = #bcc.bcc#');
end
fprintf(fid,'%s\r\n','Commnt =                  ');
fprintf(fid,'%s\r\n','Ag     =  9.8100000e+000');
fprintf(fid,'%s\r\n','Rhow   =  1.0000000e+003');
fprintf(fid,'%s\r\n','Tempw  =  1.5000000e+001');
fprintf(fid,'%s\r\n','Salw   =  0.0000000e+001');
fprintf(fid,'%s\r\n','Wstres =  6.3000000e-004  0.0000000e+000  7.2300000e-003  1.0000000e+002  7.2300000e-003  1.0000000e+002');
fprintf(fid,'%s\r\n','Rhoa   =  1.0000000e+000');
fprintf(fid,'%s\r\n','Betac  =  1.0000000e+000');
fprintf(fid,'%s\r\n','Equili = #N#'); %flag for computation of equilibrium secondary flow
fprintf(fid,'%s\r\n','Tkemod = #K-epsilon   #'); %turbulence closure model #Constant    #, #Algebraic #, #K-epsilon   #
fprintf(fid,'%s\r\n','Ktemp  = 0');
fprintf(fid,'%s\r\n','Fclou  =  0.0000000e+000');
fprintf(fid,'%s\r\n','Sarea  =  0.0000000e+000');
fprintf(fid,'%s\r\n','Temint = #Y#');
fprintf(fid,'%s\r\n','Commnt =                  ');
switch simdef.mdf.FrictType
    case 0
        fprintf(fid,'%s\r\n','Roumet = #C#'); %C, W
    case 2
        fprintf(fid,'%s\r\n','Roumet = #W#'); %C, W
    otherwise
        error('in Delft3D-4, friction can only be chezy or White-Colebrook')
end
fprintf(fid,'%s\r\n',sprintf('Ccofu  =  %0.7E',C));
fprintf(fid,'%s\r\n',sprintf('Ccofv  =  %0.7E',C));
fprintf(fid,'%s\r\n','Xlo    =  0.0000000e+000');
fprintf(fid,'%s\r\n',sprintf('Vicouv =  %0.7E',Vicouv));
fprintf(fid,'%s\r\n',sprintf('Dicouv =  %0.7E',Dicouv));
fprintf(fid,'%s\r\n',sprintf('Vicoww =  %0.7E',Vicoww));
fprintf(fid,'%s\r\n',sprintf('Dicoww =  %0.7E',Dicoww));
fprintf(fid,'%s\r\n','Htur2d = #N#');
if simdef.mdf.Idensform==2 %It cannot be switched off in D3D4. 
    fprintf(fid,'%s\r\n','DenFrm = #UNESCO#');
end
fprintf(fid,'%s\r\n',sprintf('Irov   = %d',wall_rough));
fprintf(fid,'%s\r\n',sprintf('Z0v    = %0.7E',wall_ks/30));
if simdef.mor.morphology
    [~,fname,fext]=fileparts(simdef.file.sed);
    fprintf(fid,'%s\r\n',sprintf('Filsed = #%s#',sprintf('%s%s',fname,fext)));
    [~,fname,fext]=fileparts(simdef.file.mor);
    fprintf(fid,'%s\r\n',sprintf('Filmor = #%s#',sprintf('%s%s',fname,fext)));
end
fprintf(fid,'%s\r\n','Commnt =                  ');
fprintf(fid,'%s\r\n','Iter   =      2');
%data{kl,1}=        'Dryflp = #YES#'; kl=kl+1;
fprintf(fid,'%s\r\n',sprintf('Dpsopt = #%s#',Dpsopt)); %flow depth at cell centres: DP=depth specified at cell centres; kl=kl+1; MAX; kl=kl+1; MEAN; kl=kl+1; MIN
if ischar(Dpuopt)
    fprintf(fid,'%s\r\n',sprintf('Dpuopt = #%s#',Dpuopt)); %flow depth at cell interface: ATT! DPSOPT = DP and DPUOPT = MEAN should not be used together. dpuopt = #mean_dps#,
else
    switch Dpuopt
        case 1
            fprintf(fid,'%s\r\n','Dpuopt = #min_dps#'); %flow depth at cell interface: ATT! DPSOPT = DP and DPUOPT = MEAN should not be used together. dpuopt = #mean_dps#,
        case 2
            fprintf(fid,'%s\r\n','Dpuopt = #mean_dps#'); %flow depth at cell interface: ATT! DPSOPT = DP and DPUOPT = MEAN should not be used together. dpuopt = #mean_dps#,
    end
end
fprintf(fid,'%s\r\n','Dryflc =  1.0000000e-003');
fprintf(fid,'%s\r\n','Dco    = -9.9900000e+002');
fprintf(fid,'%s\r\n','Tlfsmo =  0.0000000e+001'); %smoothing boundary conditions time [6.0000000e+001]
fprintf(fid,'%s\r\n','ThetQH =  0.0000000e+000');
fprintf(fid,'%s\r\n','Forfuv = #Y#');
fprintf(fid,'%s\r\n','Forfww = #N#');
fprintf(fid,'%s\r\n','Sigcor = #N#');
fprintf(fid,'%s\r\n','Trasol = #Cyclic-method#');
fprintf(fid,'%s\r\n','Momsol = #Cyclic#');
fprintf(fid,'%s\r\n','Commnt =                  ');
fprintf(fid,'%s\r\n','Commnt =                 no. discharges: 0');
fprintf(fid,'%s\r\n','Commnt =                 no. observation points: 0');
if isfield(simdef.file,'obs') && ~isempty(simdef.file.obs) && Flhis_dt>0
    [~,fname,fext]=fileparts(simdef.file.obs);
    fprintf(fid,'%s\r\n',sprintf('Filsta= #%s#',sprintf('%s%s',fname,fext)));
    fprintf(fid,'%s\r\n','Fmtsta= #FR#');
end
if isfield(simdef.file,'crs') && ~isempty(simdef.file.crs) && Flhis_dt>0
    [~,fname,fext]=fileparts(simdef.file.crs);
    fprintf(fid,'%s\r\n',sprintf('Filcrs= #%s#',sprintf('%s%s',fname,fext)));
    fprintf(fid,'%s\r\n','Fmtcrs= #FR#');
end
fprintf(fid,'%s\r\n','Commnt =                 no. drogues: 0');
fprintf(fid,'%s\r\n','Commnt =                  ');
fprintf(fid,'%s\r\n','Commnt =                  ');
fprintf(fid,'%s\r\n','Commnt =                 no. cross sections: 0');
fprintf(fid,'%s\r\n','Commnt =                  ');
fprintf(fid,'%s\r\n','SMhydr = #YYYYY#     ');
fprintf(fid,'%s\r\n','SMderv = #YYYYYY#    ');
fprintf(fid,'%s\r\n','SMproc = #YYYYYYYYYY#');
fprintf(fid,'%s\r\n','PMhydr = #YYYYYY#    ');
fprintf(fid,'%s\r\n','PMderv = #YYY#       ');
fprintf(fid,'%s\r\n','PMproc = #YYYYYYYYYY#');
fprintf(fid,'%s\r\n','SHhydr = #YYYY#      ');
fprintf(fid,'%s\r\n','SHderv = #YYYYY#     ');
fprintf(fid,'%s\r\n','SHproc = #YYYYYYYYYY#');
fprintf(fid,'%s\r\n','SHflux = #YYYY#      ');
fprintf(fid,'%s\r\n','PHhydr = #YYYYYY#    ');
fprintf(fid,'%s\r\n','PHderv = #YYY#       ');
fprintf(fid,'%s\r\n','PHproc = #YYYYYYYYYY#');
fprintf(fid,'%s\r\n','PHflux = #YYYY#      ');
% data{kl,1}=sprintf('Flmap  =  0.0000000e+000 %0.7e   %0.7e',Flmap_dt,ceil(Tstop/Flmap_dt)*Flmap_dt); kl=kl+1;
fprintf(fid,'%s\r\n',sprintf('Flmap  =  %0.12e %0.12e   %0.12e',Flmap_dt(1)*Tfact,Flmap_dt(2)*Tfact,Tstop*Tfact));
fprintf(fid,'%s\r\n',sprintf('Flhis  =  0.0000000e+000 %0.12e   %0.12e',Flhis_dt*Tfact,Tstop*Tfact));
fprintf(fid,'%s\r\n','Flpp   =  0.0000000e+000 0    0.0000000e+000');
fprintf(fid,'%s\r\n','Flrst  = 0');
fprintf(fid,'%s\r\n','Commnt =                  ');
fprintf(fid,'%s\r\n','CflMsg = #Y#'); %write more than 100 CFL cheks
fprintf(fid,'%s\r\n','Online = #N#');
fprintf(fid,'%s\r\n','chezy  = #Y#'); %output Chezy friction
fprintf(fid,'%s\r\n','Commnt =                  ');
if isfield(simdef.mdf,'AddTim') && strcmpi(AddTim,'Y')
    fprintf(fid,'%s\r\n','AddTim = #Y#               ');
end
% if simdef.mor.morphology
% data{kl,1}=sprintf('TraFrm = #%s#',simdef.mdf.tra); 
% end

%% CLOSE

write_local_and_copy('close',fid,fname_local,file_name)
