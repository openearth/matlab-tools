function handles=ddb_deleteMenuItem(handles,menu1,menu2)

HandleName=menu2;

h=findobj(gcf,'Type','uimenu','Tag',['Menu' menu1]);

menu1=strrep(menu1,' ','');
menu1=strrep(menu1,'.','');
menu1=strrep(menu1,'-','');
menu1=strrep(menu1,'/','');
HandleName=strrep(HandleName,' ','');
HandleName=strrep(HandleName,'.','');
HandleName=strrep(HandleName,'-','');
HandleName=strrep(HandleName,'/','');

tg=['Menu' menu1 HandleName];
delete(findobj(h,'tag',tg));
