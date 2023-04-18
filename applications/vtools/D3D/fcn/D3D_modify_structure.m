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
%variables: open D3D_list_of_variables

function simdef=D3D_modify_structure(simdef,input_m_s)

fn=fieldnames(input_m_s);
nf=numel(fn);
for kf=1:nf
    tok=regexp(fn{kf},'__','split');
    if isempty(tok); continue; end
    if strcmp(tok{1,1},fn{kf}); continue; end %there is no '__'
%     if ~isfield(simdef,tok{1,1}); continue; end
%     if ~isfield(simdef.(tok{1,1}),tok{1,2}); continue; end
    simdef.(tok{1,1}).(tok{1,2})=input_m_s.(fn{kf});
end

end