function [x0,y0,dx,dy,np]=ww3_define_nesting_sections(ww3_grid_file)
% Creates nesting sections for ww3 in ww3 nesting

% Read detailed model data
grd=ww3_read_grid_inp(ww3_grid_file);
dr=fileparts(handles.toolbox.nesting.ww3_grid_file);
bot=ww3_read_bottom_depth_file([dr filesep grd.bottom_depth_filename],grd.nx,grd.ny);
[xg,yg]=meshgrid(grd.x0:grd.dx:grd.x0+(grd.nx-1)*grd.dx,grd.y0:grd.dy:grd.y0+(grd.ny-1)*grd.dy);            

% Bottom row
ix=0;
iy=1;
nsec=0;
newsection=1;
while 1
    ix=ix+1;
    if ix>grd.nx
        break
    end
    if newsection
        % Looking for a new section
        if bot(iy,ix)>10
            % Start of new section found
            newsection=0;
            nsec=nsec+1;
            np(nsec)=1;            
            x0(nsec)=xg(iy,ix);
            y0(nsec)=yg(iy,ix); 
            dx(nsec)=grd.dx;
            dy(nsec)=0;
        end
    else
        if bot(iy,ix)<10
            % Continue along this section
            newsection=1;
        else
            np(nsec)=np(nsec)+1;            
        end
    end
end

% Top row
ix=0;
iy=grd.ny;
newsection=1;
while 1
    ix=ix+1;
    if ix>grd.nx
        break
    end
    if newsection
        % Looking for a new section
        if bot(iy,ix)>10
            % Start of new section found
            newsection=0;
            nsec=nsec+1;
            np(nsec)=1;            
            x0(nsec)=xg(iy,ix);
            y0(nsec)=yg(iy,ix); 
            dx(nsec)=grd.dx;
            dy(nsec)=0;
        end
    else
        if bot(iy,ix)<10
            % Continue along this section
            newsection=1;
        else
            np(nsec)=np(nsec)+1;            
        end
    end
end

% Left row
ix=1;
iy=1;
newsection=1;
while 1
    iy=iy+1;
    if iy==grd.ny
        break
    end
    if newsection
        % Looking for a new section
        if bot(iy,ix)>10
            % Start of new section found
            newsection=0;
            nsec=nsec+1;
            np(nsec)=1;            
            x0(nsec)=xg(iy,ix);
            y0(nsec)=yg(iy,ix); 
            dx(nsec)=0;
            dy(nsec)=grd.dx;
        end
    else
        if bot(iy,ix)<10
            % Continue along this section
            newsection=1;
        else
            np(nsec)=np(nsec)+1;            
        end
    end
end

% Right row
ix=grd.nx;
iy=1;
newsection=1;
while 1
    iy=iy+1;
    if iy==grd.ny
        break
    end
    if newsection
        % Looking for a new section
        if bot(iy,ix)>10
            % Start of new section found
            newsection=0;
            nsec=nsec+1;
            np(nsec)=1;            
            x0(nsec)=xg(iy,ix);
            y0(nsec)=yg(iy,ix); 
            dx(nsec)=0;
            dy(nsec)=grd.dx;
        end
    else
        if bot(iy,ix)<10
            % Continue along this section
            newsection=1;
        else
            np(nsec)=np(nsec)+1;            
        end
    end
end
