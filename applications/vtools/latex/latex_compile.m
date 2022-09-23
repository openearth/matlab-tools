%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18361 $
%$Date: 2022-09-14 07:43:17 +0200 (Wed, 14 Sep 2022) $
%$Author: chavarri $
%$Id: D3D_gdm.m 18361 2022-09-14 05:43:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/D3D_gdm.m $
%
%Compile LaTeX file

function latex_compile(fpath_tex)

fdir_o=pwd;

[fdir,fname,fext]=fileparts(fpath_tex);

cd(fdir);
system(sprintf('pdflatex %s',fpath_tex));
system(sprintf('bibtex  %s',fname));
system(sprintf('pdflatex %s',fpath_tex));
system(sprintf('pdflatex %s',fpath_tex));
cd(fdir_o);

end %function
