function flag=diostartwrite(dsh)
%DIOSTARTWRITE  Start writing to DelftIO stream.
%        Flag=DIOSTARTWRITE(dsh)

flag=dio_core('startwrite',dsh);
