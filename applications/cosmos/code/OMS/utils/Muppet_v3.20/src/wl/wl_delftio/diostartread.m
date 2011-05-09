function flag=diostartread(dsh)
%DIOSTARTREAD  Start reading from DelftIO stream.
%        Flag=DIOSTARTREAD(dsh)

flag=dio_core('startread',dsh);
