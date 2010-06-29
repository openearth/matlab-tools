classdef MTestInterface < handle
    properties
        MTestRunner = MTestRunner;
        
        ViewType = 'Directory';
                
        HMainFigure
        
        HToolBar
        HToolBarRun
        HToolBarRunAll
        
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
        
        HProgressToolbar
        
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
        JProgressBar
        
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
        PropertyChangedListeners = [];
        BuildingTree = false;
    end
    
    methods
        function this = MTestInterface(varargin)
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
            
            this.PropertyChangedListeners = addlistener(...
                this.MTestRunner, ...
                'Tests', ...
                'PostSet', @this.testschanged);
            
            %% Create Menu items
            this.MenuFile = uimenu(this.HMainFigure,...
                'Label','File');
            this.MenuFileOpen = uimenu(this.MenuFile,...
                'Label','&Open session',...
                'Enable','off',...
                'Callback',[]);
            this.MenuFileSave = uimenu(this.MenuFile,...
                'Label','&Save session',...
                'Enable','off',...
                'Callback',[]);
            this.MenuFileNewTest = uimenu(this.MenuFile,...
                'Label','&Create New Test',...
                'Callback','oetnewtest;');
            this.MenuFileClose = uimenu(this.MenuFile,...
                'Label','&Close',...
                'Separator','on',...
                'Callback',@this.menufileclose_callback);
            this.MenuSession = uimenu(this.HMainFigure,...
                'Label','Session');
            this.MenuSessionAddTest = uimenu(this.MenuSession,...
                'Label','Add Single Test',...
                'Callback',@this.menusessionaddtest_callback);
            this.MenuSessionEditTest = uimenu(this.MenuSession,...
                'Label','Edit Test(s)',...
                'Callback',@this.edittest);
            this.MenuSessionSearchTestsAdd = uimenu(this.MenuSession,...
                'Label','Search Tests (add)',...
                'Callback',{@this.menusessionsearchtest_callback,'add'});
            this.MenuSessionSearchTestsReplace = uimenu(this.MenuSession,...
                'Label','Search Tests (new session)',...
                'Callback',{@this.menusessionsearchtest_callback,'remove'});
            this.MenuSessionRemoveTest = uimenu(this.MenuSession,...
                'Label','Remove Test(s)',...
                'Separator','on',...
                'Callback',@this.menusessionremovetest_callback);
            this.MenuSessionclearTest = uimenu(this.MenuSession,...
                'Label','Clear Session',...
                'Callback',@this.menusessioncleartest_callback);
            
            this.MenuRun = uimenu(this.HMainFigure,...
                'Label','Run');
            this.MenuRunSelected = uimenu(this.MenuRun,...
                'Label','Run selected test',...
                'Callback',{@this.run});
            this.MenuRunAll = uimenu(this.MenuRun,...
                'Label','Run all tests',...
                'Callback',@this.runall);
            
            %% CReate Toolbar
            this.HToolBar = uitoolbar(this.HMainFigure);
            [X map] = imread(which('RunOne.gif'));
            icon = ind2rgb(X,map);
            icon(icon==0) = nan;
            this.HToolBarRun = uipushtool(this.HToolBar,...
                'CData',icon,...
                'ToolTip','Run selected test',...
                'ClickedCallback',@this.run);
            [X map] = imread(which('RunAll.gif'));
            icon = ind2rgb(X,map);
            icon(icon==0) = nan;
            this.HToolBarRun = uipushtool(this.HToolBar,...
                'CData',icon,...
                'ToolTip','Run all tests',...
                'ClickedCallback',@this.runall);
            
            %% Create dropdown box in toolbar
            drawnow;
            jToolbar = get(get(this.HToolBar,'JavaContainer'),'ComponentPeer');
            if ~isempty(jToolbar)
                choices = {'Show by <directory structure>','Show by <category>'};
                jCombo = javax.swing.JComboBox(choices);
                set(jCombo, 'ActionPerformedCallback', @this.buildtree,...
                    'UserData',this);
                jToolbar(1).addSeparator;
                jToolbar(1).add(jCombo,4);
                jToolbar(1).addSeparator;
                jCombo.setSize(0.5,1);
                jToolbar(1).repaint;
                jToolbar(1).revalidate;
            end
            
            this.HProgressToolbar = uitoolbar(this.HMainFigure);
            drawnow;
            jToolbar = get(get(this.HProgressToolbar,'JavaContainer'),'ComponentPeer');
            this.JProgressBar = javax.swing.JProgressBar;
            jToolbar(1).add(this.JProgressBar,1);
            jToolbar(1).repaint;
            jToolbar(1).revalidate;
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
                        
            jScrollPane = javax.swing.JScrollPane(this.JTextPane);
            
            jTextPanel = javax.swing.JPanel;
            jTextPanel.setLayout(BorderLayout);
            jTextPanel.add(jScrollPane);
                        
            %% Create split panel
            split = javax.swing.JSplitPane(0);
            
            split.add(this.JTreePanel,0);
            split.add(jTextPanel,1);

            % add splitpanel to gui
            [this.JSplitPanel this.HSplitPanel] = javacomponent(split,getpixelposition(this.HMainFigure).*[0 0 1 1],this.HMainFigure);
            set(this.HSplitPanel,'Units','normalized','Position',[0 0 1 1]);
            drawnow;
            this.JSplitPanel.setDividerLocation(0.5);
            
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
            set(this.JProgressBar, 'Maximum',sum(selectionId), 'Value',0);
            for itests = 1:length(selectionId)
                if selectionId(itests)
                    this.JProgressBar.setString(['Running: ' this.MTestRunner.Tests(itests).Name ' (' num2str(round((sum(selectionId(1:itests-1))/sum(selectionId))*100))  '%)']);
                    this.MTestRunner.Tests(itests).run;
                    set(this.JProgressBar, 'Value',sum(selectionId(1:itests)));
                end
            end
            this.JProgressBar.setString('Idle...');
            set(this.JProgressBar, 'Value',0);
        end
        function buildtree(this,varargin)
            this.BuildingTree = true;
            
            import javax.swing.tree.*
            import javax.swing.*
            import java.awt.*;
            
            if nargin > 1 && any(strfind(get(varargin{1},'SelectedItem'),'categ'));
                this.ViewType = 'Category';
            else
                this.ViewType = 'Directory';
            end
                
            %% Make root for Category tree
            rootNode = DefaultMutableTreeNode('RootNode');
            
            oldNodes = this.JTreeAllNodes;
            this.JTreeAllNodes = {};
            %this.JTestNodes = {};
            
            for itests = 1:length(this.MTestRunner.Tests);
                %% make treenode for test
                newNode = DefaultMutableTreeNode(this.MTestRunner.Tests(itests).Name);
                set(newNode,'UserData',itests);
