%fopen_add_header - fopen with header information

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
%Opens a file and provides identifier as `fopen` and additionally: (1) writes the
%SVN header of the top script calling it, and (2) writes the SVN repository
%information that is being used. 

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
if ~add_header
    return
end

%% write header SVN

fname_tags={'$Revision','$Date','$Author','$Id','$HeadURL','$Additional'};
fname_st=dbstack(1, '-completenames');
if isempty(fname_st)
    fpath_main=pwd;
else
    fpath_main=fname_st(end).file;
end
fid_r=fopen(fpath_main,'r');
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

%% write SVN info
rev=svn_info;
rev=insertBefore(rev,1,comment_symbol);
rev=strrep(rev,'\','\\');
rev=regexprep(rev,'\n','\n#');
rev=[rev,'\n'];
fprintf(fid,rev);

end %function