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
%Convert the input from a D3D simulation (simdef) into the input for computing
%eigenvalues (ECT_input).

function ECT_input=D3D_input_2_ECT_input(simdef)

%%

ECT_input.flg.read=1;
ECT_input.flg.check_input=0;
ECT_input.flg.sed_trans=D3D_input_tra_2_sediment_transport(simdef.tra.IFORM);
    % 1 = Meyer-Peter, Muller (1948)    
    % 2 = Engelund-Hansen (1967)
    % 3 = Ashida-Michiue (1972)
    % 4 = Wilcock-Crowe (2003)
ECT_input.flg.vp=1;
ECT_input.flg.E=1;
ECT_input.flg.friction_closure=1;
    % 1 = Chezy | Darcy-Weisbach
    % 2 = Manning 
ECT_input.flg.friction_input=1;
ECT_input.flg.hiding=D3D_input_hiding_2_sediment_transport(simdef.mor.IHidExp);
    % 0 = no hiding-exposure 
    % 1 = Egiazaroff (1965)
    % 2 = Power law
    % 3 = Ashida-Michiue (1972)
ECT_input.flg.Dm=1;
    % 1 = geometric
    % 2 = arithmetic 
ECT_input.flg.mu=0;
    % 0 = no
    % 1 = constant
    % 2 = C/C90 relation
ECT_input.flg.derivatives=1;
ECT_input.flg.particle_activity=0;
ECT_input.flg.cp=0;
ECT_input.flg.extra=0;
ECT_input.flg.pmm=0;
if numel(simdef.sed.dk)==1
    ECT_input.flg.anl=[10];
elseif ~isnan(simdef.mor.HiranoDiffusion) && simdef.mor.HiranoDiffusion~=0
    ECT_input.flg.anl=[14];
else
    ECT_input.flg.anl=[6];
end
    % 1 = fully coupled
    % 2 = quasi-steady
    % 3 = variable active layer thickness
    % 4 = Ribberink
    % 5 = advection-decay
    % 6 = 2D Shallow Water Hirano no secondary flow
    % 7 = 2D Shallow Water Hirano with secondary flow
    % 8 = 2D Shallow Water fixed bed no secondary flow
    % 9 = 2D Shallow Water fixed bed with secondary flow
    %10 = 2D Shallow Water Exner no secondary flow
    %11 = 2D Shallow Water Exner with secondary flow
    %12 = Entrainement-deposition


ECT_input.u=simdef.ini.u;
ECT_input.v=0;
ECT_input.h=simdef.ini.h;
if numel(simdef.sed.dk)==1
    ECT_input.gsd=[simdef.sed.dk,10];
else
    ECT_input.gsd=simdef.sed.dk;
end
ECT_input.Cf=simdef.mdf.g/simdef.mdf.C^2;
ECT_input.La=simdef.mor.ThTrLyr;
ECT_input.Fa1=simdef.ini.actlay_frac;
ECT_input.Fi1=simdef.ini.subs_frac;

% nu_mom=1/6*0.41*h*sqrt(Cf)*sqrt(u^2+v^2);
ECT_input.nu_mom=0;
ECT_input.Dh=ECT_input.nu_mom; %secondary flow diffusivity [m^2/s]
ECT_input.diff_hir=simdef.mor.HiranoDiffusion.*ones(size(ECT_input.gsd)); %diffusion hirano

if numel(simdef.sed.dk)==1
    %case in which we have a single fraction and after D3D_rework it turns into a cell array.
    if iscell(simdef.tra.sedTrans) && numel(simdef.tra.sedTrans)==1
        ECT_input.sedTrans=simdef.tra.sedTrans{1,1};
    else
        ECT_input.sedTrans=simdef.tra.sedTrans;
    end
else
    ECT_input.sedTrans=simdef.tra.sedTrans;
end

% ECT_input.sedTrans=[8,1.5,0.03];
% ECT_input.sedTrans=[8,1.5,0];
% ECT_input.sedTrans=[17,0.05];
% ECT_input.sedTrans=[0.05/ECT_input.Cf,2.5,0];
    % MPM48    = [a_mpm,b_mpm,theta_c] [-,-,-] ; double [3,1] | double [1,3]; MPM = [8,1.5,0.047], FLvB = [5.7,1.5,0.047] ; Ribberink = [15.85,1.5,0.0307]
    % EH67     = [m_eh,n_eh] ; [s^4/m^3,-] ; double [2,1] | double [1,2] ; original = [0.05,5]
    % AM72     = [a_am,theta_c] [-,-] ; double [2,1] | double [1,2] ; original = [17,0.05]
    % GL       = [r,w,tau_ref]
    % Ribb     = [m_r,n_r,l_r] [s^5/m^(2.5),-,-] ; double [2,1] ; original = [2.7e-8,6,1.5]
			
ECT_input.E_param=[0.0199,1.5]; %FLvB
ECT_input.vp_param=[11.5,0.7]; %FLvB

ECT_input.flg.calib_s=1; %consider bed slope effects 0=NO 1=YES
% gsk_param=[1.7,0.5,0,0]; %Talmon95
% ECT_input.gsk_param=[1/0.3,0.5,0,0]; 
ECT_input.gsk_param=[simdef.mor.AShld,simdef.mor.BShld,0,0]; 
% gsk_param=[3.33,0.5,0,0]; %Olesen
% gsk_param=[9,0.5,0.3,0]; %Talmon95

ECT_input.hiding=-simdef.mor.ASKLHE;
ECT_input.u_b=NaN;
ECT_input.kappa=NaN(size(ECT_input.gsd)); %diffusivity of Gammak

ECT_input.dx=simdef.grd.dx; %space step [m]

ECT_input.mor_fac=simdef.mor.MorFac;

end %function