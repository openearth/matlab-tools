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

function D3D_write_readme(input_m_s,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'fpath_out','readme.txt')

parse(parin,varargin{:})

fpath_readme_txt=parin.Results.fpath_out;

%% CALC

fn=fieldnames(input_m_s);
nf=numel(fn);
ns=numel(input_m_s);
fid=fopen(fpath_readme_txt,'w');

str_head=repmat('%35s,',1,nf);
str_head=strcat(str_head,'\n');

%header
fprintf(fid,str_head,fn{:});
fprintf(fid,'\n');

%str
str_w='';
for kf=1:nf
    if isnumeric(input_m_s(1).(fn{kf}))
        str_w=strcat(str_w,'%35f, ');
    elseif ischar(input_m_s(1).(fn{kf}))
        str_w=strcat(str_w,'%35s, ');
    else
        error('not sure how to treat this')
    end
end
str_w=strcat(str_w,'\n');

%sim
for ks=1:ns
    val_w=cell(1,nf);
    for kf=1:nf
        val_w{1,kf}=input_m_s(ks).(fn{kf});
    end
    fprintf(fid,str_w,val_w{:});
end

%end
fclose(fid);

end %function