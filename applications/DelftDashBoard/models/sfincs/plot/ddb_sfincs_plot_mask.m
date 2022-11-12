function handles = ddb_sfincs_plot_mask(handles, opt, varargin)

vis=1;
id=ad;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'visible'}
                vis=varargin{i+1};
            case{'domain'}
                id=varargin{i+1};
        end
    end
end

vis=vis*handles.model.sfincs.menuview.mask;

switch lower(opt)
    
    case{'plot'}
        
        % First delete old grid
        try
            delete(handles.model.sfincs.domain(id).maskhandle);
        end
        
        if isempty(handles.model.sfincs.domain(id).buq)
        
            p=hggroup;
            
            xx=handles.model.sfincs.domain(id).gridx(handles.model.sfincs.domain(id).mask==1);
            yy=handles.model.sfincs.domain(id).gridy(handles.model.sfincs.domain(id).mask==1);
            msk1=plot(xx,yy,'.');
            set(msk1,'MarkerFaceColor','y','MarkerEdgeColor','y','MarkerSize',10);
            set(msk1,'Parent',p);

            xx=handles.model.sfincs.domain(id).gridx(handles.model.sfincs.domain(id).mask==2);
            yy=handles.model.sfincs.domain(id).gridy(handles.model.sfincs.domain(id).mask==2);
            msk2=plot(xx,yy,'.');
            set(msk2,'MarkerFaceColor','r','MarkerEdgeColor','r','MarkerSize',10);
            set(msk2,'Parent',p);
            
            xx=handles.model.sfincs.domain(id).gridx(handles.model.sfincs.domain(id).mask==3);
            yy=handles.model.sfincs.domain(id).gridy(handles.model.sfincs.domain(id).mask==3);
            msk3=plot(xx,yy,'.');
            set(msk3,'MarkerFaceColor','c','MarkerEdgeColor','c','MarkerSize',10);
            set(msk3,'Parent',p);
            
        else
            
            p=hggroup;
            xx=handles.model.sfincs.domain(id).gridx(handles.model.sfincs.domain(id).mask==1);
            yy=handles.model.sfincs.domain(id).gridy(handles.model.sfincs.domain(id).mask==1);
            msk1=plot(xx,yy,'o');
            set(msk1,'MarkerFaceColor','y','MarkerEdgeColor','y','MarkerSize',2);
            set(msk1,'Parent',p);

            xx=handles.model.sfincs.domain(id).gridx(handles.model.sfincs.domain(id).mask==2);
            yy=handles.model.sfincs.domain(id).gridy(handles.model.sfincs.domain(id).mask==2);
            msk2=plot(xx,yy,'o');
            set(msk2,'MarkerFaceColor','r','MarkerEdgeColor','r','MarkerSize',2);
            set(msk2,'Parent',p);

            xx=handles.model.sfincs.domain(id).gridx(handles.model.sfincs.domain(id).mask==3);
            yy=handles.model.sfincs.domain(id).gridy(handles.model.sfincs.domain(id).mask==3);
            msk3=plot(xx,yy,'o');
            set(msk3,'MarkerFaceColor','c','MarkerEdgeColor','c','MarkerSize',2);
            set(msk3,'Parent',p);
            
        end
        
        handles.model.sfincs.domain(id).maskhandle=p;
        try
        set(p,'HitTest','off','tag','sfincsmask');
        end
        
        if vis            
            set(p,'Visible','on');
        else
            set(p,'Visible','off');
        end
        
    case{'delete'}
        
        % Delete old grid
        try
            delete(handles.model.sfincs.domain(id).maskhandle);
        catch
            h=findobj(gcf,'tag','sfincsmask');
            if ~isempty(h)
                delete(h);
            end            
        end
        
    case{'update'}
        
        try
            p=handles.model.sfincs.domain(id).maskhandle;
        catch
            p=findobj(gcf,'tag','sfincsmask');
        end
        if ~isempty(p)
            try
                if vis
                    set(p,'Visible','on');
                else
                    set(p,'Visible','off');
                end
            end
        end
end

