%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16669 $
%$Date: 2020-10-26 05:21:45 +0100 (Mon, 26 Oct 2020) $
%$Author: chavarri $
%$Id: figure_layout.m 16669 2020-10-26 04:21:45Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/figure_layout.m $
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
