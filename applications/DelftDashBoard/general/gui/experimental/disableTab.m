function disableTab(fig,tab)
ii=find(tab=='.');
ii=ii(end);
panel=tab(1:ii-1);
tab=tab(ii+1:end);
h=findobj(fig,'Tag',panel);
usd=get(h,'UserData');
ii=strmatch(tab,usd.tabNames);
set(usd.tabTextHandles(ii),'Enable','off');
% Check to see if the disabled tab was the active tab. If so, switch to the
% first available enabled tab.
if ii==usd.activeTab
    for i=1:length(usd.tabHandles)
        enab=get(usd.tabTextHandles(i),'Enable');
        if ~strcmpi(enab,'off')
            tabpanel('select','tag',panel,'tabname',usd.tabNames{i},'runcallback',0);
            break
        end
    end
end
