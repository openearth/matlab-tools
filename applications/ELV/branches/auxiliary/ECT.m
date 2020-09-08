%150213->150504
%   -inclusion of Morphological Factor
%   -inclusion of characterisctic polynomial computation
%   -inclusion of flag for characteristic polynomial
%
%150504->150603
%   -inclusion of quasi-steady solution
%
%150603->150611
%   -inclusion of variable active layer
%
%150611->150614
%   -dqbk_dMal as direct output in 'cp' structure
%   -a_dLa limits as output in 'cp' structure
%
%150614->151009
%   -inclusion of approximated eigenvalues of the coupled case
%
%151009->160111
%   -inclusion of different forms of the analytical eigenvalues
%
%160111->160121
%   -inclusion of characteristic analysis for 3 fractions
%
%160121->160212
%   -inclusion of flag for not analyzing all cases
%
%160212->160429
%   -3 fractions discriminant
%
%160429->160616
%   -Ribberink improvement
%
%160616->160808
%   -advection-decay
%
%160808->161020
%   -use of external sediment transport function
%   -2D in same function
%   -change of fully coupled matrix A, erase substrate
%   -2D secondary flow
%
%161020->161206
%   -inclusion of Shallow Water with secondary flow
%   -inclusion of Shallow Water Exner with secondary flow
%
%161206->161215
%   -addition of gradient in source term of secondary flow (Exner only)
%
%
%NOTES:
%   -The analytical solutions do not have Morphological Factor
%   -Ellipticity in the quasi-steady case it is based on the full derivative case, without the approximation for the eigenvalues

function [eigen_all,elliptic,A,cp,Ribb,out,...
          eigen_all_qs,elliptic_qs,A_qs,...
          eigen_all_dLa,elliptic_dLa,A_dLa,...
          eigen_all_ad,elliptic_ad,A_ad,...
          eigen_all_2Dx,eigen_all_2Dy,elliptic_2D,Ax,Ay,...
          eigen_all_2Dx_sf,eigen_all_2Dy_sf,elliptic_2D_sf,Ax_sf,Ay_sf,...
          eigen_all_SWx,eigen_all_SWy,elliptic_SW,Ax_SW,Ay_SW,...
          eigen_all_SWx_sf,eigen_all_SWy_sf,elliptic_SW_sf,Ax_SW_sf,Ay_SW_sf,...
          eigen_all_SWEx,eigen_all_SWEy,elliptic_SWE,Ax_SWE,Ay_SWE,...
          eigen_all_SWEx_sf,eigen_all_SWEy_sf,elliptic_SWE_sf,Ax_SWE_sf,Ay_SWE_sf...
          ]=ECT_161215(flg,varargin)
      

%% Notation

    %% flags
% flg.read = where to read input: 
    % 0 = debug (from internal function)
    % 1 = from input to function
        %input: 
        %COMPULSORY
        %   'gsd' = [dk] ; e.g. [0.003,0.005] 
        %   'nodeState' = [u,h,Sf_p,La,Fa,Fi] ; e.g. [0.5,0.5,0.008,0.1,0.75,0.25,0.85,0.15]
        %OPTIONAL (otherwise, default values will be used)
        %   'sedTrans' 
            %   MPM48 = [a_mpm,b_mpm,theta_c] ; default = [8,1.5,0.047]
            %   EH67 = [m_eh,n_eh] ; default = [0.05,5]
            %   AM72 = [a_am,theta_c] ; default = [17,0.05]
        %   'hiding'
            %   PL = [b_he] ; e.g. [-0.9]
        %   'Ribberink' = [Ribb.n,Ribb.l] ; e.g. [5,1] 
        %   'MorFac' = [MF] ; e.g. [1]
        %   'dLadt' = [a,b] ; e.g. [0.2,0.9]
        %   'ad' = [u_b] ; e.g. [1.2]
        %   'secFlow' = [I,E_s,beta_c] ; default [0,1,1]
    % 2 = from external .txt    
% flg.check_input
    % 0 = no
    % 1 = yes
% flg.sed_trans = sediment transport relation
    % 1 = Meyer-Peter, Muller (1948)    
    % 2 = Engelund-Hansen (1967)
    % 3 = Ashida-Michiue (1972)
    % 4 = Wilcock-Crowe (2003)
    % 5 = Wu et. al. (2000)
% flg.derivatives
    % 1 = finite diferences
    % 2 = analytical
% flg.friction_closure = friction closure relation
    % 1 = Chezy | Darcy-Weisbach
    % 2 = Manning 
% flg.friction_input = friction parameter input
    % 1 = non-dimensional friction coefficient (cf)
    % 2 = dimensional Chezy friction coefficient (C)
    % 3 = non-dimensional Chezy friction coefficient (Cz)
    % 4 = Darcy-Weisbach friction coefficient (f)
    % 5 = Manning friction coefficient (n)
% flg.hiding = hiding-exposure effects
    % 0 = no hiding-exposure 
    % 1 = Egiazaroff (1965)
    % 2 = Power law
    % 3 = Ashida-Michiue (1972)
% flg.Dm = mean grain size
    % 1 = geometric
    % 2 = arithmetic
% flg.cp = characteristic polynomial
% flg.anl = which output do you need
    % 1 = fully coupled
    % 2 = quasi-steady
    % 3 = variable active layer thickness
    % 4 = Ribberink
    % 5 = advection-decay
    % 6 = 2D Shallow Water Hirano no secondary flow
    % 7 = 2D Shallow Water Hirano 2D with secondary flow
    % 8 = 2D Shallow Water fixed bed no secondary flow
    % 9 = 2D Shallow Water fixed bed with secondary flow
    %10 = 2D Shallow Water Exner no secondary flow
    %11 = 2D Shallow Water Exner with secondary flow
    
    %% input 
%node variables
    % u = velocity [m/s] ; double [1,1] ; compulsory
    % h = flow depth [m] ; double [1,1] ; compulsory
    % Sf_p = friction parameter [depends] ; double [1,1] ; compulsory
    % La = active layer thickness [m] ; double [1,1] ; compulsory
    % Fa = fractions in the active layer [per one] ; double [1,nf] ; compulsory
    % Fi = fractions in the interface [per one] ; double [1,nf] ; compulsory
%GSD variables
    % dk = grain sizes [m] ; double [1,nf] ; compulsory
%sediment transport
    % b_he = hiding exposure power in power law relation [-] ; double [1,1] ; only if power law hiding-exposure
    %MPM48
        % a_mpm = A coefficient (8 in classical formulation)
        % b_mpm = B coefficient (1.5 in classical formulation)
        % theta_c = critical shear stress (0.047 in classical formulation)
    %EH67
        % m_eh = m coefficient (0.05 in classical formulation)
        % n_eh = n coefficient (5 in classical formulation)
    %AM72
        % a_am = m coefficient (17 in classical formulation)
        % theta_c = critical shear stress (0.05 in classical formulation)
%Ribberink's parameters
    % Ribb.n = n coefficient in Ribberink's sediment transport relation, power of the velocity (5.66 in his thesis)
    % Ribb.l = l coefficient in Ribberink's sediment transport relation, power of the mean grain size (0.908 in his thesis)
%Morphological Factor
    % MF = prefactor of the sediment transport (1 means no alteration)
%Variable active layer thickness
    % a = factor multiplying flow depth [1/m^(b-1)] ; double [1,1] 
    % b = flow depth power [-] ; double [1,1] 
%Advection-decay
    % u_b = characteristic sediment celerity [m/s] ; double [1,1]
%Secondary Flow
    % I = secondary flow intensity [m/s] ; double [1,1] ; e.g. [??]
    % E_s = calibration parameter of the sediment transport direction [-] ; double [1] ; e.g. [1]
    % beta_c = calibration parameter of the secondary flow shear stresses [-] ; double [1,1] ; e.g. [1]
    
    %% calculation variables
%node variables
    % q = specific flow discharge [m^2/s] ; double [1,1]
    % Mak = sediment mass at the active layer per grain size [m] ; double [1,nf]
    % tau_b = bed shear stress [Pa] ; double [1,1]
    % xik = hiding-exposure parameter per fraction [-] ; double [1,nf]
    % thetak = dimensionless bed shear stress per fraction [-] ; double [1,nf]
    % Qbk = sediment transport capacity per fraction including pores [m^2/s] ; double [1,nf]
    % qbk = sediment transport per fraction including pores [m^2/s] ; double [1,nf]
    % qb = total sediment transport
%parameters
    %friction
        % cf = non-dimensional friction coefficient [-] ; double [1,1]
        % C = dimensional Chezy friction coefficient [m^(1/2)/s] ; double [1,1]
        % Cz = non-dimensional Chezy friction coefficient [-] ; double [1,1]
        % f = Darcy-Weisbach friction coefficient [-] ; double [1,1]
        % n = Manning friction coefficient [s/m^(1/3)] ; double [1,1]
    %constants
        % cnt.g = gravity [m^2/s] ; double [1,1]
        % cnt.rho_s = sediment density [kg/m^3] ; double [1,1]
        % cnt.rho_w = water density [kg/m^3] ; double [1,1]
        % cnt.p = porosity [-] ; double [1,1]
        % cnt.R = submerged relative sediment density [-] ; double [1,1]
    
    %% sizes
    % nf = number of fractions ; integer [1,1]
    % ne = number of eigenvalues ; integer [1,1]
    % nA = number of rows in matrix A ; integer [1,1]

%% Parse input     

if flg.read==1
parin=inputParser;
    %gsd
input.gsd.default=NaN;
addOptional(parin,'gsd',input.gsd.default,@isnumeric);
    %node state
input.nodeState.default=NaN;
addOptional(parin,'nodeState',input.nodeState.default,@isnumeric);
    %sediment transport
    if flg.sed_trans==1 %MPM48
        input.sedTrans.default=[8,1.5,0.047];
    elseif flg.sed_trans==2 %EH67
        input.sedTrans.default=[0.05,5];
    elseif flg.sed_trans==3 %AM72
        input.sedTrans.default=[17,0.05];
    else
        input.sedTrans.default=NaN;
    end
addOptional(parin,'sedTrans',input.sedTrans.default,@isnumeric);
    %hiding-exposure
input.hiding.default=999; %dummy positive number in order to show the check warning in case there is no input but is needed
addOptional(parin,'hiding',input.hiding.default,@isnumeric);
    %Ribberink's parameters
input.Ribberink.default=[5,1];
addOptional(parin,'Ribberink',input.Ribberink.default,@isnumeric);
    %Morphological Factor
input.MorFac.default=1;
addOptional(parin,'MorFac',input.MorFac.default,@isnumeric);
    %Variable active layer thickness
input.dLadt.default=[0,0];
addOptional(parin,'dLadt',input.dLadt.default,@isnumeric);
    %Advection-decay
input.ad.default=NaN;
addOptional(parin,'ad',input.ad.default,@isnumeric);
    %secondary flow
input.secFlow.default=[0,1,1];
addOptional(parin,'secFlow',input.secFlow.default,@isnumeric);
    %two dimensional ellipticity
input.twoD.default=10;
addOptional(parin,'twoD',input.twoD.default,@isnumeric);

parse(parin,varargin{:});

%assign Ribberink's parameters
Ribb.n=parin.Results.Ribberink(1);
Ribb.l=parin.Results.Ribberink(2);

%assign Morphological Factor
mor_fac=parin.Results.MorFac;

%assign variable active layer thickness parameters
a_dL=parin.Results.dLadt(1); 
b_dL=parin.Results.dLadt(2); 

%assign advection-decay
u_b=parin.Results.ad(1); 

%assign secondary flow
I=parin.Results.secFlow(1); 
E_s=parin.Results.secFlow(2); 
beta_c=parin.Results.secFlow(3); 

%assign twoD
param_twoD.nr=parin.Results.twoD(1); 

end

%% Incompatibilities

if (any(flg.anl==1) || any(flg.anl==2) || any(flg.anl==3) || any(flg.anl==4) || any(flg.anl==5)) ...
&& (any(flg.anl==6) || any(flg.anl==7) || any(flg.anl==8) || any(flg.anl==9) || any(flg.anl==10) || any(flg.anl==11))
    error('You cannot do 1 and 2D at the same time')
    %this is because of how NodeState is entered
elseif (any(flg.anl==6) || any(flg.anl==8) || any(flg.anl==10)) ...
    && (any(flg.anl==7) || any(flg.anl==9) || any(flg.anl==11))
    error('You cannot do 2D with and without secondary flow at the same time')
    %this could be solved computing the sediment transport and the derivatives with and without
elseif (any(flg.anl==6) || any(flg.anl==8) || any(flg.anl==10)) ...
    && I~=0
    warning('You are entering a value for the secondary flow intensity but it is ovewriten to 0 because you are not asking for secondary flow')
    I=0;
end

if (any(flg.anl==7) || any(flg.anl==9))
    warning('Secondary flow only advective, no source term included')
end
    

%% Constants

cnt.g=9.81; %gravity [m^2/s]
cnt.rho_s=2650; %sediment density [kg/m^3]
cnt.rho_w=1000; %water density [kg/m^3]
cnt.p=0.4; %porosity [-]
cnt.nu=1e-6; %water kinematic viscosity [m^2/s]
cnt.k=0.41; %Von Karman constant [-]

der.der=1e-6; 

der.dh=der.der; %dh
der.dq=der.der; %dq
der.dMal=der.der; %dMa
der.dLa=der.der; %dLa
der.dI=der.der; %dI

%% Read GSD

if flg.read==0
    dk=[0.003,0.005];
elseif flg.read==1
    dk=parin.Results.gsd;
end

%% Sizes

nf=size(dk,2); %number of fractions
nef=nf-1; %number of effecive fractions

%fully coupled
ne=3+(nf-1); %number of eigenvalues
nA=3+(nf-1); %number of rows (or columns) in matrix A 
% nA=2*nf+1; %number of rows (or columns) in matrix A (considering the linearly dependent ones)

%quasi-steady
ne_qs=nf; %number of eigenvalues
nA_qs=nf; %number of rows (or columns) in matrix A

%variable active layer thickness
ne_dLa=3+(nf-1)+1; %number of eigenvalues
nA_dLa=3+(nf-1)+1; %number of rows (or columns) in matrix A (not considering the substrate)
% nA_dLa=2*nf+1+1; %number of rows (or columns) in matrix A (considering the linearly dependent ones)

%advection-decay
ne_ad=2*nf; %number of eigenvalues
nA_ad=2*nf; %number of rows (or columns) in matrix A

%2D
ne_2D=3+nf; %not considering substrate
nA_2D=3+nf; %not considering substrate

%2D secondary flow
ne_2D_sf=4+nf; %not considering substrate
nA_2D_sf=4+nf; %not considering substrate

%2D Shallow Water fixed bed secondary flow
% ne_SW_sf=4;
nA_SW_sf=4;

%2D Shallow Water Exner no secondary flow
nA_SWE=4;

%2D Shallow Water Exner secondary flow
nA_SWE_sf=5;

%% Read node state

if flg.read==0
    u=1;
    h=1;
    Sf_p=0.008;
    La=0.1;
    Fak=[0.5,0.5];
    Fik=[0.8,0.2];
