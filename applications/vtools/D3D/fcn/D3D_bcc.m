%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17337 $
%$Date: 2021-06-10 13:14:13 +0200 (do, 10 jun 2021) $
%$Author: chavarri $
%$Id: D3D_bct.m 17337 2021-06-10 11:14:13Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_bct.m $
%
%bct file creation

%INPUT:
%   -
%
%OUTPUT:
%   -

function D3D_bcc(simdef,varargin)

%% PARSE

parin=inputParser;

inp.check_existing.default=true;
addOptional(parin,'check_existing',inp.check_existing.default)

parse(parin,varargin{:})

check_existing=parin.Results.check_existing;

%% CALC

%% WRITE

%check if the file already exists
if check_existing && exist(simdef.file.bcc,'file')>0
    error('You are trying to overwrite a file!')
end

bct_io('write',simdef.file.bcc,simdef.bcc);

end %function
