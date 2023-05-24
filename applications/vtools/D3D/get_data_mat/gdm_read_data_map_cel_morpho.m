%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18780 $
%$Date: 2023-03-09 15:28:47 +0100 (do, 09 mrt 2023) $
%$Author: chavarri $
%$Id: gdm_read_data_map_stot.m 18780 2023-03-09 14:28:47Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_read_data_map_stot.m $
%
%

function data_var=gdm_read_data_map_cel_morpho(fdir_mat,fpath_map,varname,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tim',[]);
addOptional(parin,'var_idx',[]);
% addOptional(parin,'tol',1.5e-7);
% addOptional(parin,'idx_branch',[]);
% addOptional(parin,'branch','');
% addOptional(parin,'layer',[]);

parse(parin,varargin{:});

time_dnum=parin.Results.tim;
var_idx=parin.Results.var_idx;
% tol=parin.Results.tol;
% layer=parin.Results.layer;
% idx_branch=parin.Results.idx_branch;
% branch=parin.Results.branch;

%% READ

data_u=gdm_read_data_map(fdir_mat,fpath_map,'ucmag','tim',time_dnum);
data_h=gdm_read_data_map(fdir_mat,fpath_map,'wd','tim',time_dnum);
data_La=gdm_read_data_map(fdir_mat,fpath_map,'thlyr','tim',time_dnum,'layer',1);
data_C=gdm_read_data_map(fdir_mat,fpath_map,'czs','tim',time_dnum);
data_Fak=gdm_read_data_map(fdir_mat,fpath_map,'Fak','tim',time_dnum,'layer',1);

%% take morpho from input files or offline

ECT_input.flg.read=1;
ECT_input.flg.check_input=0;
ECT_input.flg.sed_trans=1;
    % 1 = Meyer-Peter, Muller (1948)    
    % 2 = Engelund-Hansen (1967)
    % 3 = Ashida-Michiue (1972)
    % 4 = Wilcock-Crowe (2003)
ECT_input.flg.vp=0;
ECT_input.flg.E=0;
ECT_input.flg.friction_closure=1;
    % 1 = Chezy | Darcy-Weisbach
    % 2 = Manning 
ECT_input.flg.friction_input=1;
ECT_input.flg.hiding=0;
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
ECT_input.flg.anl=2;
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

% ECT_input.sedTrans=[5.7,1.5,0.047]; %FLvB
% ECT_input.sedTrans=[8,1.5,0.03];
% ECT_input.sedTrans=[8,1.5,0];
% ECT_input.sedTrans=[17,0.05];
ECT_input.sedTrans=[0.05/ECT_input.Cf,2.5,0];
    % MPM48    = [a_mpm,b_mpm,theta_c] [-,-,-] ; double [3,1] | double [1,3]; MPM = [8,1.5,0.047], FLvB = [5.7,1.5,0.047] ; Ribberink = [15.85,1.5,0.0307]
    % EH67     = [m_eh,n_eh] ; [s^4/m^3,-] ; double [2,1] | double [1,2] ; original = [0.05,5]
    % AM72     = [a_am,theta_c] [-,-] ; double [2,1] | double [1,2] ; original = [17,0.05]
    % GL       = [r,w,tau_ref]
    % Ribb     = [m_r,n_r,l_r] [s^5/m^(2.5),-,-] ; double [2,1] ; original = [2.7e-8,6,1.5]
			
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



gsd=sediment_transport.dk;
sedTrans=sediment_transport.param;
hiding=sediment_transport.hiding;


%% LOOP

nx=numel(data_u.val);

for kx=1:nx
    %adjust input

    u=data_u.val(kx);
    h=data_h.val(kx);
    Cf=convert_friction('C2Cf',data_C.val(kx));
    La=data_La.val(kx);
    Fa1=data_Fak.val(1,1:end-1,1,kx);
    Fi1=Fa1; %assuming aggradation

    %call
    [ECT_matrices,sed_trans]=call_ECT(ECT_input);
    
    cel=ECT_matrices.eigen_x;

end %kx

%%


data_var.val=val;

end %function