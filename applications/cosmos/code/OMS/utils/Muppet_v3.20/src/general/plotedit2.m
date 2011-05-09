function varargout = plotedit(varargin)
%PLOTEDIT  Tools for editing and annotating plots
%   PLOTEDIT ON   starts plot edit mode for the current figure.
%   PLOTEDIT OFF  ends plot edit mode for the current figure.
%   PLOTEDIT  with no arguments toggles the plot edit mode for
%      the current figure.
%
%   PLOTEDIT(FIG)  toggles the plot edit mode for figure FIG.
%   PLOTEDIT(FIG,'STATE')  specifies the PLOTEDIT STATE for
%      the figure FIG.
%   PLOTEDIT('STATE')  specifies the PLOTEDIT STATE for
%      the current figure.
%
%      STATE can be one of the strings:
%          ON - starts plot edit mode
%          OFF - ends plot edit mode
%          SHOWTOOLSMENU - displays the Tools menu (the default)
%          HIDETOOLSMENU - removes the Tools menu from the menubar
%
%   When PLOTEDIT is ON, use the Tools menu to add and
%   modify objects, or select the annotation toolbar buttons
%   to add annotations such as text, line and arrows.
%   Click and drag objects to move or resize them.
%
%   To edit object properties, right click or double click on
%   the object.
%
%   Shift-click to select multiple objects.
%
%   For more information, select 'Plot Editor Help' from the
%   figure Help menu.


%   Internal interfaces for toolbox-plotedit compatibility
%
%   plotedit(FIG,'hidetoolsmenu')
%      makes the standard figure 'Tools' menu Visible off
%   plotedit(FIG,'showtoolsmenu')
%      makes the standard figure 'Tools' menu Visible on
%   h = plotedit(FIG,'gethandles')
%      returns a list of the hidden plot editor objects which
%      should be excluded from GUIDE's object browser.
%   h = plotedit(FIG,'gettoolbuttons')
%      returns a list plot editing and annotation buttons in
%      the toolbar.  Used by UISUSPEND and UIRESTORE.
%   h = plotedit(FIG,'locktoolbarvisibility')
%      freezes the current state of the toolbar.
%   plotedit(FIG,'setsystemeditmenus')
%      restores the system Edit menu.
%   plotedit(FIG,'setploteditmenus')
%      restores the plotedit Edit menu.
%
%   these are used by UISUSPEND/UIRESTORE
%   a = plotedit(FIG,'getenabletools')
%      returns the enable state of the plot editing tools
%   plotedit(FIG,'setenabletools','off')
%      disables the plot editing tools under Tools menu
%      and disables the Tools menu callback which updates
%      the status of the tools menu, and disables the plot
%      editing tools in the Toolbar
%   plotedit(FIG,'setenabletools','on')
%      enables the Tools menu and the items underneath it
%      and enables the plot editing buttons in the Toolbar
%
%   To hide the figure toolbar, set the figure 'ToolBar'
%   property (hidden) to 'none'.
%      set(fig,'ToolBar','none');
%

%   Copyright (c) 1984-98 by The MathWorks, Inc.
%   $Revision$  $Date$
%   j. H. Roh  10/20/97


fSilent = 0;

switch nargin
    case 0
        % plotedit
        f = gcf;
        action = 'toggle';
    case 1
        if ischar(varargin{1})
            % plotedit [on | off ]
            f = gcf;
            action = varargin{1};
        else
            % plotedit(fig)
            f = varargin{1};
            action = 'toggle';
        end
    case 2
        % plotedit(fig, ...
        % ['on' | 'off' | 'isactive' | 'toggle' | 'gethandles' | 'hidetoolbar' ])
        f = varargin{1};
        action = varargin{2};
        if isempty(f)
            return
        elseif length(f)>1  % only for ['on' | 'off' | 'toggle']
            % doesn't work if we need to return an value
            for i = 1:length(f)
                plotedit(f(i), action);
            end
            return
        end
    case 3
        f = varargin{1};
        action = varargin{2};
        parameter = varargin{3}; % silent: don't switch button
        switch parameter
            case 'silent'
                fSilent = 1;
        end
end


