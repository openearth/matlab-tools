%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19299 $
%$Date: 2023-12-12 17:03:24 +0100 (Tue, 12 Dec 2023) $
%$Author: chavarri $
%$Id: D3D_gdm.m 19299 2023-12-12 16:03:24Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/D3D_gdm.m $
%
%Parses input to call `eqtran`.
%
%not necessary to convert Matlab double to real integer. The C interface already takes the integer. 

function [...
    par,realpar,kmax,ws,dicww,ltur,jawave,ubot,sigmol,lundia,tauadd,scour,eps,npar,numintpar,numrealpar,...
    numstrpar,dllfunc,dllhandle,intpar,strpar,lsecfl,drho,tetacr,dstar,taucr...
    ]=D3D_erosed(...
    kmax,i2d3d,lsecfl,ws,dicww,iturbulencemodel,frac,suspfrac,wave,ucxq_mor,ucyq_mor,h1,...
    hrms,tp,teta,rlabda,uorb,kwtur,dzbdt,di50,dss,dstar,d10,d15,d90,mudfrac,hidexp,...
    wsb,rhosol,rhowat,salinity,ag,vicmol,taub,z0cur,dg,dgsd,sandfrac,acal,b,cc,...
    rmu,thcr,acals,bs,ccs,rmus,thcrs,factcr,bl,hs_mor,dzduu,dzdvv,zcc,z0rouk)

%% 2D
if i2d3d==2
    

    if kmax~=20
        warning('In 2D, `kmax` is set to 20 to compute the 3D profile. It has been changed.');
        kmax=20; 
    end
    if numel(ws)>1
        error('In 2D, the settling velocity is a single value while %d are provided.',numel(ws));
    end
    ws=ws.*ones(1,kmax+1); %it is size 0:kmax
    dicww=zeros(1,kmax+1);
    ltur=0;

%% 3D
elseif i2d3d==3


    %`ltur`:
    %  - 0 | 1 = calculate sediment mixing according to Van Rijn based on his parabolic-linear mixing distribution for current-related mixing
    %  - else  = set vertical sediment mixing values based on K-epsilon turbulence model
    %This is set internally in `fm_erosed` as a function of `iturbulencemodel`.
    switch iturbulencemodel
        case [0,1,2]
            ltur=0;
        case [3,4]
            ltur=2;
        otherwise
            error('Incorrect `iturbulencemodel`: %d',iturbulencemodel);
    end

    if lsecfl>0 
        warning('3D and secondary flow cannot coexist. Secondary flow has been disabled.')
        lsecfl=0;
    end

else
    error('It can only be 2D (`i2d3d=2`) or 3D (`i2d3d=3`): %d',i2d3d);
end

%%

if numel(frac)>1
    error('`frac should have one dimension: %d');
end
if frac<0 || frac>1
    error('`frac` should be between 1 and 0: %f',frac);
end

if ~islogical(suspfrac)
    error('`suspfrac` should be a boolean.');
end

%preserve kernel notation and type
if wave
    jawave=1;
else
    jawave=0;
end

%real(fp)                            , intent(in)    :: ubot
if jawave > 0 
    ubot=uorb;
else
    ubot=0;
end

sigmol=1; %real(fp)                            , intent(in)    :: sigmol
lundia=0; %integer                             , intent(in)    :: lundia
tauadd=0; %real(fp)                            , intent(in)    :: tauadd
scour=false; %logical                             , intent(in)    :: scour
eps=1.0e-6; %real(fp)                            , intent(in)    :: eps 
npar=30; %integer                             , intent(in)    :: npar
numintpar=1; %integer                             , intent(in)    :: numintpar !passing DLL
numrealpar=55; %integer                             , intent(in)    :: numrealpar
numstrpar=2; %integer                             , intent(in)    :: numstrpar
dllfunc=repmat('a',1,256); %character(256)                      , intent(in)    :: dllfunc
dllhandle=1; % integer(pntrsize)                   , intent(in)    :: dllhandle
intpar=zeros(size(1,numintpar)); %integer      , dimension(numintpar) , intent(inout) :: intpar -> used for DLL
strpar=repmat('a',numstrpar,256); %character(256), dimension(numstrpar), intent(inout) :: strpar
sedd50=di50;
ee=exp(1);
vonkar=0.41;
dzdx      = dzduu;
dzdy      = dzdvv;
sag=sqrt(ag);

%% FRICTION

% if (jawave > 0 .and. .not. flowWithoutWaves) then
%  z0rou = max(epsz0,z0rouk(nm))
% else ! currents only
%  z0rou = z0curk(nm)       ! currents+potentially trachy
% end if

if jawave
    z0rou=z0rouk;
else
    z0rou=z0cur;
end

chezy=sag*log(h1/ee/z0rou)/vonkar;

%%

[uuu,vvv,umod,zumod,utot,u,v,ustarc]=D3D_velocity(i2d3d,ucxq_mor,ucyq_mor,zcc,hs_mor,ee,vonkar,z0rou,chezy,ag,bl,eps);

%% PAR

par=D3D_par(ag,rhowat,rhosol,sedd50,acal,b,cc,rmu,thcr,acals,bs,ccs,rmus,thcrs);

%% realpar

ins=v2struct(utot,u,v,uuu,vvv,umod,zumod,h1,chezy,hrms,tp,teta,rlabda,uorb,kwtur,dzbdt,dzdx,dzdy,di50,dss,dstar,d10,d15,d90,mudfrac,hidexp,wsb,rhosol,rhowat,salinity,ag,vicmol,taub,vonkar,z0cur,z0rou,ustarc,dg,dgsd,sandfrac,numrealpar);

realpar=D3D_realpar(ins);

%% sediment parameters

[drho,tetacr,dstar,taucr]=D3D_sediment_parameters(rhosol,rhowat,vicmol,sedd50,ag,factcr);

end %function