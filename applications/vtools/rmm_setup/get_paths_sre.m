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

function paths=get_paths_sre(paths)

%%

paths.defrun_1=fullfile(paths.sre_out,'DEFRUN.1');

paths.defstr_4=fullfile(paths.sre_out,'DEFSTR.4');
paths.defstr_5=fullfile(paths.sre_out,'DEFSTR.5');

paths.defcnd_1=fullfile(paths.sre_out,'DEFCND.1');
paths.defcnd_2=fullfile(paths.sre_out,'DEFCND.2');
paths.defcnd_3=fullfile(paths.sre_out,'DEFCND.3');
paths.defcnd_6=fullfile(paths.sre_out,'DEFCND.6');

paths.defmet_1=fullfile(paths.sre_out,'DEFMET.1');

end %function