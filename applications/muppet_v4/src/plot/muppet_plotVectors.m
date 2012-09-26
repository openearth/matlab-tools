function handles=muppet_plotVectors(handles,i,j,k)

plt=handles.figures(i).figure.subplots(j).subplot;
nr=plt.datasets(k).dataset.number;
data=handles.datasets(nr).dataset;
opt=plt.datasets(k).dataset;

switch lower(opt.fieldthinningtype)
    case{'none'}
        x=data.x;
        y=data.y;
        u=data.u;
        v=data.v;
    case{'uniform'}
        x=data.x(1:opt.fieldthinningfactor1:end,1:opt.fieldthinningfactor2:end);
        y=data.y(1:opt.fieldthinningfactor1:end,1:opt.fieldthinningfactor2:end);
        u=data.u(1:opt.fieldthinningfactor1:end,1:opt.fieldthinningfactor2:end);
        v=data.v(1:opt.fieldthinningfactor1:end,1:opt.fieldthinningfactor2:end);
end

z=zeros(size(x));
z=z+500;
w=zeros(size(u));

% if Ax.AxesEqual==0
%     VertScale=(Ax.YMax-Ax.YMin)/Ax.Position(4);
%     HoriScale=(Ax.XMax-Ax.XMin)/Ax.Position(3);
%     multiY=HoriScale/VertScale;
% else
%     multiY=1.0;
% end
multiY=1.0;
multiv=opt.verticalvectorscaling;
opt.unitvector=1000;
if strcmpi(opt.plotroutine,'plotvectors')
    qv=quiver3(x,multiY*y,z,opt.unitvector*u,multiv*opt.unitvector*v,w,0);hold on;
    set(qv,'Color',colorlist('getrgb','color',opt.vectorcolor));
else
    if ~opt.PlotColorBar
        if strcmpi(Ax.ContourType,'limits')
            col=[Ax.CMin:(Ax.CMax-Ax.CMin)/64:Ax.CMax];
        else
            col=Ax.Contours;
        end
        ncol=size(col,2)-1;
        clmap=GetColors(handles.ColorMaps,Ax.ColMap,ncol);
        colormap(clmap);
        caxis([col(2) col(end-1)]);
        qv=quiver3(x,multiY*y,z,opt.UnitVector*u,multiV*opt.UnitVector*v,w,0);hold on;
        qv=mp_colquiver(qv,sqrt(u.^2+v.^2));
    else
        colorfix;
        col=[opt.CMin:(opt.CMax-opt.CMin)/64:opt.CMax];
        ncol=size(col,2)-1;
        clmap=GetColors(handles.ColorMaps,opt.ColMap,ncol);
        colormap(clmap);
        caxis([col(2) col(end-1)]);
        qv=quiver3(x,multiY*y,z,opt.UnitVector*u,multiV*opt.UnitVector*v,w,0);hold on;
        qv=mp_colquiver(qv,sqrt(u.^2+v.^2));
        colorfix;
        clmap=GetColors(handles.ColorMaps,Ax.ColMap,ncol);
        colormap(clmap);
    end
end

