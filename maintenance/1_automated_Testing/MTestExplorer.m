classdef MTestExplorer < handle
    properties
        MTestRunner = MTestRunner;
        
        ViewType = 'Directory';
                
        HMainFigure
        
        HToolBar
        HToolBarRun
        HToolBarRunAll
        HToolBarViewSuccess
        HToolBarViewFailed
        HToolBarViewNotRun
        JToolBar
        JCombo
        HTeamCity
        JToolBarProgress
        HProgressToolbar
        JProgressBar
        
        MenuFile
        MenuFileOpen
        MenuFileSave
        MenuFileNewTest
        MenuFileClose
        MenuSession
        MenuSessionAddTest
        MenuSessionEditTest
        MenuSessionSearchTestsAdd
        MenuSessionSearchTestsReplace
        MenuSessionRemoveTest
        MenuSessionclearTest
        MenuRun
        MenuRunSelected
        MenuRunAll

        JSplitPanelMain
        
        JidePane
        JideGrid
        JideModel
        JideList
        
        % Splitpanel
        HSplitPanel
        JSplitPanel
        
        % UpperPanel
        JTreePanel
        JScrollPane
        JTree
        JTreeModel
        JTreeRootNode
        JTreeAllNodes
        AllNodesExpandedFlag
                        
        % LowerPanel
        JTextPane
        
        JStatusBar
        
        HContextMenu
        HContextMenuRun
        HContextMenuRemove
        HContextMenuRunAll
        HContextMenuNewTest
        HContextMenuEditTests
        HContextMenuAddTest
        HContextMenuRemoveTest
        HContextMenuSearchTestsAdd
        HContextMenuSearchTestsRemove
        HContextMenuClearSession
    end
    properties (Hidden = true)
%         PropertyChangedListeners = [];
        BuildingTree = false;
    end
    
    methods
        function this = MTestExplorer(varargin)
            this.HMainFigure = figure(...
                'NumberTitle','off',...
                'Name','Unit Test Explorer',...
                'HandleVisibility','off',...
                 'MenuBar','none',...
                'Toolbar','none',...
                'Units','pix',...
                'Position',[100 100 1200 300]);
            guidata(this.HMainFigure,this);
            
            %% Initialize MTestRunner
            this.MTestRunner.Publish = false;
            this.MTestRunner.Verbose = false;
            tests = MTest;
            tests(1)=[];
            this.MTestRunner.Tests = tests;
            
