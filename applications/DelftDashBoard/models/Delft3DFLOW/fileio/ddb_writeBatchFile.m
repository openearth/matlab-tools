function ddb_writeBatchFile(runid)

handles=getHandles;
fid=fopen('batch_flw.bat','w');

% fprintf(fid,'%s\n','@echo off');
% fprintf(fid,'%s\n',['rem ===== Flow batch: ' runid ' =====']);
% fprintf(fid,'%s\n',['@echo ' runid ' > runid ']);
% fprintf(fid,'%s\n','%D3D_HOME%\%ARCH%\menu\bin\tclkit.exe %D3D_HOME%\%ARCH%\menu\bin\d3dtmpl.tcl  -flow -simulation -rm -Use runid');
% fprintf(fid,'%s\n','set WRITE_WIDGET=yes');
% fprintf(fid,'%s\n','@echo on');
% fprintf(fid,'%s\n',['@echo Delft3D-FLOW run ' runid ' running now ....']);
% fprintf(fid,'%s\n','@echo off');
% fprintf(fid,'%s\n','%D3D_HOME%\%ARCH%\menu\bin\tclkit.exe %D3D_HOME%\%ARCH%\menu\bin\hyd_online.tcl -batch');
% fprintf(fid,'%s\n','@echo on');
% fprintf(fid,'%s\n',['@echo Delft3D-FLOW run ' runid ' finished']);
% fprintf(fid,'%s\n','@echo off');

if exist([getenv('D3D_HOME') '\' getenv('ARCH') '\flow\bin\trisim.exe'],'file')
    fprintf(fid,'%s\n',['echo ' runid ' > runid ']);
    fprintf(fid,'%s\n','%D3D_HOME%\%ARCH%\flow\bin\tdatom.exe');
    fprintf(fid,'%s\n','%D3D_HOME%\%ARCH%\flow\bin\trisim.exe');
elseif exist([getenv('D3D_HOME') '\' getenv('ARCH') '\flow\bin\delftflow.exe'],'file')
    fprintf(fid,'%s\n',['set runid=' runid]);
    fprintf(fid,'%s\n',['set exedir=' getenv('D3D_HOME') '\' getenv('ARCH') '\flow\bin\']);
    fprintf(fid,'%s\n','set argfile=delft3d-flow_args.txt');
    fprintf(fid,'%s\n','echo -r %runid% >%argfile%');
    fprintf(fid,'%s\n','%exedir%\delftflow.exe %argfile% dummy delft3d');
end

fclose(fid);
