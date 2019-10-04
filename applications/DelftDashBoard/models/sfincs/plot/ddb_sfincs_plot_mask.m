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

switch lower(opt)
    
    case{'plot'}
        
        % First delete old grid
        try
            delete(handles.model.sfincs.domain(id).maskhandle);
        end
        
        x0=handles.model.sfincs.domain(id).input.x0;
        y0=handles.model.sfincs.domain(id).input.y0;
        dx=handles.model.sfincs.domain(id).input.dx;
        dy=handles.model.sfincs.domain(id).input.dy;
        mmax=handles.model.sfincs.domain(id).input.mmax;
        nmax=handles.model.sfincs.domain(id).input.nmax;
        rot=handles.model.sfincs.domain(id).input.rotation*pi/180;
        
        [xg0,yg0]=meshgrid(0:dx:mmax*dx,0:dy:nmax*dy);
        xg = x0 + xg0* cos(rot) + yg0*-sin(rot);
        yg = y0 + xg0* sin(rot) + yg0*cos(rot);
        zg=zeros(size(xg));
        zg(1:end-1,1:end-1)=handles.model.sfincs.domain(id).mask;
        zg(zg==0)=NaN;

        vals=[1;2];
        rgb=[1 1 0; 1 0 0];
        p=indexpatch(xg,yg,zg,vals,rgb);
        handles.model.sfincs.domain(id).maskhandle=p;
        
%         figure(100)
%         plot(xg,yg);axis equal
%         p=pcolor(xg,yg,zg);shading flat;
        
% %         c=zeros(nmax+1,mmax+1,3);        
% %         r=zeros(nmax+1,mmax+1);        
% %         g=zeros(nmax+1,mmax+1);        
% %         b=zeros(nmax+1,mmax+1);        
% %         i1=find(zg==1);
% %         i2=find(zg==2);
% %         r(i1)=1;
% %         g(i1)=1;
% %         r(i2)=1;
% %         c(:,:,1)=r;
% %         c(:,:,2)=g;
% %         c(:,:,3)=b;
%         
%         p=patch(xg,yg,c);%shading flat;
% %        fvc=surf2patch(xg,yg,zg);
% %        p=pcolor(xg,yg,zg);shading flat;
%         set(p,'tag','sfincsmask','HitTest','off');
%               
%         
% %         figure(100)
% % %         p=patch(xg,yg,c);shading flat;axis equal;
% %         p=patch(xg',yg','r');%shading flat;axis equal;
% % %        fvc=surf2patch(xg,yg,zg);
% %        p=pcolor(xg,yg,zg);shading flat;
% 
        
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

