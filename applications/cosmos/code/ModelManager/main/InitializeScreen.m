function InitializeScreen

hm=guidata(findobj('Tag','MainWindow'));

bckcol=get(gcf,'Color');

hm.ActiveModel=1;
hm.ActiveContinent=1;

hm.SelectContinents1 = uicontrol(gcf,'Style','popupmenu','Position',[ 30 435  195 20],'String',hm.ContinentNames,'BackgroundColor',[1 1 1],'Tag','UIControl');
% hm.SelectContinents2 = uicontrol(gcf,'Style','popupmenu','Position',[520 435  195 20],'String',hm.ContinentNames,'BackgroundColor',[1 1 1],'Tag','UIControl');
hm.ListModels1 = uicontrol(gcf,'Style','listbox','Position',[ 30  30 195 400],'String',hm.Continents(1).ModelNames,'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
% hm.ListModels2 = uicontrol(gcf,'Style','listbox','Position',[520 230 195 200],'String',hm.Continents(1).ModelNames,'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');

hm.EditName       = uicontrol(gcf,'Style','edit','Position',[330 460 100 20],'String','','HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
str={'Delft3D-FLOW','Delft3D-FLOW/WAVE','Wavewatch III','X-Beach'};
hm.SelectType     = uicontrol(gcf,'Style','popupmenu','Position',[330 435 130 20],'String',str,'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
hm.EditAbbr       = uicontrol(gcf,'Style','edit','Position',[330 410 100 20],'String','','HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
hm.EditRunid      = uicontrol(gcf,'Style','edit','Position',[330 385 100 20],'String','','HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
hm.SelectContinent= uicontrol(gcf,'Style','popupmenu','Position',[330 360 100 20],'String',hm.ContinentNames,'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
hm.EditPosition1  = uicontrol(gcf,'Style','edit','Position',[330 335  45 20],'String','','HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
hm.EditPosition2  = uicontrol(gcf,'Style','edit','Position',[385 335  45 20],'String','','HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
hm.SelectSize     = uicontrol(gcf,'Style','popupmenu','Position',[330 310 100 20],'String',{'Very Large','Large','Medium','Small','Very Small'},'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
hm.EditXLim1      = uicontrol(gcf,'Style','edit','Position',[330 285  45 20],'String','','HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
hm.EditXLim2      = uicontrol(gcf,'Style','edit','Position',[385 285  45 20],'String','','HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
hm.EditYLim1      = uicontrol(gcf,'Style','edit','Position',[330 260  45 20],'String','','HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
hm.EditYLim2      = uicontrol(gcf,'Style','edit','Position',[385 260  45 20],'String','','HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
str{1}='0';
for i=1:10
    str{i+1}=num2str(i);
end    
hm.SelectPriority = uicontrol(gcf,'Style','popupmenu','Position',[330 235 100 20],'String',str,'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

hm.ToggleNesting  = uicontrol(gcf,'Style','checkbox','Position',[330 185 100 20],'String','Nested','Tag','UIControl');
hm.EditSpinUp     = uicontrol(gcf,'Style','edit','Position',[330 160 100 20],'String','','HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
hm.EditRunTime    = uicontrol(gcf,'Style','edit','Position',[330 135 100 20],'String','','HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
hm.EditTimeStep   = uicontrol(gcf,'Style','edit','Position',[330 110 100 20],'String','','HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
hm.EditMapTimeStep= uicontrol(gcf,'Style','edit','Position',[330  85 100 20],'String','','HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
hm.EditHisTimeStep= uicontrol(gcf,'Style','edit','Position',[330  60 100 20],'String','','HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
hm.EditComTimeStep= uicontrol(gcf,'Style','edit','Position',[330  35 100 20],'String','','HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

hm.TextName       = uicontrol(gcf,'Style','text','Position',[235 456 90 20],'BackgroundColor',bckcol,'String','Name','HorizontalAlignment','right','Tag','UIControl');
hm.TextAbbr       = uicontrol(gcf,'Style','text','Position',[235 406 90 20],'BackgroundColor',bckcol,'String','Abbreviation','HorizontalAlignment','right','Tag','UIControl');
hm.TextRunid      = uicontrol(gcf,'Style','text','Position',[235 381 90 20],'BackgroundColor',bckcol,'String','Runid','HorizontalAlignment','right','Tag','UIControl');
hm.TextContinent  = uicontrol(gcf,'Style','text','Position',[235 356 90 20],'BackgroundColor',bckcol,'String','Continent','HorizontalAlignment','right','Tag','UIControl');
hm.TextPosition   = uicontrol(gcf,'Style','text','Position',[235 331 90 20],'BackgroundColor',bckcol,'String','Location','HorizontalAlignment','right','Tag','UIControl');
hm.TextSize       = uicontrol(gcf,'Style','text','Position',[235 306 90 20],'BackgroundColor',bckcol,'String','Size','HorizontalAlignment','right','Tag','UIControl');
hm.TextXLim       = uicontrol(gcf,'Style','text','Position',[235 281 90 20],'BackgroundColor',bckcol,'String','X Lim','HorizontalAlignment','right','Tag','UIControl');
hm.TextYLim       = uicontrol(gcf,'Style','text','Position',[235 256 90 20],'BackgroundColor',bckcol,'String','Y Lim','HorizontalAlignment','right','Tag','UIControl');
hm.TextPriority   = uicontrol(gcf,'Style','text','Position',[235 231 90 20],'BackgroundColor',bckcol,'String','Priority','HorizontalAlignment','right','Tag','UIControl');
hm.TextSpinUp     = uicontrol(gcf,'Style','text','Position',[235 156 90 20],'BackgroundColor',bckcol,'String','Spin Up Time','HorizontalAlignment','right','Tag','UIControl');
hm.TextRunTime    = uicontrol(gcf,'Style','text','Position',[235 131 90 20],'BackgroundColor',bckcol,'String','Run Time','HorizontalAlignment','right','Tag','UIControl');
hm.TextTimeStep   = uicontrol(gcf,'Style','text','Position',[235 106 90 20],'BackgroundColor',bckcol,'String','Time Step','HorizontalAlignment','right','Tag','UIControl');
hm.TextMapTimeStep= uicontrol(gcf,'Style','text','Position',[235  81 90 20],'BackgroundColor',bckcol,'String','Map Time Step','HorizontalAlignment','right','Tag','UIControl');
hm.TextHisTimeStep= uicontrol(gcf,'Style','text','Position',[235  56 90 20],'BackgroundColor',bckcol,'String','His Time Step','HorizontalAlignment','right','Tag','UIControl');
hm.TextComTimeStep= uicontrol(gcf,'Style','text','Position',[235  31 90 20],'BackgroundColor',bckcol,'String','Com Time Step','HorizontalAlignment','right','Tag','UIControl');

hm.PushAddModel      = uicontrol(gcf,'Style','pushbutton','Position',[590  30 130  25],'String','Add Model','Tag','UIControl');
hm.PushDeleteModel   = uicontrol(gcf,'Style','pushbutton','Position',[450  30 130  25],'String','Delete Model','Tag','UIControl');
hm.PushSaveModel     = uicontrol(gcf,'Style','pushbutton','Position',[590  60 130  25],'String','Save Model','Tag','UIControl');
hm.PushSaveAllModels = uicontrol(gcf,'Style','pushbutton','Position',[450  60 130  25],'String','Save All Models','Tag','UIControl');

hm.PushTimeSeries    = uicontrol(gcf,'Style','pushbutton','Position',[590 90 130  25],'String','Time Series','Tag','UIControl');
hm.PushMaps          = uicontrol(gcf,'Style','pushbutton','Position',[450 90 130  25],'String','Maps','Tag','UIControl');

%%

set(hm.SelectContinents1,'CallBack',{@SelectContinents1_CallBack});
% set(hm.SelectContinents2,'CallBack',{@SelectContinents2_CallBack});
set(hm.ListModels1      ,'CallBack',{@ListModels1_CallBack});
% set(hm.ListModels2      ,'CallBack',{@ListModels2_CallBack});

set(hm.EditName       ,'CallBack',{@EditName_CallBack});
set(hm.SelectType     ,'CallBack',{@SelectType_CallBack});
set(hm.EditAbbr       ,'CallBack',{@EditAbbr_CallBack});
set(hm.EditRunid      ,'CallBack',{@EditRunid_CallBack});
set(hm.SelectContinent,'CallBack',{@SelectContinent_CallBack});
set(hm.EditPosition1  ,'CallBack',{@EditPosition1_CallBack});
set(hm.EditPosition2  ,'CallBack',{@EditPosition2_CallBack});
set(hm.SelectSize     ,'CallBack',{@SelectSize_CallBack});
set(hm.EditXLim1      ,'CallBack',{@EditXLim1_CallBack});
set(hm.EditXLim2      ,'CallBack',{@EditXLim2_CallBack});
set(hm.EditYLim1      ,'CallBack',{@EditYLim1_CallBack});
set(hm.EditYLim2      ,'CallBack',{@EditYLim2_CallBack});
set(hm.SelectPriority ,'CallBack',{@SelectPriority_CallBack});
set(hm.ToggleNesting  ,'CallBack',{@ToggleNesting_CallBack});
set(hm.EditSpinUp     ,'CallBack',{@EditSpinUp_CallBack});
set(hm.EditRunTime    ,'CallBack',{@EditRunTime_CallBack});
set(hm.EditTimeStep   ,'CallBack',{@EditTimeStep_CallBack});
set(hm.EditMapTimeStep,'CallBack',{@EditMapTimeStep_CallBack});
set(hm.EditHisTimeStep,'CallBack',{@EditHisTimeStep_CallBack});
set(hm.EditComTimeStep,'CallBack',{@EditComTimeStep_CallBack});

set(hm.PushAddModel     ,'CallBack',{@PushAddModel_CallBack});
set(hm.PushDeleteModel  ,'CallBack',{@PushDeleteModel_CallBack});
set(hm.PushSaveModel    ,'CallBack',{@PushSaveModel_CallBack});
set(hm.PushSaveAllModels,'CallBack',{@PushSaveAllModels_CallBack});

set(hm.PushTimeSeries   ,'CallBack',{@PushTimeSeries_CallBack});
set(hm.PushMaps         ,'CallBack',{@PushMaps_CallBack});

guidata(findobj('Tag','MainWindow'),hm);

RefreshScreen;

%%
function SelectContinents1_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
hm.ActiveContinent=get(hObject,'Value');
guidata(findobj('Tag','MainWindow'),hm);
RefreshScreen;

%%
function ListModels1_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=get(hObject,'Value');
str=get(hObject,'String');
name=str{i};
k=strmatch(name,hm.ModelNames,'exact');
hm.ActiveModel=k;
guidata(findobj('Tag','MainWindow'),hm);
RefreshScreen;

% %%
% function SelectContinents2_CallBack(hObject,eventdata)
% hm=guidata(findobj('Tag','MainWindow'));
% guidata(findobj('Tag','MainWindow'),hm);
% RefreshScreen;
% 
% %%
% function ListModels2_CallBack(hObject,eventdata)
% hm=guidata(findobj('Tag','MainWindow'));
% i=get(hObject,'Value');
% str=get(hObject,'String');
% name=str{i};
% k=strmatch(name,hm.ModelNames,'exact');
% name2=hm.Models(hm.ActiveModel).Name;
% if ~strcmpi(name,name2)
%     hm.Models(hm.ActiveModel).NestModel=hm.ModelAbbrs{k};
%     hm.ActiveNestModel=i;
% end    
% guidata(findobj('Tag','MainWindow'),hm);
% RefreshScreen;

%%
function EditName_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=hm.ActiveModel;
str=get(hObject,'String');
hm.Models(i).Name=str;
hm=DetermineModelsInContinent(hm);
guidata(findobj('Tag','MainWindow'),hm);
RefreshScreen;

%%
function SelectType_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=hm.ActiveModel;
ii=get(hObject,'Value');
switch ii
    case 1
        hm.Models(i).Type='Delft3DFLOW';
    case 2
        hm.Models(i).Type='Delft3DFLOWWAVE';
    case 3
        hm.Models(i).Type='WW3';
    case 4
        hm.Models(i).Type='XBeach';
end
guidata(findobj('Tag','MainWindow'),hm);

%%
function EditAbbr_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=hm.ActiveModel;
str=get(hObject,'String');
hm.Models(i).Abbr=str;
guidata(findobj('Tag','MainWindow'),hm);

%%
function EditRunid_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=hm.ActiveModel;
str=get(hObject,'String');
hm.Models(i).Runid=str;
guidata(findobj('Tag','MainWindow'),hm);

%%
function SelectContinent_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=hm.ActiveModel;
k=get(hObject,'Value');
hm.Models(i).Continent=hm.Continents(k).Abbr;
guidata(findobj('Tag','MainWindow'),hm);
RefreshScreen;

%%
function EditPosition1_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=hm.ActiveModel;
val=str2double(get(hObject,'String'));
hm.Models(i).Location(1)=val;
guidata(findobj('Tag','MainWindow'),hm);

%%
function EditPosition2_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=hm.ActiveModel;
val=str2double(get(hObject,'String'));
hm.Models(i).Location(2)=val;
guidata(findobj('Tag','MainWindow'),hm);

%%
function SelectSize_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=hm.ActiveModel;
k=get(hObject,'Value');
hm.Models(i).Size=k;
guidata(findobj('Tag','MainWindow'),hm);

%%
function EditXLim1_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=hm.ActiveModel;
val=str2double(get(hObject,'String'));
hm.Models(i).XLim(1)=val;
guidata(findobj('Tag','MainWindow'),hm);

%%
function EditXLim2_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=hm.ActiveModel;
val=str2double(get(hObject,'String'));
hm.Models(i).XLim(2)=val;
guidata(findobj('Tag','MainWindow'),hm);

%%
function EditYLim1_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=hm.ActiveModel;
val=str2double(get(hObject,'String'));
hm.Models(i).YLim(1)=val;
guidata(findobj('Tag','MainWindow'),hm);

%%
function EditYLim2_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=hm.ActiveModel;
val=str2double(get(hObject,'String'));
hm.Models(i).YLim(2)=val;
guidata(findobj('Tag','MainWindow'),hm);

%%
function SelectPriority_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=hm.ActiveModel;
k=get(hObject,'Value');
hm.Models(i).Priority=k-1;
guidata(findobj('Tag','MainWindow'),hm);

%%
function ToggleNesting_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=hm.ActiveModel;
k=get(hObject,'Value');
hm.Models(i).Nested=k;
guidata(findobj('Tag','MainWindow'),hm);
RefreshScreen;

%%
function EditSpinUp_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=hm.ActiveModel;
val=str2double(get(hObject,'String'));
hm.Models(i).SpinUp=val;
guidata(findobj('Tag','MainWindow'),hm);

%%
function EditRunTime_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=hm.ActiveModel;
val=str2double(get(hObject,'String'));
hm.Models(i).RunTime=val;
guidata(findobj('Tag','MainWindow'),hm);

%%
function EditTimeStep_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=hm.ActiveModel;
val=str2double(get(hObject,'String'));
hm.Models(i).TimeStep=val;
guidata(findobj('Tag','MainWindow'),hm);

%%
function EditMapTimeStep_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=hm.ActiveModel;
val=str2double(get(hObject,'String'));
hm.Models(i).MapTimeStep=val;
guidata(findobj('Tag','MainWindow'),hm);

%%
function EditHisTimeStep_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=hm.ActiveModel;
val=str2double(get(hObject,'String'));
hm.Models(i).HisTimeStep=val;
guidata(findobj('Tag','MainWindow'),hm);

%%
function EditComTimeStep_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
i=hm.ActiveModel;
val=str2double(get(hObject,'String'));
hm.Models(i).ComTimeStep=val;
guidata(findobj('Tag','MainWindow'),hm);

%%
function PushSaveModel_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
WriteModels(hm,hm.Models(hm.ActiveModel).Abbr);

%%
function PushSaveAllModels_CallBack(hObject,eventdata)
hm=guidata(findobj('Tag','MainWindow'));
WriteModels(hm);

%%
function PushAddModel_CallBack(hObject,eventdata)
AddModel;

%%
function PushTimeSeries_CallBack(hObject,eventdata)
EditTimeSeries;

%%
function PushMaps_CallBack(hObject,eventdata)
EditMaps;
