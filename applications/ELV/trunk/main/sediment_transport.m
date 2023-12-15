%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%sediment transport calculation 
%
%[qbk,Qbk]=sediment_transport(flg,cnt,h,q,cf,La,Mak,dk,sed_trans_param,hiding_param,mor_fac,fid_log,kt)
%
%% INPUT
%Symbols used in the size definition:
    %-nx is the number of points in streamwise directions
    %-nf is the number of size fractions
    
    % flg = flags ; structure
        % flg.sed_trans = sediment transport relation
            % 1 = Meyer-Peter, Muller (1948)    
            % 2 = Engelund-Hansen (1967)
            % 3 = Ashida-Michiue (1972)
            % 4 = Wilcock-Crowe (2003)
            %
            % 6 = Parker (1990)
            % 7 = Ribberink (1987)
            % 8 = Van Rijn (1984) riv 1977
        % flg.friction_closure = friction closure relation
            % 1 = Chezy | Darcy-Weisbach
            % 2 = Manning 
        % flg.hiding = hiding-exposure effects
            % 0 = no hiding-exposure 
            % 1 = Egiazaroff (1965)
            % 2 = Power law
            % 3 = Ashida-Michiue (1972)
        % flg.Dm = mean grain size
            % 1 = geometric
            % 2 = arithmetic 
        % flg.mu = ripple factor in Meyer-Peter, Muller (1948)
            % 0 = no
            % 1 = constant
            % 2 = C/C90 relation
        % flg.sbform = bed load due to currents in Van Rijn (1984) riv 1977
            % 1 = always same formulation
            % 2 = other formulation if t (transport stage parameter) < 3
        % flg.wsform = settling velocity in Van Rijn (1984) riv 1977
            % 1 = Van Rijn
            % 2 = Ahrens (2000)
            % 3 = Ahrens (2003)
        % flg.theta_c = critical Shields stress
            % 1 = hard coded or user input (default)
            % 2 = compute from dstar
    % cnt = constans ; structure
        % cnt.g         = gravity [m^2/s] ; double [1,1]
        % cnt.rho_s     = sediment density [kg/m^3] ; double [1,1]
        % cnt.rho_w     = water density [kg/m^3] ; double [1,1]
        % cnt.p         = porosity [-] ; double [1,1]
        % cnt.R         = relative density (rho_s - rho_w)/rho_w
        % cnt.nu        = kinematic viscosity (mu/rho_w) with mu = dynamic viscosity. - in fortran code this parameter is called vismol.
    % h               = flow depth [m] ; double [nx,1] | double [1,nx] ; e.g. [0.5,0.1,0.6];
    % q               = specific water discharge [m^2/s] ; double [nx,1] | double [1,nx] ; e.g. [5;2;2];
    % cf              = dimensionless friction coefficient (u_{*}^{2}=cf*u^2) [-] ; double [nx,1] | double [1,nx] ; e.g. [0.011,0.011,0.011];
    % La              = active layer thickness [m] ; double [nx,1] | double [1,nx] ; e.g. [0.01,0.015,0.017];
    % Mak             = effective mass matrix ; double [nx,nf-1] ; e.g. [0.2,0.3;0.8,0.1;0.9,0] ;
    % dk              = characteristic grain sizes [m] ; double [1,nf] | double [nf,1] ; e.g. [0.003,0.005]
    % sed_trans_param = parameters of the sediment transport relation choosen 
            % MPM48     = [a_mpm,b_mpm,theta_c] [-,-,-] ; double [3,1] | double [1,3]; MPM = [8,1.5,0.047], FLvB = [5.7,1.5,0.047] ; Ribberink = [15.85,1.5,0.0307]
            % EH67      = [m_eh,n_eh] ; [s^4/m^3,-] ; double [2,1] | double [1,2] ; original = [0.05,5]
            % AM72      = [a_am,theta_c] [-,-] ; double [2,1] | double [1,2] ; original = [17,0.05]
            % GL        = [r,w,tau_ref]
            % Ribb      = [m_r,n_r,l_r] [s^5/m^(2.5),-,-] ; double [2,1] ; original = [2.7e-8,6,1.5]
            % VR84riv77 = [acal_b, acal_s, rksc, theta_c (optional)] ; double[4,1] ; original = CHECK
    % hiding_param    = parameter of the power law hiding function [-] ; double [1,1] ; e.g. [-0.8]
    % mor_fac         = morphological acceleration factor [-] ; double [1,1] ; e.g. [10]
    % E_param        = parameters of the entrainment function
        % 1) MPM-type = [a_E,theta_c] [-,-] ; double [2,1] ; original (FLvB) = [0.0199,6,0.047]
        % 3) AM-type  = [a_E]         [-]   ; double [1,1] ; original (to have the same depositional rate as in FLvB) = [0.0591]
        
