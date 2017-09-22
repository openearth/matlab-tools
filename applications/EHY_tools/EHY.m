
function EHY
[pathstr ~] = fileparts(which('EHY'));
D=dir([pathstr filesep '*.m']);

NoInputNeeded={};
for iD=1:length(D)
    fid=fopen([pathstr filesep D(iD).name],'r');
    line=fgetl(fid);
    fclose(fid);
    if ~isempty(strfind(line,'(varargin)'))
        NoInputNeeded{end+1,1}=D(iD).name;
    end
end

% delete certain scripts
NoInputNeeded(strmatch('EHY_opendap',NoInputNeeded))=[];
NoInputNeeded(strmatch('EHY_plot_google_map',NoInputNeeded))=[];

% select which function to use
selection=  listdlg('PromptString',['Which function would you like to use:'],...
    'SelectionMode','single',...
    'ListString',strrep(NoInputNeeded,'.m',''),...
    'ListSize',[300 200]);

% run selection
if ~isempty(selection)
    run(NoInputNeeded{selection}(1:end-2))
else
    disp('No function was selected.')
end
