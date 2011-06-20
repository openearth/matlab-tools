function Output=specdir(dirpath,filetype,dirofdirpath),
% SPECDIR returns all files of specified type
%       SPECDIR returns a cell array containing
%       all filetypes supported by this function.
%       SPECDIR(DIRECTORY,FILETYPE) returns all
%       files in the specified DIRECTORY of the
%       requested FILETYPE in a cell array.

switch nargin,
case 0,
%  Output={'nefis file', ...
%          'TEKAL file', ...
%          'Delft3D grid file', ...
%          'Delft3D bottom file', ...
%          'morf file', ...
%          'arcinfo file', ...
%          'arcgrid file', ...
%          'mike 21 file', ...
%          'FLS mdf file', ...
%          'FLS output file', ...
%          'MORSYS output file', ...
%          'AVS file', ...
%          'CFX file'};
  Output={'nefis file', ...
          'incremental file', ...
          'FLS mdf file'};
case 1,
  error('Unexpected number of arguments.');
case {2,3},
  if ~ischar(filetype) | ndims(filetype)~=2 | size(filetype,1)~=1,
    error('Second parameter must be a FILETYPE string');
  end;
  if nargin==2,
    dirofdirpath=dir(dirpath);
  end;

  switch filetype,
  case 'nefis file',
    DATDEFfiles=NefisCheck(dirofdirpath,'','dat','def');
    COMfiles=GetFilesMatching(DATDEFfiles,'com-*.dat');
    TRIDfiles=GetFilesMatching(DATDEFfiles,'trid-*.dat');
    TRIHfiles=GetFilesMatching(DATDEFfiles,'trih-*.dat');
    TRIMfiles=GetFilesMatching(DATDEFfiles,'trim-*.dat');
    TRAHfiles=GetFilesMatching(DATDEFfiles,'trah-*.dat');
    TRAMfiles=GetFilesMatching(DATDEFfiles,'tram-*.dat');
    BOTHfiles=GetFilesMatching(DATDEFfiles,'both-*.dat');
    BOTMfiles=GetFilesMatching(DATDEFfiles,'botm-*.dat');
    HWGXYfiles=GetFilesMatching(DATDEFfiles,'hwgxy*.dat');
    BAGRfiles=GetFilesMatching(DATDEFfiles,'bagr-*.dat');
    DATDEFfiles=NefisCheck(dirofdirpath,'','?da','?df');
    SobekRfiles=GetFilesMatching(DATDEFfiles,'*.rda');
    SobekMfiles=GetFilesMatching(DATDEFfiles,'*.mda');
    SobekOfiles=GetFilesMatching(DATDEFfiles,'*.oda');
    Output=[COMfiles TRIDfiles TRIHfiles TRIMfiles TRAHfiles TRAMfiles BOTHfiles BOTMfiles BAGRfiles ...
            HWGXYfiles SobekRfiles SobekMfiles SobekOfiles];
  case 'TEKAL file',
    Output=GetFilesMatching(dirofdirpath, ['*']);
  case 'Delft3D grid file',
    Output=GetFilesMatching(dirofdirpath, ['*.grd']);
  case 'Delft3D bottom file',
    Output=GetFilesMatching(dirofdirpath, ['*.dep']);
  case 'morf file',
    Output=GetFilesMatching(dirofdirpath, ['morf.*']);
  case 'FLS mdf file',
    Output=GetFilesMatching(dirofdirpath, ['*.mdf']);
  case 'arcinfo file',
    ARCdirs=GetFilesMatching(dirofdirpath, ['arc.dir']);
    E00files=GetFilesMatching(dirofdirpath, ['*.E00']);
    Output=[ARCdirs E00files];
  case 'arcgrid file',
    Output=GetFilesMatching(dirofdirpath, ['*.a*']);
  case 'mike 21 file',
    Output=MikeCheck(dirofdirpath,'ct2','dt2');
  case 'incremental file',
    Output=GetFilesMatching(dirofdirpath, ['*.inc']);
  case 'FLS output file',
    BINfiles=GetFilesMatching(dirofdirpath, ['*.bin']);
    CRSfiles=GetFilesMatching(dirofdirpath, ['*.crs']);
    HISfiles=GetFilesMatching(dirofdirpath, ['*.his']);
    INCfiles=GetFilesMatching(dirofdirpath, ['*.inc']);
    AMfiles=GetFilesMatching(dirofdirpath, ['*.am?']);
    Output=[BINfiles CRSfiles HISfiles INCfiles AMfiles];
  case 'MORSYS output file',
    DATDEFfiles=NefisCheck(dirofdirpath,'','dat','def');
    COMfiles=GetFilesMatching(DATDEFfiles,'com-*.dat');
    TRIHfiles=GetFilesMatching(DATDEFfiles,'trih-*.dat');
    TRIMfiles=GetFilesMatching(DATDEFfiles,'trim-*.dat');
    TRAHfiles=GetFilesMatching(DATDEFfiles,'trah-*.dat');
    TRAMfiles=GetFilesMatching(DATDEFfiles,'tram-*.dat');
    BOTHfiles=GetFilesMatching(DATDEFfiles,'both-*.dat');
    BOTMfiles=GetFilesMatching(DATDEFfiles,'botm-*.dat');
    Output=[COMfiles TRIHfiles TRIMfiles TRAHfiles TRAMfiles BOTHfiles BOTMfiles ];
  case 'AVS file',
    FLDfiles=GetFilesMatching(dirofdirpath, ['*.fld']);
    INPfiles=GetFilesMatching(dirofdirpath, ['*.inp']);
    Output=[FLDfiles INPfiles];
  case 'CFX file',
    DMPfiles=GetFilesMatching(dirofdirpath, ['*.dmp']);
    FOfiles=GetFilesMatching(dirofdirpath, ['*.fo']);
    GEOfiles=GetFilesMatching(dirofdirpath, ['*.geo']);
    Output=[DMPfiles FOfiles GEOfiles];
  otherwise,
    error(['Filetype ',filetype,' not supported.']);
  end;
end;

function F=GetFilesMatching(dirofdirpath,filemask,casesens);
if nargin<3
  casesens=0;
end
if isstruct(dirofdirpath), % raw output of dir
  F={dirofdirpath(~[dirofdirpath(:).isdir]).name};
  if isnumeric(F{1}), % F={[]}
    F={};
  end;
else, % cell array
  F=dirofdirpath;
end;
if ~casesens
  F=lower(F);
end
I=wildstrmatch(filemask,F);
F=F(I);


function F=NefisCheck(dirofdirpath,base,ext1,ext2),
COMDATfiles=GetFilesMatching(dirofdirpath ,[base '*.' ext1]);
COMDEFfiles=GetFilesMatching(dirofdirpath ,[base '*.' ext2]);
i=1;
while i<=length(COMDATfiles),
  COMDAT=COMDATfiles{i};
  if isempty(strmatch([COMDAT(1:(end-length(ext1))) ext2],COMDEFfiles,'exact')),
    COMDATfiles(i)=[];
  else,
    i=i+1;
  end;
end;
F=COMDATfiles;


function F=MikeCheck(dirofdirpath,ext1,ext2),
CTfiles=GetFilesMatching(dirofdirpath, ['*.' ext1]);
DTfiles=GetFilesMatching(dirofdirpath, ['*.' ext2]);
i=1;
while i<=length(CTfiles),
  CT=CTfiles{i};
  if isempty(strmatch([CT(1:(end-length(ext1))) ext2],DTfiles,'exact')),
    CTfiles(i)=[];
  else,
    i=i+1;
  end;
end;
F=CTfiles;
