function ddb_writeBatchFile(runid)

fid=fopen('batch_flw.bat','w');


if exist([getenv('D3D_HOME') '\' getenv('ARCH') '\flow\bin\deltares_hydro.exe'],'file')

    % New open-source version
    fprintf(fid,'%s\n','@ echo off');
    fprintf(fid,'%s\n','set argfile=config_flow2d3d.ini');
    fprintf(fid,'%s\n',['set exedir=' getenv('D3D_HOME') '\' getenv('ARCH') '\flow\bin\']);
    fprintf(fid,'%s\n','set PATH=%exedir%;%PATH%');
    fprintf(fid,'%s\n','%exedir%\deltares_hydro.exe %argfile%');

    % Write config file    
    fini=fopen('config_flow2d3d.ini','w');
    fprintf(fini,'%s\n','[FileInformation]');
    fprintf(fini,'%s\n',['   FileCreatedBy    = ' getenv('USERNAME')]);
    fprintf(fini,'%s\n',['   FileCreationDate = ' datestr(now)]);
    fprintf(fini,'%s\n','   FileVersion      = 00.01');
    fprintf(fini,'%s\n','[Component]');
    fprintf(fini,'%s\n','   Name                = flow2d3d');
    fprintf(fini,'%s\n',['   MDFfile             = ' runid]);
    fclose(fini);

else
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
end

fclose(fid);
