classdef MTestInterface < handle
    properties
        MTestRunner = MTestRunner;
        
        ViewType = 'Category';
                
        HMainFigure
        
        HToolBar
        HToolBarRun
        HToolBarRunAll
        
        MenuFile
        MenuFileClose
        MenuSession
        MenuSessionAddTest
        MenuSessionRemoveTest
        MenuSessionSearchTestsAdd
        MenuSessionSearchTestsReplace
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
        JTestNodes
        
        % LowerPanel
        JTextComponent
        
        JStatusBar
        JProgressBar
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
            
            %% Create Menu items
            this.MenuFile = uimenu(this.HMainFigure,...
                'Label','File');
            this.MenuFileClose = uimenu(this.MenuFile,...
                'Label','&Close',...
                'Callback',{@MTestInterface.menufileclose_callback});
            this.MenuSession = uimenu(this.HMainFigure,...
                'Label','Session');
            this.MenuSessionAddTest = uimenu(this.MenuSession,...
                'Label','Add Test',...
                'Callback',{@MTestInterface.menusessionaddtest_callback});
            this.MenuSessionRemoveTest = uimenu(this.MenuSession,...
                'Label','Remove Test',...
                'Enable','off',...
                'Callback',{@MTestInterface.menusessionremovetest_callback});
            this.MenuSessionSearchTestsAdd = uimenu(this.MenuSession,...
                'Label','Search tests and add to session',...
                'Enable','off',...
                'Separator','on',...
                'Callback',{@MTestInterface.menusessionsearchtest_callback,'add'});
            this.MenuSessionSearchTestsReplace = uimenu(this.MenuSession,...
                'Label','Search tests and replace current session',...
                'Enable','off',...
                'Callback',{@MTestInterface.menusessionsearchtest_callback,'remove'});
            
            this.MenuRun = uimenu(this.HMainFigure,...
                'Label','Tests');
            this.MenuRunSelected = uimenu(this.MenuRun,...
                'Label','Run selected test',...
                'Enable','off',...
                'Callback',{});
            this.MenuRunAll = uimenu(this.MenuRun,...
                'Label','Run all tests',...
                'Callback',{@MTestInterface.runall});
            
            %% CReate Toolbar
            this.HToolBar = uitoolbar(this.HMainFigure);
            [X map] = imread(which('RunOne.gif'));
            icon = ind2rgb(X,map);
            icon(icon==0) = nan;
            this.HToolBarRun = uipushtool(this.HToolBar,...
                'CData',icon,...
                'ToolTip','Run selected test',...
                'ClickedCallback',{@MTestInterface.run});
            [X map] = imread(which('RunAll.gif'));
            icon = ind2rgb(X,map);
            icon(icon==0) = nan;
            this.HToolBarRun = uipushtool(this.HToolBar,...
                'CData',icon,...
                'ToolTip','Run all tests',...
                'ClickedCallback',{@MTestInterface.runall});
            
            %% Create dropdown box in toolbar
            drawnow;
            jToolbar = get(get(this.HToolBar,'JavaContainer'),'ComponentPeer');
            if ~isempty(jToolbar)
                choices = {'Show by <directory structure>','Show by <category>'};
                jCombo = javax.swing.JComboBox(choices);
                jCombo.setSize(100,20);
                set(jCombo, 'ActionPerformedCallback', {@MTestInterface.buildtrees},...
                    'UserData',this);
                jToolbar(1).addSeparator;
                jToolbar(1).add(jCombo,4);
                jToolbar(1).addSeparator;
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
            set(this.JTree,'MouseClickedCallback',{@MTestInterface.mouseclickedontree_callback});
            this.JScrollPane = JScrollPane(this.JTree); %#ok<CPROP,PROP>
            this.JTreePanel.add(this.JScrollPane);
            this.JTree.setRootVisible(false);
            this.JTreeModel = this.JTree.getModel();
            this.JTreeRootNode = DefaultMutableTreeNode('RootNode');
            this.JTreeModel.setRoot(this.JTreeRootNode);
            

            %% Create split panel
            split = javax.swing.JSplitPane(0);
            this.JTextComponent = javax.swing.JLabel;
            
            split.add(this.JTreePanel,0);
            split.add(this.JTextComponent,1);

            % add splitpanel to gui
            [this.JSplitPanel this.HSplitPanel] = javacomponent(split,getpixelposition(this.HMainFigure).*[0 0 1 1],this.HMainFigure);
            set(this.HSplitPanel,'Units','normalized','Position',[0 0 1 1]);
            drawnow;
            this.JSplitPanel.setDividerLocation(0.5);
        end
    end
    methods (Static = true)
        function runall(varargin)
            this = guidata(varargin{1});
            this.JProgressBar.setVisible(1);
            set(this.JProgressBar, 'Maximum',length(this.MTestRunner.Tests), 'Value',0);
            for itests = 1:length(this.MTestRunner.Tests)
                this.JProgressBar.setString(['Running: ' this.MTestRunner.Tests(itests).Name ' (' num2str(round(((itests-1)/length(this.MTestRunner.Tests))*100))  '%)']);
                this.MTestRunner.Tests(itests).run;
                set(this.JProgressBar, 'Value',itests);
            end
            this.JProgressBar.setString('Idle...');
        end
        function gathertests(varargin)
            this = guidata(varargin{1});
            % contruct nodes in loop
            this.MTestRunner.cataloguetests;
        end
        function buildtrees(varargin)
            if isa(varargin{1},'MTestInterface');
                this = varargin{1};
            else
                this = get(varargin{1},'UserData');
                if any(strfind(get(varargin{1},'SelectedItem'),'categ'));
                    this.ViewType = 'Category';
                else
                    this.ViewType = 'Directory';
                end
            end
            
            import javax.swing.tree.*
            import javax.swing.*
            import java.awt.*;
            
            %% Make root for Category tree
            rootNode = DefaultMutableTreeNode('RootNode');

            this.JTestNodes = {};
            for itests = 1:length(this.MTestRunner.Tests);
                %% make treenode for test
                newNode = DefaultMutableTreeNode(this.MTestRunner.Tests(itests).Name);
                this.JTestNodes{itests,1} = newNode;
                
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
                                    baseNode = new;
                                    continue;
                                end
                            else
                                new = DefaultMutableTreeNode(testPath{ip});
                                baseNode.add(new);
                                baseNode = new;
                            end
                        end
                        position = baseNode.getChildCount;
                        this.JTreeModel.insertNodeInto(newNode,baseNode,position);
                
                    case 'Category'
                        %% place in category tree
                        baseNode = rootNode;
                        if isempty(this.MTestRunner.Tests(itests).Category)
                            this.MTestRunner.Tests(itests).Category = 'UnCategorized';
                        end
                        [tf catNode] = getchild(baseNode,this.MTestRunner.Tests(itests).Category);
                        if ~tf
                            catNode = DefaultMutableTreeNode(this.MTestRunner.Tests(itests).Category);
                            position = baseNode.getChildCount;
                            this.JTreeModel.insertNodeInto(catNode,baseNode,position);
                        end
                        position = catNode.getChildCount;
                        this.JTreeModel.insertNodeInto(newNode,catNode,position);
                end
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
            
            for i=0:this.JTree.getRowCount+1
                this.JTree.expandRow(i);
            end
        end
    end
    methods (Hidden = true, Static = true)
        function menufileclose_callback(varargin)
            this = guidata(varargin{1});
            delete(this.HMainFigure);
        end
        function menusessionaddtest_callback(varargin)
            this = guidata(varargin{1});
            [filename, pathname] = uigetfile('*_test.m', 'Pick a test definition');
            if isequal(filename,0) || isequal(pathname,0)
               return; 
            end
            try
                newTest = MTest(fullfile(pathname, filename));
            catch
                return;
            end
            if ~isempty(newTest)
                this.MTestRunner.Tests(end+1) = newTest;
            end
            MTestInterface.buildtrees(this);
        end
        function menusessionremovetest_callback(varargin)
            return;
        end
        function menusessionsearchtest_callback(varargin)
            return;
        end
        function mouseclickedontree_callback(varargin)
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
