function dsh=dionew(Name,nBytes)
%DIONEW  Create new DelftIO stream.
%        dsh = DIONEW(Name,nBytes) for putter.
%        dsh = DIONEW(Name) for getter.

if nargin==2
  % putter
  dsh = dio_core('newput',nBytes,Name);
elseif nargin==1
  % getter
  dsh = dio_core('newget',Name);
else
  error('Not enough input arguments.');
end