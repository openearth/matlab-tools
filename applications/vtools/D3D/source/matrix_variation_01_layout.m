
function [fn,allvari,variation_str]=matrix_variation_01(path_input_folder_refmdf)

%same name as in <simdef> (with '__' where there is substructure). 
%Same order as in <allvari_add>.
fn={'mdf__FixedWeirFile','mdf__ExtForceFileNew'}; 

%% initialize

allvari=[];

%%

variation_str{1}={'',[path_input_folder_refmdf,'fxw/','Waal_fxw.pliz']};
variation_str{2}={[path_input_folder_refmdf,'extn/','FlowFM_bnd_01.ext'],[path_input_folder_refmdf,'extn/','FlowFM_bnd_02.ext']};

%% 

variation_c{1}=1:numel(variation_str{1}); 
variation_c{2}=1:numel(variation_str{2}); 

allvari=D3D_apply_variation(allvari,variation_c);

end %function