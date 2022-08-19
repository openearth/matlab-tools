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

function stru_out=D3D_read_xyn(fname,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'version',1);

parse(parin,varargin{:});

v=parin.Results.version;


%%
obs_xy=readmatrix(fname,'FileType','text');
obs_nam=readcell(fname,'FileType','text');

switch v
    case 1
        stru_out.name=obs_nam(:,3)';
        stru_out.x=obs_xy(:,1)';
        stru_out.y=obs_xy(:,2)';
    case 2
        stru_out=struct('name',obs_nam(:,3),'xy',num2cell(obs_xy(:,1:2),2));
end
end %function