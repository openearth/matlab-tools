
%%

ECT_input.flg.read=1;
ECT_input.flg.check_input=0;
ECT_input.flg.sed_trans=1;
ECT_input.flg.vp=1;
ECT_input.flg.E=1;
ECT_input.flg.friction_closure=1;
ECT_input.flg.friction_input=1;
ECT_input.flg.hiding=0;
ECT_input.flg.Dm=1;
ECT_input.flg.mu=0;
ECT_input.flg.derivatives=1;
ECT_input.flg.particle_activity=0;
ECT_input.flg.cp=0;
ECT_input.flg.extra=0;
ECT_input.flg.pmm=0;
ECT_input.flg.anl=[8];
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

ECT_input.gsd=[0.001,0.004];
ECT_input.u=1;
ECT_input.v=0;
ECT_input.h=1;
ECT_input.Cf=0.007;
ECT_input.La=0.05;
ECT_input.Fa1=[1];
ECT_input.Fi1=[1];

% nu_mom=1/6*0.41*h*sqrt(Cf)*sqrt(u^2+v^2);
ECT_input.nu_mom=0;
ECT_input.Dh=ECT_input.nu_mom; %secondary flow diffusivity [m^2/s]
ECT_input.diff_hir=NaN(size(ECT_input.gsd)); %diffusion hirano

% sedTrans=[5.7,1.5,0.047]; %FLvB
% sedTrans=[8,1.5,0.03];
% sedTrans=[8,1.5,0];
% sedTrans=[17,0.05];
ECT_input.sedTrans=[0.05/ECT_input.Cf,2.5,0];

ECT_input.E_param=[0.0199,1.5]; %FLvB
ECT_input.vp_param=[11.5,0.7]; %FLvB

ECT_input.flg.calib_s=1; %consider bed slope effects 0=NO 1=YES
% gsk_param=[1.7,0.5,0,0]; %Talmon95
ECT_input.gsk_param=[1,0,0,0]; %Sekine
% gsk_param=[3.33,0.5,0,0]; %Olesen
% gsk_param=[9,0.5,0.3,0]; %Talmon95

ECT_input.hiding=-0.8;
ECT_input.u_b=NaN;
ECT_input.kappa=NaN(size(ECT_input.gsd)); %diffusivity of Gammak
