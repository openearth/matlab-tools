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
%

function D3D_xml(fpath_xml,fname_mdu,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'check_existing',true)

parse(parin,varargin{:})

check_existing=parin.Results.check_existing;

%% FILE

if check_existing && exist(fpath_xml,'file')==2
    error('File exists and you don''t want to overwrite %s',fpath_xml)
end

[~,~,ext]=fileparts(fname_mdu);
switch ext
    case '.mdu'
        structure=2;
    case '.mdf'
        structure=1;
    otherwise
        error('not sure what structure is file %s',fname_mdu)
end

switch structure
    case 1
        D3D_d3d4_config(fpath_xml,fname_mdu)
    case 2
        D3D_dimr_config(fpath_xml,fname_mdu);
end

