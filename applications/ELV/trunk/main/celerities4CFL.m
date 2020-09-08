%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 16573 $
%$Date: 2020-09-08 16:03:40 +0200 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: celerities4CFL.m 16573 2020-09-08 14:03:40Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/main/celerities4CFL.m $
%
%celerities computes the maximum celerity as a function of the type of simulation
%
%c=celerities4CFL(u,h,celerities,pmm,vpk,input,fid_log,kt)
%
%INPUT:
%   -
%
%OUTPUT:
%   -c = vector
%
%HISTORY:
%181102
%   -V. Created for the first time.


function c=celerities4CFL(u,h,celerities,pmm,vpk,input,fid_log,kt)
         
%%
%% RENAME
%%

nef=input.mdv.nef;
g=input.mdv.g;
porosity=input.mor.porosity;

alpha=pmm(1,:);
beta=pmm(2,:);
sqrt_gh=sqrt(g*h);

%%
%% COMPUTE CELERITY
%%

switch input.mdv.flowtype
    case 1 %steady flow
        if input.mor.particle_activity==0
            if isempty(celerities.eigen_pmm)==0
                %maximum of the celerities with and without correcting for pmm
                %ATT! the outcome from 'celerities' is dimensionless and does not account for porosity
                c_pmm=u/(1-porosity).*celerities.eigen_pmm; %this will not work prior to R2016b, use repmat in u.
                c=max(c_pmm,[],1); 
            elseif isempty(celerities.eigen)==0
                c_npmm=u/(1-porosity).*celerities.eigen; %this will not work prior to R2016b, use repmat in u.
                c=max(c_npmm,[],1);
            else
                %Attention! We are using the APPROXIMATED eigenvalues of the bed and sorting. To use the exact values it is necessary to have as output the variable 'eigen' in elliptic_nodes
                clb=u.*celerities.lb./(1-porosity)./beta; %dimensional bed celerity
                cls=repmat(u,nef,1).*celerities.ls./(1-porosity)./alpha./beta; %dimensional sorting celerity
                c=max([clb;cls]); %maximum celerity
            end
        else %particle activity
%             c=vpk(1,:)/(1-porosity); %the small particles travel faster
            c=vpk(1,:); %the small particles travel faster. Porosity does not play a role in PA update. 
        end
    case 2 %quasi-steady
        c=3/2*u;
    case {3,4} %unsteady
        c=u+sqrt_gh;
    case 6
        c = NaN;            
end


end %function

