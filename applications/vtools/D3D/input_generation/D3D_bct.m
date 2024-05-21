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
%bct file creation

%INPUT:
%   -
%
%OUTPUT:
%   -

function D3D_bct(simdef,varargin)

%% PARSE

parin=inputParser;

inp.check_existing.default=true;
addOptional(parin,'check_existing',inp.check_existing.default)

parse(parin,varargin{:})

check_existing=parin.Results.check_existing;

%% RENAME

D3D_structure=simdef.D3D.structure;

if isfield(simdef.bct,'version_V')==0
    if isfield(simdef.bct,'sec')
        simdef.bct.version_V=1;
        warning('call bct_io')
    elseif isfield(simdef.bct,'Table')
        simdef.bct.version_V=2;
    else
        simdef.bct.version_V=0;
    end
end

%% NOISE

simdef=D3D_bct_noise(simdef);

%% FILE

if D3D_structure==1
    switch simdef.bct.version_V
        case 0
            D3D_bct_s(simdef,'check_existing',check_existing);
        case 1
            simdef.bct.fname=simdef.file.bct;
            D3D_bct_2(simdef,'check_existing',check_existing);
        case 2
            bct_io('write',simdef.file.bct,simdef.bct);
    end
else
    D3D_bc_wL(simdef,'check_existing',check_existing);
    D3D_bc_q0(simdef,'check_existing',check_existing);
end

end %function

%%
%% FUNCTIONS
%%

function simdef=D3D_bct_noise(simdef)

switch simdef.bct.noise_Q
    case 1
        %currently only possible for version_V=0
        if numel(simdef.bct.time)~=2 || numel(simdef.bct.Q)~=2
            error('Generalize function.')
        end
        simdef.bct.noise_Q_dt=round(simdef.bct.noise_Q_dt/simdef.mdf.Dt)*simdef.mdf.Dt;
        simdef.bct.time_Q=simdef.bct.time_Q(1):simdef.bct.noise_Q_dt:simdef.bct.time_Q(end);
        nt=numel(simdef.bct.time_Q);
        rng(0);
        simdef.bct.Q=simdef.bct.Q(1).*ones(nt,simdef.mor.upstream_nodes)+simdef.bct.noise_Q_amp.*rand(nt,simdef.mor.upstream_nodes);
end

end %function