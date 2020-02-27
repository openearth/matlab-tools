function EHY_plotMapModelData_interactive
%% EHY_plotMapModelData_interactive
% get data
[Data,EHY_getGridInfo_line] = EHY_getMapModelData_interactive;
if isfield(Data,'face_nodes_x')
    gridInfo.face_nodes_x = Data.face_nodes_x;
    gridInfo.face_nodes_y = Data.face_nodes_y;
elseif isfield(Data,'Xcor')
    gridInfo.Xcor = Data.Xcor;
    gridInfo.Ycor = Data.Ycor;
elseif isfield(Data,'Xcen')
    gridInfo.Xcen = Data.Xcen;
    gridInfo.Ycen = Data.Ycen;
end

if isfield(Data,'times') && length(Data.times)>1
    option=listdlg('PromptString','Plot these time steps (as animation): (Use CTRL to select multiple time steps)','ListString',...
        datestr(Data.times),'ListSize',[400 400]);
    if isempty(option); disp('EHY_plotMapModelData_interactive was stopped by user');return; end
    plotInd = option;
elseif isfield(Data,'times') && length(Data.times)==1
    plotInd = 1;
else
    plotInd = [];
end

disp([newline 'Note that the example MATLAB-line to get the variable ''Data'' is a few lines above ^. '])
if ~isempty(EHY_getGridInfo_line)
    disp([newline 'Note that next time you want to plot this data, you can also use:'])
    disp(['<strong>' EHY_getGridInfo_line '</strong>'])
end

% if velocity was selected
if isfield(Data,'vel_mag')
    disp(['<strong>EHY_plotMapModelData(gridInfo,Data.vel_mag(' num2str(plotInd(1)) repmat(',:',1,ndims(Data.vel_mag)-1) '));</strong>' ])
else
    if isempty(plotInd)
        disp('<strong>EHY_plotMapModelData(gridInfo,Data.val);</strong>')
    else
        if isempty(EHY_getGridInfo_line) % data along xy-trajectory
            disp(['<strong>t = ' num2str(plotInd(1)) ';</strong>' ])
            disp(['<strong>EHY_plotMapModelData(gridInfo,Data.val(t' repmat(',:',1,ndims(Data.val)-1) '),''t'',t);</strong>' ])
        else
            disp(['<strong>EHY_plotMapModelData(gridInfo,Data.val(' num2str(plotInd(1)) repmat(',:',1,ndims(Data.val)-1) '));</strong>' ])
        end
    end
end

disp('start plotting the top-view data...')
figure
for iPI = 1:max([1 length(plotInd)])
    
    if ~isempty(plotInd)
        iT = plotInd(iPI);
        if length(plotInd)>1
            disp(['Plotting top-views: ' num2str(iPI) '/' num2str(length(plotInd))])
        end
        if isfield(Data,'vel_mag')
            EHY_plotMapModelData(gridInfo,Data.vel_mag(iT,:,:,:))
        else
            if isempty(EHY_getGridInfo_line) % data along xy-trajectory
                EHY_plotMapModelData(gridInfo,Data.val(iT,:,:,:),'t',iT)
            else
                EHY_plotMapModelData(gridInfo,Data.val(iT,:,:,:))
            end
        end
        title(datestr(Data.times(plotInd(iPI)),'dd-mmm-yyyy HH:MM:SS'))
    else
        EHY_plotMapModelData(gridInfo,Data.val)
    end
    pause(1)
end
disp('Finished plotting the top-view data!')

