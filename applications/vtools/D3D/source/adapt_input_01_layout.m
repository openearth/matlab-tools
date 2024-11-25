% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%

function simdef=adapt_input_01(simdef,input_m_s)

simdef.grd.L=10*input_m_s.ini__noise_Lb;

switch simdef.D3D.structure
    case 1
        simdef.file.software='p:\d-hydro\delft3d4\Delft3D-FLOW_WAVE\6.04.02.142586\';
        simdef.mdf.CFL=             5; %CFL number [-]. Used in FM, can be used in D3D4 to compute <Dt> 
    case 2
        simdef.file.software='p:\d-hydro\dimrset\weekly\2.28.08\';
        simdef.mdf.CFL=             0.7; %CFL number [-]. Used in FM, can be used in D3D4 to compute <Dt> 
end

end %function