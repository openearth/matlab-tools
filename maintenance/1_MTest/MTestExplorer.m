classdef MTestExplorer < handle
    properties
        MTestRunner = MTestRunner;  % MTEstRunner object that stores and catalogues tests
        
        ViewType = 'Directory';     % View type for treeview (either Directory, Category or Status)
                
        HMainFigure                 % Handle of the main matlab figure
        
        HToolBar                    % Handle of the matlab toolbar (with buttons)
        HToolBarRun                 % Handle of the uipushbutten to run the selected models
        HToolBarRunAll              % Handle of the uipushbutten to run all models
        HToolBarViewSuccess         % Handle of the uitogglebutten to view all successfull tests
        HToolBarViewFailed          % Handle of the uitogglebutten to view all failed tests
        HToolBarViewNotRun          % Handle of the uitogglebutten to view all tests that did not run yet
        JToolBar                    % Java handle for the main toolbar
        JCombo                      % Java handle for the JCombobox that determines the ViewType
        HTeamCity                   % Handle of the uitogglebutton to switch TeamCity.running mode
        JToolBarProgress            % Java handle for the progress toolbar
        HProgressToolbar            % Handle of the progress toolbar
        JProgressBar                % Java handle for the progress bar
        
        MenuFile                    % Handle of uimenu item File
        MenuFileOpen                % Handle of uimenu item Open session
        MenuFileSave                % Handle of uimenu item Save session
        MenuFileNewTest             % Handle of uimenu item Create new test
        MenuFileClose               % Handle of uimenu item Close
        MenuSession                 % Handle of uimenu item session
        MenuSessionAddTest          % Handle of uimenu item add a single test
        MenuSessionEditTest         % Handle of uimenu item edit selected test(s)
        MenuSessionSearchTestsAdd   % Handle of uimenu item search for tests and add to session
        MenuSessionSearchTestsReplace% Handle of uimenu item search for tests and replace session
        MenuSessionRemoveTest       % Handle of uimenu item remove selected test(s)
        MenuSessionclearTest        % Handle of uimenu item clear session
        MenuRun                     % Handle of uimenu item run
        MenuRunSelected             % Handle of uimenu item run selected tests
        MenuRunAll                  % Handle of uimenu item Run all tests

        HContextMenu                % Handle to the Context menu (uicontextmenu) item
        HContextMenuRun             % Handle of the uicontextmenu item Run
        HContextMenuRemove          % Handle of the uicontextmenu item Remove selected test(s)
        HContextMenuRunAll          % Handle of the uicontextmenu item Run all tests
        HContextMenuViewCoverage    % Handle of the uicontextmenu item View Test Coverage
        HContextMenuNewTest         % Handle of the uicontextmenu item Create new test
        HContextMenuEditTests       % Handle of the uicontextmenu item edit selected test(s)
        HContextMenuAddTest         % Handle of the uicontextmenu item Add test to session
        HContextMenuRemoveTest      % Handle of the uicontextmenu item remove selected test(s) from session
        HContextMenuSearchTestsAdd  % Handle of the uicontextmenu item search tests and add to session
        HContextMenuSearchTestsRemove% Handle of the uicontextmenu item search tests and replace session
        HContextMenuClearSession    % Handle of the uicontextmenu item clear session

        JSplitPanelMain             % Java handle for the main split panel (with the vertical split)
        
        JidePane                    % Java handle to the JidePane
        JideGrid                    % Java handle to the JideGrid
        JideModel                   % Java handle to the JideModel
        JideList                    % Java handle to the JideList
        
        % Splitpanel
        HSplitPanel                 % Handle of the horizontal splitpanel
        JSplitPanel                 % Java handle of the horizontal splitpanel
        
        % UpperPanel
        JTreePanel                  % Java handle of the JPane that hosts the JTree
        JScrollPane                 % Java handle of the JScrollPane that hosts the JTree
        JTree                       % Java handle of the JTree
        JTreeModel                  % Java handle of the JTreeModel
        JTreeRootNode               % Java handle of the rootnode
        JTreeAllNodes               % cell with handles to all tree nodes
        AllNodesExpandedFlag        % logical with the same size as JTreeAllNodes to indicate whether they are expanded
                        
        % LowerPanel
        JTextPane                   % Java handle to the JTextPane of the lower panel
        
        JStatusBar                  % Java handle to the JStatusBar (not used)
        
    end
    properties (Hidden = true)
