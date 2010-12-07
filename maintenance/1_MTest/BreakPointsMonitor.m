classdef BreakPointsMonitor < handle
    properties (SetObservable = true)
        CurrentBreakPoints;
    end
    
    properties
       Figure;
       Table;
       Timer = timer;
    end
            
    methods
        function this = BreakPointsMonitor(varargin)
            if nargin > 0
                error('BreakPointsMonitor:NargIn','BreakPointsMonitor does not accept input arguments');
            end
            
            set(this.Timer,'Period',1);
            set(this.Timer,'ExecutionMode','fixedSpacing');
            set(this.Timer,'TimerFcn',@this.update);
            set(this.Timer,'StopFcn','disp(''timer stopped working'');');
            start(this.Timer);
                        
            this.show;
        end
        
        function update(this,varargin)
            this.gatherbreakpoints;
            this.settabledata;
        end
        function gatherbreakpoints(this)
            this.CurrentBreakPoints = dbstatus;
        end
        
        function show(this)
            % Close ==> remove object from memory
            %% Create main figure
            this.Figure = figure(...
                'NumberTitle','off',...
                'Name','Unit Test Explorer',...
                'HandleVisibility','off',...
                'MenuBar','none',...
                'Toolbar','none',...
                'Units','pix',...
                'Visible','off',...
                'Position',[100 100 1200 300]);
            % Save object to figure so it does not get lost
            guidata(this.Figure,this);

            drawnow;
            warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
            jFrame = get(this.Figure,'JavaFrame');
            if datenum(version('-date')) > datenum(2010,1,1)
                jFrame.setFigureIcon(javax.swing.ImageIcon(which('DeltaresLogoWhiteTransparant.gif')));
            else
                jFrame.setFigureIcon(javax.swing.ImageIcon(which('DeltaresLogoWhiteTransparantSmall.gif')));
            end
            setFigDockGroup(this.Figure,'BreakPoints');

            set(this.Figure,...
                'WindowStyle','docked',...
                'Visible','on');
            
            this.Table = uitable(this.Figure,...
                'Units','normalized',...
                'Position',[0,0,1,1],...
                'Data',{' ',' ',' '},...
                'CellEditCallback',@this.celleditcallback,...
                'ColumnName',{'Enabled','Location','Condition'},...
                'ColumnFormat',{'logical','char','char'},...
                'ColumnEditable',[true, false, true],...
                'ColumnWidth',{50, 'auto', 'auto'},...
                'RearrangeableColumn','on');
            
            this.settabledata;
        end
        
        function celleditcallback(this, varargin)
            disp('test');
            
            changeData = varargin{2};
            ref = get(this.Table,'UserData');
            ref = ref(changeData.Indices(1),:);
                        
            newBreakPoints = this.CurrentBreakPoints;
            if length(newBreakPoints) < ref(1)
                error('oops');
            end
            
            if ref(2) > newBreakPoints(ref(1)).line
                error('oops');
            end 

            switch changeData.Indices(2)
                case 1
                    % enable / disable breakpoint
                    if ~changeData.NewData
                        % disable
                        expression = newBreakPoints(ref(1)).expression{ref(2)};
                        if isempty(expression)
                            expression = 'false';
                        elseif strncmp(expression, '(', 1) && strncmp(fliplr(expression), ')', 1)
                            expression = ['false&&' expression];
                        else
                            expression = ['false&&(' expression ')'];
                        end
                    else
                        % enable
                        expression = newBreakPoints(ref(1)).expression{ref(2)};
                        if strcmp(expression,'false')
                            expression = '';
                        end
                        if strncmp(expression,'false&&',7)
                            if ~isempty(expression < 8 )
                                expression = '';
                            else
                                expression = expression(8:end);
                            end
                        end
                    end
                    newBreakPoints(ref(1)).expression{ref(2)} = expression;
                    dbstop(newBreakPoints);
                case 2
                    % do nothing
                case 3
                    % edit condition
            end
            
        end 
        function settabledata(this)
            if isempty(this.CurrentBreakPoints) || isempty(this.Figure) || ~ishandle(this.Figure)
                set(this.Table,'Data',{});
                return;
            end
            
            table = cell(length([this.CurrentBreakPoints.line]),3);
            cnt = 1;
            ref = [];
            for i=1:length(this.CurrentBreakPoints)
                bp = this.CurrentBreakPoints(i);
                for iline = 1:length(bp.line)
                    
                    expression = bp.expression{iline};
                    table{cnt,1} = true;
                    
                    table{cnt,2} = [bp.name, ', line ' num2str(bp.line(iline))];
                    
                    if strncmp(expression,'false',5)
                        table{cnt,1} = false;
                        if length(expression)>5
                            expression = expression(6:end);
                            if strncmp(expression,'&&',2)
                                expression = expression(3:end);
                            end
                        else
                            expression = '';
                        end
                    end
                    table{cnt,3} = expression;
                    
                    ref(cnt,1:2) = [i, iline]; %#ok<AGROW>
                    
                    cnt = cnt + 1;
                end
            end
            set(this.Table,'Data',table);
            set(this.Table,'UserData',ref);
        end
    end
end