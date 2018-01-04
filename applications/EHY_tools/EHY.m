function EHY

EHYs(mfilename);

functions={};
functions{end+1,1}='EHY_convert';
functions{end  ,2}='Conversion from and to model input files. Including coordinate conversion';
functions{end+1,1}='EHY_getmodeldata';
functions{end  ,2}='Interactive retrieval of model data using EHY_getmodeldata';
functions{end+1,1}='EHY_simulationStatus';
functions{end  ,2}='Check the status of a simulation';
functions{end+1,1}='EHY_runTimeInfo';
functions{end  ,2}='Check the simulation period, run time, number of partitions, etc.';
functions{end+1,1}='EHY_opendap';
functions{end  ,2}='Retrieve data from Rijkswaterstaats waterbase';
functions{end+1,1}='EHY_simulationInputTimes';
functions{end  ,2}='A tool to help using the correct model input times';
functions{end+1,1}='EHY_model2GoogleEarth';
functions{end  ,2}='Visualize your model in GoogleEarth';
functions{end+1,1}='EHY_crop';
functions{end  ,2}='This function crops the surrounding area of a figure based on the background color';
functions{end+1,1}='EHY_wait';
functions{end  ,2}='Run a selected MATLAB-script once a certain date and time is reached';

h=findall(0,'type','figure','name','EHY_TOOLS');
if ~isempty(h)
    uistack(h,'top');
    figure(h);
    disp('The EHY_TOOLS GUI was already open')
else
    EHYfig=figure('units','normalized','position',[0.2698 0.3 0.4089 0.3463],'name','EHY_TOOLS');
end
height=305;
for iF=1:length(functions)
    button=uicontrol('Style', 'pushbutton', 'String',functions{iF,1},...
        'Position', [20 height-iF*30 200 20],...
        'Callback', @runEHYscript);
      uicontrol('Style','text',...
        'Position',[240 height-iF*30-3 1000 20],...
        'String',functions{iF,2},'horizontalalignment','left');
end
%close button
    button=uicontrol('Style', 'pushbutton', 'String','Close',...
        'Position', [20 height-(iF+1)*30 200 20],...
        'Callback', @closeFig);
end

function runEHYscript(hObject,event)
disp([char(10) 'EHY_tools: Start of running the function ''' get(hObject,'String') ''' - BUSY (even though MATLAB says it''s not)' char(10)])
run(get(hObject,'String'))
disp([char(10) 'EHY_tools: Finished running the ' get(hObject,'String') '-function  ' char(10)])
end

function closeFig(hObject,event)
close(get(hObject,'Parent'))
end
