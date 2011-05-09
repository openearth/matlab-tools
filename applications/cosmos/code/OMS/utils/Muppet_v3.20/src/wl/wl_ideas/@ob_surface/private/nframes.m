function N=nframes(Info),
% determine the maximum number of frames

N=Info.XStream.NumberOfFields;
N=max(N,Info.YStream.NumberOfFields);
N=max(N,Info.ZStream.NumberOfFields);
if ~ischar(Info.CStream),
  N=max(N,Info.CStream.NumberOfFields);
end;
