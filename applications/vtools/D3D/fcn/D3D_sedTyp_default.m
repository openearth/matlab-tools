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

