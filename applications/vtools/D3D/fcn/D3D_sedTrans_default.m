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

function simdef=D3D_sedTrans_default(simdef)

nf=numel(simdef.sed.dk);

%make it cell array
if ~iscell(simdef.tra.sedTrans)
    simdef.tra.IFORM=simdef.tra.IFORM.*ones(nf,1);
    aux=cell(nf,1);
    for kf=1:nf
        aux{kf}=simdef.tra.sedTrans;
    end %kf
    simdef.tra.sedTrans=aux;
end 

for kf=1:nf
    switch simdef.tra.IFORM(kf)
        case -4 %SANTOSS
            default_param=NaN; %everything default in software
            simdef.tra.sedTrans{kf}=[];
        case 1 %Engelund-Hansen
            default_param=[1,0.01,0]; %ACal, RouKs, SusFac
        case -3 %Partheniades-Krone
            default_param=[1e-4,1000,0.5]; %EroPar, TcrSed, TcrEro
        case 4 %Generalized Formula
            default_param=[8,1.5,0.047]; %ACal, PowerC, ThetaC, 
        case 14 %Ashida-Michiue
            default_param=[17,0.05]; %ACal, ThetaC, 
        otherwise
            error('add')
    end
    simdef.tra.sedTrans{kf}=check_dimensions(simdef.tra.sedTrans{kf},default_param);
end %kf

end %function

%%
%% FUNCTIONS
%%

function simdef_tra_sedTrans=check_dimensions(simdef_tra_sedTrans,default_param)

nd=numel(default_param);
%set all to default
if isempty(simdef_tra_sedTrans)
    simdef_tra_sedTrans=NaN(1,nd);
end

if numel(simdef_tra_sedTrans)~=nd
    error('Number of input sediment transport parameters is different than expected.')
end

for kd=1:nd
    if isnan(simdef_tra_sedTrans(kd))
        simdef_tra_sedTrans(kd)=default_param(kd);
    end %isnan
end %kd

end %function