switch lower(action)

    case 'toggle'
        if plotedit(f,'isactive')
            newstate = 'off';
        else
            newstate = 'on';
        end
        plotedit(f,newstate);

    case 'on'
        dontActivate = ctlpanel('Activate',f);
        if ~isempty(dontActivate), return, end
        if ~fSilent
            scribeclearmode(f,'plotedit',f,'off');
        end
        set(f,'Toolbar','figure');
        LChangeState(f,'on',fSilent)
    case 'off'
        if isempty(getappdata(f,'ScribePlotEditState'))
            return
        end
        LChangeState(f,'off',fSilent)

    case 'gethandles'
        varargout{1} = LGetScribeObjectList(f);

    case 'hidetoolsmenu'
        set(findobj(allchild(f),'flat','Type','uimenu','Tag','figMenuTools'),...
            'visible','off');

    case 'showtoolsmenu'
        set(findobj(allchild(f),'flat','Type','uimenu','Tag','figMenuTools'),...
            'visible','on');

    case 'setenabletools'
        if nargin==3
            setappdata(f,'ScribePloteditEnable',parameter)
            % disable toolbar
            toolButtons = plotedit(f,'gettoolbuttons');
            set(toolButtons,'Enable',parameter);
            % disable Tools menu
            % happens within the Tools menu callback, by polling the
            % ScribePloteditEnable state
        end

    case 'getenabletools'
        ploteditEnable = getappdata(f,'ScribePloteditEnable');
        if isempty(ploteditEnable)
            varargout{1} = 'on';    % default
        else
            varargout{1} = ploteditEnable;
        end


    case 'setsystemeditmenus'
        LModifyFigMenus(f,'off');

    case 'setploteditmenus'
        LModifyFigMenus(f,'on');

    case 'gettoolbuttons'
        c = findobj(allchild(f),'flat','Type','uitoolbar');
        b = findall(c,'Type','uitoggletool');
        h = [findobj(b,'flat','Tag','ScribeSelectToolBtn');
            findobj(b,'flat','Tag','ScribeToolBtn');
            findobj(b,'flat','Tag','figToolZoomIn');
            findobj(b,'flat','Tag','figToolZoomOut');
            findobj(b,'flat','Tag','figToolRotate3D');];
        if nargout>0
            varargout{1} = h;
        end

    case 'locktoolbarvisibility'
        toolbarShowing = ~isempty(findall(f,'Tag','ScribeSelectToolBtn'));
        if toolbarShowing
            set(f,'Toolbar','figure');
        else
            set(f,'Toolbar','none');
        end

    case 'isactive'
        switch LGetState(f)
            case 'on'
                varargout{1} = 1;
            case 'off'
                varargout{1} = 0;
        end

    case 'promoteoverlay'
        promoteoverlay(f);
        return
end

function LChangeState(f,state,fSilent)

oldPtr = LWaitPtr(f);

LModifyFigMenus(f,state);
LSetState(f,state,fSilent);
LActivateWindowFcns(f,state);
LSetSelection(f,state);
LPrepareOverlay(f,state);

set(f,'Pointer',oldPtr);


function oldPtr = LWaitPtr(f);
oldPtr = get(f,'Pointer');
set(f,'Pointer','watch');

function LSetState(f,state,silent)
setappdata(f,'ScribePlotEditState',state);
if ~silent
    tbSelectPlotEdit = findall(f,'Tag','ScribeSelectToolBtn');
    set(tbSelectPlotEdit,'State',state);
end

function state = LGetState(f)
state = getappdata(f,'ScribePlotEditState');
if isempty(state)
    state = 'off';
end

function LSetSelection(f,state)
switch state
    case 'off'
        try
            fObj = getobj(f);
            if ~isempty(fObj)
                domethod(fObj,'deselectall');
            end
        catch
            % when a figure is closed with a selection,
            % we can't depend on the order of children being
            % destroyed: fail silently and allow the window to close
        end
    case 'on'
end

function LActivateWindowFcns(f,state)
windowFcns = {...
    'WindowButtonDownFcn' ...
    'WindowButtonMotionFcn' ...
    'WindowButtonUpFcn' ...
    'KeyPressFcn' ...
    };
