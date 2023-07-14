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
%sediment initial file creation

%INPUT:
%   -
%
%OUTPUT:
%   -a .sed file compatible with D3D is created in file_name

function D3D_sed(simdef,varargin)

%% PARSE

parin=inputParser;

inp.check_existing.default=true;
addOptional(parin,'check_existing',inp.check_existing.default)

parse(parin,varargin{:})

check_existing=parin.Results.check_existing;

%% RENAME

% D3D_structure=simdef.D3D.structure;

%% FILE

%2DO: The files are the same!
%Within the function, check if tra-file exists. If yes, do not write the
%sediment parameters to the sed-file.
%

% if D3D_structure==1
%     D3D_sed_s(simdef); %should not be needed if parameters of sedtrans are there
% else
    D3D_sed_u(simdef,'check_existing',check_existing);
% end