%% OUTPUT
    % qbk = sediment transport per grain size and node including pores and morphodynamic acceleration factor [m^2/s] ; double [nx,nf]
    % Qbk = sediment transport capacity per grain size and node including pores and morphodynamic acceleration factor [m^2/s] ; double [nx,nf]
   
%% NOTES
    %-The morphodynamic accelerator factor is included in the sediment
    % transport relations. If you want to compute is outside, set it equal
    % to 1. 
    %-The porosity is included in the sediment transport relations. If you
    % want to copute it without pores, set it equal to 0.
    %-In the Hirano model, 'mass' (Mak) refers to the product of the volume
    % fractions per the active layer thickness (Mak=La*Fak). It is done in
    % this way to be able to easily calculate the derivatives respect to
    % the mass, which is what matters. 
    %-The terms 'effective' refers to nf-1 fractions. It is done in this
    % minimize mass issues and to be able to compute the derivatives respect
    % to mass. 
    %-It is thought as a 1D computation of a multi-fraction mixture in the
    % Hirano model. You can compute unisize transport by setting La equal to
    % 1 and Mak equal to an empty matrix.
    %-All input needs to be specified. The parse needs to be before the
    % function calling. This is done in this way because parameters (e.g.
    % gravity) are used outside the sediment transport. This means that
    % before calling this function there needs to be a parse and a check to,
    % for example, the sediment transport parameteres. 
    
%%
%HISTORY:
%151104
%   -V. bug in reshape La solved
%
%160418
%   -V. change of check for unisize 
%
%160517
%   -V. bug in EH for multisize
%
%160702
%   -V. tiny improvements in performance
%
%160825
%   -V. Generalized load relation
%
%170621
%   -V. Adapted to new Matlab arithmetics (after R2016b)
%
%230523
%   -V. Different size sediment transport relation for each fraction. 

%% FUNCTION 

function [qbk,Qbk,thetak,qbk_st,Wk_st,u_st,xik,Qbk_st,Ek,Ek_st,Ek_g,Dk,Dk_st,Dk_g,vpk,vpk_st,Gammak_eq,Dm]=sediment_transport(flg,cnt,h,q,cf,La,Mak,dk,sed_trans_param_in,hiding_param,mor_fac,E_param,vp_param,Gammak,fid_log,kt)

%% PARSE

%reshape h, q, dk, cf, La and at the same time check that they are vectors
nx=length(h); %number of points in streamwise direction
nf=length(dk); %number of size fractions
if nf==1
    nef=1;
else
    nef=nf-1;
end

input_i.mdv.nx=nx;
input_i.mdv.nf=nf;
input_i.sed.dk=dk;
input_i.tra.Dm=flg.Dm;

% if nx~=length(q) || nx~=size(Mak,1) || nx~= length(cf); error('h and q need to have the same length and needs to be equal to the number of rows in Mak, check your input'); end %check line, comment for improved performance

h=reshape(h,nx,1);
q=reshape(q,nx,1);
cf=reshape(cf,nx,1);
dk=reshape(dk,1,nf);
La=reshape(La,nx,1);
Mak=reshape(Mak,nx,nef); 

Fak=Mak2Fak(Mak',La',input_i);
Fak=Fak';

if numel(flg.sed_trans)==1
    nu=1;
    flg.sed_trans=ones(1,nf).*flg.sed_trans; %we still make a vector for filling `Qbk_st` with boolean
elseif numel(flg.sed_trans)~=nf
    error('The number of sediment transport relations flg.sed_trans (%d) must match the number of size fractions (%d)',numel(flg.sed_trans),nf)
