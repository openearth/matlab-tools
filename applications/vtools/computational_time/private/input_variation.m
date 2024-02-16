
function [fn,allvari,variation_str]=input_variation(path_input_folder_refmdf)

%same name as in <simdef> (with '__' where there is substructure). 
%Same order as in <allvari_add>.
fn={'D3D__nodes','D3D__tasks_per_node','D3D__partition'}; 

%% initialize

allvari=[];

%%

% variation_str{1}={'',[path_input_folder_refmdf,'fxw/','Waal_fxw.pliz']};
% variation_str{2}={[path_input_folder_refmdf,'extn/','FlowFM_bnd_01.ext'],[path_input_folder_refmdf,'extn/','FlowFM_bnd_02.ext']};
variation_str{3}={'1vcpu','4vcpu','16vcpu','24vcpu','48vcpu'};

%% reference

allvari=[1,1,1];

%% SINGLE NODE

for knodes=1:3

    variation_c{1}=knodes;

%% scaling 4vcpu

% variation_c{1}=knodes;
variation_c{2}=[1,2,4];
variation_c{3}=2;

allvari=D3D_apply_variation(allvari,variation_c);

%% scaling 16vcpu

% variation_c{1}=1;
variation_c{2}=[1,2,4,8,16];
variation_c{3}=3;

allvari=D3D_apply_variation(allvari,variation_c);

%% scaling 24vcpu

% variation_c{1}=1;
variation_c{2}=[1,2,4,8,16,24];
variation_c{3}=4;

allvari=D3D_apply_variation(allvari,variation_c);

%% scaling 48vcpu

% variation_c{1}=1;
variation_c{2}=[1,2,4,8,16,24,48];
variation_c{3}=5;

allvari=D3D_apply_variation(allvari,variation_c);

end

end %function