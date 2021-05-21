%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17028 $
%$Date: 2021-02-01 13:22:57 +0100 (Mon, 01 Feb 2021) $
%$Author: chavarri $
%$Id: latex_figure.m 17028 2021-02-01 12:22:57Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/latex_figure.m $
%
%to block figures:
%     %block figures
%     fprintflatex(fid,'\FloatBarrier');
%     fprintflatex(fid,'\clearpage');
%     fprintflatex(fid,'\newpage');

function latex_figure(fid,figpath,figcaption,figlabel)
            
figpath=strrep(figpath,'\','/');

[~,~,ext]=fileparts(figpath);

fprintflatex(fid,'\begin{figure*}[!ht]');
fprintflatex(fid,'    \centering');
switch ext
    case {'.png','.jpg'}
        fprintflatex(fid,sprintf('		\\includegraphics[width=\\textwidth]{%s}',figpath));
    case '.eps'
        fprintflatex(fid,sprintf('		\\includegraphics{%s}',figpath));
    otherwise
        fprintflatex(fid,sprintf('		\\includegraphics[width=\\textwidth]{%s}',figpath));
end
fprintflatex(fid,sprintf('    \\caption{%s}',figcaption));
fprintflatex(fid,sprintf('    \\label{%s}',figlabel));
fprintflatex(fid,'\end{figure*}');

end