%             this.PropertyChangedListeners = addlistener(...
%                 this.MTestRunner, ...
%                 'Tests', ...
%                 'PostSet', @this.testschanged);
            
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
            
            %% Create dropdown box in toolbar
            drawnow;
            this.JToolBar = get(get(this.HToolBar,'JavaContainer'),'ComponentPeer');
            if ~isempty(this.JToolBar)
                choices = {'Show by <directory structure>','Show by <category>'};
                this.JCombo = javax.swing.JComboBox(choices);
                set(this.JCombo, 'ActionPerformedCallback', @this.buildtree);
                this.JToolBar(1).addSeparator;
                this.JToolBar(1).add(this.JCombo,8);
                this.JToolBar(1).repaint;
                this.JToolBar(1).revalidate;
                this.JCombo.setMaximumSize(java.awt.Dimension(200,25))
            end
            
            this.HProgressToolbar = uitoolbar(this.HMainFigure);
            drawnow;
            this.JToolBarProgress = get(get(this.HProgressToolbar,'JavaContainer'),'ComponentPeer');
            this.JProgressBar = javax.swing.JProgressBar;
            this.JToolBarProgress(1).add(this.JProgressBar,1);
            this.JToolBarProgress(1).repaint;
            this.JToolBarProgress(1).revalidate;
            this.JProgressBar.setVisible(1);
            set(this.JProgressBar,'StringPainted','on');
            this.JProgressBar.setString('Idle...');

            %% Create tree
            import javax.swing.tree.*
            import javax.swing.*
            import java.awt.*;
            this.JTreePanel = javax.swing.JPanel;
            this.JTreePanel.setLayout(BorderLayout);
            this.JTree = javax.swing.JTree;
            set(this.JTree,...
                'MouseClickedCallback',{@this.mouseclickedontree_callback,'mouse'},...
                'TreeExpandedCallback',@this.treeexpanded_callback,...
                'KeyPressedCallback',{@this.mouseclickedontree_callback,'keypress'},...
                'TreeCollapsedCallback',@this.treecollapsed_callback);
            this.JScrollPane = JScrollPane(this.JTree); %#ok<CPROP,PROP>
            this.JTreePanel.add(this.JScrollPane);
            this.JTree.setRootVisible(false);
            this.JTreeModel = this.JTree.getModel();
            this.JTreeRootNode = DefaultMutableTreeNode('RootNode');
            this.JTreeModel.setRoot(this.JTreeRootNode);
            this.JTree.getSelectionModel().setSelectionMode(TreeSelectionModel.CONTIGUOUS_TREE_SELECTION);
            
            renderer = this.JTree.getCellRenderer;
            renderer.setLeafIcon(ImageIcon(which('testicon_16.gif')));
            this.JTree.setCellRenderer(renderer);
            this.JTree.repaint;
            set(this.JTree,'UserData',this);

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
                        
            %% Create split panels
            splitmain = javax.swing.JSplitPane(1);
            
            this.JSplitPanel = javax.swing.JSplitPane(0);
            this.JSplitPanel.add(this.JTreePanel,0);
            this.JSplitPanel.add(jTextPanel,1);
            
            
            % Prepare a properties table containing the list
            % Initialize JIDE's usage within Matlab
            com.mathworks.mwswing.MJUtilities.initJIDE;
            this.JideList = java.util.ArrayList();
            this.JideModel = com.jidesoft.grid.PropertyTableModel(this.JideList);
            this.JideModel.expandAll();
            this.JideGrid = com.jidesoft.grid.PropertyTable(this.JideModel);
            this.JidePane = com.jidesoft.grid.PropertyPane(this.JideGrid);
            splitmain.add(this.JSplitPanel,1);
            splitmain.add(this.JidePane,0);
            
            % add splitpanel to gui
            [this.JSplitPanelMain this.HSplitPanel] = javacomponent(splitmain,getpixelposition(this.HMainFigure).*[0 0 1 1],this.HMainFigure);
            set(this.HSplitPanel,'Units','normalized','Position',[0 0 1 1]);
            drawnow;
            this.JSplitPanel.setDividerLocation(0.5);
            this.JSplitPanelMain.setDividerLocation(0.8);
            
            %% Context menu
            this.HContextMenu = uicontextmenu('Parent',this.HMainFigure);
            this.HContextMenuRun = uimenu(this.HContextMenu,...
                'Label','Run',...
                'Callback',@this.run);
            this.HContextMenuRunAll = uimenu(this.HContextMenu,...
                'Label','Run All',...
                'Callback',@this.runall);
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
        end
    end
    methods
        function run(this,varargin)
            selectionId = getselectedtestsid(this);
            this.runtests(selectionId);
        end
        function runall(this,varargin)
            selectionId = true(size(this.MTestRunner.Tests));
            this.runtests(selectionId);
        end
        function runtests(this,selectionId)
            this.JProgressBar.setVisible(1);
            set(this.JProgressBar, ...
                'Maximum',sum(selectionId), ...
                'Value',0);
            this.JProgressBar.setForeground(java.awt.Color(0.3,0.5,0.3))
            for itests = 1:length(selectionId)
                if selectionId(itests)
                    this.setteamcity_callback; %In case some test has altered the prop
                    this.JProgressBar.setString(['Running: ' this.MTestRunner.Tests(itests).Name ' (' num2str(round((sum(selectionId(1:itests-1))/sum(selectionId))*100))  '%)']);
                    this.MTestRunner.Tests(itests).AutoRefresh = true;
                    this.MTestRunner.Tests(itests).Ignore = false;
                    this.MTestRunner.Tests(itests).run;
                    if ~this.MTestRunner.Tests(itests).TestResult
                        this.JProgressBar.setForeground(java.awt.Color(1, 0.3, 0.3));
                    end
                    set(this.JProgressBar, 'Value',sum(selectionId(1:itests)));
                    this.buildtree;
                    this.mouseclickedontree_callback(itests,'selection');
                end
            end
            this.JProgressBar.setString('Idle...');
        end
        function buildtree(this,varargin)
            this.BuildingTree = true;
            
            import javax.swing.tree.*
            import javax.swing.*
            import java.awt.*;
            
            if nargin > 1 && ~ischar(varargin{end})
                if any(strfind(get(varargin{1},'SelectedItem'),'categ'));
                    this.ViewType = 'Category';
                else
                    this.ViewType = 'Directory';
                end
            end
                
            %% Gather visibility
            showNotRun = strcmp(get(this.HToolBarViewNotRun,'State'),'on');
            showSuccess = strcmp(get(this.HToolBarViewSuccess,'State'),'on');
            showFailed = strcmp(get(this.HToolBarViewFailed,'State'),'on');

            %% Make root for Category tree
            rootNode = DefaultMutableTreeNode('RootNode');
            
            oldNodes = this.JTreeAllNodes;
            this.JTreeAllNodes = {};
            %this.JTestNodes = {};
            
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
                if testExecutedFlag
                    if this.MTestRunner.Tests(itests).Ignore
                        newNode = DefaultMutableTreeNode([this.MTestRunner.Tests(itests).Name '  (Ignored)']);
                    elseif testResult
                        newNode = DefaultMutableTreeNode([this.MTestRunner.Tests(itests).Name '  (Passed)']);
                    else
                        newNode = DefaultMutableTreeNode([this.MTestRunner.Tests(itests).Name '  (Failed)']);
                    end
                else
                    newNode = DefaultMutableTreeNode(this.MTestRunner.Tests(itests).Name);
                end
                set(newNode,'UserData',itests);
                
                baseNode = rootNode;
                switch this.ViewType
                    case 'Directory'
                        %% place in dirstructure tree
                        testPath = strread(this.MTestRunner.Tests(itests).FilePath,'%s',-1,'delimiter',[filesep filesep]);
                        for ip = 2:length(testPath)
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
                end
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
            
            import javax.swing.tree.*
            if isempty(this.JTreeAllNodes)
                return;
            end
            
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
            this.BuildingTree = false;
        end
        function edittest(this,varargin)
            selectionId = getselectedtestsid(this);
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
                    if isnan(this.MTestRunner.Tests(selectionId).Date)
                        % did not run yet, construct string
                        str = ['<h1>' this.MTestRunner.Tests(selectionId).Name '</h1>',...
                            '<hr />',...
                            'Did not run yet, please run the test first'];
                        this.JTextPane.setBackground(java.awt.Color(0.8, 0.8, 0.8));
                    else
                        testResult = this.MTestRunner.Tests(selectionId).TestResult;
                        ignored = this.MTestRunner.Tests(selectionId).Ignore;
                        if ignored
                            % Ignored
                            this.JTextPane.setBackground(java.awt.Color(1,1,0.4)); % yellow / gray
                            str = ['<h1>' this.MTestRunner.Tests(selectionId).Name '</h1>',...
                                ['<b>Ignored:</b> ', this.MTestRunner.Tests(selectionId).IgnoreMessage],...
                                '<hr />',...
                                '<br />',...
                                '<code>',...
                                strrep(stackTrace,char(10),'<br />'),...
                                '</code>'];
                        elseif testResult
                            % Test Passed
                            this.JTextPane.setBackground(java.awt.Color(0.7,1,0.7)); % light green
                            str = ['<div style="border-style:solid"><h1>' this.MTestRunner.Tests(selectionId).Name '</h1></div>',...
                                '<hr />',...
                                '<br />',...
                                '<code>',...
                                strrep(stackTrace,char(10),'<br />'),...
                                '</code>'];
                        else
                            % Test failed
                            this.JTextPane.setBackground(java.awt.Color(1, 0.55, 0.55)); % red-ish
                            str = ['<h1>' this.MTestRunner.Tests(selectionId).Name '</h1>',...
                                '<hr />',...
                                '<br />',...
                                '<code> ',...
                                strrep(stackTrace,char(10),'<br />'),...
                                '</code>'];
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
                                newprop.setType(javaclass('char',1));
                                newprop.setValue(prop);
                            case 'logical'
                                newprop.setType(javaclass('logical'));
                                newprop.setEditorContext(com.jidesoft.grid.BooleanCheckBoxCellEditor.CONTEXT);
                                newprop.setValue(prop);
                            case 'int'
                                newprop.setType(javaclass('int32'));
                                newprop.setValue(int32(prop));
                            case 'double'
                                newprop.setType(javaclass('double'));
                                newprop.setValue(prop);
                            case 'cell'
                                newprop.setType(javaclass('cellstr'));
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