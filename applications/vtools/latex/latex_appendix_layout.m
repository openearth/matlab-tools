%%

fpath_figs='d:\temporal\220602_Maas2D\05_reports\07_memo_SO\co\01_figures\03_BC\'; %folder with the figures to apply <dir>
fdir_fig_rel='./01_figures/03_BC/'; %relative to tex-file
fname_latex='bc'; %file name of the tex-file to be included
fdir_inc='d:\temporal\220602_Maas2D\05_reports\07_memo_SO\co\02_include'; %folder where to save the tex-file. 
tit='Boundary Conditions';

%% 

dire=dir(fpath_figs);
fpath_latex=fullfile(fdir_inc,fname_latex);
fid=fopen(fpath_latex,'w');

fprintf(fid,'\\gensection{\\isreport}{1}{%s} \n',tit);
fprintf(fid,'\\label{app:%s} \n',fname_latex);

ne=numel(dire);
for ke=1:ne
    if dire(ke).isdir; continue; end
    fnameext=dire(ke).name;
    [~,fname]=fileparts(fnameext);
    fig_caption=sprintf('Boundary condition at \\texttt{%s}.',strrep(fname,'_','\_'));
    fname_clean=clean_str(fname);
    fig_label=sprintf('fig:%s',fname_clean);
    fpath=strcat(fdir_fig_rel,fnameext);

    latex_figure(fid,fpath,fig_caption,fig_label);
end %ke