elseif flg.read==1
    if any(flg.anl==1) || any(flg.anl==2) || any(flg.anl==3) || any(flg.anl==4) || any(flg.anl==5)
        if numel(parin.Results.nodeState)~=4+nf*2
            error('wrong NodeState, you may be using a 2D input')
        end
            u=parin.Results.nodeState(1);
            h=parin.Results.nodeState(2);
            Sf_p=parin.Results.nodeState(3);
            La=parin.Results.nodeState(4);
            Fak=parin.Results.nodeState(5:4+nf);
            Fik=parin.Results.nodeState(5+nf:4+nf*2);
    elseif any(flg.anl==6) || any(flg.anl==7) || any(flg.anl==8) || any(flg.anl==9)|| any(flg.anl==10) || any(flg.anl==11)
        if numel(parin.Results.nodeState)~=5+nf*2
            error('wrong NodeState, you may be using a 1D input')
        end
            u=parin.Results.nodeState(1:2); %vector
            h=parin.Results.nodeState(3);
            Sf_p=parin.Results.nodeState(4);
            La=parin.Results.nodeState(5);
            Fak=parin.Results.nodeState(6:5+nf);
            Fik=parin.Results.nodeState(6+nf:5+nf*2);  
    end
end

%% Read sediment transport relation

if flg.read==0 
    if flg.sed_trans==1 %MPM48
        sed_trans_param=[8,1.5,0.047];
    end
elseif flg.read==1
    sed_trans_param=parin.Results.sedTrans;
    if flg.sed_trans==1 %MPM48
        a_mpm=parin.Results.sedTrans(1);
        b_mpm=parin.Results.sedTrans(2);
        theta_c=parin.Results.sedTrans(3);
    elseif flg.sed_trans==2 %EH67
        m_eh=parin.Results.sedTrans(1);
        n_eh=parin.Results.sedTrans(2);
    elseif flg.sed_trans==3 %AM72
        a_am=parin.Results.sedTrans(1);
        theta_c=parin.Results.sedTrans(2);
    end
end

%% Read hiding-exposure

if flg.read==0
    if flg.hiding==2
        b_he=1;
%         cnt.b_he=b_he; %trick in order to pass the parameter to the sediment transport formulas if necessary without modifying arguments.
    end
elseif flg.read==1
    hiding_param=parin.Results.hiding(1);
    if flg.hiding==2
%         hiding_param=parin.Results.hiding(1);
        b_he=parin.Results.hiding(1);
%         cnt.b_he=b_he; %trick in order to pass the parameter to the sediment transport formulas if necessary without modifying arguments.
    end
end

%% Check input

if flg.check_input==1
    %fractions
    chk.Fa=sum(Fak,2);
    chk.Fi=sum(Fik,2);
    if chk.Fi~=1 || chk.Fa~=1
        warning('Input fractions do not add 1')
    end
    %GSD
    chk.diff_d=diff(dk);
    if any(chk.diff_d<0)
        warning('Input GSD is not increasing in size')
    elseif any(dk>0.05)
        warning('Input GSD may not be in meters')
    end
    %friction
    if (flg.friction_input==1) && (Sf_p>0.020 || Sf_p<0.001) %cf
        warning('Input friction coefficient may be wrong')
    elseif (flg.friction_input==2) && (Sf_p>50 || Sf_p<10) %C
        warning('Input friction coefficient may be wrong')
    elseif (flg.friction_input==3) && (Sf_p>0.2 || Sf_p<0.01) %Cz
        warning('Input friction coefficient may be wrong')
    end
    %power law in hiding exposure
    if flg.hiding==2
        if b_he>0
            warning('The power law is defined as (dsk/Dm)^b_he, input may be wrong')
        end
    end
    %sediment transport parameters
    if flg.read==1
        if flg.sed_trans==1 %MPM48
            if length(parin.Results.sedTrans)~=3
                error('You need 3 input parameters for using Meyer-Peter, Muller (1948)');
            elseif (a_mpm>8.5) || (a_mpm<3) || (b_mpm>2) || (b_mpm<1) || (theta_c>0.05) || (theta_c<0.01)
                warning('Meyer-Peter, Muller parameters may not be correct')
            end
        elseif flg.sed_trans==2 %EH67
            if length(parin.Results.sedTrans)~=2
                error('You need 2 input parameters for using Engelund-Hansen (1967)');
            elseif (n_eh>5.5) || (n_eh<4.5) || (m_eh>0.06) || (m_eh<0.04)
                warning('Engelund-Hansen parameters may not be correct')
            end
        elseif flg.sed_trans==3 %AM72
            if length(parin.Results.sedTrans)~=2
                error('You need 2 input parameters for using Ashida-Michiue (1972)');
            elseif (a_am>20) || (a_am<5) || (theta_c>0.05) || (theta_c<0.01)
                warning('Ashida-Michiue parameters may not be correct')
            end
        end
    end
    if any(flg.anl==11) && u(2)~=0
        warning('Secondary flow only if v=0')
    end
end

%% Initial calculations

Fr=u/sqrt(cnt.g*h);
q=u*h; %specific water discharge [m^2/s]
Mak=Fak(1:nf-1).*La; %sediment mass at the active layer per effective grain size [m] 
cnt.R=(cnt.rho_s-cnt.rho_w)/cnt.rho_w; %submerged relative sediment density [-]

%% Friction parameter

if flg.friction_input==1 %cf
    cf=Sf_p;
elseif flg.friction_input==2 %C
    C=Sf_p;
    cf=g/(C^2);
elseif flg.friction_input==3 %Cz
    Cz=Sf_p;
    cf=1/(Cz^2);
elseif flg.friction_input==4 %f
    f=Sf_p;
    cf=f/8;
elseif flg.friction_input==5 %n
    n=Sf_p;
    cf=cnt.g*n^(2)/h^(1/3);
end

%% Derivatives

if flg.derivatives==1 %finite differences
if any(flg.anl==1) || any(flg.anl==2) || any(flg.anl==3) || any(flg.anl==4) || any(flg.anl==5)
    [qbk,Qbk]=sediment_transport(flg,cnt,h,q,cf,La,Mak,dk,sed_trans_param,hiding_param,mor_fac);
    qb=sum(qbk); %qb
    Qb=sum(Qbk); %Qb 

    [qbk_hdh,~]=sediment_transport(flg,cnt,h+der.dh,q,cf,La,Mak,dk,sed_trans_param,hiding_param,mor_fac);
    qb_hdh=sum(qbk_hdh); %qb(h+dh)

    [qbk_qdq,~]=sediment_transport(flg,cnt,h,q+der.dq,cf,La,Mak,dk,sed_trans_param,hiding_param,mor_fac);
    qb_qdq=sum(qbk_qdq); %qb(q+dq)

    qbk_MaldMal=zeros(nf-1,nf); %qbk(Mal+dMal)
    Qbk_MaldMal=zeros(nf-1,nf); %Qbk(Mal+dMal)
    for kf=1:nf-1
        der.dMa=zeros(1,nf-1);
        der.dMa(kf)=der.dMal;
        [qbk_MaldMal(kf,:),Qbk_MaldMal(kf,:)]=sediment_transport(flg,cnt,h,q,cf,La,Mak+der.dMa,dk,sed_trans_param,hiding_param,mor_fac);
    end %kf
    qb_MaldMal=sum(qbk_MaldMal,2); %qb(Mal)
    Qb_MaldMal=sum(Qbk_MaldMal,2); %Qb(Mal) 

    [qbk_LadLa,~]=sediment_transport(flg,cnt,h,q,cf,La+der.dLa,Mak,dk,sed_trans_param,hiding_param,mor_fac);
    qb_LadLa=sum(qbk_LadLa); %qb(La+dLa)

    %d(qb)/d(h) ; %double [1,1]
    qb_h=qb; %qb(h)
    dqb_dh=(qb_hdh-qb_h)/der.dh; 

    %d(qb)/d(q) ; %double [1,1]
    qb_q=qb; %qb(q)
    dqb_dq=(qb_qdq-qb_q)/der.dq; 
    
    %d(qbk)/d(h) ; double [1,nf]
    qbk_h=qbk; %qbk(h)
    dqbk_dh=(qbk_hdh-qbk_h)./der.dh; 

    %d(qbk)/d(q) ; double [1,nf]
    qbk_q=qbk; %qbk(q)
    dqbk_dq=(qbk_qdq-qbk_q)./der.dq;
    
    %d(qb)/d(Mal) ; double [nf-1,1]
    qb_Mal=ones(nf-1,1)*qb; %qb(Ma) 
    dqb_dMal=(qb_MaldMal-qb_Mal)./der.dMal;
    
    %d(Qb)/d(Mal) ; double [nf-1,1] 
    Qb_Mal=ones(nf-1,1)*Qb; %Qb(Ma)  
    dQb_dMal=(Qb_MaldMal-Qb_Mal)./der.dMal; 
    dQb_dFal=La*dQb_dMal; 
    
    %d(qbk)/d(Mal) ; double [nf-1,nf]
    qbk_Mal=repmat(qbk,nf-1,1); %qbk(Mal)
    dqbk_dMal=(qbk_MaldMal-qbk_Mal)./der.dMal; %e.g. (nf=3): [dqb1/dMa1, dqb2/dMa1, dqb3/dMa1; dqb1/dMa2, dqb2/dMa2, dqb3/dMa2]
    
    %d(Qbk)/d(Mal) ; double [nf-1,nf] 
    Qbk_Mal=repmat(Qbk,nf-1,1); %Qbk(Mal) 
    dQbk_dMal=(Qbk_MaldMal-Qbk_Mal)./der.dMal; 
    dQbk_dFal=La*dQbk_dMal; 
    
    %d(qb)/d(La) ; double [1,1]
    qb_La=qb; %qb(La)
    dqb_dLa=(qb_LadLa-qb_La)/der.dLa; 
    
    %d(qbk)/d(La) ; double [1,nf]
    qbk_La=qbk; %qbk(q)
    dqbk_dLa=(qbk_LadLa-qbk_La)./der.dLa;
    
   elseif any(flg.anl==6) || any(flg.anl==7) || any(flg.anl==8) || any(flg.anl==9) || any(flg.anl==10) || any(flg.anl==11) 
    
    [qbkx,qbky,Qbkx,Qbky]=sediment_transport_2D(flg,cnt,h,q,cf,La,Mak,dk,sed_trans_param,hiding_param,mor_fac,I,E_s);
    qbx=sum(qbkx); %qbx
    qby=sum(qbky); %qby
    Qbx=sum(Qbkx); %Qbx
    Qby=sum(Qbky); %Qby

    [qbkx_hdh,qbky_hdh,~]=sediment_transport_2D(flg,cnt,h+der.dh,q,cf,La,Mak,dk,sed_trans_param,hiding_param,mor_fac,I,E_s);
    qbx_hdh=sum(qbkx_hdh); %qbx(h+dh)
    qby_hdh=sum(qbky_hdh); %qby(h+dh)

    [qbkx_qdqx,qbky_qdqx,~]=sediment_transport_2D(flg,cnt,h,q+[der.dq,0],cf,La,Mak,dk,sed_trans_param,hiding_param,mor_fac,I,E_s);
    qbx_qdqx=sum(qbkx_qdqx); %qbx(qx+dq)
    qby_qdqx=sum(qbky_qdqx); %qby(qx+dq)

    [qbkx_qdqy,qbky_qdqy,~]=sediment_transport_2D(flg,cnt,h,q+[0,der.dq],cf,La,Mak,dk,sed_trans_param,hiding_param,mor_fac,I,E_s);
    qbx_qdqy=sum(qbkx_qdqy); %qbx(qy+dq)
    qby_qdqy=sum(qbky_qdqy); %qby(qy+dq)
    
    qbkx_MaldMal=zeros(nf-1,nf); %qbkx(Mal+dMal)
    qbky_MaldMal=zeros(nf-1,nf); %qbky(Mal+dMal)
    Qbkx_MaldMal=zeros(nf-1,nf); %Qbkx(Mal+dMal)
    Qbky_MaldMal=zeros(nf-1,nf); %Qbky(Mal+dMal)
    for kf=1:nf-1
        der.dMa=zeros(1,nf-1);
        der.dMa(kf)=der.dMal;
        [qbkx_MaldMal(kf,:),qbky_MaldMal(kf,:),Qbkx_MaldMal(kf,:),Qbky_MaldMal(kf,:)]=sediment_transport_2D(flg,cnt,h,q,cf,La,Mak+der.dMa,dk,sed_trans_param,hiding_param,mor_fac,I,E_s);
    end %kf
    qbx_MaldMal=sum(qbkx_MaldMal,2); %qbx(Mal)
    qby_MaldMal=sum(qbky_MaldMal,2); %qby(Mal)
    Qbx_MaldMal=sum(Qbkx_MaldMal,2); %Qbx(Mal) 
    Qby_MaldMal=sum(Qbky_MaldMal,2); %Qby(Mal) 

    [qbkx_LadLa,qbky_LadLa,~]=sediment_transport_2D(flg,cnt,h,q,cf,La+der.dLa,Mak,dk,sed_trans_param,hiding_param,mor_fac,I,E_s);
    qbx_LadLa=sum(qbkx_LadLa); %qbx(La+dLa)
    qby_LadLa=sum(qbky_LadLa); %qby(La+dLa)

    [qbkx_IdI,qbky_IdI,~]=sediment_transport_2D(flg,cnt,h,q,cf,La,Mak,dk,sed_trans_param,hiding_param,mor_fac,I+der.dI,E_s);
    qbx_IdI=sum(qbkx_IdI); %qbx(I+dI)
    qby_IdI=sum(qbky_IdI); %qby(I+dI)

    %% in x
    
    %d(qbx)/d(h) ; %double [1,1]
    qbx_h=qbx; %qbx(h)
    dqbx_dh=(qbx_hdh-qbx_h)/der.dh; 

    %d(qbx)/d(qx) ; %double [1,1]
    qbx_qx=qbx; %qbx(qx)
    dqbx_dqx=(qbx_qdqx-qbx_qx)/der.dq; 
    
    %d(qbx)/d(qy) ; %double [1,1]
    qbx_qy=qbx; %qbx(qy)
    dqbx_dqy=(qbx_qdqy-qbx_qy)/der.dq; 
    
    %d(qbk)/d(h) ; double [1,nf]
    qbkx_h=qbkx; %qbk(h)
    dqbkx_dh=(qbkx_hdh-qbkx_h)./der.dh; 

    %d(qbkx)/d(qx) ; double [1,nf]
    qbkx_qx=qbkx; %qbk(qx)
    dqbkx_dqx=(qbkx_qdqx-qbkx_qx)./der.dq;
    
    %d(qbkx)/d(qy) ; double [1,nf]
    qbkx_qy=qbkx; %qbk(qy)
    dqbkx_dqy=(qbkx_qdqy-qbkx_qy)./der.dq;
    
    %d(qb)/d(Mal) ; double [nf-1,1]
    qbx_Mal=ones(nf-1,1)*qbx; %qb(Ma) 
    dqbx_dMal=(qbx_MaldMal-qbx_Mal)./der.dMal;
    
    %d(Qb)/d(Mal) ; double [nf-1,1] 
    Qbx_Mal=ones(nf-1,1)*Qbx; %Qb(Ma)  
    dQbx_dMal=(Qbx_MaldMal-Qbx_Mal)./der.dMal; 
    dQbx_dFal=La*dQbx_dMal; 
    
    %d(qbk)/d(Mal) ; double [nf-1,nf]
    qbkx_Mal=repmat(qbkx,nf-1,1); %qbk(Mal)
    dqbkx_dMal=(qbkx_MaldMal-qbkx_Mal)./der.dMal; %e.g. (nf=3): [dqb1/dMa1, dqb2/dMa1, dqb3/dMa1; dqb1/dMa2, dqb2/dMa2, dqb3/dMa2]
    
    %d(Qbk)/d(Mal) ; double [nf-1,nf] 
    Qbkx_Mal=repmat(Qbkx,nf-1,1); %Qbk(Mal) 
    dQbkx_dMal=(Qbkx_MaldMal-Qbkx_Mal)./der.dMal; 
    dQbkx_dFal=La*dQbkx_dMal; 
    
    %d(qb)/d(La) ; double [1,1]
    qbx_La=qbx; %qb(La)
    dqbx_dLa=(qbx_LadLa-qbx_La)/der.dLa; 
    
    %d(qbk)/d(La) ; double [1,nf]
    qbkx_La=qbkx; %qbk(La)
    dqbkx_dLa=(qbkx_LadLa-qbkx_La)./der.dLa;

    %d(qb)/d(I) ; double [1,1]
    qbx_I=qbx; %qb(I)
    dqbx_dI=(qbx_IdI-qbx_I)/der.dI; 

    %d(qbk)/d(I) ; double [1,nf]
    qbkx_I=qbkx; %qbk(I)
    dqbkx_dI=(qbkx_IdI-qbkx_I)./der.dI;
    
    %% in y
    
    %d(qby)/d(h) ; %double [1,1]
    qby_h=qby; %qb(h)
    dqby_dh=(qby_hdh-qby_h)/der.dh; 

    %d(qby)/d(qx) ; %double [1,1]
    qby_qx=qby; %qby(qx)
    dqby_dqx=(qby_qdqx-qby_qx)/der.dq; 
    
    %d(qby)/d(qy) ; %double [1,1]
    qby_qy=qby; %qby(qy)
    dqby_dqy=(qby_qdqy-qby_qy)/der.dq; 
    
    %d(qbk)/d(h) ; double [1,nf]
    qbky_h=qbky; %qbk(h)
    dqbky_dh=(qbky_hdh-qbky_h)./der.dh; 

    %d(qbky)/d(qx) ; double [1,nf]
    qbky_qx=qbky; %qbk(q)
    dqbky_dqx=(qbky_qdqx-qbky_qx)./der.dq;

    %d(qbky)/d(qy) ; double [1,nf]
    qbky_qy=qbky; %qbk(q)
    dqbky_dqy=(qbky_qdqy-qbky_qy)./der.dq;
    
    %d(qb)/d(Mal) ; double [nf-1,1]
    qby_Mal=ones(nf-1,1)*qby; %qb(Ma) 
    dqby_dMal=(qby_MaldMal-qby_Mal)./der.dMal;
    
    %d(Qb)/d(Mal) ; double [nf-1,1] 
    Qby_Mal=ones(nf-1,1)*Qby; %Qb(Ma)  
    dQby_dMal=(Qby_MaldMal-Qby_Mal)./der.dMal; 
    dQby_dFal=La*dQby_dMal; 
    
    %d(qbk)/d(Mal) ; double [nf-1,nf]
    qbky_Mal=repmat(qbky,nf-1,1); %qbk(Mal)
    dqbky_dMal=(qbky_MaldMal-qbky_Mal)./der.dMal; %e.g. (nf=3): [dqb1/dMa1, dqb2/dMa1, dqb3/dMa1; dqb1/dMa2, dqb2/dMa2, dqb3/dMa2]
    
    %d(Qbk)/d(Mal) ; double [nf-1,nf] 
    Qbky_Mal=repmat(Qbky,nf-1,1); %Qbk(Mal) 
    dQbky_dMal=(Qbky_MaldMal-Qbky_Mal)./der.dMal; 
    dQbky_dFal=La*dQbky_dMal; 
    
    %d(qb)/d(La) ; double [1,1]
    qby_La=qby; %qb(La)
    dqby_dLa=(qby_LadLa-qby_La)/der.dLa; 
    
    %d(qbk)/d(La) ; double [1,nf]
    qbky_La=qbky; %qbk(q)
    dqbky_dLa=(qbky_LadLa-qbky_La)./der.dLa;

    %d(qb)/d(I) ; double [1,1]
    qby_I=qby; %qb(I)
    dqby_dI=(qby_IdI-qby_I)/der.dI; 

    %d(qbk)/d(I) ; double [1,nf]
    qbky_I=qbky; %qbk(I)
    dqbky_dI=(qbky_IdI-qbky_I)./der.dI;
    
