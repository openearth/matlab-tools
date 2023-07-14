%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18696 $
%$Date: 2023-02-01 21:38:46 +0100 (wo, 01 feb 2023) $
%$Author: chavarri $
%$Id: D3D_rework.m 18696 2023-02-01 20:38:46Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_rework.m $
%
%generate other input parameters 

function simdef=D3D_sedTyp_default(simdef)

nf=numel(simdef.sed.dk);

if ~isfield(simdef.tra,'SedTyp')
    simdef.tra.SedTyp=NaN(1,nf);
end

%make it vector
if numel(simdef.tra.SedTyp)==1
    simdef.tra.SedTyp=simdef.tra.SedTyp.*ones(1,nf);
end 

for kf=1:nf
    switch simdef.tra.IFORM(kf)
        case -4 %SANTOSS
            default_param=3; 
        case 1 %Engelund-Hansen
            default_param=3; 
        case -3 %Partheniades-Krone
            default_param=1; 
        case 4 %Generalized Formula
            default_param=3; 
        case 14 %Ashida-Michiue
            default_param=3; 
        otherwise
            error('add')
    end
    simdef.tra.SedTyp(kf)=set2default(simdef.tra.SedTyp(kf),default_param);
end %kf

end %function

%%
%% FUNCTIONS
%%

function simdef_tra_SedTyp=set2default(simdef_tra_SedTyp,default_param)

if isnan(simdef_tra_SedTyp)
    simdef_tra_SedTyp=default_param;
end %isnan

end %function

