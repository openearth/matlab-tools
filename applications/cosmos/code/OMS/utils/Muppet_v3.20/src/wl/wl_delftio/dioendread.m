function flag=dioendread(dsh)
%DIOENDREAD  End reading from DelftIO stream.
%        Flag=DIOENDREAD(dsh)

dio_core('endread',dsh);
