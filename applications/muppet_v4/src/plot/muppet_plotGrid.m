function handles=muppet_plotGrid(handles,i,j,k)

plt=handles.figures(i).figure.subplots(j).subplot;
nr=plt.datasets(k).dataset.number;
data=handles.datasets(nr).dataset;
opt=plt.datasets(k).dataset;

if isfield(data,'xdam')
    if size(data.xdam,1)>0
        h=thindam(data.x,data.y,data.xdam,data.xdam);
        set(h,'LineStyle',opt.linestyle,'LineWidth',opt.linewidth,'Color',colorlist('getrgb','color',opt.linecolor));
    else
        xdam=zeros(size(data.x));
        xdam=xdam+1;
        ydam=xdam;
        h=thindam(data.x,data.y,xdam,ydam);
        set(h,'LineStyle',opt.linestyle,'LineWidth',opt.linewidth,'Color',colorlist('getrgb','color',opt.linecolor));
    end
else
    XDam=zeros(size(data.x));
    XDam=XDam+1;
    YDam=XDam;
    h=thindam(data.x,data.y,XDam,YDam);
    set(h,'LineStyle',opt.linestyle,'LineWidth',opt.linewidth,'Color',colorlist('getrgb','color',opt.linecolor));
end

hold on;

plt.datasets(k).dataset.handle=h;
handles.figures(i).figure.subplots(j).subplot=plt;
