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
%Convert a set of files to xy-files, changing the coordinate system.

function fpath_out_c_out=convert_filetype(fpath_in,fext_out_no_dot,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'epsg_in',4326);
addOptional(parin,'epsg_out',28992);
addOptional(parin,'overwrite',true);

parse(parin,varargin{:});

epsg_out=parin.Results.epsg_out;
epsg_in=parin.Results.epsg_in;
overwrite=parin.Results.overwrite;

%% CALC

if ~iscell(fpath_in)
    if ischar(fpath_in)
        fpath_in_c{1}=fpath_in;
        fpath_in=fpath_in_c;
    else
        error('Not ready')
    end
end

nf=numel(fpath_in);
fpath_out_c_out=cell(nf,1);
for kf=1:nf
    fpath_in_1=fpath_in{kf};

    [~,~,fext]=fileparts(fpath_in_1);
    fext_out=sprintf('.%s',fext_out_no_dot);
    fpath_out=strrep(fpath_in_1,fext,fext_out);
    EHY_convert(fpath_in_1,fext_out_no_dot,'outputFile',fpath_out,'overwrite',overwrite);
    fpath_out_c=strrep(fpath_out,fext_out,sprintf('_%d%s',epsg_out,fext_out));
    EHY_convert(fpath_out,fext_out_no_dot,'fromEPSG',epsg_in,'toEPSG',epsg_out,'outputFile',fpath_out_c,'overwrite',overwrite);

    fpath_out_c_out{kf}=fpath_out_c;

end

end %function