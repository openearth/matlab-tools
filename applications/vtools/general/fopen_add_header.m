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
addOptional(parin,'comment_symbol','#');

parse(parin,varargin{:});

add_header=parin.Results.add_header;
comment_symbol=parin.Results.comment_symbol;

%% CALC

fid=fopen(fname,flg);
if add_header
    fname_tags={'$Revision','$Date','$Author','$Id','$HeadURL','$Additional'};
    fname_st=dbstack(1, '-completenames');
    if isempty(fname_st)
        fpath_main=pwd;
    else
        fpath_main=fname_st(end).file;
    end
    fid_r=fopen(fpath_main,'r');
    
    %write
    fprintf(fid,'%sUser execution: %s\n',comment_symbol,[getenv("USER"),getenv("USERNAME")]);
    fprintf(fid,'%sDate execution: %s\n',comment_symbol,datestr(now())); 
    fprintf(fid,'%sScript: %s\n',comment_symbol,fpath_main); 
    while ~feof(fid_r)
        lin=fgets(fid_r);
        bol_tags=contains(lin,fname_tags);
        if any(bol_tags)
            fprintf(fid,'%s%s',comment_symbol,lin); 
        end
    end
    fclose(fid_r);

    rev=svn_info;
    idx_nl=regexp(rev,'\n');
    rev(idx_nl)='*'; %this is tricky. I assume that there cannot be a '*' in the string. I replace the new line character by it and then replace that by 
    rev=strrep(rev,'\','\\');
    rev=strrep(rev,'*',sprintf(' \\n%s',comment_symbol));
    fprintf(fid,rev);
end

end %function