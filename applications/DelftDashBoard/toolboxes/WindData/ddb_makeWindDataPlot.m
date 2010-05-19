function ddb_makeWindDataPlot(handles)

ii=get(handles.GUIHandles.ListStations,'Value');
stations=get(handles.GUIHandles.ListStations,'String');
windData=handles.Toolbox(tb).Input.windData;

if isempty(windData)
    giveWarning([],'No data available for this station and period');
    return;
end

fig=MakeNewWindow('Wind Data Time Series',[600 400],[handles.SettingsDir '\icons\deltares.gif']);
set(fig,'renderer','painters');
figure(fig);

tbh = uitoolbar;

subplot(3,1,1);
plot(windData(:,1),windData(:,2));
datetick('x',19,'keepticks','keeplimits');
ylabel('wind speed [m/s]');
grid on;
subplot(3,1,2)
plot(windData(:,1),windData(:,3));
datetick('x',19,'keepticks','keeplimits');
ylabel('wind direction [deg N]');
grid on;
subplot(3,1,3)
plot(windData(:,1),windData(:,4));
datetick('x',19,'keepticks','keeplimits');
ylabel('air pressure [mbar]');
grid on;
md_paper('a4p','wl',{strvcat(['Wind data for station: ' stations{ii}],['Source: ' handles.Toolbox(tb).Input.Source]),' ',' ',' ',' ',' '});