end

%% derivatives of secondary flow intensity
if any(flg.anl==7) || any(flg.anl==9) || any(flg.anl==11)

    [Txx,Txy,Tyy,alpha]=secondary_flow(flg,cnt,q,cf,I,beta_c);
    [Txx_qdqx,Txy_qdqx,Tyy_qdqx]=secondary_flow(flg,cnt,q+[der.dq,0],cf,I,beta_c);
    [Txx_qdqy,Txy_qdqy,Tyy_qdqy]=secondary_flow(flg,cnt,q+[0,der.dq],cf,I,beta_c);
    [Txx_IdI,Txy_IdI,Tyy_IdI]=secondary_flow(flg,cnt,q,cf,I+der.dI,beta_c);
    
    % _dqx
    %d(Txx)/d(qx) ; %double [1,1]
    Txx_qx=Txx; %Txx(qx)
    dTxx_dqx=(Txx_qdqx-Txx_qx)/der.dq; 
    
    %d(Txy)/d(qx) ; %double [1,1]
    Txy_qx=Txy; %Txy(qx)
    dTxy_dqx=(Txy_qdqx-Txy_qx)/der.dq;     
    
    %d(Txy)/d(qx) ; %double [1,1]
    dTyx_dqx=dTxy_dqx;
    
    %d(Tyy)/d(qx) ; %double [1,1]
    Tyy_qx=Tyy; %Tyy(qx)
    dTyy_dqx=(Tyy_qdqx-Tyy_qx)/der.dq;     
    
    % _dqy
    %d(Txx)/d(qy) ; %double [1,1]
    Txx_qy=Txx; %Txx(qy)
    dTxx_dqy=(Txx_qdqy-Txx_qy)/der.dq; 
    
    %d(Txy)/d(qy) ; %double [1,1]
    Txy_qy=Txy; %Txy(qy)
    dTxy_dqy=(Txy_qdqy-Txy_qy)/der.dq;     
    
    %d(Txy)/d(qy) ; %double [1,1]
    dTyx_dqy=dTxy_dqy;
    
    %d(Tyy)/d(qy) ; %double [1,1]
    Tyy_qy=Tyy; %Tyy(qy)
    dTyy_dqy=(Tyy_qdqy-Tyy_qy)/der.dq;   
    
    % _dI
    %d(Txx)/d(I) ; %double [1,1]
    Txx_I=Txx; %Txx(I)
    dTxx_dI=(Txx_IdI-Txx_I)/der.dI; 
    
    %d(Txy)/d(I) ; %double [1,1]
    Txy_I=Txy; %Txy(I)
    dTxy_dI=(Txy_IdI-Txy_I)/der.dI;     
    
    %d(Txy)/d(I) ; %double [1,1]
    dTyx_dI=dTxy_dI;
    
    %d(Tyy)/d(I) ; %double [1,1]
    Tyy_I=Tyy; %Tyy(I)
    dTyy_dI=(Tyy_IdI-Tyy_I)/der.dI;   
    
end


elseif flg.derivatives==2 %analytic
    %check MF=1
    if mor_fac~=1
        error('The analytical derivatives are not computed for Morphological Factors different than 1')
    end
    if flg.friction_closure==1 %Darcy | Weisbach
        if flg.sed_trans==1 %MPM48
            if flg.hiding==0 %no hiding-exposure
                %COMPROBADO
                Mak=Fak.*La;
                dqbk_dh=NaN(1,nf);
                dqbk_dq=NaN(1,nf);
                Qbk=NaN(nf-1,nf);
                dQbk_dFal=NaN(nf-1,nf);
                dFak_dFal=eye(nf-1,nf-1);
                dFak_dFal(:,nf)=-ones(nf-1,1);
                for kf=1:nf                       
                    dqbk_dh(kf)=(2*Mak(kf)*a_mpm*b_mpm*cf*q_m^2*((cf*q_m^2)/(cnt.R*dk(kf)*cnt.g*h^2) - theta_c)^(b_mpm - 1)*(cnt.R*dk(kf)^3*cnt.g)^(1/2))/(La*cnt.R*dk(kf)*cnt.g*h^3*(cnt.p - 1));
                    dqbk_dq(kf)=-(2*Mak(kf)*a_mpm*b_mpm*cf*q_m*((cf*q_m^2)/(cnt.R*dk(kf)*cnt.g*h^2) - theta_c)^(b_mpm - 1)*(cnt.R*dk(kf)^3*cnt.g)^(1/2))/(La*cnt.R*dk(kf)*cnt.g*h^2*(cnt.p - 1));
                    for kl=1:nf-1                        
                        Qbk(kl,kf)=-(a_mpm*((cf*q_m^2)/(cnt.R*dk(kf)*cnt.g*h^2) - theta_c)^b_mpm*(cnt.R*dk(kf)^3*cnt.g)^(1/2))/(cnt.p - 1);                        
                        dQbk_dFal(kl,kf)=0;
                        if isreal(Qbk(kl,kf))==0
                            Qbk(kl,kf)=0;
                            dQbk_dFal(kl,kf)=0;
                            dqbk_dh(kf)=0;
                            dqbk_dq(kf)=0;                            
                        end                        
                    end                        
                end                
                dqbk_dMal=1/La.*(dFak_dFal.*Qbk+repmat(Fak,nf-1,1).*dQbk_dFal);
                dQb_dFal=sum(dQbk_dFal,2);
                dqb_dh=sum(dqbk_dh);
                dqb_dq=sum(dqbk_dq);
                dqb_dMal=sum(dqbk_dMal,2); 
            elseif flg.hiding==1 %Egiazaroff
                if flg.Dm==1 %geometric 
                    error('Sorry, at this moment you cannot do this! :D')
                elseif flg.Dm==2
                    %COMPROBADO
                    Dm=sum(Fak.*dk);
                    
                    Mak=Fak.*La;
                    dqbk_dh=NaN(1,nf);
                    dqbk_dq=NaN(1,nf);
                    Qbk=NaN(nf-1,nf);
                    dQbk_dFal=NaN(nf-1,nf);
                    dFak_dFal=eye(nf-1,nf-1);
                    dFak_dFal(:,nf)=-ones(nf-1,1);
                    for kf=1:nf                       
                        dqbk_dh(kf)=(2*Mak(kf)*a_mpm*b_mpm*cf*q_m^2*((cf*q_m^2)/(cnt.R*dk(kf)*cnt.g*h^2) - ((log10(19)./log10(19*dk(kf)/Dm))^2)*theta_c)^(b_mpm - 1)*(cnt.R*dk(kf)^3*cnt.g)^(1/2))/(La*cnt.R*dk(kf)*cnt.g*h^3*(cnt.p - 1));
                        dqbk_dq(kf)=-(2*Mak(kf)*a_mpm*b_mpm*cf*q_m*((cf*q_m^2)/(cnt.R*dk(kf)*cnt.g*h^2) - ((log10(19)./log10(19*dk(kf)/Dm))^2)*theta_c)^(b_mpm - 1)*(cnt.R*dk(kf)^3*cnt.g)^(1/2))/(La*cnt.R*dk(kf)*cnt.g*h^2*(cnt.p - 1));
                        for kl=1:nf-1                        
                            Qbk(kl,kf)=-(a_mpm*((cf*q_m^2)/(cnt.R*dk(kf)*cnt.g*h^2) - ((log10(19)./log10(19*dk(kf)/Dm))^2)*theta_c)^b_mpm*(cnt.R*dk(kf)^3*cnt.g)^(1/2))/(cnt.p - 1);                        
                            dQbk_dFal(kl,kf)=(129554744785116508134396328225*a_mpm*b_mpm*theta_c*log(10)^2*((cf*q_m^2)/(cnt.R*dk(kf)*cnt.g*h^2) - (129554744785116508134396328225*theta_c*log(10)^2)/(79228162514264337593543950336*log((19*dk(kf))/Dm)^2))^(b_mpm - 1)*(dk(kl) - dk(end))*(cnt.R*dk(kf)^3*cnt.g)^(1/2))/(39614081257132168796771975168*Dm*log((19*dk(kf))/Dm)^3*(cnt.p - 1));
                            if isreal(Qbk(kl,kf))==0
                                Qbk(kl,kf)=0;
                                dQbk_dFal(kl,kf)=0;
                                dqbk_dh(kf)=0;
                                dqbk_dq(kf)=0;                            
                            end                        
                        end                        
                    end                
                    dqbk_dMal=1/La.*(dFak_dFal.*Qbk+repmat(Fak,nf-1,1).*dQbk_dFal);
                    dQb_dFal=sum(dQbk_dFal,2);
                    dqb_dh=sum(dqbk_dh);
                    dqb_dq=sum(dqbk_dq);
                    dqb_dMal=sum(dqbk_dMal,2); 
                end
            elseif flg.hiding==2 %Power law
                if flg.Dm==1 %geometric 
                    error('Sorry, at this moment you cannot do this! :D')
                elseif flg.Dm==2 %arithmetic
                    %COMPROBADO
                    Dm=sum(Fak.*dk);
                    xik=(dk./Dm).^b_he;
                    thetak=(cf*q_m^2)./(cnt.R.*dk.*cnt.g.*h^2);
                    
                    Mak=Fak.*La;
                    dqbk_dh=NaN(1,nf);
                    dqbk_dq=NaN(1,nf);
                    Qbk=NaN(nf-1,nf);
                    dQbk_dFal=NaN(nf-1,nf);
                    dFak_dFal=eye(nf-1,nf-1);
                    dFak_dFal(:,nf)=-ones(nf-1,1);
                    for kf=1:nf                       
                        dqbk_dh(kf)=(2*Mak(kf)*a_mpm*b_mpm*cf*q_m^2*(thetak(kf)-xik(kf)*theta_c)^(b_mpm - 1)*(cnt.R*dk(kf)^3*cnt.g)^(1/2))/(La*cnt.R*dk(kf)*cnt.g*h^3*(cnt.p - 1));
                        dqbk_dq(kf)=-(2*Mak(kf)*a_mpm*b_mpm*cf*q_m*(thetak(kf)-xik(kf)*theta_c)^(b_mpm - 1)*(cnt.R*dk(kf)^3*cnt.g)^(1/2))/(La*cnt.R*dk(kf)*cnt.g*h^2*(cnt.p - 1));
                        for kl=1:nf-1                        
                            Qbk(kl,kf)=-(a_mpm*((cf*q_m^2)/(cnt.R*dk(kf)*cnt.g*h^2) - xik(kf)*theta_c)^b_mpm*(cnt.R*dk(kf)^3*cnt.g)^(1/2))/(cnt.p - 1);                        
                            dQbk_dFal(kl,kf)=(b_mpm*theta_c*b_he)*(Qbk(1,kf)*xik(kf)/((cf*q_m^2)/(cnt.R*dk(kf)*cnt.g*h^2)-xik(kf)*theta_c))*((dk(kl)-dk(end))/Dm);
                            if isreal(Qbk(kl,kf))==0
                                Qbk(kl,kf)=0;
                                dQbk_dFal(kl,kf)=0;
                                dqbk_dh(kf)=0;
                                dqbk_dq(kf)=0;                            
                            end                        
                        end                        
                    end                
                    dqbk_dMal=1/La.*(dFak_dFal.*Qbk+repmat(Fak,nf-1,1).*dQbk_dFal);
                    dQb_dFal=sum(dQbk_dFal,2);
                    dqb_dh=sum(dqbk_dh);
                    dqb_dq=sum(dqbk_dq);
                    dqb_dMal=sum(dqbk_dMal,2); 
                end
            elseif flg.hiding==3 %Ashida Michihue
                error('Sorry, at this moment you cannot do this! :D')
            end

            
