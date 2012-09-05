function [handles,ok]=muppet_importDatasets(handles)

ok=0;

for id=1:handles.nrdatasets
    dataset=handles.datasets(id).dataset;
    if ~dataset.combineddataset
        try
            % Find import routine
            ift=muppet_findIndex(handles.filetype,'filetype','name',dataset.filetype);
            dataset.callback=str2func(handles.filetype(ift).filetype.callback);
            % Get file info
            dataset=feval(dataset.callback,'read',dataset);
            if dataset.nrparameters>0
                % Multiple parameters available, copy appropriate data from parameters structure to
                % dataset structure
                ii=muppet_findIndex(dataset.parameters,'parameter','dimensions','parametername',dataset.parameter);
                fldnames=fieldnames(dataset.parameters(ii).parameter);
                for j=1:length(fldnames)
                    dataset.(fldnames{j})=dataset.parameters(ii).parameter.(fldnames{j});
                end
            end
            % Import
            dataset=feval(dataset.callback,'import',dataset);
        catch
            ok=0;
            muppet_giveWarning('text',['Could not load dataset ' dataset.name ' !']);
            return
        end
        handles.datasets(id).dataset=dataset;
    end
end

% Combine

% Find numbers and types of dataset in subplot
for ifig=1:handles.nrfigures
    for isub=1:handles.figures(ifig).figure.nrsubplots
        for id=1:handles.figures(ifig).figure.subplots(isub).subplot.nrdatasets
            nr=muppet_findIndex(handles.datasets,'dataset','name',handles.figures(ifig).figure.subplots(isub).subplot.datasets(id).dataset.name);
            handles.figures(ifig).figure.subplots(isub).subplot.datasets(id).dataset.nr=nr;
            if ~isempty(nr)
                handles.figures(ifig).figure.subplots(isub).subplot.datasets(id).dataset.type=handles.datasets(nr).dataset.type;
            else
                ok=0;
                muppet_giveWarning('text',['Dataset ' handles.figures(ifig).figure.subplots(isub).subplot.datasets(id).dataset.name ' not found!']);
                return
            end            
        end
    end
end

ok=1;
