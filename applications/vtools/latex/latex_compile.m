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
%Compile LaTeX file

function latex_compile(fpath_tex)

fdir_o=pwd;

[fdir,fname,fext]=fileparts(fpath_tex);

cd(fdir);
delete(sprintf('%s.aux',fname));
delete(sprintf('%s.log',fname));
system(sprintf('pdflatex %s',fpath_tex));
system(sprintf('bibtex  %s',fname));
system(sprintf('pdflatex %s',fpath_tex));
system(sprintf('pdflatex %s',fpath_tex));
cd(fdir_o);

end %function
