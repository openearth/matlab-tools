function EHY_plotMapData_FM_interactive
%% EHY_plotMapData_FM_interactive
% get data
[Data,EHY_getGridInfo_line] = EHY_getMapModelData_interactive;
if isfield(Data,'face_nodes_x')
    gridInfo.face_nodes_x = Data.face_nodes_x;
    gridInfo.face_nodes_y = Data.face_nodes_y;
elseif isfield(Data,'Xcor')
    gridInfo.Xcor = Data.Xcor;
    gridInfo.Ycor = Data.Ycor;
end

if isfield(Data,'times') && length(Data.times)>1
    option=listdlg('PromptString','Plot these time steps (as animation): (Use CTRL to select multiple time steps)','ListString',...
        datestr(Data.times),'ListSize',[400 400]);
    if isempty(option); disp('EHY_plotMapData_FM_interactive was stopped by user');return; end
    plotInd = option;
elseif isfield(Data,'times') && length(Data.times)==1
    plotInd = 1;
else
    plotInd = [];
end

disp([char(10) 'Note that the example MATLAB-line to get the variable ''Data'' is a few lines above ^. '])
disp([char(10) 'Note that next time you want to plot this data, you can also use:'])
disp(['<strong>' EHY_getGridInfo_line '</strong>'])

% if velocity was selected
if isfield(Data,'vel_mag')
    disp(['<strong>EHY_plotMapData_FM(gridInfo,Data.vel_mag(' num2str(plotInd(1)) repmat(',:',1,ndims(Data.vel_mag)-1) '));</strong>' ])
else
    if isempty(plotInd)
        disp('<strong>EHY_plotMapData_FM(gridInfo,Data.val);</strong>')
    else
        disp(['<strong>EHY_plotMapData_FM(gridInfo,Data.val(' num2str(plotInd(1)) repmat(',:',1,ndims(Data.val)-1) '));</strong>' ])
    end
end

disp('start plotting the top-view data...')
figure
for iPI=1:max([1 length(plotInd)])
    
    if ~isempty(plotInd)
        iT = plotInd(iPI);
        if length(plotInd)>1
            disp(['Plotting top-views: ' num2str(iPI) '/' num2str(length(plotInd))])
        end
        if isfield(Data,'vel_mag')
            EHY_plotMapData_FM(gridInfo,Data.vel_mag(iT,:,:))
        else
            EHY_plotMapData_FM(gridInfo,Data.val(iT,:,:))
        end
        title(datestr(Data.times(plotInd(iPI)),'dd-mmm-yyyy HH:MM'))
    else
        EHY_plotMapData_FM(gridInfo,Data.val)
    end
    pause(2)
end
disp('Finished plotting the top-view data!')

