classdef MTestCoverageBrowser < handle
    properties
        HMainFigure
        HMenuBar
        
        HBrowser
        JBrowser
        
        CoverageHTML
        CoverageHTMLURL
    end
    methods
        function this = MTestCoverageBrowser(varargin)
            if nargin<1
                return;
            end
            
            if exist(varargin{1},'file')
                [pt name ext] = fileparts(varargin{1});
                if isempty(pt)
                    pt = fileparts(which(varargin{1}));
                end
                this.CoverageHTMLURL = fullfile(pt,[name,ext]);
            else
                this.CoverageHTML = varargin{1};
            end
            
            this.HMainFigure = figure(...
                'Name','Coverage Viewer',...
                'MenuBar','none',...
                'NumberTitle','off',...
                'Units','pix',...
                'Visible','off',...
                'Position',[150 150 1200 500]);
            guidata(this.HMainFigure,this);
            
            this.HMenuBar = uitoolbar(this.HMainFigure);
            
            drawnow;
            warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
            jFrame = get(this.HMainFigure,'JavaFrame');
            if datenum(version('-date')) > datenum(2010,1,1)
                jFrame.setFigureIcon(javax.swing.ImageIcon(which('DeltaresLogoWhiteTransparant.gif')));
            else
                jFrame.setFigureIcon(javax.swing.ImageIcon(which('DeltaresLogoWhiteTransparantSmall.gif')));
            end
            setFigDockGroup(this.HMainFigure,'MTest');
            
            set(this.HMainFigure,...
                'WindowStyle','docked',...
                'Visible','on');
            
            % Add the browser object
            jObject = com.mathworks.mlwidgets.html.HTMLBrowserPanel;
            [this.JBrowser,this.HBrowser] = javacomponent(jObject, [], this.HMainFigure);
            set(this.HBrowser,...
                'Units','normalized',...
                'Position',[0,0,1,1]);
            
            if ~isempty(this.CoverageHTML)
                this.JBrowser.setHtmlText(this.CoverageHTML);
            else
                this.JBrowser.setCurrentLocation(this.CoverageHTMLURL);
            end
        end
    end
end