switch state
    case 'on'
        saveFcns = getappdata(f,'ScribeSaveWindowFcns');
        if isempty(saveFcns)
            saveFcns = get(f, windowFcns);
            setappdata(f,'ScribeSaveWindowFcns', saveFcns);
        end
        set(f,windowFcns, {'scribeeventhandler' '' '' 'dokeypress(gcbf)'});
    case 'off'
        saveFcns = getappdata(f,'ScribeSaveWindowFcns');
        if ~isempty(saveFcns)
            set(f,windowFcns, saveFcns);
            rmappdata(f,'ScribeSaveWindowFcns');
        end
end


function LPrepareOverlay(f,state)
saveProps = {...
    'DoubleBuffer'};

switch state
    case 'on'
        overlay = findall(f,'Tag','ScribeOverlayAxesActive');
        if isempty(overlay)
            currentAxes = get(f,'CurrentAxes');
            overlay = LAddOverlayAxes(f);
            set(f,'CurrentAxes',currentAxes);

            % make sure new axes are created behind the overlay axes
            % don't turn this off even if plotedit is off!
            axesCreateFcn = get(0,'DefaultAxesCreateFcn');
            set(f,'DefaultAxesCreateFcn', ...
                ['plotedit(gcbf,''promoteoverlay''); ' axesCreateFcn]);
        end

        fh = getobj(f);
        if isempty(fh)
            fh = scribehandle(figobj(f));
        end

        figSaveProps = getappdata(f,'ScribeFigSaveProps');
        if isempty(figSaveProps)
            figSaveProps = get(f,saveProps);
            setappdata(f,'ScribeFigSaveProps',figSaveProps);
        end
        scribeVals = {...
            'on'};

        set(f, saveProps, scribeVals);
    case 'off'
        figSaveProps = getappdata(f,'ScribeFigSaveProps');
        if ~isempty(figSaveProps)
            set(f,saveProps,figSaveProps);
            rmappdata(f,'ScribeFigSaveProps');
        end
end

function aOverlay = LAddOverlayAxes(f)
aOverlay = axes(...
    'Parent',f,...
    'Position',[0 0 1 1],...
    'Box','off',...
    'XLimMode','manual',...
    'YLimMode','manual',...
    'XColor',[.8 .8 .8],...
    'YColor',[.8 .8 .8],...
    'XTick',[],...
    'YTick',[],...
    'Color','none',...
    'Tag','ScribeOverlayAxesActive',...
    'HitTest','off',...
    'Visible','off',...
    'CreateFcn','',...
    'HandleVisibility','off'...
    );

function LModifyFigMenus(fig,state)
figMenuBar = get(fig,'MenuBar');

