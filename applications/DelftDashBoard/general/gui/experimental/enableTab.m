function enableTab(fig,tab)
ii=find(tab=='.');
ii=ii(end);
panel=tab(1:ii-1);
tab=tab(ii+1:end);
h=findobj(fig,'Tag',panel);
usd=get(h,'UserData');
ii=strmatch(tab,usd.tabNames);
set(usd.tabTextHandles(ii),'Enable','inactive');