%             dqb_dLa=-sum(Qbk(1,:).*Fak)/La;
%             dqbk_dLa=-Qbk(1,:).*Fak/La;
        elseif flg.sed_trans~=1
            error('Sorry, at this moment you cannot do this! :D')
        end
    elseif flg.friction_closure==2 %Manning
      error('Sorry, at this moment you cannot do this! :D')
    end
end

% dqb_dh_n-dqb_dh
% dqbk_dh_n-dqbk_dh
% dqb_dq_n-dqb_dq
% dqbk_dq_n-dqbk_dq
% dqb_dMal_n-dqb_dMal
% dqbk_dMal_n-dqbk_dMal

% dqb_dh_n=dqb_dh;
% dqbk_dh_n=dqbk_dh;
% dqb_dq_n=dqb_dq;
% dqbk_dq_n=dqbk_dq;
% dqb_dMal_n=dqb_dMal;
% dqbk_dMal_n=dqbk_dMal;

%% FULLY COUPLED

%% Matrix construction (fully coupled)

if any(flg.anl==1)
A=NaN(nA,nA);

%Block (1,1) (Saint-Venant, Exner)
A(1,1:3)=[0,1,0];
A(2,1:3)=[cnt.g*h-u^2,2*u,cnt.g*h];
A(3,1:3)=[dqb_dh,dqb_dq,0];

%Block (1,2)
A(1,3+1:3+nf-1)=zeros(1,nf-1);
A(2,3+1:3+nf-1)=zeros(1,nf-1);
A(3,3+1:3+nf-1)=dqb_dMal(1:nf-1);

%Block (1,3)
% A(1,3+nf-1+1:end)=zeros(1,nf-1);
% A(2,3+nf-1+1:end)=zeros(1,nf-1);
% A(3,3+nf-1+1:end)=zeros(1,nf-1);

%Block (2,1)
A(3+1:3+nf-1,1)=dqbk_dh(1:nf-1)'-Fik(1:nf-1)'*dqb_dh;
A(3+1:3+nf-1,2)=dqbk_dq(1:nf-1)'-Fik(1:nf-1)'*dqb_dq;
A(3+1:3+nf-1,3)=zeros(nf-1,1);

%Block (2,2)
A(3+1:3+nf-1,3+1:3+nf-1)=(dqbk_dMal(1:nf-1,1:nf-1)-dqb_dMal(1:nf-1,1)*Fik(1:nf-1))';

%Block (2,3)
% A(3+1:3+nf-1,3+nf-1+1:end)=zeros(nf-1,nf-1);

%Block (3,1)
% A(3+nf-1+1:end,1)=Fik(1:nf-1)'*dqb_dh;
% A(3+nf-1+1:end,2)=Fik(1:nf-1)'*dqb_dq;
% A(3+nf-1+1:end,3)=zeros(nf-1,1);

%Block (3,2)
% A(3+nf-1+1:end,3+1:3+nf-1)=(dqb_dMal(1:nf-1,1)*Fik(1:nf-1))'; 

%Block (3,3)
% A(3+nf-1+1:end,3+nf-1+1:end)=zeros(nf-1,nf-1);

%% Eigenvalues (fully coupled)
eig_l_all=eig(A);

elliptic=0;
if isreal(eig_l_all)==0
    elliptic=1;
end

eigen_all_f=eig_l_all(abs(eig_l_all)>1e-14); %all eigenvalues above threshold (filtered)
ne_d0=length(eigen_all_f); %number of eigenvalues above threshold
eigen_all=[eigen_all_f;zeros(ne-ne_d0,1)]; %assign 0 to the very small eigenvalues

else 
    A=NaN;
    eigen_all=NaN;
    elliptic=NaN;
end

%% QUASI-STEADY

%% Matrix construction (quasi-steady)

if any(flg.anl==2)
A_qs=NaN(nA_qs,nA_qs);

%Block (1,1) 
A_qs(1,1)=-1/(1-Fr^2)*dqb_dh;

%Block (1,2)
A_qs(1,2:end)=dqb_dMal(1:nf-1);

%Block (2,1)
A_qs(2:end,1)=-1/(1-Fr^2).*(dqbk_dh(1:nf-1)'-Fik(1:nf-1)'*dqb_dh);

%Block (2,2)
A_qs(2:end,2:end)=(dqbk_dMal(1:nf-1,1:nf-1)-dqb_dMal(1:nf-1,1)*Fik(1:nf-1))';
                  
%% Eigenvalues (quasi-steady)
eig_l_all_qs=eig(A_qs);

elliptic_qs=0;
if isreal(eig_l_all_qs)==0
    elliptic_qs=1;
end

eigen_all_f_qs=eig_l_all_qs(abs(eig_l_all_qs)>1e-14); %all eigenvalues above threshold (filtered)
ne_d0_qs=length(eigen_all_f_qs); %number of eigenvalues above threshold
eigen_all_qs=[eigen_all_f_qs;zeros(ne_qs-ne_d0_qs,1)]; %assign 0 to the very small eigenvalues

else
    A_qs=NaN;
    eigen_all_qs=NaN;
    elliptic_qs=NaN;
end

%% VARIABLE ACTIVE LAYER THICKNESS

%% Matrix construction (variable active layer thickness)

if any(flg.anl==3)
A_dLa=NaN(nA_dLa,nA_dLa);

%Block (1,1) (Saint-Venant, Exner, and active layer)
A_dLa(1,1:4)=[0,1,0,0];
A_dLa(2,1:4)=[cnt.g*h-u^2,2*u,cnt.g*h,0];
A_dLa(3,1:4)=[dqb_dh,dqb_dq,0,dqb_dLa];
A_dLa(4,1:4)=[0,a_dL*b_dL*h^(b_dL-1),0,0];

%Block (1,2)
A_dLa(1,4+1:4+nf-1)=zeros(1,nf-1);
A_dLa(2,4+1:4+nf-1)=zeros(1,nf-1);
A_dLa(3,4+1:4+nf-1)=dqb_dMal(1:nf-1);
A_dLa(4,4+1:4+nf-1)=zeros(1,nf-1);

%Block (1,3)
% A_dLa(1,4+nf-1+1:end)=zeros(1,nf-1);
% A_dLa(2,4+nf-1+1:end)=zeros(1,nf-1);
% A_dLa(3,4+nf-1+1:end)=zeros(1,nf-1);
% A_dLa(4,4+nf-1+1:end)=zeros(1,nf-1);

%Block (2,1)
A_dLa(4+1:4+nf-1,1)=dqbk_dh(1:nf-1)'-Fik(1:nf-1)'*dqb_dh;
A_dLa(4+1:4+nf-1,2)=dqbk_dq(1:nf-1)'-Fik(1:nf-1)'*dqb_dq+Fik(1:nf-1)'*a_dL*b_dL*h^(b_dL-1);
A_dLa(4+1:4+nf-1,3)=zeros(nf-1,1);
A_dLa(4+1:4+nf-1,4)=dqbk_dLa(1:nf-1)'-Fik(1:nf-1)'*dqb_dLa;

%Block (2,2)
A_dLa(4+1:4+nf-1,4+1:4+nf-1)=(dqbk_dMal(1:nf-1,1:nf-1)-dqb_dMal(1:nf-1,1)*Fik(1:nf-1))';

%Block (2,3)
% A_dLa(4+1:4+nf-1,4+nf-1+1:end)=zeros(nf-1,nf-1);

%Block (3,1)
% A_dLa(4+nf-1+1:end,1)=Fik(1:nf-1)'*dqb_dh;
% A_dLa(4+nf-1+1:end,2)=Fik(1:nf-1)'*dqb_dq-Fik(1:nf-1)'*a_dL*b_dL*h^(b_dL-1);
% A_dLa(4+nf-1+1:end,3)=zeros(nf-1,1);
% A_dLa(4+nf-1+1:end,4)=Fik(1:nf-1)'*dqb_dLa;

%Block (3,2)
% A_dLa(4+nf-1+1:end,4+1:4+nf-1)=(dqb_dMal(1:nf-1,1)*Fik(1:nf-1))'; 

%Block (3,3)
% A_dLa(4+nf-1+1:end,4+nf-1+1:end)=zeros(nf-1,nf-1);

%% Eigenvalues (variable active layer thickness)
eig_l_all_dLa=eig(A_dLa);

elliptic_dLa=0;
if isreal(eig_l_all_dLa)==0
    elliptic_dLa=1;
end

eigen_all_f_dLa=eig_l_all_dLa(abs(eig_l_all_dLa)>1e-14); %all eigenvalues above threshold (filtered)
ne_d0_dLa=length(eigen_all_f_dLa); %number of eigenvalues above threshold
eigen_all_dLa=[eigen_all_f_dLa;zeros(ne_dLa-ne_d0_dLa,1)]; %assign 0 to the very small eigenvalues

else
    A_dLa=NaN;
    eigen_all_dLa=NaN;
    elliptic_dLa=NaN;
end

%% RIBBERINK 

if any(flg.anl==4)
Ribb.Dm_i=sum(Fik.*dk); %arithmetic mean grain size of the interface
Ribb.Dm_a=sum(Fak.*dk); %arithmetic mean grain size of the active layer
Ribb.M=1/Ribb.n*h/La*(1-Fr^2); %M parameter
Ribb.L=Ribb.l*(Ribb.Dm_i/Ribb.Dm_a-1); %L parameter
Ribb.dis=Ribb.M^2*(1+Ribb.L)^2+2*Ribb.M*(Ribb.L-1)+1; %eigenvalues discriminant
Ribb.ell=0; %assign hyperbolic
if Ribb.dis<0 %if discriminant is negative it is elliptic
    Ribb.ell=1; %assign elliptic
end

%Ribberinks analysis with our sediment transport relations

%d(qb)_d(Dml) ; double [nf-1,1]
Dm=sum(Fak.*dk);
dDmk=NaN(nf-1,1);
for kf=1:nf-1
    der.dMa=zeros(1,nf-1);
    der.dMa(kf)=der.dMal;
    MakdMa=Mak+der.dMa;
    FakdFa=MakdMa./La;
    FakdFa_all=[FakdFa,1-sum(FakdFa)];
    DmdDmk=sum(FakdFa_all.*dk);
    dDmk(kf,1)=DmdDmk-Dm;
end
dqb_dDml=dqb_dMal.*der.dMal./dDmk;

%d(qb)/d(Dm) ; double [1,1]
dqb_dDm=mean(dqb_dDml);

Ribb.L2=(Ribb.Dm_a-Ribb.Dm_i)/qb*dqb_dDm;
Ribb.lr=qb/u/La*(1+Ribb.L2);
Ribb.lb=dqb_dq/(1-Fr^2);
Ribb.disc2=(Ribb.lr-Ribb.lb)^2+4*Ribb.lr*Ribb.lb*Ribb.L2/(1+Ribb.L2);

Ribb.ell2=0; %assign hyperbolic
if Ribb.disc2<0 %if discriminant is negative it is elliptic
    Ribb.ell2=1; %assign elliptic
end

else
    Ribb=NaN;    
end

%% ADVECTION-DECAY

%% Matrix construction (advection-decay)

if any(flg.anl==5)
A_ad=NaN(nA_ad,nA_ad);

%Block (1,1) 
A_ad(1,1)=zeros(1,1);

%Block (1,2)
A_ad(1,2:2+nef-1)=zeros(1,nef);

%Block (1,3)
A_ad(1,2+nef)=ones(1,1);

%Block (1,4)
A_ad(1,2+nef+1:2+2*nef)=zeros(1,nef);

%Block (2,1)
A_ad(2:2+nef-1,1)=zeros(nef,1);

%Block (2,2)
A_ad(2:2+nef-1,2:2+nef-1)=zeros(nef,nef);

%Bloc (2,3)
A_ad(2:2+nef-1,2+nef)=-Fik(1,nef)';

%Bloc (2,4)
A_ad(2:2+nef-1,2+nef+1:2+2*nef)=eye(nef);

%Bloc (3,1)
A_ad(2+nef,1)=u_b/(1-Fr^2)*dqb_dh;

%Bloc (3,2)
A_ad(2+nef,2:2+nef-1)=-u_b.*dqb_dMal(1:nef,1)';

