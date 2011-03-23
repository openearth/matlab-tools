function ddb_plotDD(option,varargin)

switch lower(option)
    case{'delete'}
        h=findobj(gca,'Tag','DDCornerPoint');
        if ~isempty(h)
            delete(h);
        end
        h=findobj(gca,'Tag','TemporaryDDGrid');
        if ~isempty(h)
            delete(h);
        end
        handles=getHandles;
        ddb_Delft3DFLOW_plotDD(handles,'delete');
    case{'activate'}
        h=findobj(gca,'Tag','TemporaryDDGrid');
        if ~isempty(h)
            set(h,'Visible','on');
        end
        h=findobj(gca,'Tag','DDCornerPoint');
        if ~isempty(h)
            set(h,'Visible','on');
        end
        handles=getHandles;
        ddb_Delft3DFLOW_plotDD(handles,'update','active',1);
    case{'deactivate'}
        h=findobj(gca,'Tag','TemporaryDDGrid');
        if ~isempty(h)
            set(h,'Visible','off');
        end
        h=findobj(gca,'Tag','DDCornerPoint');
        if ~isempty(h)
            set(h,'Visible','off');
        end
        handles=getHandles;
        ddb_Delft3DFLOW_plotDD(handles,'update','active',0);
end
