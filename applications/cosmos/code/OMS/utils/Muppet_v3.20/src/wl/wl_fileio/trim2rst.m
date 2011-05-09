function trim2rst(trim,i,rst)
%TRIM2RST Extract Delft3D-FLOW restart file from TRIM-file
%
%      TRIM2RST(TRIMFILE,i,ResartFilename)
%      Read data for time step i from TRIM-file and write
%      data to specified Delft3D-FLOW restart file. The
%      TRIM-file can be specified by means of its name or
%      data structure obtained from VS_USE.
%
%      TRIM2RST(timestep,TRIRSTFILE)
%      Use the last opened nefis file.

% (c) 2003  WL | Delft Hydraulics
% Author: H.R.A. Jagers
% Date: July 31, 2003

if nargin==2
  rst=i;
  i=trim;
  trim=vs_use('lastread');
end
if ischar(trim)
  trim=vs_use(trim);
end
if ~isstruct(trim) | ~isfield(trim,'SubType') | ~isequal(trim.SubType,'Delft3D-trim')
  error('Invalid TRIM-file specified.');
end
if ~ischar(rst)
  error('Invalid restart file name specified.');
end

C=vs_get(trim,'map-series',{i},'*','nowarn');

c={};
c{1}=C.S1';
i=1;
kmax=size(C.U1,3);
for k=1:kmax,
  i=i+1;
  c{i}=C.U1(:,:,k)';
end
for k=1:kmax,
  i=i+1;
  c{i}=C.V1(:,:,k)';
end
if ~isequal(size(C.R1),[1 1])
  for s=1:size(C.R1,4)
    for k=1:kmax,
      i=i+1;
      c{i}=C.R1(:,:,k,s)';
    end
  end
end
if ~isequal(size(C.RTUR1),[1 1])
  for s=1:size(C.RTUR1,4)
    for k=1:kmax+1,
      i=i+1;
      c{i}=C.RTUR1(:,:,k,s)';
    end
  end
end
if ~isequal(size(C.UMNLDF),[1 1]) & ~isempty(C.UMNLDF)
  i=i+1;
  c{i}=C.UMNLDF';
  i=i+1;
  c{i}=C.VMNLDF';
else
  i=i+1;
  c{i}=0*C.S1';
  i=i+1;
  c{i}=0*C.S1';
end

trirst('write',rst,c{:})