%Bloc (3,3)
A_ad(2+nef,2+nef)=u_b-sum(Fik(1:nef).*dqb_dMal(1:nef,1)');

%Bloc (3,4)
A_ad(2+nef,2+nef+1:2+2*nef)=dqb_dMal(1:nef,1)';

%Bloc (4,1) 
A_ad(2+nef+1:2+2*nef,1)=u_b/(1-Fr^2).*dqbk_dh(1,1:nef)';

%Bloc (4,2)
A_ad(2+nef+1:2+2*nef,2:2+nef-1)=-u_b.*dqbk_dMal(1:nef,1:nef)';

%Bloc (4,3)
A_ad(2+nef+1:2+2*nef,2+nef)=-sum(repmat(Fik(1:nef),nef,1).*dqbk_dMal(1:nef,1:nef)',2);

%Bloc (4,4)
A_ad(2+nef+1:2+2*nef,2+nef+1:2+2*nef)=u_b.*eye(nef)+dqbk_dMal(1:nef,1:nef)';

%% Eigenvalues (advection decay)
eig_l_all_ad=eig(A_ad);

elliptic_ad=0;
if isreal(eig_l_all_ad)==0
    elliptic_ad=1;
end

eigen_all_f_ad=eig_l_all_ad(abs(eig_l_all_ad)>1e-14); %all eigenvalues above threshold (filtered)
ne_d0_ad=length(eigen_all_f_ad); %number of eigenvalues above threshold
eigen_all_ad=[eigen_all_f_ad;zeros(ne_ad-ne_d0_ad,1)]; %assign 0 to the very small eigenvalues

else
    A_ad=NaN;
    eigen_all_ad=NaN;
    elliptic_ad=NaN;
end

%% 2D no secondary flow
if any(flg.anl==6)
    %% Ax
Ax=NaN(nA_2D,nA_2D);

%Bloc (1,1)
Ax(1,1:4)=[0,1,0,0]; 
Ax(2,1:4)=[cnt.g*h-(q(1)/h)^2,2*q(1)/h,0,cnt.g*h];
Ax(3,1:4)=[-q(1)*q(2)/h^2,q(2)/h,q(1)/h,0];
Ax(4,1:4)=[dqbx_dh,dqbx_dqx,dqbx_dqy,0];

%Bloc (1,2)
Ax(1,5:nf+3)=zeros(nef,1);
Ax(2,5:nf+3)=zeros(nef,1);
Ax(3,5:nf+3)=zeros(nef,1);
Ax(4,5:nf+3)=dqbx_dMal(1:nef);

%Bloc (2,1)
Ax(5:nf+3,1)=dqbkx_dh(1:nef)'-Fik(1:nef)'*dqbx_dh; 
Ax(5:nf+3,2)=dqbkx_dqx(1:nef)'-Fik(1:nef)'*dqbx_dqx; 
Ax(5:nf+3,3)=dqbkx_dqy(1:nef)'-Fik(1:nef)'*dqbx_dqy; 
Ax(5:nf+3,4)=zeros(nef,1); 

%Bloc (2,2)
Ax(5:nf+3,5:nf+3)=(dqbkx_dMal(1:nef,1:nef)-dqbx_dMal(1:nef,1)*Fik(1:nf-1))';

    %% Ay
Ay=NaN(nA_2D,nA_2D);

%Bloc (1,1)
Ay(1,1:4)=[0,0,1,0]; 
Ay(2,1:4)=[-q(1)*q(2)/h^2,q(2)/h,q(1)/h,0];
Ay(3,1:4)=[cnt.g*h-(q(2)/h)^2,0,2*q(2)/h,cnt.g*h];
Ay(4,1:4)=[dqby_dh,dqby_dqx,dqby_dqy,0];

%Bloc (1,2)
Ay(1,5:nf+3)=zeros(nef,1);
Ay(2,5:nf+3)=zeros(nef,1);
Ay(3,5:nf+3)=zeros(nef,1);
Ay(4,5:nf+3)=dqby_dMal(1:nef);

%Bloc (2,1)
Ay(5:nf+3,1)=dqbky_dh(1:nef)'-Fik(1:nef)'*dqby_dh; 
Ay(5:nf+3,2)=dqbky_dqx(1:nef)'-Fik(1:nef)'*dqby_dqx; 
Ay(5:nf+3,3)=dqbky_dqy(1:nef)'-Fik(1:nef)'*dqby_dqy; 
Ay(5:nf+3,4)=zeros(nef,1); 

%Bloc (2,2)
Ay(5:nf+3,5:nf+3)=(dqbky_dMal(1:nef,1:nef)-dqby_dMal(1:nef,1)*Fik(1:nf-1))';

%% Eigenvalues (2D)
eig_l_all_2Dx=eig(Ax);
eig_l_all_2Dy=eig(Ay);

elliptic_2D=0;
if isreal(eig_l_all_2Dx)==0 || isreal(eig_l_all_2Dy)==0
    elliptic_2D=1;
end

eigen_all_f_2Dx=eig_l_all_2Dx(abs(eig_l_all_2Dx)>1e-14); %all eigenvalues above threshold (filtered)
ne_d0_2Dx=length(eigen_all_f_2Dx); %number of eigenvalues above threshold
eigen_all_2Dx=[eigen_all_f_2Dx;zeros(ne_2D-ne_d0_2Dx,1)]; %assign 0 to the very small eigenvalues

eigen_all_f_2Dy=eig_l_all_2Dy(abs(eig_l_all_2Dy)>1e-14); %all eigenvalues above threshold (filtered)
ne_d0_2Dy=length(eigen_all_f_2Dy); %number of eigenvalues above threshold
eigen_all_2Dy=[eigen_all_f_2Dy;zeros(ne_2D-ne_d0_2Dy,1)]; %assign 0 to the very small eigenvalues

else
    Ax=NaN;
    Ay=NaN;
    eigen_all_2Dx=NaN;
    eigen_all_2Dy=NaN;
    elliptic_2D=NaN;
end %2D

%% 2D secondary flow
if any(flg.anl==7)
    %% Ax_sf
Ax_sf=NaN(nA_2D_sf,nA_2D_sf);

%Bloc (1,1)
Ax_sf(1,1:5)=[0,1,0,0,0]; 
Ax_sf(2,1:5)=[cnt.g*h-(q(1)/h)^2,2*q(1)/h-dTxx_dqx,-dTxx_dqy,-dTxx_dI,cnt.g*h];
Ax_sf(3,1:5)=[-q(1)*q(2)/h^2,q(2)/h-dTyx_dqx,q(1)/h-dTyx_dqy,-dTyx_dI,0];
Ax_sf(4,1:5)=[0,0,0,q(1)/h,0];
Ax_sf(5,1:5)=[dqbx_dh,dqbx_dqx,dqbx_dqy,dqbx_dI,0];

%Bloc (1,2)
Ax_sf(1,6:nf+4)=zeros(nef,1);
Ax_sf(2,6:nf+4)=zeros(nef,1);
Ax_sf(3,6:nf+4)=zeros(nef,1);
Ax_sf(4,6:nf+4)=zeros(nef,1);
Ax_sf(5,6:nf+4)=dqbx_dMal(1:nef);

%Bloc (2,1)
Ax_sf(6:nf+4,1)=dqbkx_dh(1:nef)'-Fik(1:nef)'*dqbx_dh; 
Ax_sf(6:nf+4,2)=dqbkx_dqx(1:nef)'-Fik(1:nef)'*dqbx_dqx; 
Ax_sf(6:nf+4,3)=dqbkx_dqy(1:nef)'-Fik(1:nef)'*dqbx_dqy; 
Ax_sf(6:nf+4,4)=dqbkx_dI(1:nef)'-Fik(1:nef)'*dqbx_dI; 
Ax_sf(6:nf+4,5)=zeros(nef,1); 

%Bloc (2,2)
Ax_sf(6:nf+4,6:nf+4)=(dqbkx_dMal(1:nef,1:nef)-dqbx_dMal(1:nef,1)*Fik(1:nf-1))';

    %% Ay_sf
Ay_sf=NaN(nA_2D,nA_2D);

%Bloc (1,1)
Ay_sf(1,1:5)=[0,0,1,0,0]; 
Ay_sf(2,1:5)=[-q(1)*q(2)/h^2,q(2)/h-dTxy_dqx,q(1)/h-dTxy_dqy,-dTxy_dI,0];
Ay_sf(3,1:5)=[cnt.g*h-(q(2)/h)^2,-dTyy_dqx,2*q(2)/h-dTyy_dqy,-dTyy_dI,cnt.g*h];
Ay_sf(4,1:5)=[0,0,0,q(2)/h,0];
Ay_sf(5,1:5)=[dqby_dh,dqby_dqx,dqby_dqy,dqby_dI,0];

%Bloc (1,2)
Ay_sf(1,6:nf+4)=zeros(nef,1);
Ay_sf(2,6:nf+4)=zeros(nef,1);
Ay_sf(3,6:nf+4)=zeros(nef,1);
Ay_sf(4,6:nf+4)=zeros(nef,1);
Ay_sf(5,6:nf+4)=dqby_dMal(1:nef);

%Bloc (2,1)
Ay_sf(6:nf+4,1)=dqbky_dh(1:nef)'-Fik(1:nef)'*dqby_dh; 
Ay_sf(6:nf+4,2)=dqbky_dqx(1:nef)'-Fik(1:nef)'*dqby_dqx; 
Ay_sf(6:nf+4,3)=dqbky_dqy(1:nef)'-Fik(1:nef)'*dqby_dqy; 
Ay_sf(6:nf+4,4)=dqbky_dI(1:nef)'-Fik(1:nef)'*dqby_dI; 
Ay_sf(6:nf+4,5)=zeros(nef,1); 

%Bloc (2,2)
Ay_sf(6:nf+4,6:nf+4)=(dqbky_dMal(1:nef,1:nef)-dqby_dMal(1:nef,1)*Fik(1:nf-1))';

%% Eigenvalues (2D secondary flow)
eig_l_all_2Dx_sf=eig(Ax_sf);
eig_l_all_2Dy_sf=eig(Ay_sf);

elliptic_2D_sf=0;
if isreal(eig_l_all_2Dx_sf)==0 || isreal(eig_l_all_2Dy_sf)==0
    elliptic_2D_sf=1;
end

eigen_all_f_2Dx_sf=eig_l_all_2Dx_sf(abs(eig_l_all_2Dx_sf)>1e-14); %all eigenvalues above threshold (filtered)
ne_d0_2Dx_sf=length(eigen_all_f_2Dx_sf); %number of eigenvalues above threshold
eigen_all_2Dx_sf=[eigen_all_f_2Dx_sf;zeros(ne_2D_sf-ne_d0_2Dx_sf,1)]; %assign 0 to the very small eigenvalues

eigen_all_f_2Dy_sf=eig_l_all_2Dy_sf(abs(eig_l_all_2Dy_sf)>1e-14); %all eigenvalues above threshold (filtered)
ne_d0_2Dy_sf=length(eigen_all_f_2Dy_sf); %number of eigenvalues above threshold
eigen_all_2Dy_sf=[eigen_all_f_2Dy_sf;zeros(ne_2D_sf-ne_d0_2Dy_sf,1)]; %assign 0 to the very small eigenvalues

else
    Ax_sf=NaN;
    Ay_sf=NaN;
    eigen_all_2Dx_sf=NaN;
    eigen_all_2Dy_sf=NaN;
    elliptic_2D_sf=NaN;
end %2D

%% 2D SW no secondary flow
if any(flg.anl==8)
    %% Ax_sf
Ax_SW=NaN(3,3);

Ax_SW(1,1:3)=[0,1,0]; 
Ax_SW(2,1:3)=[cnt.g*h-(q(1)/h)^2,2*q(1)/h,0];
Ax_SW(3,1:3)=[-q(1)*q(2)/h^2,q(2)/h,q(1)/h];

    %% Ay_sf
Ay_SW=NaN(3,3);

%Bloc (1,1)
Ay_SW(1,1:3)=[0,0,1]; 
Ay_SW(2,1:3)=[-q(1)*q(2)/h^2,q(2)/h,q(1)/h];
Ay_SW(3,1:3)=[cnt.g*h-(q(2)/h)^2,0,2*q(2)/h];

%% Eigenvalues (SW no secondary flow)
eig_l_all_SWx=eig(Ax_SW);
eig_l_all_SWy=eig(Ay_SW);

elliptic_SW=0;

% if isreal(eig_l_all_2Dx_sf)==0 || isreal(eig_l_all_2Dy_sf)==0
%     elliptic_2D_sf=1;
% end

eigen_all_SWx=eig_l_all_SWx;
eigen_all_SWy=eig_l_all_SWy;
% eigen_all_f_2Dx_sf=eig_l_all_2Dx_sf(abs(eig_l_all_2Dx_sf)>1e-14); %all eigenvalues above threshold (filtered)
% ne_d0_2Dx_sf=length(eigen_all_f_2Dx_sf); %number of eigenvalues above threshold
% eigen_all_2Dx_sf=[eigen_all_f_2Dx_sf;zeros(ne_2D_sf-ne_d0_2Dx_sf,1)]; %assign 0 to the very small eigenvalues
% 
% eigen_all_f_2Dy_sf=eig_l_all_2Dy_sf(abs(eig_l_all_2Dy_sf)>1e-14); %all eigenvalues above threshold (filtered)
% ne_d0_2Dy_sf=length(eigen_all_f_2Dy_sf); %number of eigenvalues above threshold
% eigen_all_2Dy_sf=[eigen_all_f_2Dy_sf;zeros(ne_2D_sf-ne_d0_2Dy_sf,1)]; %assign 0 to the very small eigenvalues


else
    Ax_SW=NaN;
    Ay_SW=NaN;
    eigen_all_SWx=NaN;
    eigen_all_SWy=NaN;
    elliptic_SW=NaN;
end %2D SW no secflow

%% SW secondary flow
if any(flg.anl==9)
    %% Ax_sf
Ax_SW_sf=NaN(nA_SW_sf,nA_SW_sf);

%Bloc (1,1)
Ax_SW_sf(1,1:4)=[0,1,0,0]; 
Ax_SW_sf(2,1:4)=[cnt.g*h-(q(1)/h)^2,2*q(1)/h-dTxx_dqx,-dTxx_dqy,-dTxx_dI];
Ax_SW_sf(3,1:4)=[-q(1)*q(2)/h^2,q(2)/h-dTyx_dqx,q(1)/h-dTyx_dqy,-dTyx_dI];
Ax_SW_sf(4,1:4)=[0,0,0,q(1)/h];

    %% Ay_sf
Ay_SW_sf=NaN(nA_SW_sf,nA_SW_sf);

%Bloc (1,1)
Ay_SW_sf(1,1:4)=[0,0,1,0]; 
Ay_SW_sf(2,1:4)=[-q(1)*q(2)/h^2,q(2)/h-dTxy_dqx,q(1)/h-dTxy_dqy,-dTxy_dI];
Ay_SW_sf(3,1:4)=[cnt.g*h-(q(2)/h)^2,-dTyy_dqx,2*q(2)/h-dTyy_dqy,-dTyy_dI];
Ay_SW_sf(4,1:4)=[0,0,0,q(2)/h];

%% Eigenvalues (2D secondary flow)

[elliptic_SW_sf]=ellipticity_2D(param_twoD,Ax_SW_sf,Ay_SW_sf);

% eigen_all_SWx_sf=eig(Ax_SW_sf);
% eigen_all_SWy_sf=eig(Ax_SW_sf);
eigen_all_SWx_sf=NaN;
eigen_all_SWy_sf=NaN;

else
    Ax_SW_sf=NaN;
    Ay_SW_sf=NaN;
    eigen_all_SWx_sf=NaN;
    eigen_all_SWy_sf=NaN;
    elliptic_SW_sf=NaN;
end %2D

%% 2D SW-Exner no secondary flow
if any(flg.anl==10)
    %% Ax_sf
Ax_SWE=NaN(nA_SWE,nA_SWE);

Ax_SWE(1,1:4)=[0,1,0,0]; 
Ax_SWE(2,1:4)=[cnt.g*h-(q(1)/h)^2,2*q(1)/h,0,cnt.g*h];
Ax_SWE(3,1:4)=[-q(1)*q(2)/h^2,q(2)/h,q(1)/h,0];
Ax_SWE(4,1:4)=[dqbx_dh,dqbx_dqx,dqbx_dqy,0];

    %% Ay_sf
Ay_SWE=NaN(nA_SWE,nA_SWE);

Ay_SWE(1,1:4)=[0,0,1,0]; 
Ay_SWE(2,1:4)=[-q(1)*q(2)/h^2,q(2)/h,q(1)/h,0];
Ay_SWE(3,1:4)=[cnt.g*h-(q(2)/h)^2,0,2*q(2)/h,cnt.g*h];
Ay_SWE(4,1:4)=[dqby_dh,dqby_dqx,dqby_dqy,0];

%% Eigenvalues (2D SWE secondary flow)

[elliptic_SWE]=ellipticity_2D(param_twoD,Ax_SWE,Ay_SWE);

% eigen_all_SWEx=eig(Ax_SWE);
% eigen_all_SWEy=eig(Ay_SWE);
eigen_all_SWEx=NaN;
eigen_all_SWEy=NaN;

else
    Ax_SWE=NaN;
    Ay_SWE=NaN;
    eigen_all_SWEx=NaN;
    eigen_all_SWEy=NaN;
    elliptic_SWE=NaN;
end %2D


%% SW-E secondary flow
if any(flg.anl==11)
    %% Ax_sf
Ax_SWE_sf=NaN(nA_SWE_sf,nA_SWE_sf);

Ax_SWE_sf(1,1:5)=[0,1,0,0,0]; 
Ax_SWE_sf(2,1:5)=[cnt.g*h-(q(1)/h)^2,2*q(1)/h-dTxx_dqx,-dTxx_dqy,-dTxx_dI,cnt.g*h];
Ax_SWE_sf(3,1:5)=[-q(1)*q(2)/h^2,q(2)/h-dTyx_dqx,q(1)/h-dTyx_dqy,-dTyx_dI,0];
% Ax_SWE_sf(4,1:5)=[0,0,0,q(1)/h,0];
Ax_SWE_sf(4,1:5)=[0,0,2*cnt.k^2*alpha/(1-2*alpha)*q(1)/h^2,q(1)/h,0];
Ax_SWE_sf(5,1:5)=[dqbx_dh,dqbx_dqx,dqbx_dqy,dqbx_dI,0];


    %% Ay_sf
Ay_SWE_sf=NaN(nA_SWE_sf,nA_SWE_sf);

Ay_SWE_sf(1,1:5)=[0,0,1,0,0]; 
Ay_SWE_sf(2,1:5)=[-q(1)*q(2)/h^2,q(2)/h-dTxy_dqx,q(1)/h-dTxy_dqy,-dTxy_dI,0];
Ay_SWE_sf(3,1:5)=[cnt.g*h-(q(2)/h)^2,-dTyy_dqx,2*q(2)/h-dTyy_dqy,-dTyy_dI,cnt.g*h];
Ay_SWE_sf(4,1:5)=[0,0,0,q(2)/h,0];
Ay_SWE_sf(5,1:5)=[dqby_dh,dqby_dqx,dqby_dqy,dqby_dI,0];

%% Eigenvalues (2D secondary flow)

[elliptic_SWE_sf]=ellipticity_2D(param_twoD,Ax_SWE_sf,Ay_SWE_sf);

% eigen_all_SWEx_sf=eig(Ax_SWE_sf);
% eigen_all_SWEy_sf=eig(Ax_SWE_sf);
eigen_all_SWEx_sf=NaN;
eigen_all_SWEy_sf=NaN;

else
    Ax_SWE_sf=NaN;
    Ay_SWE_sf=NaN;
    eigen_all_SWEx_sf=NaN;
    eigen_all_SWEy_sf=NaN;
    elliptic_SWE_sf=NaN;
end %2D

%%
%% Mobility check
%%

if any(flg.anl==1) || any(flg.anl==2) || any(flg.anl==3) || any(flg.anl==4) || any(flg.anl==5)
        out.rev_mob=any(diff(Qbk)>1e-14); %reverse mobility
        out.inm_frac=any(Qbk<1e-14); %inmobile fraction
        out.qbk=qbk;
elseif any(flg.anl==6) || any(flg.anl==7) || any(flg.anl==8)|| any(flg.anl==9)|| any(flg.anl==10)|| any(flg.anl==11)     
        out.rev_mob=any(diff(Qbkx)>1e-14)||any(diff(Qbky)>1e-14); %reverse mobility
        out.inm_frac=any(Qbkx<1e-14)||any(Qbky<1e-14); %inmobile fraction
        out.qbk=[qbkx,qbky];
end

if flg.check_input==1
    if out.inm_frac==1; disp('at least one fraction is inmobile!'); end 
    if out.rev_mob==1; disp('reverse mobility!'); end 
end

%%
%% Characteristic polinomia
%%

if flg.cp==1
    
cp.Fr=Fr;
    %definitions
    %new
cp.psi=dqb_dq; %double [1,1]
cp.chi=1/u.*dqb_dMal; %double [nf-1,1]
cp.c=dqbk_dq(1:nf-1)./cp.psi; %double [nf-1,1]
cp.gamma=cp.c-Fik(1:nf-1); %double [nf-1,1]
cp.d=dqbk_dMal(:,1:nf-1)'./repmat(u*cp.chi',nf-1,1); %double [nf-1,nf-1]
cp.mu=cp.d'-repmat(Fik(1:nf-1),nf-1,1); %double [nf-1,nf-1]
cp.lb=cp.psi/(1-cp.Fr^2); %double [1,1]
cp.ls1=cp.chi(1)*cp.mu(1,1); %double [1,1]
cp.qbk=qbk;

if length(dk)==2 %two fractions 

    %old
cp.Qbk=Qbk;

cp.dqbk_dq=dqbk_dq;
cp.dQbk_dFal=dQbk_dFal;
cp.dQb_dFal=dQb_dFal;
cp.dqbk_dMal=dqbk_dMal;
cp.dqb_dMal=dqb_dMal;
cp.dqbk_dFal=La.*dqbk_dMal;
cp.dqb_dFal=sum(cp.dqbk_dFal);

cp.psi=dqb_dq;
cp.psi_Fr=cp.psi/(1-Fr^2); %obsolete
cp.DV=cp.psi/(1-Fr^2);

cp.c1=1/cp.psi.*dqbk_dq(1);
cp.gamma1=cp.c1-Fik(1);
cp.kappa1=cp.gamma1+cp.c1;

cp.diffQbk=(Qbk(1)-Qbk(2));

cp.kappaQb=Qbk(1)-cp.kappa1*cp.diffQbk;
cp.FikQb=Qbk(1)-Fik(1)*cp.diffQbk;
cp.c1Qb=Qbk(1)-cp.c1*cp.diffQbk;

cp.R=1/u*(dqbk_dMal(1,1)-Fik(1)*dqb_dMal(1)); %dimensionless Ribberink celerity without simplification
cp.R_s=cp.FikQb/(u*La); %dimensionless Ribberink celerity with simplification

% cp.charpoly=charpoly(A(1:end-1,1:end-1)); %eliminate substrate equation

%quasi-steady (non-dimensional characteristic polynomial)
    %without simplification
cp.qs_disc=cp.psi_Fr*(cp.psi_Fr-2/u*(cp.dqbk_dMal(1,1)-cp.kappa1*cp.dqb_dMal(1)))+1/u^2*(cp.dqbk_dMal(1,1)-Fik(1)*cp.dqb_dMal(1))^2; %discriminant 
cp.qs_eigen(1)=1/2*(cp.psi_Fr+1/u*(cp.dqbk_dMal(1,1)-Fik(1)*cp.dqb_dMal(1))+sqrt(cp.qs_disc)); %analytic eigenvalues 
cp.qs_eigen(2)=1/2*(cp.psi_Fr+1/u*(cp.dqbk_dMal(1,1)-Fik(1)*cp.dqb_dMal(1))-sqrt(cp.qs_disc)); %analytic eigenvalues 
cp.qs_disc_2=(cp.DV-cp.R)^2+4*cp.DV*cp.gamma1*1/u*cp.dqb_dMal(1);
cp.qs_eigen_2(1)=1/2*(cp.DV+cp.R+sqrt(cp.qs_disc_2));
cp.qs_eigen_2(2)=1/2*(cp.DV+cp.R-sqrt(cp.qs_disc_2));

% cp.charpoly_qs=charpoly(A_qs); %characterisic polynomial of A (A_qs does not have the substrate equations)
        %active layer domain
cp.qs_disc_1La_ns=-4*cp.gamma1*cp.dqb_dFal*(cp.dqbk_dFal(1)-cp.c1*cp.dqb_dFal); 
cp.qs_La_lim_ns(1)=1/((u*cp.psi_Fr/(cp.dqbk_dFal(1)-Fik(1)*cp.dqb_dFal)^2)*((cp.dqbk_dFal(1)-cp.kappa1*cp.dqb_dFal)+sqrt(cp.qs_disc_1La_ns)));
cp.qs_La_lim_ns(2)=1/((u*cp.psi_Fr/(cp.dqbk_dFal(1)-Fik(1)*cp.dqb_dFal)^2)*((cp.dqbk_dFal(1)-cp.kappa1*cp.dqb_dFal)-sqrt(cp.qs_disc_1La_ns)));

        %to check another writting
cp.qsA2=[u*cp.psi/(1-Fr^2),u*cp.chi(1);u*cp.psi/(1-Fr^2)*cp.gamma(1),u*cp.chi(1)*cp.mu(1,1)]; %dimensional matix
cp.qs_disc_2=(cp.lb-cp.ls1)^2+4*cp.gamma(1)/cp.mu(1,1)*cp.lb*cp.ls1; %dimensionless discriminant
cp.qs_disc_22=(cp.ls1*La)^2*(1/La)^2+2*cp.lb*(cp.ls1*La)*(2*cp.gamma(1)/cp.mu(1,1)-1)*(1/La)+cp.lb^2; %dimensionless discriminant for 1/La
cp.qs_La_lim_ns_2(1)=1/(cp.lb/(cp.ls1*La)*(1-2*cp.gamma(1)/cp.mu(1,1)+sqrt((2*cp.gamma(1)/cp.mu(1,1)-1)^2-1))); %dimensional lower limit of the active layer domain 
cp.qs_La_lim_ns_2(2)=1/(cp.lb/(cp.ls1*La)*(1-2*cp.gamma(1)/cp.mu(1,1)-sqrt((2*cp.gamma(1)/cp.mu(1,1)-1)^2-1))); %dimensional lower limit of the active layer domain 

% aux.prec=1e-8; %for checking differences
% if max(abs(cp.qs_disc-cp.qs_disc_2)) > aux.prec; warning('wrong'); end
% if max(abs(cp.qs_disc-cp.qs_disc_22)) > aux.prec; warning('wrong'); end
% if max(max(abs(cp.qsA2-A_qs))) > aux.prec; warning('wrong'); end
% if max(abs(cp.qs_La_lim_ns_2-cp.qs_La_lim_ns)) > aux.prec; warning('wrong'); end

    %simplified dqbk_dMal
cp.qs_disc_sim=1/La^2*(cp.psi_Fr^2*La^2-2/u*cp.psi_Fr*cp.kappaQb*La+1/u^2*cp.FikQb^2); %discriminant    
% cp.qs_disc_sim2=1/(u^2*La^2)*cp.diffQbk^2*Fik(1)^2-2/(u*La)*cp.diffQbk*(Qbk(1)/(u*La)+cp.psi_Fr)*Fik(1)+cp.psi_Fr*(cp.psi_Fr+2/(u*La)*(2*cp.c1*cp.diffQbk-Qbk(1)))+1/(u^2*La^2)*Qbk(1)^2; %discriminant (Fi1) (just to check if it is the same as the one above)
cp.qs_disc_sim_3=(cp.DV-cp.R_s)^2+4*cp.DV*cp.gamma1*1/u*cp.diffQbk/La;
cp.qs_disc_sim_dLa=1/(a_dL*h^b_dL)^2*(cp.psi_Fr^2*(a_dL*h^b_dL)^2-2/u*cp.psi_Fr*cp.kappaQb*(a_dL*h^b_dL)+1/u^2*cp.FikQb^2); %discriminant with La=(a_dL*h^b_dL)
        %active layer domain
cp.qs_disc_La=cp.kappaQb^2-cp.FikQb^2; %discriminant of the active layer domain 
cp.qs_disc_La2=-4*cp.gamma1*cp.diffQbk*cp.c1Qb; %discriminant of the active layer domain (just to check if it is the same as the one above)
cp.qs_La_lim(1)=1/u*1/cp.psi_Fr*(cp.kappaQb-sqrt(cp.qs_disc_La)); %lower limit of the active layer domain 
cp.qs_La_lim(2)=1/u*1/cp.psi_Fr*(cp.kappaQb+sqrt(cp.qs_disc_La)); %upper limit of the active layer domain 
        %Fik domain
cp.qs_disc_Fik=4/(u*La)*cp.psi_Fr*cp.c1Qb; %discriminant of the Fi1 domain
cp.qs_Fik_lim(1)=1/(1/(u*La)*cp.diffQbk)*(Qbk(1)/(u*La)+cp.psi_Fr-sqrt(cp.qs_disc_Fik)); %lower limit of the Fik domain
cp.qs_Fik_lim(2)=1/(1/(u*La)*cp.diffQbk)*(Qbk(1)/(u*La)+cp.psi_Fr+sqrt(cp.qs_disc_Fik)); %upper limit of the Fik domain
        %a_dLa domain
cp.qs_a_La_lim(1)=1/h^b_dL*1/u*1/cp.psi_Fr*(cp.kappaQb-sqrt(cp.qs_disc_La)); %lower limit of the active layer domain 
cp.qs_a_La_lim(2)=1/h^b_dL*1/u*1/cp.psi_Fr*(cp.kappaQb+sqrt(cp.qs_disc_La)); %upper limit of the active layer domain 

cp.qs_ell_disc=0;
if cp.qs_disc<0
    cp.qs_ell_disc=1;
end

%fully coupled (non-dimensional characteristic polynomial)
cp.dl=1/La/u*(Qbk(1)-Qbk(2)+sum(Fak.*cp.dQbk_dFal))*cp.gamma1*cp.psi/Fr^2; %slope of d(lambda)
cp.G_d=[-cp.dl,cp.dl];
cp.G_sve=[cp.psi/Fr^2,1-1/Fr^2*(1+cp.psi),-2,1];
cp.G_ls=(Qbk.*(1-Fik)+Fik*Qbk(end))./(u*La); %simplified approximation of sorting eigenvalues for the coupled case [nf,1], only the first nf-1 are valid
cp.hl=1/La/u*(Fik(2)*Qbk(1)+Fik(1)*Qbk(2)+Fik(2)*Fak(1)*cp.dQbk_dFal(1)-Fik(1)*Fak(2)*cp.dQbk_dFal(2)); %slope of h(lambda) 

cp.dLa_beta=a_dL*b_dL*h^(b_dL-1);
cp.dLa_svep=cp.dLa_beta*Fak(1)*(Qbk(1)-Qbk(2))/u/La/Fr^2;
cp.dLa_r1=[-cp.dl,cp.dl];
cp.dLa_r2r=Fak(1)/Fik(1)*(Qbk(1).*(1-Fik(1))+Fik(1)*Qbk(2))./(u*La); %[1,1]
cp.dLa_r2s=cp.dLa_beta*Fik(1)*(Qbk(1)-Qbk(2))/u/La/Fr^2;
cp.dLa_r2=[-cp.dLa_r2r*cp.dLa_r2s,cp.dLa_r2s];

% (cp.gamma(1)*cp.psi+Fak(1)*cp.dLa_beta*cp.G_ls(1))/(cp.gamma(1)*cp.psi+Fik(1)*cp.dLa_beta)

%check
% cp.dLa_dt_pn=charpoly(A_dLa);
% 
% syms l
% cp.d1=-cnt.g*h*u*cp.gamma(1)*cp.psi+l*cnt.g*h*(cp.gamma(1)*cp.psi+Fik(1)*cp.dLa_beta);
% cp.d2=l*cp.dLa_beta*cnt.g*h;
% cp.d3=cp.d2;
% cp.d4=l^2*(2*u-l)-u*cp.psi*cnt.g*h+l*cp.psi*cnt.g*h+l*u^2*(1/Fr^2-1);
% cp.dLa_dt_pa=dqb_dMal(1)*(l*cp.d1+(dqbk_dLa(1)-Fik(1)*dqb_dLa)*cp.d2)-(dqbk_dMal(1,1)-Fik(1)*dqb_dMal(1)-l)*(dqb_dLa*cp.d3+l*cp.d4);
% 
% cp.dLa_aux0=-Fak(1)/La*(Qbk(1)*(1-Fik(1))+Fik(1)*Qbk(2));
% cp.dLa_aux1=(Qbk(1)-Qbk(2))/La*cnt.g*h*(-u*cp.gamma(1)*cp.psi+l*(cp.gamma(1)*cp.psi+Fik(1)*cp.dLa_beta)+cp.dLa_beta*cp.dLa_aux0); %r dim
% cp.dLa_aux1_n=cp.dLa_aux1./u^4; %r dim
% cp.dLa_aux2=(Qbk(1)*(1-Fik(1))+Fik(1)*Qbk(2))/La;
% cp.dLa_aux3=(cp.dLa_aux2-l)*(-Fak(1)/La*(Qbk(1)-Qbk(2))*cp.dLa_beta*cnt.g*h-poly2sym(fliplr(cp.G_sve),l)); %m
% cp.dLa_aux4=cp.dLa_aux1-cp.dLa_aux3;
% cp.r2=poly2sym(fliplr(cp.dLa_r2),l);
% cp.r1=poly2sym(fliplr(cp.dLa_r1),l);
% cp.m=(l-cp.G_ls(1))*poly2sym(fliplr(cp.G_sve),l);
% 
% double(coeffs(cp.m))
% double(coeffs(cp.dLa_aux3))
% 
% double(coeffs(cp.dLa_aux1))-double(coeffs(cp.r1+cp.r2))
% double(coeffs(cp.dLa_aux1_n))-double(coeffs(cp.r1+cp.r2))
% norm(fliplr(double(coeffs(-cp.dLa_aux4)))-cp.dLa_dt_pn(1:end-1))
% sort(eigen_all_dLa(1:end-1))-sort(real(double(roots(fliplr(coeffs(-cp.dLa_aux4))))))
% 
% norm(fliplr(double(coeffs(-cp.dLa_dt_pa)))-cp.dLa_dt_pn(1:end-1))
% % sort(eigen_all_dLa(1:end-1))-sort(real(double(roots(fliplr(coeffs(-cp.dLa_dt_pa))))))



elseif length(dk)==3 %three fractions 

cp.Fr=Fr;

%computing last fraction
cp.psi=dqb_dq; %double [1,1]
cp.chi=1/u.*dqb_dMal; %double [nf-1,1]
cp.c=dqbk_dq./cp.psi; %double [nf,1]
cp.gamma=cp.c-Fik; %double [nf,1]
cp.d=dqbk_dMal(:,1:nf-1)'./repmat(u*cp.chi',nf-1,1); %double [nf-1,nf-1]
cp.mu=cp.d'-repmat(Fik(1:nf-1),nf-1,1); %double [nf-1,nf-1]
cp.lb=cp.psi/(1-cp.Fr^2); %double [1,1]
cp.ls1=cp.chi(1)*cp.mu(1,1); %double [1,1]
cp.ls2=cp.chi(2)*cp.mu(2,2); %double [1,1]