switch state
    case 'off'
        if strcmp(figMenuBar,'none'), return, end;
        menuObjects = getappdata(fig,'ScribeSaveMenuHandles');
        oldMenuValues = getappdata(fig,'ScribeSaveMenuProps');
        toolObjects = getappdata(fig,'ScribeSaveToolHandles');
        oldToolValues = getappdata(fig,'ScribeSaveToolProps');
        if isempty(menuObjects) | isempty(oldMenuValues)
            return
        end
        try
            if ishandle(menuObjects) & ishandle(toolObjects)
                set(menuObjects,{'Callback' 'Tag' 'Enable'}, oldMenuValues);
                set(toolObjects,{'ClickedCallback' 'Tag'}, ...
                    oldToolValues);
            end % else, the menus have been reloaded...
        catch
            warning('Failed to restore state for some menus')
        end


    case 'on'
        if strcmp(figMenuBar,'none')
            return
        end

        editMenu = findall(fig,'Type','uimenu','Tag','figMenuEdit');
        if ~isempty(editMenu)
            editPostCallback = get(editMenu,'Callback');
            if ~isempty(editPostCallback)
                eval(editPostCallback);
            end
        end


        menuObjects = LGetMenuList(fig);
        if isempty(menuObjects)
            if feature('figuretools')
                set(fig,'MenuBar','none');
                set(fig,'MenuBar','figure');  % loads the default menus
            else
                feature('figuretools',1);
                set(fig,'MenuBar','none');
                set(fig,'MenuBar','figure');  % loads the default menus
                feature('figuretools',0);     % restore state
            end
            menuObjects = LGetMenuList(fig);
        end

        if isempty(menuObjects)
            error(['Unable to activate Plot Editor: ' lasterr]);
        end


        % save tools
        toolObjects = findall(fig,'Tag','figToolSave');
        oldValues = get(toolObjects,{'ClickedCallback' 'Tag'});
        setappdata(fig,'ScribeSaveToolProps', oldValues);
        setappdata(fig,'ScribeSaveToolHandles', toolObjects);

        set(toolObjects,...
            'ClickedCallback','domymenu(''menubar'',''save'',gcbf)',...
            'Tag','scrSaveMenu');

        % save menus
        oldValues = get(menuObjects,{'Callback' 'Tag' 'Enable'});
        setappdata(fig,'ScribeSaveMenuProps', oldValues);
        setappdata(fig,'ScribeSaveMenuHandles', menuObjects);

        callbacks = {...
            ''
            ''
            'domymenu(''updatemenu'',''edit'',gcbf);'
            'domymenu(''menubar'',''cut'',gcbf);'
            'domymenu(''menubar'',''copy'',gcbf);'
            'domymenu(''menubar'',''paste'',gcbf);'
            'domymenu(''menubar'',''clear'',gcbf);'
            'domymenu(''menubar'',''save'',gcbf);'
            'domymenu(''menubar'',''saveas'',gcbf);'
            };

        tags = {...
            ''
            ''
            'scrEditMenu'
            'scrCCCMenu'
            'scrCCCMenu'
            'scrPasteMenu'
            'scrCCCMenu'
            'scrSaveMenu'
            'scrSaveAsMenu'
            };

        enable =  {...
            'off'
            'off'
            'on'
            'on'
            'on'
            'on'
            'on'
            'on'
            'on'};

        set(menuObjects,{'Callback' 'Tag' 'Enable'}, cat(2, ...
            callbacks, tags, enable));

end

function h = LFindMenu(fig,tag)
h = findall(fig,'Type','uimenu','Tag',tag);
if length(h)>1  % ???
    h = h(1);
end

function V = LGetMenuList(fig)
try
    V = [...
        LFindMenu(fig,'figMenuEditSelectAll') ...
        LFindMenu(fig,'figMenuEditUndo') ...
        LFindMenu(fig,'figMenuEdit') ...
        LFindMenu(fig,'figMenuEditCut') ...
        LFindMenu(fig,'figMenuEditCopy') ...
        LFindMenu(fig,'figMenuEditPaste') ...
        LFindMenu(fig,'figMenuEditClear') ...
        LFindMenu(fig,'figMenuFileSave') ...
        LFindMenu(fig,'figMenuFileSaveAs') ...
        ];
catch
    V = [];
end


function h = LGetScribeObjectList(f)
fkids = allchild(f);
% overlay axes
overlay = findobj(fkids,'flat','Tag','ScribeOverlayAxesActive');
if ~isempty(overlay) & ishandle(overlay)
    % add everything in the overlay axis
    % this line creates the label objects if they don't already
    % exist
    labels = get(overlay,{'XLabel' 'YLabel' 'ZLabel' 'Title'});
    annotations = findall(overlay);
    % labels = [labels{:}]';
else
    labels = [];
    annotations = [];
end
% uicontext menus
cxm = findobj(fkids,'flat','Type','uicontextmenu');
myContextMenus = [...
    findobj(cxm, 'Tag', 'ScribeAxisObjContextMenu');
    findobj(cxm, 'Tag', 'ScribeAxistextObjContextMenu');
    findobj(cxm, 'Tag', 'ScribeEditlineObjContextMenu');
    ];
% add children of the context menus
myContextMenus = findall(myContextMenus);

% hidden figobj storage
figStoreObj = findall(fkids,'flat','Tag','ScribeFigObjStorage');
% other vector objects
storageObj = findobj(fkids,'flat','Tag','ScribeHGBinObject');

h = [annotations; myContextMenus; figStoreObj; ...
    storageObj];
