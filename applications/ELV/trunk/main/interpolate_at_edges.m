%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 16814 $
%$Date: 2020-11-19 05:33:47 +0100 (Thu, 19 Nov 2020) $
%$Author: chavarri $
%$Id: bed_level_update.m 16814 2020-11-19 04:33:47Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/main/bed_level_update.m $
%
%bed_level_update updates the bed elevation
%
%etab_new=bed_level_update(etab,qbk,bc,input,fid_log,kt)
%
%INPUT:
%   -input = variable containing the input [struct] e.g. input
%
%OUTPUT:
%   -
%
%HISTORY:
%210315
%   -V. Created for the first time.
%

function [u_edg,h_edg,Cf_b_edg,La_edg,Mak_edg,qbk_edg,celerities_edg,pmm_edg]=interpolate_at_edges(input,u,h,Cf_b,La,Mak,celerities,pmm,fid_log)

%%
%% RENAME
%%

%escape
if input.mdv.interp_edges==0
    return
end
%in the future check if interpolating with griddedInterpolant is too expensive and use the flag for a different interpolation

xedg=input.mdv.xedg;
xcen=input.mdv.xcen;
nef=input.mdv.nef;

%% INTERPOLATE

% scatteredInterpolant ?
% manual ?
val_mat=[u',h',Cf_b',La',Mak',celerities.lb',celerities.ls',pmm'];

val_mat_edg=interp1(xcen,val_mat,xedg,'linear','extrap');

u_edg=val_mat_edg(:,1)';
h_edg=val_mat_edg(:,2)';
Cf_b_edg=val_mat_edg(:,3)';
La_edg=val_mat_edg(:,4)';

Mak_edg=val_mat_edg(:,5:5+nef-1)';
Fak_edg=Mak_edg./La_edg;
Fak_edg(Fak_edg>1)=1;
Fak_edg(Fak_edg<0)=0;
Mak_edg=Fak_edg.*La_edg;

celerities_edg.lb=val_mat_edg(:,5+nef)';
celerities_edg.ls=val_mat_edg(:,5+nef+1:5+2*nef)';
celerities_edg.gamma=[];
celerities_edg.mu=[];
celerities_edg.A=[];
celerities_edg.eigen=[];
celerities_edg.eigen_pmm=[];

pmm_edg=val_mat_edg(:,5+2*nef+1:end)';

% u_edg=interp1(xcen,u,xedg,'linear','extrap');
% h_edg=interp1(xcen,h,xedg,'linear','extrap');
% Cf_b_edg=interp1(xcen,Cf_b,xedg,'linear','extrap');
% La_edg=interp1(xcen,La,xedg,'linear','extrap');
% Mak_edg=interp1(xcen,Mak,xedg,'linear','extrap');

%% SEDIMENT TRANSPORT

qbk_edg=sediment_transport(input.aux.flg,input.aux.cnt,h_edg,(u_edg.*h_edg)',Cf_b_edg,La_edg',Mak_edg',input.sed.dk,input.tra.param,input.aux.flg.hiding_parameter,1,input.tra.E_param,input.tra.vp_param,NaN(size(u)),fid_log,NaN);
qbk_edg=qbk_edg';

end %function