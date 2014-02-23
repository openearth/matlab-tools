% DOUBLEARRAY2D property for a 2d array of double precision numbers. Editor has one line for each row
% expands further to one line for each element
classdef doubleArray2D < metaprop.base
    properties (Constant)
        jType = metaprop.base.jClassNameToJType('[[D')
    end
    properties (SetAccess=immutable)        
        jEditor = com.jidesoft.grid.CalculatorCellEditor;
        jRenderer = com.jidesoft.grid.ContextSensitiveCellRenderer;
    end
    methods
        function self = doubleArray2D(varargin)
            self = self@metaprop.base(varargin{:});
            
            % set specific restrictions
            self.DefaultClasses    = {'double'};
            self.DefaultAttributes = {'2d'};
            
            self.CheckDefault();
        end
        function jProp = jProp(self,mValue)
            jProp = jProp@metaprop.base(self,mValue); %#ok<NODEF>
            for m = 1:size(mValue,1)
                jRowProp = com.jidesoft.grid.DefaultProperty();
                jRowProp.setName(sprintf('%s(%0.0f,:)',self.Name,m));
                jRowProp.setDescription(sprintf('Sub row of %s',self.Name));
                jRowProp.setType(self.jType);
                
                jRowContext = com.jidesoft.grid.EditorContext(jRowProp.getName);
                jRowProp.setEditorContext(jRowContext);
                
                com.jidesoft.grid.CellEditorManager.registerEditor(self.jType, self.jEditor, jRowContext);
                com.jidesoft.grid.CellRendererManager.registerRenderer(self.jType, self.jRenderer, jRowContext);
                for n = 1:size(mValue,2)
                    jColProp = com.jidesoft.grid.DefaultProperty();
                    jColProp.setName(sprintf('%s(%0.0f,%0.0f)',self.Name,m,n));
                    jColProp.setDescription(sprintf('Sub element of %s',self.Name));
                    jColProp.setType(self.jType);
                    
                    jColContext = com.jidesoft.grid.EditorContext(jColProp.getName);
                    jColProp.setEditorContext(jColContext);
                    
                    com.jidesoft.grid.CellEditorManager.registerEditor(self.jType, self.jEditor, jColContext);
                    com.jidesoft.grid.CellRendererManager.registerRenderer(self.jType, self.jRenderer, jColContext);
                    jRowProp.addChild(jColProp);
                end
                jProp.addChild(jRowProp);
                jRowProp.setEditable(false);
            end
            jProp.setEditable(false);
            self.updateChildValues(jProp);
        end
    end
    methods (Static)
        function updateChildValues(jProp)
            mValue = metaprop.doubleRow.mValue(jProp.getValue);
            jRows = jProp.getChildren;
            for m = 1:size(mValue,1)
                jRowProp = jRows.get(m-1);
                jCols = jRowProp.getChildren;
                for n = 1:size(mValue,2);
                    jColProp = jCols.get(n-1);
                    jValue = metaprop.doubleArray2D.jValue(mValue(m,n));
                    jColProp.setValue(jValue);
                end
                jValue = metaprop.doubleArray2D.jValue(mValue(m,:));
                jRowProp.setValue(jValue);
            end
        end
    end
end