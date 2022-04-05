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
%OUTPUT:

function [fpath_dia,structure]=D3D_simdef_2_dia(simdef)

if isstruct(simdef)
    fpath_dia=simdef.file.dia;
    structure=simdef.D3D.structure;
elseif isfolder(simdef)
    dire_sim=simdef;
    simdef=struct();
    simdef.D3D.dire_sim=dire_sim;
    simdef=D3D_simpath(simdef);
    fpath_dia=simdef.file.dia;
    structure=simdef.D3D.structure;
elseif exist(simdef,'file')==2
    fpath_dia=simdef;
    [~,~,ext]=fileparts(fpath_dia);
    switch ext
        case '.dia'
            structure=2;
        otherwise
            structure=1;
    end
else
    error('not a dir, not a structure')
end

end %function