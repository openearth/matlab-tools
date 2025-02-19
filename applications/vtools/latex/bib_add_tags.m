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
str_set={'year','journal'     ,'school'};
str_get={'date','journaltitle','institution'};

%calc
fprintf(fid_w,lin); %first line with @
bol_end=false; %condition to finish reading block

%% BEGIN DEBUG
% if contains(lin,'Stoelum96')
% if contains(lin,'Eke14_2')
%     
%     a=1;
% end

%% END DEBUG
ns=numel(str_set);
bol_set=false(1,ns);
bol_get=false(1,ns);
str_save=cell(1,ns);
lin_set=NaN(1,ns);
txt={}; %we could preallocate and check
kl=0;
while ~bol_end
    lin=fgets(fid_r);
    [bol_end,txt,kl]=fcn_is_end_block(lin,txt,kl);
    if bol_end; continue; end
    %replace non-asci character
    lin=latex_nonascii(lin);
    %replace special characters for writing.
    lin=fcn_add_for_sprintf(lin);
    %check if it is closing the tag (i.e., '}') and it has a comma. If 
    %there is no comma, add it. 
    lin=fcn_add_comma(lin);
    %check if it does not have '{' '}' surrounding the tag and add them.
    %!!!ATTENTION!!! we only deal with the case in which it is in one line. 
    lin=fcn_close_text(lin);
    %put all tag in one line
    lin=fcn_only_one_line(lin,fid_r);

    %add line to cell for writing.
    kl=kl+1;
    txt{kl,1}=lin;
    %check if there is tag
    if ~contains(lin,'='); continue, end
    tok=regexp(lin,'=','split');
    for ks=1:ns
        %check if it has `year`
        if strcmp(strtrim(tok{1,1}),str_set{ks})
            bol_set(ks)=true;
            lin_set(ks)=kl;
        end
        %save `date`
        if strcmp(strtrim(tok{1,1}),str_get{ks})
            bol_get(ks)=true;
            str_save{ks}=tok{1,2};
        end
    end
end %while

%up to this point we have not written the end of the block `}`

for ks=1:ns
    if ~bol_set(ks) && bol_get(ks)
        kl=kl+1;
        txt{kl,1}=sprintf('%s = %s',str_set{ks},str_save{ks});
    elseif bol_set(ks) && bol_get(ks)
        txt{lin_set(ks),1}=sprintf('%s = %s',str_set{ks},str_save{ks});
    end
end

kl=kl+1;
txt{kl,1}='}\r';
    
%% WRITE
nl=numel(txt);
for kw=1:nl
    fprintf(fid_w,txt{kw,1});
end

end %process_block

%%

function lin=fcn_add_comma(lin)

lin_clean=strtrim(deblank(lin)); %no white spaces at the end or beginning.
if ~isempty(lin_clean) && strcmp(lin_clean(end),'}')
    lin_clean(end)='';
    lin_clean=sprintf('%s},\r',lin_clean);
    lin=lin_clean;
end

end %function

%%

function lin=fcn_close_text(lin)

if contains(lin,'=')
    tok=regexp(lin,'=','split');
    lin_clean=strtrim(deblank(tok{1,2}));
    if ~strcmp(lin_clean(1),'{')
        lin_clean(end)='';
%         lin_clean=strrep(lin_clean,',',''); %remove final commal. !!!ATTENTION we may remove several commas!
        if strcmp(lin_clean(end),',')
            lin_clean(end)='';
        end
        lin_clean=sprintf(' {%s},',lin_clean);
        lin=sprintf('%s = %s \n',tok{1,1},lin_clean);
    end
end

end %function

%% 

function     [lin]=fcn_only_one_line(lin,fid_r)

lin_clean=strtrim(deblank(lin)); %no white spaces at the end or beginning.
if ~isempty(lin_clean)
    %At this point a line must contain an equal and not be empty
    if ~contains(lin,'=') 
        error('Line does not have equal: %s',lin)
    end
    %the first character after the equal must be '{' 
    tok=regexp(lin,'=','split');
    %if number of tokens is larger than 2, there is an equal in the text
    ntok=numel(tok);
    if ntok>2
        ktok=2;
        lin_clean=strtrim(deblank(tok{1,ktok}));
        txt_sl=lin_clean;
        for ktok=3:ntok %the first is the tag
            lin_clean=strtrim(deblank(tok{1,ktok}));
            txt_sl=sprintf('%s %s',txt_sl,lin_clean);
        end %ktok
        tok{1,2}=txt_sl;
    end
    lin_clean=strtrim(deblank(tok{1,2}));
    if ~strcmp(lin_clean(1),'{') 
        error('First character after equal is not opening tag: %s',lin)
    end
    %last character of the line must be '},'. Otherwise, the tag is in several lines. 
    %Also escape the LaTeX character }, '\}'.
    if ~fcn_is_last_character(lin_clean)
        txt_sl=deblank(lin); %text in several lines
        while ~fcn_is_last_character(lin_clean)
            lin=fgetl(fid_r);
            lin=fcn_add_for_sprintf(lin);
            lin_clean=strtrim(deblank(lin));
            txt_sl=sprintf('%s %s',txt_sl,lin_clean);
        end
        if ~strcmp(txt_sl(end),',')
            txt_sl=sprintf('%s,',txt_sl);
        end
        lin=sprintf('%s \n',txt_sl);
    end
end

end %function

%%

function lin=fcn_add_for_sprintf(lin)

lin=strrep(lin,'\','\\');
lin=strrep(lin,'%','%%'); 

end

%%

function bol_lc=fcn_is_last_character(lin_clean)

bol_lc=false;
if isempty(lin_clean)
    return;
end
if numel(lin_clean)==1
    if strcmp(lin_clean(end),'}')
        bol_lc=1;
    end
    return;
end
if strcmp(lin_clean(end-1:end),'\}')
    return;
end
if strcmp(lin_clean(end-1:end),'},') || strcmp(lin_clean(end),'}') 
    bol_lc=true;
end

end

%% 

function [bol_end,txt,kl]=fcn_is_end_block(lin,txt,kl)

lin=fcn_add_for_sprintf(lin);
lin_clean=strtrim(deblank(lin)); %no white spaces at the end or beginning.
lin_clean=strrep(lin_clean,' ',''); %remove spaces for the case in which the block ends with the last tag. E.g.: pages={sediment.27} }

bol_end=false;

if numel(lin_clean)==0

elseif numel(lin_clean)==1 && strcmp(lin_clean,'}') %boolean to check whether the line only contains '}', i.e., it is the last line of the block. 
    bol_end=true;
elseif numel(lin_clean)>1 && strcmp(lin_clean(end-1:end),'}}')
    kl=kl+1;
    txt{kl,1}=sprintf(' %s,\n',lin_clean(1:end-1));
    bol_end=true;
elseif numel(lin_clean)>1 && strcmp(lin_clean(end-1:end),'},}')
    kl=kl+1;
    txt{kl,1}=sprintf(' %s\n',lin_clean(1:end-1));
    bol_end=true;
end

end %function
