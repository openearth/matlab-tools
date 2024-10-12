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
%Write the TOC of a latex file.
%
%E.G. of batch file calling the compiled routine:
%```
% @echo off
% for %%f in (*.tex) do (
%     rem if "%%~xf"==".tex" echo %%f
% 	if "%%~xf"==".tex" call latex_toc %%f
% )
% pause
%```
%
%TO DO:
%   -Add figures and equations

function toc=latex_toc(fpath_tex)

%% read

fid=fopen(fpath_tex,'r');
toc={}; %better to preallocate
kc=0;
while ~feof(fid)
    lin=fgetl(fid);
    bol_sec=contains(lin,'\gensection');
    if bol_sec
        tok=regexp(lin,'{(.*?)}','tokens');
        kc=kc+1;
        toc{kc,1}=tok{1,3}{1,1};
        toc{kc,2}=str2double(tok{1,2}{1,1});
        toc{kc,3}=search_for_label(fid);
    end %bol_sec

    bol_sec=contains(lin,'\chapter');
    if bol_sec
        tok=regexp(lin,'{(.*?)}','tokens');
        kc=kc+1;
        toc{kc,1}=tok{1,1}{1,1};
        toc{kc,2}=1;
        toc{kc,3}=search_for_label(fid);
    end

    bol_sec=contains(lin,'\section');
    if bol_sec
        tok=regexp(lin,'{(.*?)}','tokens');
        kc=kc+1;
        toc{kc,1}=tok{1,1}{1,1};
        toc{kc,2}=2;
        toc{kc,3}=search_for_label(fid);
    end

    bol_sec=contains(lin,'\subsection');
    if bol_sec
        tok=regexp(lin,'{(.*?)}','tokens');
        kc=kc+1;
        toc{kc,1}=tok{1,1}{1,1};
        toc{kc,2}=3;
        toc{kc,3}=search_for_label(fid);
    end

end %feof

fclose(fid);

%% write

[fdir,fname,~]=fileparts(fpath_tex);
fpath_w=fullfile(fdir,sprintf('%s.mtoc',fname));
fid=fopen(fpath_w,'w');
nl=size(toc,1);
for kl=1:nl
    ntab=toc{kl,2}-1;
    str_tab=repmat('      ',ntab,1);
    fprintf(fid,'%s %s (%s) \r\n',str_tab,toc{kl,1},toc{kl,3});
end %kl
fclose(fid);

end %function

%%
%% FUNCTIONS
%%

function lab=search_for_label(fid)

lab='';
nmax=100;
kc=0;
is_label=false;
while ~is_label && kc<nmax
    lin=fgetl(fid);
    bol_lab=contains(lin,'\label');
    if bol_lab
        tok=regexp(lin,'{(.*?)}','tokens');
        lab=tok{1,1}{1,1};
        is_label=true;
    end %bol_lab
    kc=kc+1;
end

end