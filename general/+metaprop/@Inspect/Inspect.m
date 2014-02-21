classdef Inspect < oop.handle_light
% inspect a class with a user interface
% inspired by:
%	  propertiesGUI by Yair M. Altman: altmany(at)gmail.com;
%     http://www.mathworks.com/matlabcentral/fileexchange/38864-propertiesgui-display-properties-in-an-editable-context-aware-table
%   and  
%     PropertyGrid by Levente Hunyadi
%     http://www.mathworks.com/matlabcentral/fileexchange/28732-property-grid-using-jide-implementation/content/PropertyGrid.m

    properties
        Figure
        Object % object to be inspected
    end
    methods
        function self = Inspect(Object)
            % input check
            isprop(Object,'metaprops','Inspect can only inspect objects with metaprops');
            
            self.Object = Object;
            
            % Initialize JIDE's usage within Matlab
            com.mathworks.mwswing.MJUtilities.initJIDE;
            
            % Prepare the properties list:
            list = java.util.ArrayList();
            propnames = fieldnames(Object.metaprops);
            for ii = 1:length(propnames)
                propname = propnames{ii};
                metaprop = self.Object.metaprops.(propname);
                jProp       = metaprop.jProp(self.Object.(propname));
                list.add(jProp);
            end
            
            % Prepare a properties table containing the list
            model = com.jidesoft.grid.PropertyTableModel(list);
            model.expandFirstLevel();
            grid = com.jidesoft.grid.PropertyTable(model);
            pane = com.jidesoft.grid.PropertyPane(grid);
            
            hModel = handle(model, 'CallbackProperties');
            set(hModel, 'PropertyChangeCallback', @self.callback_onPropertyChange);
            
            % Display the properties pane onscreen
            self.Figure = figure(...
                'Number', 'off',...
                'Name',   'Application properties',...
                'Units',  'pixel',...
                'Pos',    [300,200,300,500],...
                'Menu',   'none',...
                'Toolbar','none',...
                'Tag',    'fpropertiesGUI',...
                'Visible','off',...
                'CloseRequestFcn',@(varargin) self.delete);
            % Set the figure icon & make visible
            jFrame = get(handle(self.Figure),'JavaFrame');
            icon = javax.swing.ImageIcon(fullfile(matlabroot, '/toolbox/matlab/icons/tool_legend.gif'));
            jFrame.setFigureIcon(icon);
            set(self.Figure, 'Visible','on'); % 'WindowStyle','modal',
            panel = uipanel(self.Figure);
            ppos = getpixelposition(panel);
            javacomponent(pane, [0 0 ppos(3) ppos(4)], panel);
        end
        
        function callback_onPropertyChange(self, model, event)
            newValue = event.getNewValue();
            jProp = model.getProperty(event.getPropertyName());
            
            % discern between normal and child properties
            if jProp.getLevel > 0
                % by convention, the index of the property is the last bit of the
                % name, so name ends with (x,y,z)
                index = regexp(char(jProp.getName),'\d+(?=[,\d]*\)$)','match');
                index = cellfun(@str2double,index,'UniformOutput',false);
                
                % get the parent property
                while jProp.getLevel > 0
                    jProp = jProp.getParent;
                end
                
                propname = char(jProp.getName);
                metaprop = self.Object.metaprops.(propname);
                
                oldValue = metaprop.mValue(self.Object.(propname));
                try
                    oldValue(index{:}) = metaprop.mValue(newValue);
                catch
                    return
                end
                newValue = oldValue;
                
            else
                propname = char(jProp.getName);
                newValue = self.Object.metaprops.(propname).mValue(newValue);
            end
            
            % assign new value to Object
            try
                self.Object.(propname) = newValue;
            catch 
                return
            end
            
            % refresh all property values
            propnames = fieldnames(self.Object.metaprops);
            for ii = 1:length(propnames)
                propname = propnames{ii};
                jProp = model.getProperty(propname);
                jProp.setValue(self.Object.metaprops.(propname).jValue(self.Object.(propname)));
                
                % update value of child jProps, if any
                self.Object.metaprops.(propname).updateChildValues(jProp);
            end
            model.refresh();  % refresh value onscreen
        end
        function delete(self)
            % clear Java mess
            com.jidesoft.grid.CellRendererManager.unregisterAllRenderers
                       
            % delete figure
            delete(self.Figure);
            
            % call superclass delete method
            delete@handle(self);
        end
    end
end