%not computing last fraction
% cp.psi=dqb_dq; %double [1,1]
% cp.chi=1/u.*dqb_dMal; %double [nf-1,1]
% cp.c=dqbk_dq(1:nf-1)./cp.psi; %double [nf-1,1]
% cp.gamma=cp.c-Fik(1:nf-1); %double [nf-1,1]
% cp.d=dqbk_dMal(:,1:nf-1)'./repmat(u*cp.chi',nf-1,1); %double [nf-1,nf-1]
% cp.mu=cp.d'-repmat(Fik(1:nf-1),nf-1,1); %double [nf-1,nf-1]
% cp.lb=cp.psi/(1-cp.Fr^2); %double [1,1]
% cp.ls1=cp.chi(1)*cp.mu(1,1); %double [1,1]
% cp.ls2=cp.chi(2)*cp.mu(2,2); %double [1,1]

syms lambda
cp.m=(lambda-cp.lb)*(lambda-cp.ls1)*(lambda-cp.ls2);
cp.r1=cp.gamma(1)*cp.lb*cp.ls1/cp.mu(1,1)*(lambda-cp.ls2*(1-cp.mu(1,2)/cp.mu(2,2)));
cp.r2=cp.gamma(2)*cp.lb*cp.ls2/cp.mu(2,2)*(lambda-cp.ls1*(1-cp.mu(2,1)/cp.mu(1,1)));
cp.r3=cp.mu(1,2)*cp.mu(2,1)/cp.mu(1,1)/cp.mu(2,2)*cp.ls1*cp.ls2*(lambda-cp.lb);
cp.r=cp.r1+cp.r2+cp.r3;
cp.p=cp.m-cp.r;

