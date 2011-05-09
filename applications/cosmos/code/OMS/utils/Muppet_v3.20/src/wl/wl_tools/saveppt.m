%function SAVEPPT(filespec) saves the current Matlab
%  figure window to a PowerPoint file designated by
%  filespec.  If filespec is omitted, the figure is
%  saved to a default PowerPoint file.  If the path
%  is omitted from filespec, the PowerPoint file is
%  created in the current Matlab working directory.
%  The default Powerpoint file is C:\MATLAB01.PPT.

%Ver 1.0, Copyright 1998, Mark W. Brown, Northgrop Grumman

function saveppt(filespec)

% Default PowerPoint file:
default_file = 'c:\matlab01.ppt';

% Establish valid file name:
if nargin<1 | isempty(filespec);
  filespec = default_file;
  fprintf(1,'saving figure to "%s"\n',default_file)
else
  [fpath,fname,fext] = fileparts(filespec);
  if isempty(fpath); fpath = pwd; end
  if isempty(fext); fext = '.ppt'; end
  filespec = fullfile(fpath,[fname,fext]);
end

% Capture current figure into clipboard:
print -dmeta

% Start an ActiveX session with PowerPoint:
ppt = actxserver('PowerPoint.Application');
ppt.Visible = 1;

if ~exist(filespec,'file');
  % Create new presentation:
  op = invoke(ppt.Presentations,'Add');
else
  % Open existing presentation:
  op = invoke(ppt.Presentations,'Open',filespec);
end

% Get current number of slides:
slide_count = get(op.Slides,'Count');

% Add a new slide:
new_slide = invoke(op.Slides,'Add',slide_count+1,12);

% Get height and width of slide:
slide_H = op.PageSetup.SlideHeight;
slide_W = op.PageSetup.SlideWidth;

% Paste the contents of the Clipboard:
pic1 = invoke(new_slide.Shapes,'Paste');

% Get height and width of picture:
pic_H = get(pic1,'Height');
pic_W = get(pic1,'Width');

% Center picture on page:
set(pic1,'Left',(slide_W - pic_W)/2);
set(pic1,'Top',(slide_H - pic_H)/2);

if ~exist(filespec,'file')
  % Save file as new:
  invoke(op,'SaveAs',filespec,1);
else
  % Save existing file:
  invoke(op,'Save');
end

% Close the presentation window:
invoke(op,'Close');

% Quit PowerPoint
invoke(ppt,'Quit');

% Close PowerPoint and terminate ActiveX:
delete(ppt);

return