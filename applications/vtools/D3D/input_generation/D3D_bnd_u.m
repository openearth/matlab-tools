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
%bnd file creation

%INPUT:
%   -
%
%OUTPUT:
%   -

function D3D_bnd_u(simdef)
%% RENAME

dire_sim=simdef.D3D.dire_sim;
upstream_nodes=simdef.mor.upstream_nodes;

%% FILE

%no edit
kl=1;
    for kny=1:upstream_nodes
data{kl, 1}=''; kl=kl+1;
data{kl, 1}='[boundary]'; kl=kl+1;
data{kl, 1}='quantity=dischargebnd'; kl=kl+1;
data{kl, 1}=sprintf('locationfile=Upstream_%02d.pli',kny); kl=kl+1;
data{kl, 1}='forcingfile=bc_q0.bc'; kl=kl+1;
    end
data{kl, 1}=''; kl=kl+1;
data{kl, 1}='[boundary]'; kl=kl+1;
data{kl, 1}='quantity=waterlevelbnd'; kl=kl+1;
data{kl, 1}='locationfile=Downstream.pli'; kl=kl+1;
data{kl, 1}='forcingfile=bc_wL.bc'; kl=kl+1;
data{kl, 1}=''; 

%% WRITE

file_name=fullfile(dire_sim,'bnd.ext');
writetxt(file_name,data)

