function ddb_fig2Quit()
global Mw
global iarea
global nseg

xx=warndlg('All values will be reset','Information');
delete(findobj('tag','Figure2'));
ddb_dnami_initValues()
ddb_dnami_setValues()
end