%         PropertyChangedListeners = [];
        BuildingTree = false;       % boolean indicating whether the MTestExplorer is building the tree
    end
    
    methods
        function this = MTestExplorer(varargin)
            %% Create main figure
            this.HMainFigure = figure(...
                'NumberTitle','off',...
                'Name','Unit Test Explorer',...
                'HandleVisibility','off',...
                 'MenuBar','none',...
                'Toolbar','none',...
                'Units','pix',...
                'Position',[100 100 1200 300]);
            % Save object to figure so it does not get lost
            guidata(this.HMainFigure,this);
            
            %% Initialize and configure MTestRunner
            this.MTestRunner.Publish = false;
            this.MTestRunner.Verbose = false;
            tests = MTest;
            tests(1)=[];
            this.MTestRunner.Tests = tests;
            
            %% Create Menu items
            this.MenuFile = uimenu(this.HMainFigure,...
                'Label','&File');
            this.MenuFileOpen = uimenu(this.MenuFile,...
                'Label','&Open session',...
                'Enable','off',...
                'Callback',[]);
            this.MenuFileSave = uimenu(this.MenuFile,...
                'Label','&Save session',...
                'Enable','off',...
                'Callback',[]);
            this.MenuFileNewTest = uimenu(this.MenuFile,...
                'Label','Create &New Test',...
                'Callback','oetnewtest;');
            this.MenuFileClose = uimenu(this.MenuFile,...
                'Label','&Close',...
                'Separator','on',...
                'Callback',@this.menufileclose_callback);
            this.MenuSession = uimenu(this.HMainFigure,...
                'Label','&Session');
            this.MenuSessionAddTest = uimenu(this.MenuSession,...
                'Label','&Add Single Test',...
                'Callback',@this.menusessionaddtest_callback);
            this.MenuSessionEditTest = uimenu(this.MenuSession,...
                'Label','&Edit Test(s)',...
                'Callback',@this.edittest);
            this.MenuSessionSearchTestsAdd = uimenu(this.MenuSession,...
                'Label','&Search Tests (add)',...
                'Callback',{@this.menusessionsearchtest_callback,'add'});
            this.MenuSessionSearchTestsReplace = uimenu(this.MenuSession,...
                'Label','Search Tests (&new session)',...
                'Callback',{@this.menusessionsearchtest_callback,'remove'});
            this.MenuSessionRemoveTest = uimenu(this.MenuSession,...
                'Label','&Remove Test(s)',...
                'Separator','on',...
                'Callback',@this.menusessionremovetest_callback);
            this.MenuSessionclearTest = uimenu(this.MenuSession,...
                'Label','&Clear Session',...
                'Callback',@this.menusessioncleartest_callback);
            this.MenuRun = uimenu(this.HMainFigure,...
                'Label','&Run');
            this.MenuRunSelected = uimenu(this.MenuRun,...
                'Label','Run &selected test',...
                'Callback',{@this.run});
            this.MenuRunAll = uimenu(this.MenuRun,...
                'Label','Run &all tests',...
                'Callback',@this.runall);
            
            %% Create Context menu
            this.HContextMenu = uicontextmenu('Parent',this.HMainFigure);
            this.HContextMenuRun = uimenu(this.HContextMenu,...
                'Label','Run',...
                'Callback',@this.run);
            this.HContextMenuRunAll = uimenu(this.HContextMenu,...
                'Label','Run All',...
                'Callback',@this.runall);
            this.HContextMenuViewCoverage = uimenu(this.HContextMenu,...
                'Label','View Coverage',...
                'Enable','off',...
                'Callback',@this.viewcoverage);
            this.HContextMenuNewTest = uimenu(this.HContextMenu,...
                'Label','New Test',...
                'Separator','on',...
                'Callback','oetnewtest;');
            this.HContextMenuEditTests = uimenu(this.HContextMenu,...
                'Label','Edit Test(s)',...
                'Callback',@this.edittest);
            this.HContextMenuAddTest = uimenu(this.HContextMenu,...
                'Label','Add Single Test',...
                'Separator','on',...
                'Callback',@this.menusessionaddtest_callback);
            this.HContextMenuRemoveTest = uimenu(this.HContextMenu,...
                'Label','Remove Test(s)',...
                'Callback',@this.menusessionremovetest_callback);
            this.HContextMenuSearchTestsAdd = uimenu(this.HContextMenu,...
                'Label','Search Tests (add)',...
                'Callback',{@this.menusessionsearchtest_callback,'add'});
            this.HContextMenuSearchTestsRemove = uimenu(this.HContextMenu,...
                'Label','Search Tests (new session)',...
                'Callback',{@this.menusessionsearchtest_callback,'remove'});
            this.HContextMenuClearSession = uimenu(this.HContextMenu,...
                'Label','Clear Session',...
                'Separator','on',...
                'Callback',{@this.menusessioncleartest_callback,'add'});

            %% CReate Toolbar
            this.HToolBar = uitoolbar(this.HMainFigure);
            this.HToolBarRun = uipushtool(this.HToolBar,...
                'CData',loadicon('RunOne.gif'),...
                'ToolTip','Run selected test',...
                'ClickedCallback',@this.run);
            this.HToolBarRun = uipushtool(this.HToolBar,...
                'CData',loadicon('RunAll.gif'),...
                'ToolTip','Run all tests',...
                'ClickedCallback',@this.runall);
            this.HToolBarViewNotRun = uitoggletool(this.HToolBar,...
                'CData',loadicon('ViewTestsNotRun.gif'),...
                'Separator','on',...
                'State','on',...
                'ClickedCallback',{@this.buildtree,'refresh'},...
                'ToolTip','View tests that did not run');
            this.HToolBarViewFailed = uitoggletool(this.HToolBar,...
                'CData',loadicon('ViewFailedTests.gif'),...
                'State','on',...
                'ClickedCallback',{@this.buildtree,'refresh'},...
                'ToolTip','View all failed tests');
            this.HToolBarViewSuccess = uitoggletool(this.HToolBar,...
                'CData',loadicon('ViewPassedTests.gif'),...
                'State','on',...
                'ClickedCallback',{@this.buildtree,'refresh'},...
                'ToolTip','View all successfull tests');
            this.HTeamCity = uitoggletool(this.HToolBar,...
                'CData',loadicon('TeamCityIcon.gif'),...
                'Separator','on',...
                'ClickedCallback',@this.setteamcity_callback,...
                'ToolTip','Run as TeamCity');
            TeamCity.running(false);

            % The category selection box
            drawnow;
            this.JToolBar = get(get(this.HToolBar,'JavaContainer'),'ComponentPeer');
            if ~isempty(this.JToolBar)
                choices = {'Show by <directory structure>','Show by <category>','Show by <status>'};
                this.JCombo = javax.swing.JComboBox(choices);
                set(this.JCombo, 'ActionPerformedCallback', @this.buildtree);
                this.JToolBar(1).addSeparator;
                this.JToolBar(1).add(this.JCombo,8);
                this.JCombo.setMaximumSize(java.awt.Dimension(200,25))
            end
            
            % The progressbar
            this.HProgressToolbar = uitoolbar(this.HMainFigure);
            drawnow;
            this.JToolBarProgress = get(get(this.HProgressToolbar,'JavaContainer'),'ComponentPeer');
            this.JProgressBar = javax.swing.JProgressBar;
            this.JToolBarProgress(1).add(this.JProgressBar,1);
            this.JProgressBar.setVisible(1);
            set(this.JProgressBar,'StringPainted','on');
            this.JProgressBar.setString('Idle...');

            %% Create tree
            import javax.swing.tree.*
            import javax.swing.*
            import java.awt.*;
            
            % create a tree
            this.JTree = javax.swing.JTree;
            set(this.JTree,...
                'MouseClickedCallback',{@this.mouseclickedontree_callback,'mouse'},...
                'TreeExpandedCallback',@this.treeexpanded_callback,...
                'KeyPressedCallback',{@this.mouseclickedontree_callback,'keypress'},...
                'TreeCollapsedCallback',@this.treecollapsed_callback);
            this.JTreeRootNode = DefaultMutableTreeNode('RootNode');
            this.JTreeModel = this.JTree.getModel();
            this.JTreeModel.setRoot(this.JTreeRootNode);
            
            % Configure tree
            this.JTree.setRootVisible(false);
            this.JTree.getSelectionModel().setSelectionMode(TreeSelectionModel.CONTIGUOUS_TREE_SELECTION);
            renderer = this.JTree.getCellRenderer;
            renderer.setLeafIcon(ImageIcon(which('testicon_16.gif')));
            this.JTree.setCellRenderer(renderer);
            this.JTree.repaint;
            set(this.JTree,'UserData',this);

            % place tree in scrollpane
            this.JScrollPane = javax.swing.JScrollPane(this.JTree);
            % create JPanel to host the tree
            this.JTreePanel = javax.swing.JPanel;
            this.JTreePanel.setLayout(BorderLayout);
            % add scrollpane to panel
            this.JTreePanel.add(this.JScrollPane);
            
            %% Create text panel
            this.JTextPane = javax.swing.JTextPane;
            this.JTextPane.setBackground(java.awt.Color.LIGHT_GRAY);
            this.JTextPane.setContentType('text/html');
            this.JTextPane.setEditable(false);
            this.JTextPane.setText('<h1>MTest</h1><p>Add a test and run</p>');
            hjTextpane = handle(this.JTextPane,'CallbackProperties');
            set(hjTextpane,'HyperlinkUpdateCallback',@MTestExplorer.textpanelinkfunction);
            
            jScrollPane = javax.swing.JScrollPane(this.JTextPane);
            
            jTextPanel = javax.swing.JPanel;
            jTextPanel.setLayout(BorderLayout);
            jTextPanel.add(jScrollPane);
            
            %% CReate JIDE property manager
            % Prepare a properties table containing the list
            % Initialize JIDE's usage within Matlab
            com.mathworks.mwswing.MJUtilities.initJIDE;
            this.JideList = java.util.ArrayList();
            this.JideModel = com.jidesoft.grid.PropertyTableModel(this.JideList);
            this.JideModel.expandAll();
            this.JideGrid = com.jidesoft.grid.PropertyTable(this.JideModel);
            this.JidePane = com.jidesoft.grid.PropertyPane(this.JideGrid);

            %% Create split panels
            splitmain = javax.swing.JSplitPane(1);

            % horizontal splitpanel
            this.JSplitPanel = javax.swing.JSplitPane(0);
            this.JSplitPanel.add(this.JTreePanel,0);
            this.JSplitPanel.add(jTextPanel,1);
                        
            % vertical splitpanel
            splitmain.add(this.JSplitPanel,1);
            splitmain.add(this.JidePane,0);
            
            %% Add splitpanel to gui
            [this.JSplitPanelMain this.HSplitPanel] = javacomponent(splitmain,getpixelposition(this.HMainFigure).*[0 0 1 1],this.HMainFigure);
            set(this.HSplitPanel,'Units','normalized','Position',[0 0 1 1]);
            drawnow;
            this.JSplitPanel.setDividerLocation(0.5);
            this.JSplitPanelMain.setDividerLocation(0.8);
        end
    end
    methods
        function run(this,varargin)
            %RUN  runs the selected test(s).
            %
            %   This method collects the tests selected in the MTestExplorer and runs them.
            %
            %   Syntax:
            %   run(this)
            %   this.run
            %
            %   Input:
            %   this  = MTestExplorer object
            %
            %   See also MTestExplorer MTestExplorer.runtests MTestExplorer.runtall MTestExplorer.getselectedtestsid
            
            %% get selection
            selectionId = getselectedtestsid(this);
            
            %% Run tets
            this.runtests(selectionId);
        end
        function runall(this,varargin)
            %RUNALL  runs all test in the MTestExplorer session.
            %
            %   This method runs all tests in the current MTestExplorer session.
            %
            %   Syntax:
            %   runall(this)
            %   this.runall
            %
            %   Input:
            %   this  = MTestExplorer object
            %
            %   See also MTestExplorer MTestExplorer.runtests MTestExplorer.run MTestExplorer.getselectedtestsid
            
            %% Select all tests
            selectionId = true(size(this.MTestRunner.Tests));
            
            %% Run them
            this.runtests(selectionId);
        end
        function runtests(this,selectionId)
            %RUNTESTS  runs test in the MTestExplorer session.
            %
            %   This method runs tests in the current MTestExplorer session selected by selectionId.
            %
            %   Syntax:
            %   runtests(this,selectionId)
            %   this.runtests(selectionId);
            %
            %   Input:
            %   this        = MTestExplorer object
            %   selectionId = boolean  the size of this.MTestRunner.Tests indicating which tests
            %                   must be executed
            %
            %   See also MTestExplorer MTestExplorer.runall MTestExplorer.run
            
            %% Reset progressbar
            this.JProgressBar.setVisible(1);
            set(this.JProgressBar, ...
                'Maximum',sum(selectionId), ...
                'Value',0);
            this.JProgressBar.setForeground(java.awt.Color(0.3,0.5,0.3));
            
            %% Loop tests
            for itests = 1:length(selectionId)
                if selectionId(itests)
                    % reset teamcity in case a test has altered the running prop
                    this.setteamcity_callback;
                    
                    % prepare progressbar
                    this.JProgressBar.setString(['Running: ' this.MTestRunner.Tests(itests).Name ' (' num2str(round((sum(selectionId(1:itests-1))/sum(selectionId))*100))  '%)']);
                    
                    % reset some test parameters (ignore for example should not remain true)
                    this.MTestRunner.Tests(itests).Publish = false;     % Never publish from the MTestExplorer
                    this.MTestRunner.Tests(itests).AutoRefresh = true;  % Auto update to the latest definition
                    this.MTestRunner.Tests(itests).Ignore = false;      % Should not remain true, whereas it isn't run a next time
                    
                    % Run the test
                    this.MTestRunner.Tests(itests).run;
                    
                    % Update the progressbar
                    if ~this.MTestRunner.Tests(itests).TestResult
                        this.JProgressBar.setForeground(java.awt.Color(1, 0.3, 0.3));
                    end
                    set(this.JProgressBar, 'Value',sum(selectionId(1:itests)));
                    
                    % Rebuild the treeview to show testresult in nodes
                    if strcmp(this.ViewType,'Status')
                        % This has no effect on the other viewtypes, so don't waste time on it...
                        this.buildtree;
                    end
                    
                    % Show test information of the test that has just finished
                    this.mouseclickedontree_callback(itests,'selection');
                    
                    % delete any teamcity message if there is one
                    delete(which('teamcitymessage.matlab'));
                end
            end
            
            %% Finish progress bar
            this.JProgressBar.setString('Idle...');
        end
        function buildtree(this,varargin)
            %BUILDTREE  Rebuilds the treeview based on the current MTestRunner object.
            %
            %   This method rebuilds the treeview based on the currentMTestRunner object in
            %   MTestExplorer.
            %
            %   Syntax:
            %   buildtree(this,eventData);
            %   this.buildtree;
            %
            %   Input:
            %   this        = MTestExplorer object
            %   eventData   = callback event data from the JCombobox in the toolbar
            %
            %   See also MTestExplorer MTestExplorer.runtests

            %% Indicate that we are building the tree
            this.BuildingTree = true;
            
            %% import some java classes that we need
            import javax.swing.tree.*
            import javax.swing.*
            import java.awt.*;
            
            %% Interpret input
            if nargin > 1 && ~ischar(varargin{end})
                if any(strfind(get(varargin{1},'SelectedItem'),'categ'));
                    this.ViewType = 'Category';
                elseif any(strfind(get(varargin{1},'SelectedItem'),'direc'));
                    this.ViewType = 'Directory';
                else
                    this.ViewType = 'Status';
                end
            end
                
            %% Gather visibility
            showNotRun = strcmp(get(this.HToolBarViewNotRun,'State'),'on');
            showSuccess = strcmp(get(this.HToolBarViewSuccess,'State'),'on');
            showFailed = strcmp(get(this.HToolBarViewFailed,'State'),'on');

            %% Make root for treeview
            rootNode = DefaultMutableTreeNode('RootNode');
            
            oldNodes = this.JTreeAllNodes;
            this.JTreeAllNodes = {};
            
            for itests = 1:length(this.MTestRunner.Tests);
                %% Determine whether the test should be visible
                % determine state
                testExecutedFlag = ~isnan(this.MTestRunner.Tests(itests).Date);
                testResult = this.MTestRunner.Tests(itests).TestResult;
                
                if ~testExecutedFlag
                    % test was not run
                    visible = showNotRun;
                elseif testResult
                    % Test was successfull
                    visible = showSuccess;
                else
                    % Test failed
                    visible = showFailed;
                end
                
                if ~visible
                    continue;
                end
                
                %% make treenode for test
                % TODO: renaming nodes messes up the test ability to find nodes based on their names
                % (in this.treeexpanded_callback for example). Find a way to deal with this, than we
                % can rename. For now we also have the viewtype Status, to disctinguish tests with a
                % different status.
                newNode = DefaultMutableTreeNode(this.MTestRunner.Tests(itests).Name);
                if testExecutedFlag
                    if this.MTestRunner.Tests(itests).Ignore
