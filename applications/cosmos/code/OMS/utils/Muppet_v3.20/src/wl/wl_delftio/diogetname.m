function out=diogetname(dsh)
%DIOGETNAME Retrieve the name of the DelftIO stream.
%        Name = DIOGETNAME(dsh)

Name = dio_core('getname',dsh);
if nargout==0
   disp(Name);
else
   out=Name;
end
