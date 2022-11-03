function ddb_sfincs_save_input(handles)

inp=handles.model.sfincs.domain(ad).input;

sfincs_write_input('sfincs.inp',inp);

fid=fopen('run.bat','wt');
fprintf(fid,'%s\n',['call "', handles.model.sfincs.exedir filesep 'sfincs.exe">sfincs_log.txt']);
fclose(fid);
