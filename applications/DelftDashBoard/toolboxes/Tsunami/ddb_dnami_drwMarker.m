function ddb_dnami_drwMarker()
%
global Mw        lat_epi     lon_epi    fdtop     totflength  fwidth   disloc    foption
global iarea     filearea    xareaGeo   yareaGeo  overviewpic fltpatch mrkrpatch
global xgrdarea  ygrdarea

yg = get(findobj('Tag','EQLat'),'string');
xg = get(findobj('Tag','EQLon'),'string');
ok = 1;

if (~isempty(xg))
   lon_epi = str2num(xg);
   if lon_epi > xgrdarea(2) | lon_epi < xgrdarea(1)
      lon_epi = 0.;
      ok = 0;
      set(findobj('Tag','EQLon'),'string','');
      errordlg(['Value must be between ' num2str(xgrdarea(1)) ' and ' num2str(xgrdarea(2))])
   end
else
   ok = 0;
end

if (~isempty(yg))
   lat_epi = str2num(yg);
   if lat_epi > ygrdarea(2) | lat_epi < ygrdarea(1)
      lat_epi = 0.;
      ok = 0;
      set(findobj('Tag','EQLat'),'string','');
      errordlg(['Value must be between ' num2str(ygrdarea(1)) ' and ' num2str(ygrdarea(2))])
   end
else
   ok = 0;
end
if ok
   fig2 = (findobj('tag','Figure2'));
   if (~isempty(fig2))
      figure(fig2);
      try
        delete(mrkrpatch)
      end
      mrkrpatch = patch(lon_epi,lat_epi,'r','LineWidth', 3,'Marker','p','MarkerEdgeColor','r');
   else
      warndlg('To draw epicenter Load Area first');
      return
   end
end
