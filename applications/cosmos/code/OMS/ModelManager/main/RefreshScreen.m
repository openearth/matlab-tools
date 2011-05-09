function RefreshScreen

hm=guidata(findobj('Tag','MainWindow'));

i=hm.ActiveModel;
j=hm.ActiveContinent;

if hm.Continents(j).NrModels>0

    set(hm.ListModels1       ,'Enable','on');
%     set(hm.ListModels2       ,'Enable','on');
%     set(hm.SelectContinents2 ,'Enable','on');
    set(hm.EditName          ,'Enable','on');
    set(hm.EditAbbr          ,'Enable','on');
    set(hm.EditRunid         ,'Enable','on');
    set(hm.SelectContinent   ,'Enable','on');
    set(hm.EditPosition1     ,'Enable','on');
    set(hm.EditPosition2     ,'Enable','on');
    set(hm.SelectSize        ,'Enable','on');
    set(hm.EditXLim1         ,'Enable','on');
    set(hm.EditXLim2         ,'Enable','on');
    set(hm.EditYLim1         ,'Enable','on');
    set(hm.EditYLim2         ,'Enable','on');
    set(hm.SelectPriority    ,'Enable','on');
    set(hm.ToggleNesting     ,'Enable','on');
    set(hm.EditSpinUp        ,'Enable','on');
    set(hm.EditRunTime       ,'Enable','on');
    set(hm.EditTimeStep      ,'Enable','on');
    set(hm.EditMapTimeStep   ,'Enable','on');
    set(hm.EditHisTimeStep   ,'Enable','on');
    set(hm.EditComTimeStep   ,'Enable','on');

    set(hm.ListModels1,'String',hm.Continents(j).ModelNames);
%     set(hm.ListModels2,'String',hm.Continents(j).ModelNames);

    n=strmatch(hm.Models(i).Name,hm.Continents(j).ModelNames,'exact');
    if isempty(n)
        hm.ActiveModel=hm.Continents(j).Models(1);
        i=hm.ActiveModel;
        n=1;
    end
    set(hm.ListModels1,'Value',n);

    ii=1;
    switch lower(hm.Models(i).Type)
        case{'delft3dflow'}
            ii=1;
        case{'delft3dflowwave'}
            ii=2;
        case{'ww3'}
            ii=3;
        case{'xbeach'}
            ii=4;
    end
    set(hm.SelectType,'Value',ii);
        
%     if hm.Models(i).Nested
%         if ~isempty(hm.Models(i).NestModel)
%             n=strmatch(hm.Models(i).NestModel,hm.Continents(j).ModelAbbrs,'exact');
%         else
%             n=1;
%             hm.Models(i).NestModel=hm.Continents(j).ModelAbbrs{1};
%         end
%     else
%         hm.Models(i).NestModel=[];
%         n=1;
%     end
%     set(hm.ListModels2,'Value',n);
% 
%     if hm.Models(i).Nested
%         set(hm.SelectContinents2,'Enable','on');
%         set(hm.ListModels2,'Enable','on');
%     else
%         set(hm.SelectContinents2,'Enable','off');
%         set(hm.ListModels2,'Enable','off');
%     end
% 
    set(hm.EditName       ,'String',hm.Models(i).Name);
    set(hm.EditAbbr       ,'String',hm.Models(i).Abbr);
    set(hm.EditRunid      ,'String',hm.Models(i).Runid);
    icont=strmatch(hm.Models(i).Continent,hm.ContinentAbbrs,'exact');
    set(hm.SelectContinent,'Value',icont);
    set(hm.EditPosition1  ,'String',num2str(hm.Models(i).Location(1)));
    set(hm.EditPosition2  ,'String',num2str(hm.Models(i).Location(2)));
    set(hm.SelectSize     ,'Value' ,hm.Models(i).Size);
    set(hm.EditXLim1      ,'String',num2str(hm.Models(i).XLim(1)));
    set(hm.EditXLim2      ,'String',num2str(hm.Models(i).XLim(2)));
    set(hm.EditYLim1      ,'String',num2str(hm.Models(i).YLim(1)));
    set(hm.EditYLim2      ,'String',num2str(hm.Models(i).YLim(2)));
    set(hm.SelectPriority ,'Value' ,hm.Models(i).Priority+1);
    set(hm.ToggleNesting  ,'Value' ,hm.Models(i).Nested);
    set(hm.EditSpinUp     ,'String',num2str(hm.Models(i).SpinUp));
    set(hm.EditRunTime    ,'String',num2str(hm.Models(i).RunTime));
    set(hm.EditTimeStep   ,'String',num2str(hm.Models(i).TimeStep));
    set(hm.EditMapTimeStep,'String',num2str(hm.Models(i).MapTimeStep));
    set(hm.EditHisTimeStep,'String',num2str(hm.Models(i).HisTimeStep));
    set(hm.EditComTimeStep,'String',num2str(hm.Models(i).ComTimeStep));

else
    set(hm.ListModels1       ,'String',' ','Enable','off','Value',1);
%     set(hm.ListModels2       ,'String',' ','Enable','off','Value',1);
%     set(hm.SelectContinents2 ,'Value',j   ,'Enable','off');
    set(hm.EditName          ,'String','','Enable','off');
    set(hm.EditAbbr          ,'String','','Enable','off');
    set(hm.EditRunid         ,'String','','Enable','off');
    set(hm.SelectContinent   ,'Value',j  ,'Enable','off');
    set(hm.EditPosition1     ,'String','','Enable','off');
    set(hm.EditPosition2     ,'String','','Enable','off');
    set(hm.SelectSize        ,'Value' ,1 ,'Enable','off');
    set(hm.EditXLim1         ,'String','','Enable','off');
    set(hm.EditXLim2         ,'String','','Enable','off');
    set(hm.EditYLim1         ,'String','','Enable','off');
    set(hm.EditYLim2         ,'String','','Enable','off');
    set(hm.SelectPriority    ,'Value' ,1 ,'Enable','off');
    set(hm.ToggleNesting     ,'Value' ,0 ,'Enable','off');
    set(hm.EditSpinUp        ,'String','','Enable','off');
    set(hm.EditRunTime       ,'String','','Enable','off');
    set(hm.EditTimeStep      ,'String','','Enable','off');
    set(hm.EditMapTimeStep   ,'String','','Enable','off');
    set(hm.EditHisTimeStep   ,'String','','Enable','off');
    set(hm.EditComTimeStep   ,'String','','Enable','off');
end

guidata(gcf,hm);

			     