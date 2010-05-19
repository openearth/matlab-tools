function ddb_okadadef_OnOff()
global Mw        lat_epi     lon_epi    fdtop      totflength fwidth   disloc     foption

h1 = findobj(gcbo);
ival = get(h1,'Value');

nsg = str2num(get(findobj(gcf,'tag','Nseg'), 'string'));
if (isempty(nsg))
   nsg = 0;
end
if (ival == 0.0)
  set(h1,'tag','SeismoOkada','string','Fault unrelated to epicentre','SelectionHighlight','off');
  foption='Fault unrelated to EQ';
else
  if (nsg == 1)
     set(h1,'tag','SeismoOkada','string','Centre fault around epicentre','SelectionHighlight','on');
     foption='Centre Fault around EQ epicentre';
  elseif (nsg==0)
     set(h1,'Value',0)
     foption='Fault unrelated to EQ';
  end
end
