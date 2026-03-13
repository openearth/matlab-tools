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

function D3D_display_simdef(simdef)

ECT_input=D3D_input_2_ECT_input(simdef);
v2struct(ECT_input)

Gammak=NaN(size(gsd));

cnt.g=simdef.mdf.g;
cnt.rho_s=2650;
cnt.rho_w=1000;
cnt.p=0.4; %in ECT sedtrnas uses this porosity
cnt.k=0.41;
cnt.nu=1e-6; %we should compute based on temperature?

cnt.R=(cnt.rho_s-cnt.rho_w)/cnt.rho_w;

Mak=Fa1.*La;

[qbk,Qbk,thetak,qbk_st,Wk_st,u_st,xik,Qbk_st,Ek,Ek_st,Ek_g,Dk,Dk_st,Dk_g,vpk,vpk_st,Gammak_eq,Dm]=sediment_transport(flg,cnt,h,u*h,Cf,La,Mak,gsd,sedTrans,hiding,mor_fac,E_param,vp_param,Gammak);
qbk_no_pores=qbk.*(1-cnt.p);

fprintf('Width = %.2f m\n',simdef.grd.B);

fprintf('Dimensional Chézy friction coefficient `C` = %.4f m^{1/2}/s = %.4e m^{1/2}/s\n',simdef.mdf.C, simdef.mdf.C);
fprintf('Dimensionless friction coefficient `Cf=u_star^2/u^2` = %.4f = %.4e \n',convert_friction('C2Cf',simdef.mdf.C), convert_friction('C2Cf',simdef.mdf.C));
fprintf('Dimensionless friction coefficient `Cn=C/sqrt(g)` = %.4f = %.4e \n',convert_friction('C2Cn',simdef.mdf.C), convert_friction('C2Cn',simdef.mdf.C));

fprintf('Bed slope = %.4e \n',simdef.ini.s);
fprintf('Flow depth = %.2f m\n',simdef.ini.h);
fprintf('Flow velocity (at normal flow with previous values) = %.2f m/s\n',simdef.ini.u);
fprintf('Characteristic grain size = %.4f m = %.4e m \n',simdef.sed.dk, simdef.sed.dk);
fprintf('Froude number = %.2f \n',simdef.ini.u/sqrt(simdef.ini.h*simdef.mdf.g));
fprintf('Shear velocity = %.3f m/s \n',sqrt(simdef.mdf.g)/simdef.mdf.C*simdef.ini.u);
fprintf('Shield''s stress = %.3f \n',(sqrt(simdef.mdf.g)/simdef.mdf.C*simdef.ini.u)^2/(simdef.mdf.g*1.65*simdef.sed.dk));
fprintf('Bed shear stress = %.3f \n',cnt.rho_w*convert_friction('C2Cf',simdef.mdf.C)*simdef.ini.u^2);

fprintf('Sediment transport relation: A=%0.2f, B=%0.2f, theta_c=%0.4f \n',simdef.tra.sedTrans(1), simdef.tra.sedTrans(2), simdef.tra.sedTrans(3));
fprintf('Sediment transport rate with pores = %.4e m^2/s \n',qbk);
fprintf('Sediment transport rate without pores = %.4e m^2/s \n',qbk_no_pores);

fprintf('Bed-slope-effect parameter: A_sh=%0.2f, 1/A_sh=r=%0.2f, B_sh=%0.2f \n',simdef.mor.AShld, 1/simdef.mor.AShld, simdef.mor.BShld);

end %function