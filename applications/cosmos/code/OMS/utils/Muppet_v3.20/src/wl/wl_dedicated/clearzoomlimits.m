function clearzoomlimits
%CLEARZOOMLIMITS  Clear the zoom limits for zooming out

if isappdata(get(gca,'zlabel'),'ZOOMAxesData')
  rmappdata(get(gca,'zlabel'),'ZOOMAxesData')
end