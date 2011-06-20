function avi_break,
% AVI_BREAK breaks the creation of an AVI movie
%       no animation is created.

global AVI_animation
if isstruct(AVI_animation),
  Succes=avi_write;
  if Succes<0, % if doesn't go the nice way, do it the ugly way ...
    fclose(AVI_animation.fid);
    clear global AVI_animation
    fprintf(1,'AVI file creation interrupted, created file will be corrupt.\n');
  end;
else,
  AVIid=-1;
  fprintf(1,'No AVI file creation in progress.\n');
  return;
end;