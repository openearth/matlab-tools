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
addOptional(parin,'sediment_transport',[]);

parse(parin,varargin{:});

time_dnum=parin.Results.tim;
var_idx=parin.Results.var_idx;
% tol=parin.Results.tol;
% layer=parin.Results.layer;
% idx_branch=parin.Results.idx_branch;
% branch=parin.Results.branch;
sediment_transport=parin.Results.sediment_transport;

%% CHECK

if isempty(sediment_transport)
    messageOut(NaN,'Cannot compute celerities without information on sediment transport relation')
    return
else
    messageOut(NaN,'Start loading data for `cel_morpho`')
end

%% READ

data_u=gdm_read_data_map(fdir_mat,fpath_map,'ucmag','tim',time_dnum);
data_h=gdm_read_data_map(fdir_mat,fpath_map,'wd','tim',time_dnum);
data_La=gdm_read_data_map(fdir_mat,fpath_map,'thlyr','tim',time_dnum,'layer',1);
data_C=gdm_read_data_map(fdir_mat,fpath_map,'czs','tim',time_dnum);
data_Fak=gdm_read_data_map(fdir_mat,fpath_map,'Fak','tim',time_dnum,'layer',1);

%% take morpho from input files or offline

ECT_input.flg.sed_trans=sediment_transport.sedtrans;
    % 1 = Meyer-Peter, Muller (1948)    
    % 2 = Engelund-Hansen (1967)
    % 3 = Ashida-Michiue (1972)
    % 4 = Wilcock-Crowe (2003)
ECT_input.flg.hiding=sediment_transport.sedtrans_hiding;
    % 0 = no hiding-exposure 
    % 1 = Egiazaroff (1965)
    % 2 = Power law
    % 3 = Ashida-Michiue (1972)
ECT_input.flg.Dm=1;
    % 1 = geometric
    % 2 = arithmetic 
ECT_input.flg.mu=sediment_transport.sedtrans_mu;
    % 0 = no
    % 1 = constant
    % 2 = C/C90 relation
ECT_input.flg.mu_param=sediment_transport.sedtrans_mu_param;

if isfield(sediment_transport,'sedtrans_sbform')
    ECT_input.flg.sbform=sediment_transport.sedtrans_sbform;
end

if isfield(sediment_transport,'sedtrans_wsform')
    ECT_input.flg.wsform=sediment_transport.sedtrans_wsform;
end

if isfield(sediment_transport,'sedtrans_theta_c')
    ECT_input.flg.theta_c=sediment_transport.sedtrans_theta_c;
end

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
ECT_input.sedTrans=sediment_transport.sedtrans_param;
    % MPM48    = [a_mpm,b_mpm,theta_c] [-,-,-] ; double [3,1] | double [1,3]; MPM = [8,1.5,0.047], FLvB = [5.7,1.5,0.047] ; Ribberink = [15.85,1.5,0.0307]
    % EH67     = [m_eh,n_eh] ; [s^4/m^3,-] ; double [2,1] | double [1,2] ; original = [0.05,5]
    % AM72     = [a_am,theta_c] [-,-] ; double [2,1] | double [1,2] ; original = [17,0.05]
    % GL       = [r,w,tau_ref]
    % Ribb     = [m_r,n_r,l_r] [s^5/m^(2.5),-,-] ; double [2,1] ; original = [2.7e-8,6,1.5]
    % VR84riv77 = [acal_b, acal_s, rksc, theta_c (optional)] ; double[4,1] ;
ECT_input.gsd=sediment_transport.dk;

ECT_input.hiding=sediment_transport.sedtrans_hiding_param;

%other
ECT_input.v=0;
ECT_input.flg.vp=0;
ECT_input.flg.E=0;
ECT_input.flg.compute_eigenvalues=1;

%% LOOP

nx=numel(data_u.val);
nf=numel(ECT_input.gsd);

val=NaN(nx,nf);

for kx=1:nx
    %adjust input

    u=data_u.val(kx);
    h=data_h.val(kx);
    Cf=convert_friction('C2Cf',data_C.val(kx));
    La=data_La.val(kx);
    Fa1=data_Fak.val(1,1:end-1,1,kx);
    Fi1=Fa1; %assuming aggradation
    
    %rename
    ECT_input.u=u;
    ECT_input.h=h;
    ECT_input.Cf=Cf;
    ECT_input.La=La;
    ECT_input.Fa1=Fa1;
    ECT_input.Fi1=Fi1;
    
    %call
    if isinf(Cf) || u<1e-4 || h<1e-4 || La<1e-6
        val(kx,:)=zeros(1,nf);
    else
        [ECT_matrices,sed_trans]=call_ECT(ECT_input);
        val(kx,:)=sort(ECT_matrices.eigen_x);
    end

end %kx

%% OUT

data_var.val=val;

end %function