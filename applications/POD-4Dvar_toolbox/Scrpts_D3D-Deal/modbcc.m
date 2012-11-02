function [st] = modbcc(bccPath, time0,timef)
%MODBCC Reads and modifies the content of BCC files for Delft3D runs. 
%    MODBCC(bccPath,time0,timef) 'BCCPATH' is a string with 
%    the full path of the bcc file that is going to be read. 'TIDALTIMES'
%    is a number with, usually, the simulation time of the model. It turns
%    out that the boundary conditions are not properly updated by the GUI
%    when a modification is done in the MDF file. This guarantees that the
%    boundary conditions are always properly defined; avoiding the Delft3D
%    sadly recurrent error:
%        
%     "  *** ERROR Last time time dependent data < Simulation stop time "
%
%    MODBCC returns a boolean flag: 1 for modification succesful and 0 for
%    modification unsuccesful.
    
    if (bccPath(end-3)~='.'), bccPath = [bccPath,'.bcc']; end

    %Modify start and stop times also in the boundary conditions file.
    bcc=textread(bccPath,'%s','delimiter',char(10));
    id = find(strncmpi(bcc,'records-in-table',16));
    
    for i=1:1:size(id,1), 
        bcc{id(i)+1} = [' ' num2str(time0,'%12.7e') '  ' num2str(0,'%12.7e') '  ' num2str(0,'%12.7e')]; 
        bcc{id(i)+2} = [' ' num2str(timef,'%12.7e') '  ' num2str(0,'%12.7e') '  ' num2str(0,'%12.7e')]; 
    end
    
    fid = fopen(bccPath,'w');
    for kk = 1:length(bcc), fprintf(fid,'%s\n',bcc{kk}); end
    st = fclose(fid);