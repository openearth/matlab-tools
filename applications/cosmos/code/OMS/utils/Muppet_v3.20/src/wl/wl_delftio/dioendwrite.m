function flag=dioendwrite(dsh)
%DIOENDWRITE  End writing to DelftIO stream.
%        Flag=DIOENDWRITE(dsh)

dio_core('endwrite',dsh);