cp.p=sym2poly(cp.p);
cp.m=sym2poly(cp.m);
cp.r=sym2poly(cp.r);
cp.r1=sym2poly(cp.r1);
cp.r2=sym2poly(cp.r2);
cp.r3=sym2poly(cp.r3);
if cp.r1==0; cp.r1=[0,0]; end
if cp.r2==0; cp.r2=[0,0]; end
if cp.r3==0; cp.r3=[0,0]; end
if isempty(cp.r1); cp.r3=[0,0]; end
if isempty(cp.r2); cp.r3=[0,0]; end
if isempty(cp.r3); cp.r3=[0,0]; end

cp.l01=cp.ls2*(1-cp.mu(1,2)/cp.mu(2,2));
cp.l02=cp.ls1*(1-cp.mu(2,1)/cp.mu(1,1));
cp.lr0=cp.lb*cp.ls1*cp.ls2*(cp.gamma(1)/cp.mu(1,1)*(1-cp.mu(1,2)/cp.mu(2,2))+cp.gamma(2)/cp.mu(2,2)*(1-cp.mu(2,1)/cp.mu(1,1))+cp.mu(1,2)*cp.mu(2,1)/cp.mu(1,1)/cp.mu(2,2))/(cp.gamma(1)*cp.lb*cp.ls1/cp.mu(1,1)+cp.gamma(2)*cp.lb*cp.ls2/cp.mu(2,2)+cp.ls1*cp.ls2*cp.mu(2,1)*cp.mu(1,2)/cp.mu(1,1)/cp.mu(2,2));
cp.cpA_qs=charpoly(A_qs./u); %dimensionless

cp.lpm(1)=1/3*(cp.lb+cp.ls1+cp.ls2-sqrt((cp.lb+cp.ls1+cp.ls2)^2-3*(cp.lb*cp.ls1*(1-cp.gamma(1)/cp.mu(1,1))+cp.lb*cp.ls2*(1-cp.gamma(2)/cp.mu(2,2))+cp.ls1*cp.ls2*(1-Fik(1)*Fik(2)/cp.mu(1,1)/cp.mu(2,2)))));
cp.lpm(2)=1/3*(cp.lb+cp.ls1+cp.ls2+sqrt((cp.lb+cp.ls1+cp.ls2)^2-3*(cp.lb*cp.ls1*(1-cp.gamma(1)/cp.mu(1,1))+cp.lb*cp.ls2*(1-cp.gamma(2)/cp.mu(2,2))+cp.ls1*cp.ls2*(1-Fik(1)*Fik(2)/cp.mu(1,1)/cp.mu(2,2)))));

cp.alphapm=cp.lpm-(cp.lpm-cp.lb).*(cp.lpm-cp.ls1).*(cp.lpm-cp.ls2)./(cp.gamma(1)*cp.lb*cp.ls1/cp.mu(1,1)+cp.gamma(2)*cp.lb*cp.ls2/cp.mu(2,2)+cp.ls1*cp.ls2*cp.mu(2,1)*cp.mu(1,2)/cp.mu(1,1)/cp.mu(2,2));

%expanded characteristic polynomial
%p(\lambda)=\lambda^3+a1*\lambda^2+a2*\lambda+a3
cp.a1=-(cp.lb+cp.ls1+cp.ls2); 
cp.a2=cp.lb*cp.ls1*(1-cp.gamma(1)/cp.mu(1,1))+cp.lb*cp.ls2*(1-cp.gamma(2)/cp.mu(2,2))+cp.ls1*cp.ls2*(1-cp.mu(1,2)*cp.mu(2,1)/cp.mu(1,1)/cp.mu(2,2));
% cp.a3=cp.lb*cp.ls1*cp.ls2*(cp.gamma(1)/cp.mu(1,1)*(1-cp.mu(1,2)/cp.mu(2,2))+cp.gamma(2)/cp.mu(2,2)*(1-cp.mu(2,1)/cp.mu(1,1))+cp.mu(1,2)*cp.mu(2,1)/cp.mu(1,1)/cp.mu(2,2)-1); %INCORRECT BUT UNNECESSARY

cp.discW=cp.a1^2-3*cp.a2;
%% for checking solution

% syms a11 a12 a13 a21 a22 a23 a31 a32 a33 x
syms alpha2 alpha1 beta1
% 
% A=[a11,a12,a13;a21,a22,a23;a31,a32,a33];
% M=beta1*[1,0,0;0,alpha1,0;0,0,alpha2];
% 
% A_cp=[ 1, - a11 - a22 - a33, a11*a22 - a12*a21 + a11*a33 - a13*a31 + a22*a33 - a23*a32, a11*a23*a32 - a11*a22*a33 + a12*a21*a33 - a12*a23*a31 - a13*a21*a32 + a13*a22*a31];

% A_det=det(x.*eye(3,3)-A);
% A_c=collect(A_det);

% Am_det=det(x.*M-A);
% Am_cp=collect(Am_det);

a11=A_qs(1,1); a12=A_qs(1,2); a13=A_qs(1,3);
a21=A_qs(2,1); a22=A_qs(2,2); a23=A_qs(2,3);
a31=A_qs(3,1); a32=A_qs(3,2); a33=A_qs(3,3);

a=(alpha1*alpha2*beta1^3);
b=(- a22*alpha2*beta1^2 - a33*alpha1*beta1^2 - a11*alpha1*alpha2*beta1^2);
c=(a22*a33*beta1 - a23*a32*beta1 + a11*a22*alpha2*beta1 - a12*a21*alpha2*beta1 + a11*a33*alpha1*beta1 - a13*a31*alpha1*beta1);
d=a11*a23*a32 - a11*a22*a33 + a12*a21*a33 - a12*a23*a31 - a13*a21*a32 + a13*a22*a31;    
    
cp.disc3=18*a.*b.*c.*d-4.*b.^3.*d+b.^2.*c.^2-4.*a.*c.^3-27.*a.^2.*d.^2;    

pc=[ a11^2*(a11*a22 - a12*a21 + a11*a33 - a13*a31)^2 - 4*a11^3*(a11*a22*a33 - a11*a23*a32 - a12*a21*a33 + a12*a23*a31 + a13*a21*a32 - a13*a22*a31), 18*a11*(a11*a22 - a12*a21 + a11*a33 - a13*a31)*(a11*a22*a33 - a11*a23*a32 - a12*a21*a33 + a12*a23*a31 + a13*a21*a32 - a13*a22*a31) - 4*(a11*a22 - a12*a21 + a11*a33 - a13*a31)^3 + 2*a11*(a22 + a33)*(a11*a22 - a12*a21 + a11*a33 - a13*a31)^2 + 2*a11^2*(a22*a33 - a23*a32)*(a11*a22 - a12*a21 + a11*a33 - a13*a31) - 12*a11^2*(a22 + a33)*(a11*a22*a33 - a11*a23*a32 - a12*a21*a33 + a12*a23*a31 + a13*a21*a32 - a13*a22*a31), a11^2*(a22*a33 - a23*a32)^2 + (a22 + a33)^2*(a11*a22 - a12*a21 + a11*a33 - a13*a31)^2 - 12*(a22*a33 - a23*a32)*(a11*a22 - a12*a21 + a11*a33 - a13*a31)^2 - 27*(a11*a22*a33 - a11*a23*a32 - a12*a21*a33 + a12*a23*a31 + a13*a21*a32 - a13*a22*a31)^2 - 12*a11*(a22 + a33)^2*(a11*a22*a33 - a11*a23*a32 - a12*a21*a33 + a12*a23*a31 + a13*a21*a32 - a13*a22*a31) + 18*a11*(a22*a33 - a23*a32)*(a11*a22*a33 - a11*a23*a32 - a12*a21*a33 + a12*a23*a31 + a13*a21*a32 - a13*a22*a31) + 18*(a22 + a33)*(a11*a22 - a12*a21 + a11*a33 - a13*a31)*(a11*a22*a33 - a11*a23*a32 - a12*a21*a33 + a12*a23*a31 + a13*a21*a32 - a13*a22*a31) + 4*a11*(a22 + a33)*(a22*a33 - a23*a32)*(a11*a22 - a12*a21 + a11*a33 - a13*a31), 2*(a22 + a33)^2*(a22*a33 - a23*a32)*(a11*a22 - a12*a21 + a11*a33 - a13*a31) - 4*(a22 + a33)^3*(a11*a22*a33 - a11*a23*a32 - a12*a21*a33 + a12*a23*a31 + a13*a21*a32 - a13*a22*a31) - 12*(a22*a33 - a23*a32)^2*(a11*a22 - a12*a21 + a11*a33 - a13*a31) + 18*(a22 + a33)*(a22*a33 - a23*a32)*(a11*a22*a33 - a11*a23*a32 - a12*a21*a33 + a12*a23*a31 + a13*a21*a32 - a13*a22*a31) + 2*a11*(a22 + a33)*(a22*a33 - a23*a32)^2, (a22 + a33)^2*(a22*a33 - a23*a32)^2 - 4*(a22*a33 - a23*a32)^3];
%pt=[ alpha1^6, alpha1^5, alpha1^4, alpha1^3, alpha1^2];

pr=roots([pc,0,0]);
cp.disc3_r=imag(pr)==0 & real(pr)~=0 & real(pr)<1;


