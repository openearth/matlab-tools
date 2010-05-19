function ddb_dnami_quit()

%Quits Tsunami Toolkit
answ=questdlg('Really quit?','Quit?','Yes','No','No');

if strcmp(answ,'Yes')
    delete(gcbf);
    delete(findobj('tag','Figure2'));
    delete(findobj('tag','ddb_dnami_mainWin'));
end
clear all
