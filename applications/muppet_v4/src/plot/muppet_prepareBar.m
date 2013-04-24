function handles=muppet_prepareBar(handles,ifig,isub)

% In case of histogram plots and stacked area plots, data sets must first
% be merged.

plt=handles.figures(ifig).figure.subplots(isub).subplot;

nodat=plt.nrdatasets;

bary=[];
stackedareay=[];

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
            bary(:,nbar)=handles.datasets(ii).dataset.y;
            if strcmpi(handles.datasets(ii).dataset.type,'bar')
                plt.xtcklab=handles.datasets(ii).dataset.xticklabel;
            else
                plt.xtcklab=[];
            end
        case {'plotstackedarea'}
            nstackedarea=nstackedarea+1;
            plt.datasets(k).dataset.areanr=nstackedarea;
            stackedareay(:,nstackedarea)=handles.datasets(ii).dataset.y;
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

plt.bary=bary;
plt.stackedareay=stackedareay;

handles.figures(ifig).figure.subplots(isub).subplot.bary=bary;
handles.figures(ifig).figure.subplots(isub).subplot.stackedareay=stackedareay;

handles.figures(ifig).figure.subplots(isub).subplot=plt;