%alpha1=alpha2; beta1=1
% [pc,pt]=coeffs(simplify(subs(cp.disc3,[alpha2,beta1],[alpha1,1])),alpha1);





%%

% cp.ar3=cp.gamma(1)*cp.chi(1)*cp.lb+cp.gamma(2)*cp.chi(2)*cp.lb+Fik(1)*Fik(2)*cp.chi(1)*cp.chi(2);
% cp.lr0_3=(cp.gamma(1)*cp.chi(1)*cp.lb*Qbk(2)/u/La+cp.gamma(2)*cp.chi(2)*cp.lb*Qbk(1)/u/La+Fik(1)*Fik(2)*cp.chi(1)*cp.chi(2)*cp.lb)/(cp.gamma(1)*cp.chi(1)*cp.lb+cp.gamma(2)*cp.chi(2)*cp.lb+Fik(1)*Fik(2)*cp.chi(1)*cp.chi(2))
%OUT

%definitions
% cp.psi=-1/u*dqb_dh; %double [1,1]
% cp.chi=dqb_dMal; %double [nf-1,1]
% cp.c=-1/u*dqbk_dh(1:nf-1)./cp.psi; %double [nf-1,1]
% cp.gamma=cp.c-Fik(1:nf-1); %double [nf-1,1]
% cp.d=dqbk_dMal(:,1:nf-1)'./repmat(cp.chi',2,1); %double [nf-1,nf-1]
% cp.mu=cp.d'-repmat(Fik(1:nf-1),2,1); %double [nf-1,nf-1]
% cp.ldv=cp.psi/(1-cp.Fr^2); %double [1,1]
% cp.lr1=dqbk_dMal(1,1)-Fik(1)*dqb_dMal(1); %double [1,1]
% cp.lr2=dqbk_dMal(2,2)-Fik(2)*dqb_dMal(2); %double [1,1]

% dQbk_dq=dqbk_dq./Fak;
% sum(Fak.*dQbk_dq./dQbk_dq(1));
% sum(Fak.*dQbk_dq./dQbk_dq(2));
% sum(Fak.*dQbk_dq./dQbk_dq(3));
% sum(cp.c)-sum(Fak(1:nf-1));
% Qbk(1)/(Qbk(1)-Qbk(3));


%characteristic polynomial (1)
% cp.ca=1;
% cp.cb=cp.ldv+cp.lr1+cp.lr2;
% cp.cc=-(cp.ldv*cp.lr1*(cp.gamma(1)/cp.mu(1,1)-1)+cp.ldv*cp.lr2*(cp.gamma(2)/cp.mu(2,2)-1)+cp.lr1*cp.lr2*(cp.mu(1,2)*cp.mu(2,1)/cp.mu(1,1)/cp.mu(2,2)-1));
% cp.cd=-(cp.ldv*cp.lr1*cp.lr2/cp.mu(1,1)/cp.mu(2,2)*(cp.gamma(1)*(cp.mu(1,2)-cp.mu(2,2))+cp.gamma(2)*(cp.mu(2,1)-cp.mu(1,1))+cp.mu(1,1)*cp.mu(2,2)-cp.mu(1,2)*cp.mu(2,1)));
% 
% cp.cp_v=[cp.ca,-cp.cb,cp.cc,cp.cd];
% 
% cp.e1=-cp.ldv*(cp.lr1*cp.gamma(1)/cp.mu(1,1)+cp.lr2*cp.gamma(2)/cp.mu(2,2));
% cp.e2=cp.ldv*cp.lr1+cp.ldv*cp.lr2-cp.lr1*cp.lr2*(cp.mu(1,2)*cp.mu(2,1)/cp.mu(1,1)/cp.mu(2,2)-1);
% 
% %tangent (1)
% cp.lambda_p=(cp.cb+sqrt(cp.cb^2-3*cp.cc))/3; %lambda +
% cp.lambda_m=(cp.cb-sqrt(cp.cb^2-3*cp.cc))/3; %lambda -
% cp.alpha_p=cp.lambda_p+(cp.lambda_p^3-cp.cb*cp.lambda_p^2)/cp.cc; %alpha +
% cp.alpha_m=cp.lambda_m+(cp.lambda_m^3-cp.cb*cp.lambda_m^2)/cp.cc; %alpha -

% fprintf('%1.5e',-cp.cd/cp.cc)
% fprintf('%1.5e',cp.alpha_p)
% fprintf('%1.5e \n',cp.cb^2)
% fprintf('%1.5e \n',4*cp.cc)

%characteristic polynomial (2)
% syms lambda
% cp.m=(lambda-cp.ldv)*(lambda-cp.lr1)*(lambda-cp.lr2);
% cp.r1=cp.gamma(1)*cp.ldv*cp.lr1/cp.mu(1,1)*(lambda-cp.lr2*(1-cp.mu(1,2)/cp.mu(2,2)));
% cp.r2=cp.gamma(2)*cp.ldv*cp.lr2/cp.mu(2,2)*(lambda-cp.lr1*(1-cp.mu(2,1)/cp.mu(1,1)));
% cp.r3=cp.mu(1,2)*cp.mu(2,1)/cp.mu(1,1)/cp.mu(2,2)*cp.lr1*cp.lr2*(lambda-cp.ldv);
% cp.r=cp.r1+cp.r2+cp.r3;
% cp.p=cp.m-cp.r;
% 
% cp.p=sym2poly(cp.p);
% cp.m=sym2poly(cp.m);
% cp.r=sym2poly(cp.r);
% cp.r1=sym2poly(cp.r1);
% cp.r2=sym2poly(cp.r2);
% cp.r3=sym2poly(cp.r3);
% cp.l01=cp.lr2*(1-cp.mu(1,2)/cp.mu(2,2));
% cp.l02=cp.lr1*(1-cp.mu(2,1)/cp.mu(1,1));

% cp.lr0_2=cp.ls1*cp.lb*(cp.gamma(1)*Qbk(2)/u/La+cp.gamma(2)*cp.chi(2)*cp.d(1,1)+cp.chi(2)*Fik(1)*Fik(2))/(cp.lb*cp.ls1*cp.gamma(1)+cp.lb*cp.gamma(2)*cp.chi(2)*cp.mu(1,1)+cp.ls1*cp.chi(2)*Fik(1)*Fik(2));

% (cp.lb*cp.ls1*cp.gamma(1)+cp.lb*cp.gamma(2)*cp.chi(2)*cp.mu(1,1)+cp.ls1*cp.chi(2)*Fik(1)*Fik(2))-cp.lb*(cp.gamma(1)*Qbk(2)/u/La+cp.gamma(2)*cp.chi(2)*cp.d(1,1)+cp.chi(2)*Fik(1)*Fik(2))

% (cp.gamma(1)*cp.mu(2,2)*cp.ls1/cp.ls2+cp.gamma(2)*cp.mu(1,1)+cp.ls1/cp.lb*Fik(1)*Fik(2))-(cp.gamma(1)*cp.d(2,2)+cp.gamma(2)*cp.d(1,1)+Fik(1)*Fik(2))
% cp.gamma(1)*(cp.ls1/cp.ls2*cp.mu(2,2)-cp.d(2,2))+Fik(1)*(Fik(2)*cp.ls1/cp.lb-cp.c(2))
% cp.gamma(1)*(cp.ls1/cp.ls2*cp.mu(2,2)-cp.d(2,2))+Fik(1)*(Fik(2)*cp.ls1/cp.ls2-cp.c(2))
% 
% cp.c(1)+cp.c(2)
% Fik(1)+Fik(2)

% (Qbk(1)*cp.gamma(1)*(1-Fik(1))-Qbk(2)*cp.gamma(1)*(1-cp.gamma(2)/cp.gamma(1)*Fik(1))+Qbk(3)*Fik(1)*(cp.gamma(1)+cp.gamma(2)))/(Qbk(2)-Qbk(3))+Fik(1)*Fik(2)*(cp.ls1/cp.lb-1);
% cp.gamma(1)*(cp.ls1/cp.ls2*(Fik(2)-cp.d(2,2))+cp.d(2,2))-Fik(1)*(-cp.c(2)+cp.ls1/cp.lb*Fik(2))
% cp.gamma(1)*(cp.ls1/cp.ls2*cp.mu(2,2)-cp.d(2,2))+cp.gamma(2)*(-Fik(1))+Fik(1)*Fik(2)*(cp.ls1/cp.lb-1)
% cp.ls1*(cp.gamma(1)*cp.d(2,2)+cp.gamma(2)*cp.d(1,1)+Fik(1)*Fik(2))/(cp.gamma(1)*cp.mu(2,2)*cp.ls1/cp.ls2+cp.gamma(2)*cp.mu(1,1)+cp.ls1/cp.lb*Fik(1)*Fik(2))
% cp.lb*Qbk(2)/u/La*cp.gamma(1)*cp.chi(1)+cp.lb*Qbk(1)/u/La*cp.gamma(2)*cp.chi(2)-(cp.lb*cp.gamma(1)*cp.chi(1)+cp.lb*cp.gamma(2)*cp.chi(2))
% cp.gamma(1)*cp.d(2,2)+cp.gamma(2)*cp.d(1,1)-(cp.gamma(1)*cp.mu(2,2)*cp.ls1/cp.ls2+cp.gamma(2)*cp.mu(1,1))
% Qbk(1)*cp.gamma(1)*(1-Fik(1))-Qbk(2)*cp.gamma(1)*(1-cp.gamma(2)/cp.gamma(1)*Fik(1))


% cp.lb*cp.ls2*(cp.gamma(1)/cp.mu(1,1)*(1-cp.mu(1,2)/cp.mu(2,2))+cp.gamma(2)/cp.mu(2,2)*(1-cp.mu(2,1)/cp.mu(1,1))+cp.mu(1,2)*cp.mu(2,1)/cp.mu(1,1)/cp.mu(2,2))/(cp.gamma(1)*cp.lb*cp.ls1/cp.mu(1,1)+cp.gamma(2)*cp.lb*cp.ls2/cp.mu(2,2)+cp.ls1*cp.ls2*cp.mu(2,1)*cp.mu(1,2)/cp.mu(1,1)/cp.mu(2,2))
 
% cp.ls1-cp.ls2
% cp.gamma(1)*cp.lb/cp.mu(1,1)*(cp.ls2-cp.ls1)-cp.lb*cp.ls2/cp.mu(1,1)/cp.mu(2,2)*(cp.gamma(1)*cp.mu(1,2)+cp.gamma(2)*cp.mu(2,1))+cp.ls2*cp.mu(1,2)*cp.mu(2,1)/cp.mu(1,1)/cp.mu(2,2)*(cp.lb-cp.ls1)
% cp.c(1)*Fik(2)+cp.c(2)*Fik(1)-Fik(1)*Fik(2)
% -cp.gamma(1)*cp.mu(1,2)-cp.gamma(2)*cp.mu(2,1)+cp.mu(2,1)*cp.mu(1,2)
% cp.chi(1)*cp.d(1,1)-cp.chi(2)*cp.d(2,2)-(cp.chi(1)*Fik(1)-cp.chi(2)*Fik(2))
% cp.chi(1)*cp.d(1,1)-cp.chi(2)*cp.d(2,2)-(cp.chi(1)*Fik(1)+cp.chi(2)*cp.gamma(2)/cp.gamma(1)*Fik(1))


%CHECK
% cp.cpA_qs=charpoly(A_qs);
% aux.prec=1e-8;
% cp.A=u*[cp.lb,cp.ls1/cp.mu(1,1),cp.ls2/cp.mu(2,2);cp.lb*cp.gamma(1),cp.ls1,cp.ls2*cp.mu(2,1)/cp.mu(2,2);cp.lb*cp.gamma(2),cp.ls1*cp.mu(1,2)/cp.mu(1,1),cp.ls2]; %double [nf,nf]     
% if abs(cp.lr0-cp.lr0_2) > aux.prec; warning('wrong'); end
% if max(abs(cp.ls2-cp.chi(2)*(cp.d(2,2)-Fik(2)))) > aux.prec; warning('wrong'); end
% if max(abs(cp.ls1-cp.chi(1)*(cp.d(1,1)-Fik(1)))) > aux.prec; warning('wrong'); end
% if max(abs(cp.d(1,2)-1/cp.chi(1)*dqbk_dMal(2,1))) > aux.prec; warning('wrong'); end
% if max(abs(cp.mu(2,1)-(cp.d(2,1)-Fik(1)))) > aux.prec; warning('wrong'); end
% if max(max(abs(A_qs-cp.A))) > aux.prec; warning('wrong'); end    
% % if max(abs(cp.cp_v-cp.cpA_qs)) > aux.prec; warning('wrong'); end    
% % if max(abs(cp.cc-(cp.e1+cp.e2))) > aux.prec; warning('wrong'); end    
% if max(abs(cp.cpA_qs-cp.p)) > aux.prec; warning('wrong'); end    


else %length(dk)~=(2,3)
    error('Sorry! the characteristic polynomial it is only for 2 or 3 fractions!')
end

else %flg.cp~=1
    %to not do all cp if only psi is necessary...
if (any(flg.anl==1) || any(flg.anl==2) || any(flg.anl==3) || any(flg.anl==4) || any(flg.anl==5))
%         cp.psi=dqb_dq; %double [1,1]
        
%         cp.Fr=Fr;
        cp.psi=dqb_dq; %double [1,1]
%         cp.chi=1/u.*dqb_dMal; %double [nf-1,1]
%         cp.c=dqbk_dq./cp.psi; %double [nf,1]
%         cp.gamma=cp.c-Fik; %double [nf,1]
%         cp.d=dqbk_dMal(:,1:nf-1)'./repmat(u*cp.chi',nf-1,1); %double [nf-1,nf-1]
%         cp.mu=cp.d'-repmat(Fik(1:nf-1),nf-1,1); %double [nf-1,nf-1]
%         cp.lb=cp.psi/(1-cp.Fr^2); %double [1,1]
%         cp.ls1=cp.chi(1)*cp.mu(1,1); %double [1,1]

else
        cp.psi=[dqbx_dqx,dqby_dqy]; %double [1,1]
end

end 

end %function ECT_~

function [elliptic]=ellipticity_2D(param_twoD,Ax,Ay)

%% RENAME

np=param_twoD.nr;

%% LOOP

% n_v=combvec(linspace(-1,1,np),linspace(-1,1,np))';
% nn_v=n_v./sqrt(n_v(:,1).^2+n_v(:,2).^2); %>2016b
% nn_v2=unique(nn_v,'rows');
% nonan_idx=~isnan(nn_v2(:,1));
% nn_v2=nn_v2(nonan_idx,:);

rho=1;
theta=linspace(0,360,np)*2*pi/360;
[nn_vx,nn_vy]=pol2cart(theta,rho);
nn_v2=[nn_vx',nn_vy'];

np=size(nn_v2,1);

elliptic=0;
kp=1;
while kp<np && elliptic==0
    A=Ax*nn_v2(kp,1)+Ay*nn_v2(kp,2);
    eigen_A=eig(A);
    if isreal(eigen_A)==0
        elliptic=1;
    else
        kp=kp+1;
    end
end    
   
end
