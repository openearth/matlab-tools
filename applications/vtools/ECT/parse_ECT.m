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

function ECT_input=parse_ECT(ECT_input)

if isfield(ECT_input.flg,'read')==0
    ECT_input.flg.read=1;
end

if isfield(ECT_input.flg,'check_input')==0
    ECT_input.flg.check_input=0;
end

if isfield(ECT_input.flg,'friction_closure')==0
    ECT_input.flg.friction_closure=1;
end
if ECT_input.flg.friction_closure==2
    error('I think that the matrices should change! it is not only to convert the value to Chezy')
end

if isfield(ECT_input.flg,'friction_input')==0
    ECT_input.flg.friction_input=1;
end

if isfield(ECT_input.flg,'derivatives')==0
    ECT_input.flg.derivatives=1;
end

if isfield(ECT_input.flg,'particle_activity')==0
    ECT_input.flg.particle_activity=0;
end

if isfield(ECT_input.flg,'cp')==0
    ECT_input.flg.cp=0;
end

if isfield(ECT_input.flg,'extra')==0
    ECT_input.flg.extra=0;
end

if isfield(ECT_input.flg,'pmm')==0
    ECT_input.flg.pmm=0;
end

if isfield(ECT_input.flg,'vp')==0
    ECT_input.flg.vp=1; %compute particle velocity: 0=NO, 1=YES
end

if isfield(ECT_input.flg,'E')==0
    ECT_input.flg.E=1; %compute entrainment-deposition formulation: 0=NO, 1=YES
end

if isfield(ECT_input.flg,'calib_s')==0
    ECT_input.flg.calib_s=1; 
end

if isfield(ECT_input,'u_b')==0
    ECT_input.u_b=NaN; 
end

if isfield(ECT_input,'v')==0
    ECT_input.v=0;
end

if isfield(ECT_input,'E_param')==0
    ECT_input.E_param=NaN;
end

if isfield(ECT_input,'vp_param')==0
    ECT_input.vp_param=NaN;
end

if isfield(ECT_input,'gsk_param')==0
    ECT_input.gsk_param=[0,0,0,0];
end

if isfield(ECT_input,'nu_mom')==0
    ECT_input.nu_mom=0;
end

if isfield(ECT_input,'diff_hir')==0
    ECT_input.diff_hir=0;
end

if isfield(ECT_input,'mor_fac')==0
    ECT_input.mor_fac=1;
end

end %function