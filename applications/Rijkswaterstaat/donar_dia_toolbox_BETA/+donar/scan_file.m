function Blocks = scan_file(diafile,varargin)
%scan_file scans an entire donar file: all blocks
%
% Blocks = scan_file(diafile) scans all blocks
% of an entire donar file, by alternatingly calling
% donar.read_header() and donar.scan_block(). Blocks
% contains the ftell positions of al headers and blokcs
% to allow direct access of those headers and blocks.
% * ftell  - [ftell_header ftell_block]
% * nlines - number of ascii lines
% * nval   - number of data tuples :-separated (x,y,t,value)
%
%See also: read_header, scan_block

OPT.disp = 100;

OPT = setproperty(OPT,varargin);

fid = fopen(diafile,'r');
[hdr,boh] = donar.read_header(fid);
i   = 0; % block counter
if OPT.disp > 0
disp([mfilename,' scanning ',diafile]) % in case one of first OPT.disp blocks is BIG
end
while ~isnumeric(hdr)
   i = i + 1;
   Blocks(i).index    = i;
   Blocks(i).hdr      = hdr;
   Blocks(i).ftell(1) = boh;
  [Blocks(i).nline,...
   Blocks(i).nval, ...
   Blocks(i).ftell(2)] = donar.scan_block (fid,'rewind',0);
  [hdr,boh]            = donar.read_header(fid);
  if mod(i,OPT.disp)==0
  disp([mfilename,' scanned block ',num2str(i)])
  end
end
fclose(fid);
if OPT.disp > 0
  disp([mfilename,' # of blocks = ',num2str(i)])
  disp([mfilename,' # of values = ',num2str(sum([Blocks.nval]))]) 
end