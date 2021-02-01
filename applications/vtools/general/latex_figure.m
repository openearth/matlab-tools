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
