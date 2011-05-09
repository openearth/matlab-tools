function out1dv(filename,group,fld,thr)
%OUT1DV Plot data based on Tekal formatted 1DV output file
%       OUT1DV
%       Make plots using user interface
%
%       OUT1DV(FileName,Group,Fld,ClassThresholds)
%       Plot for given file from the specified group (TURB,
%       CONC or SEDR) the specified datafield (number) using
%       the specified thresholds for the contours.
%

% 1/6/2001 : created by Bert Jagers

UI=1;
if nargin==0
  [fn,pn]=uigetfile('out1dv.*');
  if ~ischar(pn), return; end
  filename=[pn fn];
elseif nargin>=3
  UI=0;
end
if isstruct(filename)
  f=filename;
  filename=f.FileName;
else
  f=tekal('open',filename);
end
[pn,fn,ex]=fileparts(filename);
%
%  File contents:
%  Records with the following names
%
%    'IN01'  \
%    'CO01'  |  repeated NTimes: IN01,CO01,SR01,IN02,CO02,SR02,...
%    'SR01'  /
%    'TURB'
%    'CONC'
%    'SEDR'
%    'GRID'
%
NTimes=(length(f.Field)-4)/3;
%
%  Per timestep:
%     IN__        NLayers-1, 1+NTurbQuant
%       column 1: z-coordinate layer interface
%     CO__        NLayers  , 1+NConcQuant
%       column 1: z-coordinate concentration point
%     SR__        NLayers  , 1+NSedQuant
%       column 1: relative z-coordinate
%
%  Final datablocks
%     TURB     2+NTurbQuant, NLayers-1, NTimes
%       column 1: time (minutes)
%       column 2: z-coordinate layer interface
%     CONC     2+NConcQuant, NLayers  , NTimes
%       column 1: time (minutes)
%       column 2: z-coordinate concentration point
%     SEDR     2+NSedQuant , NLayers  , NTimes
%       column 1: time (minutes)
%       column 2: z-coordinate concentration point
%     GRID     NTimes , 6
%       column 1: time (minutes)
%       column 2: Depth value
%       column 3: Free water surface
%       column 4: Depth averaged velocity
%       column 5: Calculated depth averaged velocity
%       column 6: Difference UREAL - UMEAN for depth averaged velocity
%
qntgrp={f.Field(1:3).ColLabels};
qntgrp{1}(1)=[]; qntgrp{2}(1)=[]; qntgrp{3}(1)=[];
qnts=cat(1,qntgrp{:});
%
% Look for TUNIT :
%
tunit='min';
for i=1:length(f.Field(1).Comments)
  if ~isempty(findstr(f.Field(1).Comments{i},'TUNIT :'))
    j=findstr(f.Field(1).Comments{i},'TUNIT :');
    tunit=lower(f.Field(1).Comments{i}(j+8:end));
  end
end
while 1,
  %
  % Select qntgrp
  %
  if UI
    qnt=ui_type('Plot quantity',qnts);
    if isempty(qnt)
      return
    end
    %
    % Find group and quantity index
    %
    for group=1:3
      fld=strmatch(qnt,qntgrp{group},'exact');
      if ~isempty(fld)
        break
      end
    end
    fld=fld+2;
    group=group+NTimes*3;
  else
    group=strmatch(upper(group),{'TURB','CONC','SEDR'})+NTimes*3;
    qnt=f.Field(group).ColLabels{fld};
  end
  %
  % Load data
  %
  data=tekal('read',f,group);
  val=data(:,:,fld);
  minval=min(val(:));
  maxval=max(val(:));
  if nargin<4
    thr=minval+(0:.1:1)*(maxval-minval);
  end
  figure('color','w');
  [c,h]=contourf(data(:,:,1),data(:,:,2),val,thr);
  for i=1:length(h), set(h(i),'cdata',max(find(thr<=get(h(i),'cdata')))); end
  set(gca,'layer','top');
  set(h,'edgecolor','none');
  title(sprintf('%s (%s)',qnt,ex(2:end)))
  xlabel(['[',tunit,'] \rightarrow'])
  ylabel('[m] \rightarrow')
  classbar(colorbar,1:length(thr),'label',thr);
  if ~UI, return; end
end