%                         newNode = DefaultMutableTreeNode([this.MTestRunner.Tests(itests).Name '  (Ignored)']);
                        status = 'Ignored';
                    elseif testResult
%                         newNode = DefaultMutableTreeNode([this.MTestRunner.Tests(itests).Name '  (Passed)']);
                        status = 'Passed';
                    else
%                         newNode = DefaultMutableTreeNode([this.MTestRunner.Tests(itests).Name '  (Failed)']);
                        status = 'Failed';
                    end
                else
%                     newNode = DefaultMutableTreeNode(this.MTestRunner.Tests(itests).Name);
                    status = 'Not Run';
                end
                set(newNode,'UserData',itests);
                
                %% Determine place in tree structure
                baseNode = rootNode;
                switch this.ViewType
                    case 'Directory'
                        %% place in dirstructure tree
                        testPath = strread(this.MTestRunner.Tests(itests).FilePath,'%s',-1,'delimiter',[filesep filesep]);
                        for ip = 2:length(testPath)
                            %% Check if the directory is already presented in the tree, otherwise add it
                            if baseNode.getChildCount > 0
                                [tf node] = getchild(baseNode,testPath{ip});
                                if tf
                                    baseNode = node;
                                else
                                    new = DefaultMutableTreeNode(testPath{ip});
                                    position = baseNode.getChildCount;
                                    this.JTreeModel.insertNodeInto(new,baseNode,position);
                                    
                                    this.JTreeAllNodes{end+1,1} = new;
                                    this.JTreeAllNodes{end,2} = fullfile(testPath{1:ip});
                                    this.JTreeAllNodes{end,3} = true;
                                    if ~isempty(oldNodes) && ...
                                            any(strcmp(oldNodes(:,2),fullfile(testPath{1:ip})))
                                        this.JTreeAllNodes{end,3} = oldNodes{strcmp(oldNodes(:,2),fullfile(testPath{1:ip})),3};
                                    end
                                    baseNode = new;
                                    continue;
                                end
                            else
                                new = DefaultMutableTreeNode(testPath{ip});
                                baseNode.add(new);
                                this.JTreeAllNodes{end+1,1} = new;
                                this.JTreeAllNodes{end,2} = fullfile(testPath{1:ip});
                                this.JTreeAllNodes{end,3} = true;
                                if ~isempty(oldNodes) && ...
                                        any(strcmp(oldNodes(:,2),fullfile(testPath{1:ip})))
                                    this.JTreeAllNodes{end,3} = oldNodes{strcmp(oldNodes(:,2),fullfile(testPath{1:ip})),3};
                                end
                                baseNode = new;
                            end
                        end
                        position = baseNode.getChildCount;
                    case 'Category'
                        %% place in category tree
                        if isempty(this.MTestRunner.Tests(itests).Category)
                            this.MTestRunner.Tests(itests).Category = 'UnCategorized';
                        end
                        [tf baseNode] = getchild(rootNode,this.MTestRunner.Tests(itests).Category);
                        if ~tf
                            baseNode = DefaultMutableTreeNode(this.MTestRunner.Tests(itests).Category);
                            position = baseNode.getChildCount;
                            this.JTreeModel.insertNodeInto(baseNode,rootNode,position);
                            this.JTreeAllNodes{end+1,1} = baseNode;
                            this.JTreeAllNodes{end,2} = this.MTestRunner.Tests(itests).Category;
                            this.JTreeAllNodes{end,3} = true;
                            if ~isempty(oldNodes) && ...
                                    any(strcmp(oldNodes(:,2),this.MTestRunner.Tests(itests).Category))
                                this.JTreeAllNodes{end,3} = oldNodes{strcmp(oldNodes(:,2),this.MTestRunner.Tests(itests).Category),3};
                            end
                        end
                        position = baseNode.getChildCount;
                    case 'Status'
                        [tf baseNode] = getchild(rootNode,status);
                        if ~tf
                            baseNode = DefaultMutableTreeNode(status);
                            position = baseNode.getChildCount;
                            this.JTreeModel.insertNodeInto(baseNode,rootNode,position);
                            this.JTreeAllNodes{end+1,1} = baseNode;
                            this.JTreeAllNodes{end,2} = status;
                            this.JTreeAllNodes{end,3} = true;
                            if ~isempty(oldNodes) && ...
                                    any(strcmp(oldNodes(:,2),status))
                                this.JTreeAllNodes{end,3} = oldNodes{strcmp(oldNodes(:,2),status),3};
                            end
                        end
                end
                
                %% Add node to tree structure
                this.JTreeModel.insertNodeInto(newNode,baseNode,position);
            end
            
            %% Repaint tree
            if isempty(rootNode)
                import javax.swing.tree.*
                this.JTreeRootNode = DefaultMutableTreeNode('RootNode');
                this.JTreeModel.setRoot(this.RootNode);
                return;
            end
            this.JTreeRootNode = rootNode;
            this.JTreeModel.setRoot(this.JTreeRootNode);
            
            if isempty(this.JTreeAllNodes)
                return;
            end
            
            %% Collapse nodes that were collapsed earlier
            import javax.swing.tree.*
            allnodenames = cellfun(@node2str,this.JTreeAllNodes(:,1),'UniformOutput',false);
            for i=1:size(this.JTreeAllNodes,1)
                if this.JTreeAllNodes{i,3} && ~this.JTreeAllNodes{i,1}.isLeaf
                    leaf = this.JTreeAllNodes{i,1};
                    parentnodes = cellfun(@node2str,getparentsrecursive(leaf),'UniformOutput',false);
                    if any(~[this.JTreeAllNodes{ismember(allnodenames,parentnodes),3}])
                        continue;
                    end
                    if this.JTreeAllNodes{i,1}.getChildCount > 0
                        leaf = this.JTreeAllNodes{i,1}.getChildAt(0);
                    end
                    path = leaf.getPath;
                    this.JTree.scrollPathToVisible(TreePath(path));
                end
            end
            
            %% Unregister BuildingTree flag 
            this.BuildingTree = false;
        end
        function edittest(this,varargin)
            %edittests  opens the selected testdefinition(s) for editing.
            %
            %   This method gathers the test selection and performs the edit method to each selected
            %   test.
            %
            %   Syntax:
            %   edittest(this)
            %   this.edittest
            %
            %   Input:
            %   this  = MTestExplorer object
            %
            %   See also MTestExplorer MTestExplorer.getselectedtestsid MTest.edit
            
            %% Gather selected tests
            selectionId = getselectedtestsid(this);
            
            %% edit the tests
            edit(this.MTestRunner.Tests(selectionId));
        end
    end
    methods (Hidden = true)
        function selectionId = getselectedtestsid(this)
            selectionId = false(size(this.MTestRunner.Tests));
            
            selectedPaths = this.JTree.getSelectionPaths;
            selectedNodes = [];
            for ipaths = 1:length(selectedPaths)
                newSelectedNodes = getleafnodesrecursive(selectedPaths(ipaths).getLastPathComponent);
                selectedNodes = cat(1,selectedNodes,newSelectedNodes);
            end
            for inode = 1:length(selectedNodes)
                selectionId(get(selectedNodes{inode},'UserData')) = true;
            end
        end
        function treecollapsed_callback(this,varargin)
            allnodenames = cellfun(@node2str,this.JTreeAllNodes(:,1),'UniformOutput',false);
            pt = varargin{2}.getPath;
            node = pt.getLastPathComponent;
            this.JTreeAllNodes{ismember(allnodenames,node2str(node)),3} = false;
        end
        function treeexpanded_callback(this,varargin)
            if this.BuildingTree
                return
            end
            allnodenames = cellfun(@node2str,this.JTreeAllNodes(:,1),'UniformOutput',false);
            pt = varargin{2}.getPath;
            node = pt.getLastPathComponent;
            this.JTreeAllNodes{ismember(allnodenames,node2str(node)),3} = true;
        end
        function menufileclose_callback(this,varargin)
            delete(this.HMainFigure);
        end
        function menusessionaddtest_callback(this,varargin)
            [filename, pathname] = uigetfile('*_test.m', 'Pick a test definition');
            if isequal(filename,0) || isequal(pathname,0)
               return; 
            end
            try
                newTest = MTest(fullfile(pathname, filename));
            catch %#ok<CTCH>
                return;
            end
            if isempty(newTest)
                return;
            end
            this.MTestRunner.Tests(end+1) = newTest;
            
            [nms uid] = unique({this.MTestRunner.Tests.FileName});
            this.MTestRunner.Tests = this.MTestRunner.Tests(uid);
            
            this.buildtree;
        end
        function menusessionremovetest_callback(this,varargin)
            selectionId = getselectedtestsid(this);
            this.MTestRunner.Tests(selectionId) = [];
            this.buildtree;
        end
        function menusessionsearchtest_callback(this,varargin)
            %% Ask directory
            dir = uigetdir(cd,'Select a directory:');
            if isempty(dir) || ~ischar(dir)
                return;
            end
            
            this.MTestRunner.MainDir = dir;
            if nargin>2 && strcmp(varargin{3},'add')
                oldTests = this.MTestRunner.Tests;
            end
            
            this.MTestRunner.Tests = MTest;
            this.MTestRunner.Tests(1) = [];
            this.MTestRunner.cataloguetests;
            
            if nargin>2 && strcmp(varargin{3},'add')
                this.MTestRunner.Tests = cat(2,oldTests,this.MTestRunner.Tests);
            end
            [nms uid] = unique({this.MTestRunner.Tests.FileName});
            this.MTestRunner.Tests = this.MTestRunner.Tests(uid);
            
            this.buildtree;
        end
        function menusessioncleartest_callback(this,varargin)
            this.MTestRunner.Tests = MTest;
            this.MTestRunner.Tests(1) = [];
            
            this.buildtree;
        end
        function mouseclickedontree_callback(this,varargin)
            switch varargin{end}
                case 'mouse'
                    button = varargin{end-1}.getButton;
                case 'selection'
                    button = 1;
                    selectionId = varargin{end-1};
                otherwise
                    button = 1;
            end
            switch button
                case 1
                    %% display message
                    if ~exist('selectionId','var')
                        pt = this.JTree.getSelectionPath;
                        if isempty(pt)
                            return;
                        end
                        node2Display = pt.getLastPathComponent.getFirstLeaf;
                        selectionId = get(node2Display,'UserData');
                    end
                    stackTrace = this.MTestRunner.Tests(selectionId).StackTrace;
                    if isempty(stackTrace)
                        stackTrace = '';
                    else
                        stackTrace = strrep(stackTrace,[char(10),' '],[char(10),repmat('&nbsp',1,20)]);
                    end
                    str = ['<h1><a href = "matlab:edit(''' fullfile(this.MTestRunner.Tests(selectionId).FilePath,[this.MTestRunner.Tests(selectionId).FileName '.m']) ''');">' this.MTestRunner.Tests(selectionId).Name '</a></h1>'];
                    if isnan(this.MTestRunner.Tests(selectionId).Date)
                        % did not run yet, construct string
                        str = cat(2,str,...
                            '<hr />',...
                            'Did not run yet, please run the test first');
                        this.JTextPane.setBackground(java.awt.Color(0.8, 0.8, 0.8));
                    else
                        testResult = this.MTestRunner.Tests(selectionId).TestResult;
                        ignored = this.MTestRunner.Tests(selectionId).Ignore;
                        if ignored
                            % Ignored
                            this.JTextPane.setBackground(java.awt.Color(1,1,0.4)); % yellow / gray
                            str = cat(2,str,...
                                ['<b>Ignored:</b> ', this.MTestRunner.Tests(selectionId).IgnoreMessage],...
                                '<hr />',...
                                '<br />',...
                                '<code>',...
                                strrep(stackTrace,char(10),'<br />'),...
                                '</code>');
                        elseif testResult
                            % Test Passed
                            this.JTextPane.setBackground(java.awt.Color(0.7,1,0.7)); % light green
                            str = cat(2,str,...
                                '<hr />',...
                                '<br />',...
                                '<code>',...
                                strrep(stackTrace,char(10),'<br />'),...
                                '</code>');
                        else
                            % Test failed
                            this.JTextPane.setBackground(java.awt.Color(1, 0.55, 0.55)); % red-ish
                            str = cat(2,str,...
                                '<hr />',...
                                '<br />',...
                                '<code> ',...
                                strrep(stackTrace,char(10),'<br />'),...
                                '</code>');
                        end
                    end
                    this.JTextPane.setText(str);
                    %% Show top selection in JIDE
                    % Initialize JIDE's usage within Matlab
                    com.mathworks.mwswing.MJUtilities.initJIDE;
                    
                    this.JideList.clear;
                    categories = {...
                        'File Info',...
                        'Help Block',...
                        'Other Info',...
                        'Run'};
                    props = {...
                        'Name','Test Name',1;...
                        'FileName','Filename',1;...
                        'FilePath','File Location',1;...
                        'FunctionName','Function Name',1;...
                        'TimeStamp','Timestamp',1;...
                        'FunctionHeader','Function Header',2;...
                        'H1Line','H1 Line',2;...
                        'Description','Description',2;...
                        'Author','Last Author',3;...
                        'Category','Category',3;...
                        'AutoRefresh','AutoRefresh',3;...
                        'TestResult','Test Passed',4;...
                        'Time','Elapsed Time (s)',4;...
                        'Date','Date',4;...
                        'Ignore','Ignore',4;...
                        'IgnoreMessage','Ignore Message',4};
                    
                    for iprop = 1:length(props)
                        newprop = com.jidesoft.grid.DefaultProperty();
                        newprop.setEditable(false);
                        newprop.setName(props{iprop,2});
                        newprop.setCategory(categories{props{iprop,3}});
                            
                        prop = this.MTestRunner.Tests(selectionId).(props{iprop,1});
                        if any(ismember(props{iprop,1},{'TimeStamp','Date'}))
                            if isnan(prop)
                                prop = '';
                            else
                                prop = datestr(prop);
                            end
                        end
                        switch class(prop)
                            case 'char'
                                newprop.setType(MTestUtils.javaclass('char',1));
                                newprop.setValue(prop);
                            case 'logical'
                                newprop.setType(MTestUtils.javaclass('logical'));
                                newprop.setEditorContext(com.jidesoft.grid.BooleanCheckBoxCellEditor.CONTEXT);
                                newprop.setValue(prop);
                            case 'int'
                                newprop.setType(MTestUtils.javaclass('int32'));
                                newprop.setValue(int32(prop));
                            case 'double'
                                newprop.setType(MTestUtils.javaclass('double'));
                                newprop.setValue(prop);
                            case 'cell'
                                newprop.setType(MTestUtils.javaclass('cellstr'));
                                newprop.setValue(prop);
                            otherwise
                                continue;
                        end
                        this.JideList.add(newprop);
                    end
                  
                    this.JideModel.expandAll();
                    this.JideModel.refresh;
                    
                otherwise
                    %% Set selection
                    row = this.JTree.getClosestRowForLocation(varargin{2}.getX, varargin{2}.getY);  
                    this.JTree.setSelectionRow(row);
                    %% activate context menu
                    set(this.HContextMenu,...
                        'Position',[0 this.JSplitPanel.getHeight] + [varargin{2}.getX, -varargin{2}.getY],...
                        'Visible','on');
            end
        end
        function setteamcity_callback(this,varargin)
            TeamCity.running(strcmp(get(this.HTeamCity,'State'),'on'));
        end
        function viewcoverage(this,varargin)
            selectionId = find(getselectedtestsid(this),1,'first');
            coverage = this.MTestRunner.Tests(selectionId).ProfilerInfo;
            
            if ~isempty(coverage)
                profview(coverage);
            end
        end
%         function testschanged(this,varargin)
%            return; 
%         end
    end
    methods (Hidden = true , Static = true)
        function textpanelinkfunction(varargin)
            eventData = varargin{2};
            description = char(eventData.getDescription); % URL string
            switch char(eventData.getEventType)
                case char(eventData.getEventType.ENTERED)
                    return;
                case char(eventData.getEventType.EXITED)
                    return;
                case char(eventData.getEventType.ACTIVATED)
                    eval(description(min(strfind(description,':'))+1:end));
            end
        end
    end
end

function [tf node] = getchild(baseNode,name)
tf = false;
node = [];
childCount = baseNode.getChildCount;
for i=1:childCount
    child = baseNode.getChildAt(i-1);
    if strcmp(child.toString,name)
        tf = true;
        node = child;
        return;
    end
end
end
function newSelectedNodes = getleafnodesrecursive(rootNode)
newSelectedNodes = {};
if rootNode.isLeaf
    newSelectedNodes = {rootNode};
    return;
end
for ichild = 0:rootNode.getChildCount-1
    newNodes = getleafnodesrecursive(rootNode.getChildAt(ichild));
    newSelectedNodes = cat(1,newSelectedNodes,newNodes);
end
end
function str = node2str(node)
if node.isRoot
    str = char(node.toString);
else
    str = [char(node.getParent.toString) '_' char(node.toString)];
end
end
function parentnodes = getparentsrecursive(node)
parent = node.getParent;
parentnodes = {};
if ~isempty(parent)
    parentnodes = cat(1,{parent},getparentsrecursive(parent));
end
end
function icon = loadicon(filename)
[X map] = imread(which(filename));
icon = ind2rgb(X,map);
icon(icon==0) = nan;
end