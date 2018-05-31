function EHY
%% EHY
%
% Run this function (or 'ehy' or 'EHF') to open the GUI and interactively use the EHY_Tools
%
% created by Julien Groenenboom, 2017
%% Check if lastest version is used
try
    [~,out1]=system(['svn info -r HEAD ' fileparts(which('EHY.m'))]);
    rev1 = str2num(char(regexp(out1, 'Last Changed Rev: (\d+)', 'tokens', 'once')));
    [~,out2]=system(['svn info ' fileparts(which('EHY.m'))]);
    rev2 = str2num(char(regexp(out2, 'Last Changed Rev: (\d+)', 'tokens', 'once')));
    if rev2<rev1
        disp('Your EHY_tools are not up-to-date.')
        disp('Status: Updating the EHY_tools folder in your OET.')
        try
            system(['svn update ' fileparts(which('EHY.m'))]);
            disp('Status: <strong>Succesfully updated the EHY_tools folder in your OET.</strong>')
        catch
            disp('Automatic update failed. Please update the folder yourself. Location on your pc:')
            disp([fileparts(which('EHY.m')) filesep])
        end
    end
end
%%
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
functions{end+1,1}='EHY_findLimitingCells';
functions{end  ,2}='Get the time step limiting cells and max. flow velocities from a Delft3D-FM run';
functions{end+1,1}='EHY_getGridInfo';
functions{end  ,2}='Get grid info from a grid file, modelinputfile (.mdf,.mdu,siminp) or modeloutputfile';

h=findall(0,'type','figure','name','EHY_TOOLS  - Everbody Helps You');
if ~isempty(h)
    uistack(h,'top');
    figure(h);
    movegui(h,'center');
    disp('The EHY_TOOLS GUI was already open')
else
%     EHYfig=figure('units','centimeters','position',[12.0227 6.4982 16.8 9.5],'name','EHY_TOOLS  - Everbody Helps You','color',[0.94 0.94 0.94]);
    EHYfig=figure('units','centimeters','position',[12.0227 6.4982 16.8 10.6],'name','EHY_TOOLS  - Everbody Helps You','color',[0.94 0.94 0.94]);
    movegui(EHYfig,'center');
end
% height=9.6;
height=10.7;
for iF=1:length(functions)
    button=uicontrol('Style', 'pushbutton', 'String',functions{iF,1},...
        'units','centimeters','Position',[0.5027 height-iF*0.7938 5.2917 0.5292],... % 'Position', [20 height-iF*30 200 20],... %
        'Callback', @runEHYscript);
    uicontrol('Style','text',...
        'units','centimeters','Position',[6 height-iF*0.7938-0.1 12 0.5292],...
        'String',functions{iF,2},'horizontalalignment','left');
end
% aboutEHY
button=uicontrol('Style', 'pushbutton', 'String','About EHY_tools',...
    'units','centimeters','Position',[0.5027 height-(iF+1)*0.7938 5.2917 0.5292],...
    'Callback', @aboutEHY);
% close button
button=uicontrol('Style', 'pushbutton', 'String','Close',...
    'units','centimeters','Position',[0.5027 height-(iF+2)*0.7938 5.2917 0.5292],...
    'Callback', @closeFig);
% status
hStatusText=uicontrol('Style','text',...
    'units','centimeters','Position',[6 height-(iF+2)*0.7938 12 0.5292],...
    'String','Status:  Please select a function','horizontalalignment','left',...
    'FontWeight','bold','foregroundcolor',[0 0.5 0],'fontSize',12);
EHYs(mfilename);

    function runEHYscript(hObject,event)
        h=findall(0,'type','figure','name','EHY_TOOLS');
        set(h, 'pointer', 'watch')
        set(hStatusText,'String',...
            ['Status:  BUSY running ''' get(hObject,'String') ''''],'foregroundcolor',[1 0 0],'fontSize',12);
%         try
            run(get(hObject,'String'))
%         catch
%             disp(['Failed to execute function: ''' get(hObject,'String') ''', last error message:' char(10) lasterr])
%             disp('<strong>Questions / Suggestions for improvements > Julien.Groenenboom@Deltares.nl</strong>')
%         end
        set(h, 'pointer', 'arrow')
        set(hStatusText,'String',...
            'Status:  Please select a function','foregroundcolor',[0 0.5 0],'fontSize',12);
    end

    function closeFig(hObject,event)
        close(get(hObject,'Parent'))
    end
    function aboutEHY(hObject,event)
        msgbox({'This toolbox aims to help users of Delft3D-FM, Delft3D 4 and SIMONA',...
                'software in pre- and post-processing of simulations. The toolbox was',...
                'initially set-up and used within the group of Environmental',...
                'Hydrodynamics of Deltares, but is now a tool where other modellers can',...
                'benefit from and contribute to as well (OpenEarthTools philosophy).',...
                '',...
                'The scripts are created in such a way that they can be used interactively.',...
                'More experience MATLAB-users can use the functions with input and output',...
                'arguments to adopt the functions in their scripts.',...
                '',...
                'In case of questions/suggestions for improvements. Please contact:',...
                'Julien.Groenenboom@Deltares.nl'},'About EHY_tools');
    end
end