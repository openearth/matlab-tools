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

function fid=fopen_add_header(fname,flg,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'add_header',true);

parse(parin,varargin{:});

add_header=parin.Results.add_header;

%% CALC

fid=fopen(fname,flg);
if add_header
    fname_tags={'$Revision','$Date','$Author','$Id','$HeadURL','$Additional'};
    fname_st=dbstack(1, '-completenames');
    fpath_main=fname_st(end).file;
    fid_r=fopen(fpath_main,'r');
    
    %write
    fprintf(fid,'#User execution: %s\n', [getenv("USER"),getenv("USERNAME")]);
    fprintf(fid,'#Date execution: %s\n', datestr(now())); 
    fprintf(fid,'#Script: %s\n', fpath_main); 
    while ~feof(fid_r)
        lin=fgets(fid_r);
        bol_tags=contains(lin,fname_tags);
        if any(bol_tags)
            fprintf(fid,'#%s',lin); 
        end
    end
    fclose(fid_r);
end

end %function