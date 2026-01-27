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
% SEDIMENT_TRANSPORT_2D - Calculates 2D sediment transport with secondary flow and slope effects
%
% This function computes two-dimensional sediment transport by first calculating
% the magnitude-based transport using sediment_transport, then adjusting for
% secondary flow and transverse slope effects, and finally correcting for
% longitudinal slope effects.
%
% Syntax: [qbkx,qbky,Qbkx,Qbky,thetak,qbkx_trans,qbky_trans,Qbkx_trans,Qbky_trans] = 
%         sediment_transport_2D(flg,cnt,h,q,cf,La,Mak,dk,sed_trans_param,hiding_param,
%                               mor_fac,I,E_s,sx,sy,E_param,vp_param,Gammak,gsk_param)
%
% Inputs:
%   flg              - Flags structure
%   cnt              - Constant structure
%   h                - Water depth [m]
%   q                - Specific water discharge vector [m^2/s]
%   cf               - Friction coefficient [-]
%   La               - Active layer thickness [m]
%   Mak              - Mass of size fraction k in active layer
%   dk               - Grain size diameter [m]
%   sed_trans_param  - Sediment transport parameters
%   hiding_param     - Hiding/exposure parameters
%   mor_fac          - Morphological acceleration factor
%   I                - Secondary flow intensity
%   E_s              - Secondary flow intensity parameter
%   sx               - Slope in x-direction [-]
%   sy               - Slope in y-direction [-]
%   E_param          - Entrainment parameters
%   vp_param         - Particle velocity parameters
%   Gammak           - Particle activity parameters
%   gsk_param        - Gravitational slope parameters
%
% Outputs:
%   qbkx, qbky       - Sediment transport components in x and y directions [m^2/s]
%   Qbkx, Qbky       - Sediment transport capacity components in x and y directions [m^2/s]
%   thetak           - Shields parameter [-]
%   qbkx_trans, qbky_trans - Transport with transverse adjustments only [m^2/s]
%   Qbkx_trans, Qbky_trans - Sediment transport capacity with transverse adjustments only [m^2/s]

%% HISTORY
%   -161024 V created it

function [qbkx,qbky,Qbkx,Qbky,thetak,qbkx_trans,qbky_trans,Qbkx_trans,Qbky_trans]=sediment_transport_2D(flg,cnt,h,q,cf,La,Mak,dk,sed_trans_param,hiding_param,mor_fac,I,E_s,sx,sy,E_param,vp_param,Gammak,gsk_param)

%% MODULE

q_m=norm(q); %module of the specific water discharge [m^2/s] 

[qbk,Qbk,thetak,~,~,~,~,~,~,~,~,~,~,~,~,~,~,Dm]=sediment_transport(flg,cnt,h,q_m,cf,La,Mak,dk,sed_trans_param,hiding_param,mor_fac,E_param,vp_param,Gammak);

[qbkx_trans,qbky_trans,Qbkx_trans,Qbky_trans,varphi_tot]=adjust_for_secondary_flow_transverse_slope(flg,cnt,h,q,q_m,cf,dk,I,E_s,sy,sx,gsk_param,thetak,Dm,qbk,Qbk);

[qbkx,qbky,Qbkx,Qbky]=adjust_for_longitudinal_slope(flg,sx,sy,qbkx_trans,qbky_trans,Qbkx_trans,Qbky_trans,varphi_tot);

end %function

%%
%% FUNCTIONS
%%

function [qbkx_trans,qbky_trans,Qbkx_trans,Qbky_trans,varphi_tot]=adjust_for_secondary_flow_transverse_slope(flg,cnt,h,q,q_m,cf,dk,I,E_s,sy,sx,gsk_param,thetak,Dm,qbk,Qbk)

calib_s=isfield_default(flg,'calib_s',1.0,'output','array'); %calibration factor for bed slope effects

% alpha_I=2/cnt.k^2*E_s*(1-sqrt(cf)/(2*cnt.k)); %D3D (error?) contant [-]
alpha_I=2/cnt.k^2*E_s*(1-sqrt(cf)/(1*cnt.k)); % contant [-]

% varphi_tau=atan((q(2)-h*alpha_I*q(1)/q_m*I)/(q(1)-h*alpha_I*q(2)/q_m*I)); %direction of the sediment transport modified due to secondary flow [rad]
% varphi_tau=atan2(q(2)-h*alpha_I*q(1)/q_m*I,q(1)-h*alpha_I*q(2)/q_m*I); %direction of the sediment transport modified due to secondary flow [rad]
%ATTENTION! I think that the Delft3D manual is wrong and below there should be a plus sign
varphi_tau=atan2(q(2)-h*alpha_I*q(1)/q_m*I,q(1)+h*alpha_I*q(2)/q_m*I); %direction of the sediment transport modified due to secondary flow [rad]

gsk=gsk_param(1).*thetak.^gsk_param(2).*(dk./h).^gsk_param(3).*(dk./Dm).^gsk_param(4);

varphi_sk=atan2(sin(varphi_tau)-calib_s./gsk*sy,cos(varphi_tau)-calib_s./gsk*sx); %Delft3D %direction of sediment transport modified due to secondary flow and bed slope
% varphi_sk=atan(-1./gsk*(-sin(varphi_tau)*sx+cos(varphi_tau)*sy)); %Siviglia13 %direction of sediment transport modified due to secondary flow and bed slope

%for computational purposes consider the fact that:
%cos(atan(x))=1/sqrt(1+x^2)
%sin(atan(x))=x/sqrt(1+x^2)

varphi_tot=varphi_sk; %D3D
% varphi_tot=varphi_tau+varphi_sk; %Siviglia13

qbkx_trans=qbk.*cos(varphi_tot);
qbky_trans=qbk.*sin(varphi_tot);

Qbkx_trans=Qbk.*cos(varphi_tot);
Qbky_trans=Qbk.*sin(varphi_tot);

%without secondary flow
% qbkx=qbk*q(1)/q_m;
% qbky=qbk*q(2)/q_m;
% 
% Qbkx=Qbk*q(1)/q_m;
% Qbky=Qbk*q(2)/q_m;

end %function

%%

function [qbkx,qbky,Qbkx,Qbky]=adjust_for_longitudinal_slope(flg,sx,sy,qbkx_trans,qbky_trans,Qbkx_trans,Qbky_trans,varphi_tot)

longitudinal_slope_model=isfield_default(flg,'longitudinal_slope_model','none','output','array'); %model for longitudinal slope effects
alpha_bs=isfield_default(flg,'alpha_bs',1.0,'output','array'); %streamwise bed slope correction factor. Note: default is 1.0 (correction), but default model is 'none' (no correction).
phi=isfield_default(flg,'phi',30,'output','array'); 

switch longitudinal_slope_model
    case 'none'
        alpha_s=1.0; %no correction
    case 'bagnold'
        % Placeholder for Bagnold model
        error('Bagnold model not implemented yet');
    case 'kock_and_flokstra'
        deta_ds=sx.*cos(varphi_tot)+sy.*sin(varphi_tot); %longitudinal bed slope [-]
        alpha_s=min(1-alpha_bs*deta_ds,0.9*tan(phi*2*pi/360)); %slope correction factor [-]
    otherwise
        error('Unknown longitudinal slope model %s',longitudinal_slope_model);
end

qbkx=qbkx_trans.*alpha_s;
qbky=qbky_trans.*alpha_s;

Qbkx=Qbkx_trans.*alpha_s;
Qbky=Qbky_trans.*alpha_s;

end %function