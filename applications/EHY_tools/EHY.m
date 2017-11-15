function EHY

EHYs(mfilename);

functions{1,1}='EHY_convert';
functions{1,2}='Conversion from and to model input files. Including coordinate conversion.';
functions{2,1}='EHY_simulationStatus';
functions{2,2}='Check the status of a simulation.';
functions{3,1}='EHY_runTimeInfo';
functions{3,2}='Check the simulation period, run time, number of partitions, etc.';
functions{4,1}='EHY_opendap';
functions{4,2}='Retrieve data from Rijkswaterstaats waterbase';
functions{5,1}='EHY_simulationInputTimes';
functions{5,2}='A tool to help using the corrent model input times';
functions{6,1}='EHY_model2GoogleEarth';
functions{6,2}='Visualize your model in GoogleEarth';
functions{7,1}='EHY_crop';
functions{7,2}='This function crops the surrounding area of a figure based on the background color.';

h=findall(0,'type','figure','name','EHY_TOOLS');
if ~isempty(h)
    uistack(h,'top');
    figure(h);
    disp('The EHY_TOOLS GUI was already open')
else
    EHYfig=figure('units','normalized','position',[0.4922 0.0583 0.5000 0.3000],'name','EHY_TOOLS');
end
for iF=1:length(functions)
    button=uicontrol('Style', 'pushbutton', 'String',functions{iF,1},...
        'Position', [20 255-iF*30 200 20],...
        'Callback', @runEHYscript);
      uicontrol('Style','text',...
        'Position',[240 255-iF*30-3 1000 20],...
        'String',functions{iF,2},'horizontalalignment','left');
end
%close button
    button=uicontrol('Style', 'pushbutton', 'String','Close',...
        'Position', [20 255-(iF+1)*30 200 20],...
        'Callback', @closeFig);
end

function runEHYscript(hObject,event)
run(get(hObject,'String'))
end

function closeFig(hObject,event)
close(get(hObject,'Parent'))
end
