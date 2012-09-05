function handles=muppet_prepareBar(handles,ifig,isub)

plt=handles.figures(ifig).figure.subplots(isub).subplot;

nodat=plt.nrdatasets;

BarY=[];
StackedAreaY=[];

plt.xtcklab=[];

nbar=0;
nstackedarea=0;
for k=1:nodat
    ii=plt.datasets(k).dataset.number;
    plt.datasets(k).dataset.barnr=0;
    plt.datasets(k).dataset.areanr=0;
    switch lower(plt.datasets(k).dataset.plotroutine)
        case {'plothistogram'}
            nbar=nbar+1;
            plt.datasets(k).dataset.barnr=nbar;
            BarY(:,nbar)=handles.datasets(ii).dataset.y;
            if strcmpi(handles.datasets(ii).dataset.type,'bar')
                plt.xtcklab=handles.datasets(ii).dataset.xticklabel;
            else
                plt.xtcklab=[];
            end
        case {'plotstackedarea'}
            nstackedarea=nstackedarea+1;
            plt.datasets(k).dataset.areanr=nstackedarea;
            StackedAreaY(:,nstackedarea)=handles.datasets(ii).dataset.y;
    end
end

for k=1:nodat
    if plt.datasets(k).dataset.barnr>0
        plt.datasets(k).dataset.nrbars=nbar;
    end
    if plt.datasets(k).dataset.areanr>0
        plt.datasets(k).dataset.nrareas=nstackedarea;
    end
end

handles.bary=BarY;
handles.stackedareay=StackedAreaY;

handles.figures(ifig).figure.subplots(isub).subplot=plt;