else %correct we reshape just in case
    flg.sed_trans=reshape(flg.sed_trans,1,nf);
    nu=nf;
end

if ~iscell(sed_trans_param_in) %only one sediment transport relation
    sed_trans_param_cell{1,1}=sed_trans_param_in;
else %different transport relation for each fraction
    sed_trans_param_cell=sed_trans_param_in;
    if numel(sed_trans_param_cell)~=nf
        error('The number of sediment transport parameters (%d) must match the number of size fractions (%d)',numel(sed_trans_param_cell),nf)
    end
end

if ~isfield(flg,'theta_c')
    flg.theta_c = ones(nu,1);
end
if any(flg.theta_c<1 | flg.theta_c>2)
    error('Provide consistent input for critical bed shear stress flag.')
end

if ~isfield(flg,'sbform')
    flg.sbform = zeros(nu,1);
end

if ~isfield(flg,'wsform')
    flg.wsform = zeros(nu,1);
end

%% D90 ; double [1,nx]

d90=grainsize_dX(Fak',dk',90);

%% bed shear stress (tau_b) [N/m^2] ; double [nx,1]

switch flg.friction_closure
    case 1 %Darcy-Weisbach
        tau_b=cnt.rho_w*cf.*(q./h).^2;
    case 2 %Manning
        n=sqrt(cf.*h.^(1/3)/cnt.g); %reconversion
        tau_b=cnt.rho_w*cnt.g*n.^2.*(q./h).^2./h.^(1/3); 
    otherwise
        error('check friction input')
end

%% dimensionless particle parameter D* ; double[1,nf]

dstar = dk*(cnt.R*cnt.g/cnt.nu^2)^(1/3);

%% Shields stress (thetak) [-] ; double [nx,nf]

thetak=1/(cnt.rho_w*cnt.g*cnt.R)*tau_b./dk;  

%% mean grain size (Dm) [m] ; double [nx,1]

