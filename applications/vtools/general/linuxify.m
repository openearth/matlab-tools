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
%

function path_lin=linuxify(path_win)

path_win=small_p(path_win);
path_lin=strcat('/',path_win);
path_lin=strrep(path_lin,':','');
path_lin=strrep(path_lin,'\','/');

end

%%
%% FUNCTIONS
%%

function path_dir=small_p(path_dir)

path_dir=strrep(path_dir,'P:','p:');

end %function