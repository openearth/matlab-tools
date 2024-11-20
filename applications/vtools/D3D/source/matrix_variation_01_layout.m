% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Create variation matrix. 
%
%When input for variation is a string (e.g., filename), this is input in 
%`variation_str` an integer array with the variation is created in `variation_c`
%`variation_str` is left empty when the variation is on a double. 

function [fn,allvari,variation_str]=matrix_variation_01(path_input_folder_refmdf)

%Same name as in <simdef> (with '__' where there is substructure). 
%Same order as in <allvari>.
% fn={'ini__etab_noise','ini__noise_Lb','nx'}; 
fn={'mdf__FixedWeirFile','mdf__ExtForceFileNew','ini__etab_noise','ini__noise_Lb','nx'}; 

%% initialize

allvari=[];

%% 

variation_str{1}={'',[path_input_folder_refmdf,'fxw/','Waal_fxw.pliz']};
variation_c{1}=1:numel(variation_str{1}); 

variation_str{2}={[path_input_folder_refmdf,'extn/','FlowFM_bnd_01.ext'],[path_input_folder_refmdf,'extn/','FlowFM_bnd_02.ext']};
variation_c{2}=1:numel(variation_str{2}); 

variation_c{3}=[0,2]; 
variation_str{3}='';

variation_c{4}=400; 
variation_str{4}='';

variation_c{5}=10; 
variation_str{5}='';

allvari=D3D_apply_variation(allvari,variation_c);

%% 

variation_str{1}={''};
variation_c{1}=1:numel(variation_str{1}); 

variation_str{2}={''};
variation_c{2}=1:numel(variation_str{2}); 

variation_c{3}=[2]; 
variation_str{3}='';

variation_c{4}=[400,500]; 
variation_str{4}='';

variation_c{5}=10; 
variation_str{5}='';

allvari=D3D_apply_variation(allvari,variation_c);

%%

%We want to vary a string but force it to be constant for some variation of another parameter:

variation_c{1}=[0,1,2,3,4,5,6,7];  %we vary this integer
variation_str{1}='';

variation_str{2}={'generic1d2d3d','implicit1d'}; %all possibilities of the string
variation_c{2}=1; %we only use this one

allvari=D3D_apply_variation(allvari,variation_c); %we apply the variation

variation_c{1}=[0]; %now this integer is constant
variation_str{1}='';

variation_str{2}={'generic1d2d3d','implicit1d'};
variation_c{2}=2; %and we use the other string

allvari=D3D_apply_variation(allvari,variation_c);

end %function