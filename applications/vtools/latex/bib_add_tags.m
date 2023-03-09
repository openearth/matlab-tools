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
%Adds 'year' to a bib-file copying from 'date' if it is not present.

function bib_add_tags(fpath_r)

fpath_w=strrep(fpath_r,'.bib','_tmp.bib');

fid_w=fopen(fpath_w,'w');
fid_r=fopen(fpath_r,'r');
kb=0;
while ~feof(fid_r)
    lin=fgets(fid_r); %with newline character
    bol_begin=strcmp(lin(1),'@') && ~contains(lin,'@Comment{'); %condition to find a begin of the block. Could be improved if it is not always the first character. We have to exclude the last line
    if  bol_begin
        process_block(fid_w,fid_r,lin);
        kb=kb+1;
        fprintf('Entrances processes: %d \n',kb);
    else
        fprintf(fid_w,lin);
    end
end %while
fclose(fid_w);
fclose(fid_r);

%rewrite and delete
copyfile(fpath_w,fpath_r);
delete(fpath_w);

end %function

%% 
%% FUNCTIONS
%%

%%

function process_block(fid_w,fid_r,lin)

%input
str_set={'year','journal'     };
str_get={'date','journaltitle'};

%calc
fprintf(fid_w,lin); %first line with @
bol_end=false; %condition to finish reading block

ns=numel(str_set);
bol_set=false(1,ns);
bol_get=false(1,ns);
str_save=cell(1,ns);
while ~bol_end
    lin=fgets(fid_r);
    bol_end=strcmp(lin(1),'}'); %it should be the first character. It is always after saving with jabref I think.
    if bol_end; continue; end
    lin=strrep(lin,'\','\\');
    lin=strrep(lin,'%','%%'); 
    fprintf(fid_w,lin);
    if ~contains(lin,'='); continue; end
    tok=regexp(lin,'=','split');
    for ks=1:ns
        %check if it has `year`
        if strcmp(strtrim(tok{1,1}),str_set{ks})
            bol_set(ks)=true;
        end
        %save `date`
        if contains(tok{1,1},str_get{ks})
            bol_get(ks)=true;
            str_save{ks}=tok{1,2};
        end
    end
end %while

%up to this point we have not written the end of the block `}`

for ks=1:ns
    if ~bol_set(ks) && bol_get(ks)
        fprintf(fid_w,'%s = %s',str_set{ks},str_save{ks});
    end
end

fprintf(fid_w,'}\r');
    
end %process_block