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
