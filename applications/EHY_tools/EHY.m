
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
NoInputNeeded(strmatch('EHY_plot_google_map',NoInputNeeded))=[];

% select which function to use
selection=  listdlg('PromptString',['Which function would you like to use:'],...
    'SelectionMode','single',...
    'ListString',strrep(NoInputNeeded,'.m',''),...
    'ListSize',[300 200]);

% try to write user to file, to check usage of EHY tools
try
    filename='n:\Deltabox\Bulletin\groenenb\OET_EHY\stats\stats.csv';
    if exist(filename,'file')
        fid=fopen(filename,'a');
    else
        fid=fopen(filename,'w');
    end
    fprintf(fid,'%s\n',[getenv('username') ';' NoInputNeeded{selection}(1:end-2) ';' datestr(now)]);
    fclose(fid);
end

% run selection
if ~isempty(selection)
    run(NoInputNeeded{selection}(1:end-2))
else
    disp('No function was selected.')
end