Dm=mean_grain_size(Fak',input_i)'; %this function deals with the dimensions appropriately, it is sediment_transport which should be adapted.

%% hiding function (xik) [-] ; double [nx,nf]

switch flg.hiding
    case 0 %no hiding-exposure
        xik=ones(nx,nf); 
    case 1 %Egiazaroff
        xik=(log10(19)./log10(19*dk./Dm)).^2;
    case 2 %power-law
        xik=(dk./Dm).^hiding_param;
    case 3 %Ashida-Michiue
        xik_br1_idx=dk./Dm<0.38889; %indeces of xik in branch 1 ; boolean [nx,nf]
        xik_br1=0.8429*Dm./dk; %all as 1st branch (br 1)
        xik=(log10(19)./log10(19*dk./Dm)).^2; %all as 2nd branch (Egiazaroff) (br 0)
        xik(xik_br1_idx)=xik_br1(xik_br1_idx); %compose
    otherwise
        error('check hiding')
end

%% ripple factor
switch flg.mu
    case 0 %unspecified
        mu=ones(nx,nf);
    case 1 %specified constant
        mu=flg.mu_param.*ones(nx,nf); %this is crap, I need to parse the input to properly do this
    case 2 %C/C90 expression
        Cg90=18*log10(12.*h./d90');
        C=sqrt(cnt.g./cf);
        mu_v=min((C./Cg90).^(1.5),1);
        mu=repmat(mu_v,1,nf);        
    otherwise
        error('not implemented')        
end

%% dimensionless sediment transport capacity (Qbk_st) [-] ; ; double [nx,nf]

%We cannot use `unique` on `flg.sed_trans` because the sediment transport 
%parameters may be different. 
% sed_trans_u=unique(flg.sed_trans);
% nu=numel(sed_trans_u);

Qbk_st_all=NaN(nx,nf);

for ku=1:nu
    sed_trans_loc=flg.sed_trans(ku);
    sed_trans_param=sed_trans_param_cell{ku};
    
    %calculate critical Shields stress (theta_c) [-] ; double [1,nf]

    switch flg.theta_c(ku)
        case 1 %user input or hard coded
            switch sed_trans_loc
                case 1 %MPM48
                    theta_c=sed_trans_param(3);
                case 2 %AM
                    theta_c=sed_trans_param(2);
                case 6 %Parker
                    theta_c = 0.0386;
                case 8 %VR84riv77
                    theta_c=sed_trans_param(4);
                otherwise
                    theta_c = 0;
            end
        case 2 %compute from dstar
            theta_c = 0.055.*ones(1,length(dstar));
            
            bol_thetac_br1 = dstar<=4;
            theta_c_br1 = 0.240./dstar;
            bol_thetac_br2 = dstar>4 & dstar<=10;
            theta_c_br2 = 0.140./dstar.^0.64; 
            bol_thetac_br3 = dstar>10 & dstar<=20;
            theta_c_br3 = 0.040./dstar.^0.10;
            bol_thetac_br4 = dstar>20 & dstar<=150;
            theta_c_br4 = 0.013.*dstar.^0.29;
            
            theta_c(bol_thetac_br1) = theta_c_br1(bol_thetac_br1);
            theta_c(bol_thetac_br2) = theta_c_br2(bol_thetac_br2);
            theta_c(bol_thetac_br3) = theta_c_br3(bol_thetac_br3);
            theta_c(bol_thetac_br4) = theta_c_br4(bol_thetac_br4);
            
%             if dstar<=4 %!!!ATTENTION `dstar` is vector! --> THIS PART CAN BE REMOVED
%                 theta_c = 0.240./dstar;
%             elseif dstar<=10
%                 theta_c = 0.140./dstar.^0.64;
%             elseif dstar<=20
%                 theta_c = 0.040./dstar.^0.10;
%             elseif dstar<=150
%                 theta_c = 0.013.*dstar.^0.29;
%             else
%                 theta_c = 0.055;
%             end     
    end 
    
    %calculate sediment transport
    switch sed_trans_loc
        case 1 %MPM48
            a_mpm=sed_trans_param(1);
            b_mpm=sed_trans_param(2);
%             theta_c=sed_trans_param(3);
            no_trans_idx=(mu.*thetak-xik.*theta_c)<0; %indexes of fractions below threshold ; boolean [nx,nf]
            Qbk_st=a_mpm.*(mu.*thetak-xik.*theta_c).^b_mpm; %MPM relation
            Qbk_st(no_trans_idx)=0; %the transport capacity of those fractions below threshold is 0
        case 2 %EH67
            m_eh=sed_trans_param(1);
            n_eh=sed_trans_param(2);
%             theta_c=0;
            u=q./h; %depth averaged flow velocity [m/s]
            Qbk_st=cf.^(3/2).*(cnt.g*cnt.R*dk).^(-5/2).*m_eh.*(u.^n_eh); %EH relation
            no_trans_idx=false(nx,nf);
        case 3 %AM72
            a_am=sed_trans_param(1);
%             theta_c=sed_trans_param(2);
            no_trans_idx=(thetak-xik.*theta_c)<0; %indexes of fractions below threshold
            Qbk_st=a_am.*(thetak-xik.*theta_c).*(sqrt(thetak)-sqrt(xik.*theta_c));
            Qbk_st(no_trans_idx)=0; %the transport capacity of those fractions below threshold is 0
        case 4 %WC03 
            alpha=sed_trans_param(1);
%             theta_c=0;
            dk_sand_idx=dk<0.002; %size fractions indeces considered as sand ; boolean [1,nf]
            Fs=sum(dk_sand_idx.*Fak,2); %sand fraction (Fs) [-] ; double [nx,1]
            tau_st_rm=0.021+0.015*exp(-20*Fs); %reference Shields stress for the mixture (tau_st_rm) [-] ; double [nx,1]
            tau_rm=(cnt.R*cnt.rho_w*cnt.g).*tau_st_rm.*Dm; %reference bed shear stress for the mixture (tau_rm) [N/m^2] ; double [nx,1]
            dk_Dm=dk./Dm; %dk/Dm [-] ; double [nx,nf]
            b=0.67./(1+exp(1.5-dk_Dm)); %hiding power [-] ; double [nx,nf]
            tau_rk=tau_rm.*(dk_Dm).^b; %reference shear stress for each grain size [N/m^2] ; double [nx,nf]
            phi_k=tau_b./tau_rk; %parameter phi in WC [-] ; double [nx,nf]
            phi_k_br1_idx=phi_k<1.35; %indeces of phi_i in branch 1 ; boolean [nx,nf]
            Wk_st_br1=0.002*phi_k.^(7.5); %dimensionsless transport W as if all values were in branch 1 [-] ; double [nx,nf] 
            Wk_st=14.*(1-0.894./(phi_k.^(1/2))).^(4.5); %dimensionsless transport W as if all values were in branch 2 [-] ; double [nx,nf] 
            Wk_st(phi_k_br1_idx)=Wk_st_br1(phi_k_br1_idx); %compose
    %         Qbk=Wk_st.*(cf.^(3/2).*(q./h).^3)./cnt.R./cnt.g./(1-cnt.p); %transform Wk into Qbk   
    %         Qbk_st=Wk_st.*thetak.^(3/2);
            Qbk_st=alpha.*Wk_st.*thetak.^(3/2);
            no_trans_idx=false(nx,nf);
        case 5 %Generalized load relation
%             theta_c=0;
            r = sed_trans_param(1);
            w = sed_trans_param(2);
            tau_ref = sed_trans_param(3);
            D_ref = 0.001;
            G = cf.^(w+3/2)/(tau_ref^w*(cnt.R*cnt.g)^(w+1));
            Qbk_st = (1-cnt.p)./sqrt(cnt.g*cnt.R*dk.^3).*(dk/D_ref).^r.*G.*1./dk.^w.*(q./h).^(2*w+3); %!!! Attention. Porosity included in the formulation.
            no_trans_idx=false(nx,nf);
        case 6 %Parker
            a_park=0.00218;
%             theta_c=0.0386;
            chi=thetak./theta_c;
            G=exp(14.2*(chi-1)-9.28*(chi-1).^2); %all in branch 2
            G_1=5474*(1-0.853./chi).^(4.5); %branch 1
            G_3=chi.^(14.2); %branch 3
            G_1_idx=chi>=1.59; %branch 1 identifier
            G_3_idx=chi< 1.00; %branch 3 identifier
            G(G_1_idx)=G_1(G_1_idx);
            G(G_3_idx)=G_3(G_3_idx);
            Qbk_st=a_park.*thetak.^(3/2).*G;
            no_trans_idx=false(nx,nf);
        case 7 %Ribberink      
            m_r=sed_trans_param(1);
            n_r=sed_trans_param(2);
            l_r=sed_trans_param(3);
%             theta_c=0;
            u=q./h; %depth averaged flow velocity [m/s]
            %the calibrated formula of Ribberink is already including pores. Here we substract them to later add the in Exner
            Qbk_st=1./sqrt(cnt.g*cnt.R*dk.^3).*(1-0.40)*m_r.*(u.^n_r)./(Dm.^l_r); %Ribberink
            no_trans_idx=false(nx,nf);
        case 8 %Van Rijn 84 riv 77  
            acal_b = sed_trans_param(1); %calibration coefficient for bed load
            acal_s = sed_trans_param(2); %calibration coefficient for suspended load
            alf1 = 1; %calibration factor. CHECK - DISCUSS SETTING
            rksc = sed_trans_param(3); %bottom roughness height
            
            % bed load transport
            tbcr = (cnt.rho_s - cnt.rho_w)*cnt.g*dk.*theta_c; %[1,nf] %V: ATT! inconsistent input. rho_s has been added as input, but R was already input, which is a function of rho_s! Remove!
            
            rmuc = (log10(12.0.*h/rksc)./log10(12.0.*h/3./d90')).^2; %[nx,1]
            fc = 0.24*(log10(12.0.*h/rksc)).^(-2); %[nx,1]
            tbc = 0.125*cnt.rho_w*fc.*(q./h).^2; %[nx,1]
            tbce = rmuc.*tbc; %[nx,1]
            
            tsp = (tbce - tbcr)./tbcr; %transport stage parameter [nx,nf]
            no_tsp_idx = tsp<1.0000e-06; %boolean [nx,nf]
            tsp(no_tsp_idx) = 1.0000e-06; %!!!ATTENTION in original is set go 1e-6: if (t<0.000001_hp) t = 0.000001_hp. --> I HAVE CHANGED IT ACCORDINGLY. CHECK

            % bed load due to currents
            sbc = 0.100*acal_b*cnt.R^0.5*sqrt(cnt.g)*dk.^1.5.*dstar.^(-0.3).*tsp.^1.5;
            if flg.sbform(ku)
                sbc_br2=0.053*acal_b*cnt.R^0.5*sqrt(cnt.g)*dk.^1.5.*dstar.^(-0.3).*tsp.^2.1;
                bol_br2=tsp<3;
                sbc(bol_br2)=sbc_br2(bol_br2);
            end

            %Better not to repeat code. Someone in the future may change it at one location but not the other.
%             switch flg.sbform(ku) % bed load due to currents
%                 case 1 %always same formulation
%                     sbc = 0.100*acal_b*cnt.R^0.5*sqrt(cnt.g)*dk.^1.5.*dstar.^(-0.3).*tsp.^1.5;
%                 case 2 %other formulation if tsp (transport stage parameter) < 3
%                     if tsp < 3 %!!!ATTENTION it is a matrix!
%                         sbc = 0.053*acal_b*cnt.R^0.5*sqrt(cnt.g)*dk.^1.5.*dstar.^(-0.3).*tsp.^2.1;
%                     else
%                         sbc = 0.100*acal_b*cnt.R^0.5*sqrt(cnt.g)*dk.^1.5.*dstar.^(-0.3).*tsp.^1.5;
%                     end
%                 otherwise
%                     error('specify sbform')
%             end

            % suspended sediment transport: use settling_velocity.m with ws_flag = 2
            ws_flag = 2; %!!! why hardcode it? I would leave it up to the user and set the default to 2 if not specified. %ws_flag = 1 is not part of the original VR implementation. CHECK
            wsform = flg.wsform(ku);
            ws = settling_velocity(dk,ws_flag,wsform,dstar);
            ca = 0.015*alf1*dk/rksc.*tsp.^1.5./dstar.^0.3;
            rkap = 0.4;
            ustar = sqrt(0.125*fc).*(q./h); 
            
            beta = 1.0 + 2.0*(ws./ustar).^2; %[nx,nf]
            beta = min(beta, 1.5,'includenan'); %[nx,nf]
            psi = 2.5*(ws./ustar).^0.8.*(ca/0.65).^0.4; %[nx,nf]
            
            zc = ws./rkap./ustar./beta + psi; %[nx,nf]
            zc = min(zc,20.0,'includenan'); %[nx,nf]
                
            no_zc_idx = ustar<=0; %[nx,1]
            zc(no_zc_idx,:) = 0; %[nx,nf]
            
            ah = rksc./h;
            bol_br1=abs(zc - 1.2)>1.0E-4;
            ff_br1=(ah.^zc - ah.^1.2)./(1.0 - ah).^zc./(1.2 - zc); 
            ff=-(ah./(1.0 - ah)).^1.2.*log(ah);
            ff=repmat(ff,1,size(ff_br1,2));
            ff(bol_br1)=ff_br1(bol_br1);
            ssus = acal_s.*ff.*q.*ca; 
            
            % sum
            Qbk_st = 1./sqrt(cnt.g*cnt.R*dk.^3).*(sbc + ssus); %dimensionless sediment transport with pores. ??? CHECK IF POROSITY SHOULD BE INCLUDED HERE OR NOT
            no_trans_idx = (h/rksc<1.33 | q./h < 1.0E-3 | h<1e-12); %indexes of fractions below threshold ; boolean [nx,1]
            Qbk_st(no_trans_idx,:) = 0; %the transport capacity of those fractions below threshold is 0
        otherwise 
            error('sediment transport formulation')
    end %sed_trans_loc

%assign to each fraction
bol_st=flg.sed_trans==sed_trans_loc;
Qbk_st_all(:,bol_st)=Qbk_st(:,bol_st);

end %ku

Qbk_st=Qbk_st_all; %keep original name

%% entrainment

switch flg.E
    case 0 %do not compute
        Ek_st=NaN;
    case 1 %FLvB 
        a_E=E_param(1);
        b_E=E_param(2);
        
        no_E_idx=thetak-xik.*theta_c<0; %indexes of fractions below threshold ; boolean [nx,nf]
        Ek_st=a_E.*(thetak-xik.*theta_c).^b_E;
        Ek_st(no_E_idx)=0; %the transport capacity of those fractions below threshold is 0
    case 3 %AM-type
        a_E=E_param(1);
        
        no_E_idx=thetak-xik.*theta_c<0; %indexes of fractions below threshold ; boolean [nx,nf]
        Ek_st=a_E.*(thetak-xik.*theta_c).*(sqrt(thetak)-sqrt(xik.*theta_c));
        Ek_st(no_E_idx)=0; %the transport capacity of those fractions below threshold is 0
    otherwise
        
end

%% velocity

switch flg.vp
    case 0 %do not compute
        vpk_st=NaN;
    case 1
        a_vpk=vp_param(1);
        b_vpk=vp_param(2);
        
        no_vpk_idx=sqrt(thetak)-b_vpk.*sqrt(xik.*theta_c)<0; %indexes of fractions below threshold ; boolean [nx,nf]
        vpk_st=a_vpk.*(sqrt(thetak)-b_vpk.*sqrt(xik.*theta_c));
        vpk_st(no_vpk_idx)=0; %the transport capacity of those fractions below threshold is 0
    otherwise
        
end

%% dependencies of entrainment deposition

if flg.E~=0

    %deposition
    Dk_st_all=NaN(nx,nf);
    for ku=1:nu
        sed_trans_loc=flg.sed_trans(ku);
        sed_trans_param=sed_trans_param_cell{ku};
        switch sed_trans_loc
            case 1
                a_mpm=sed_trans_param(1);
                Dk_st=a_E/a_mpm*vpk_st;
            case 3
                a_am=sed_trans_param(1);
                Dk_st=a_E/a_am*vpk_st;
            otherwise
                %ATT! this does not work! It creates a discontinuity in Dk because it is 0 when Qbk_st is 0 but it should not because the term (thetak-theta_c) in Qbk_st cancels with the one in Ek_st
                Dk_st=Ek_st.*vpk_st./Qbk_st; 
                Dk_st(no_trans_idx)=0;
        %         Dk_st(no_vpk_idx)=0;
        end

        %assign to each fraction
        bol_st=flg.sed_trans==sed_trans_loc;
        Dk_st_all(:,bol_st)=Dk_st(:,bol_st);

    end
    Dk_st=Dk_st_all; %keep original name

    %equilibrium particle activity
    Gammak_eq_st=Fak.*Qbk_st./vpk_st;
    Gammak_eq=Gammak_eq_st.*dk; %without pores
    % Gammak_eq=Gammak_eq_st./(1-cnt.p); %with pores
    
    %dimensionalize
    Ek_g=Ek_st.*sqrt(cnt.g*cnt.R*dk)./La;
    Ek=(Fak.*La).*Ek_g; %do not use Mak due to dimensions

    Dk_g=Dk_st.*sqrt(cnt.g*cnt.R*dk)./dk;
    Dk=Gammak.*Dk_g; 

    vpk=vpk_st.*sqrt(cnt.g*cnt.R*dk);

else
    Dk_st=NaN;
    Gammak_eq=NaN;
    Ek_g=NaN;
    Ek=NaN;
    Dk_g=NaN;
    Dk=NaN;
    vpk=NaN;
end

%% sediment transport including pores and morphodynamic acceleration factor (qbk) [m^2/s] ; double [nx,nf]

Qbk=Qbk_st.*sqrt(cnt.g*cnt.R*dk.^3)./(1-cnt.p); %sediment transport capacity including pores (Qbk) [m^2/s] ; double [nx,nf]

if flg.particle_activity==0
    qbk=mor_fac.*Fak.*Qbk; 
else
    dGammak=diff(Gammak,1);
    dGammak_dx=[dGammak;dGammak(end,:)]/cnt.dx;
    qbk=vpk.*Gammak-cnt.kappa'.*dGammak_dx;
end

%% other dependencies

if flg.extra
    qbk_st=qbk./sqrt(cnt.g*cnt.R*dk.^3).*(1-cnt.p)./Fak;
    Wk_st=qbk_st./thetak.^(3/2);
    u_st=sqrt(tau_b/cnt.rho_w);
else
    qbk_st=NaN;
    Wk_st=NaN;
    u_st=NaN;
end

end %sediment_transport
    
