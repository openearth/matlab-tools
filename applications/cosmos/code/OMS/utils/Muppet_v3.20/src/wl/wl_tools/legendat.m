function h=legendat(varargin);
%LEGENDAT  Plots legend at specified location
%      LEGENDAT(hAxes,...)
%      plots the legend at the location of the
%      specified axes object (does not use or
%      delete the specified axes object)
%
%      LEGENDAT(Units,Pos,...)
%      plots the legend at the specified
%      position expressed in the specified units.
%
%      LEGENDAT({m,n,p},...)
%      plots the legend at the location of
%      subplot(m,n,p).
%
%      The other input arguments are passed to
%      the LEGEND function. For a description of
%      these parameters see the help of LEGEND.
%      Do not use the location specifier of the
%      LEGEND function.

if ischar(varargin{1})
  i=3;
  unit=varargin{1};
  pos=varargin{2};
  if ~strcmp(unit,'points')
    h=axes('position',[0 0 0 0]);
    set(h,'units',unit,'position',pos)
    set(h,'units','points')
    pos=get(h,'position');
    delete(h)
  end
else
  i=2;
  h=varargin{1};
  delh=0;
  if iscell(h)
    h=subplot(h{:});
    delh=1;
  end
  un=get(h,'units');
  set(h,'units','points')
  pos=get(h,'position');
  set(h,'units',un)
  if delh
    delete(h)
  end
end
[h,o]=legend(varargin{3:end},pos);
set([h;findall(h)],'buttondownfcn','')