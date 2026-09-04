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

if numel(path_win)>=2 && strcmp(path_win(2),':') %windows absolute path
    path_win=small_p(path_win);
    path_lin=strcat('/',path_win);
    path_lin=strrep(path_lin,':','');
    path_lin=strrep(path_lin,'\','/');
elseif ismember('\',path_win) %windows relative path
    path_lin=strrep(path_win,'\','/');
else %linux path
    path_lin=path_win;
end

%copying to the clipboard is meant for interactive use, so it is skipped
%when the result is assigned to a variable
is_gui_mode = usejava('desktop') && usejava('awt');
if is_gui_mode && nargout==0
   clipboard("copy",path_lin);
end

end %function

%%
%% FUNCTIONS
%%

function path_dir=small_p(path_dir)

path_dir=strrep(path_dir,'P:','p:');

end %function