%                 this.JTestNodes{itests} = newNode;
                
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
                otherwise
                    button = 1;
            end
            switch button
                case 1
                    %% display message
                    pt = this.JTree.getSelectionPath;
                    if isempty(pt)
                        return;
                    end
                    node2Display = pt.getLastPathComponent.getFirstLeaf;
                    selectionId = get(node2Display,'UserData');
                    if this.MTestRunner.Tests(selectionId).TestResult
                        this.JTextPane.setBackground(java.awt.Color.green);
                        str = ['<h1>' this.MTestRunner.Tests(selectionId).Name '</h1>',...
                                'Test went well!'];
                    else
                        stackTrace = this.MTestRunner.Tests(selectionId).StackTrace;
                        if isempty(stackTrace)
                            % did not run yet, construct string
                            str = ['<h1>' this.MTestRunner.Tests(selectionId).Name '</h1>',...
                                'Did not run yet, please run the test first'];
                            this.JTextPane.setBackground(java.awt.Color.gray);
                        else
                            % Remove hyperlinks from messages
                            id1 = unique(cat(2,strfind(stackTrace,'<a href'),strfind(stackTrace,'</a')));
                            id2 = strfind(stackTrace,'>');
                            for ii = length(id1):-1:1
                                stackTrace(id1(ii):min(id2(id2>id1(ii)))) = [];
                            end
                            % construct string
                            str = ['<h1>' this.MTestRunner.Tests(selectionId).Name '</h1>',...
                                strrep(stackTrace,char(10),'<br />')];
                            this.JTextPane.setBackground(java.awt.Color.red);
                        end
                    end
                    this.JTextPane.setText(str);
                otherwise
                    %% activate context menu
                    set(this.HContextMenu,...
                        'Position',[0 this.JSplitPanel.getHeight] + [varargin{2}.getX, -varargin{2}.getY],...
                        'Visible','on');
            end
        end
        function testschanged(this,varargin)
           return; 
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