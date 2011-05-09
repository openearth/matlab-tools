function refreshall,
%REFRESHALL Refresh all figure.
%    REFRESHALL causes all figures to be redrawn.

AllFigs=allchild(0);
for h=AllFigs,
  refresh(h);
end;