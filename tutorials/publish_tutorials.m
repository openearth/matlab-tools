tutorial_scripts = dir(fullfile(openearthtoolsroot,'tutorials','tutorial_*.m'));
cd(fullfile(openearthtoolsroot,'tutorials'))

% status
% 0 = not done at all
% 1 = work in progress
% 2 = almost done
% 3 = completed
% 4 = completed, tested, and on the openearth wiki
%
%         1 2 3 4 5 6 7 8 9 10 11 12 13 14 15
status = [2 1 3 3 3 2 0 3 1  2  3  0  1  2  0];
options.maxOutputLines = 15;
options.format         = 'html'; %'doc','html' (default), 'latex', 'ppt', 'xml'
options.catchError = true;
for ii = 1:length(tutorial_scripts)
    switch status(ii)
        case 0; disp(sprintf('%3d <a href="matlab: edit %s">%-43s</a> - not done at all'                             ,ii,tutorial_scripts(ii).name(1:end-2),tutorial_scripts(ii).name))
        case 1; disp(sprintf('%3d <a href="matlab: edit %s">%-43s</a> - beginning made, work in progress'                            ,ii,tutorial_scripts(ii).name(1:end-2),tutorial_scripts(ii).name))
        case 2; disp(sprintf('%3d <a href="matlab: edit %s">%-43s</a> - almost done'                                 ,ii,tutorial_scripts(ii).name(1:end-2),tutorial_scripts(ii).name))
        case 3; disp(sprintf('%3d <a href="matlab: edit %s">%-43s</a> - completed'                                   ,ii,tutorial_scripts(ii).name(1:end-2),tutorial_scripts(ii).name))
        case 4; disp(sprintf('%3d <a href="matlab: edit %s">%-43s</a> - completed, tested, and on the openearth wiki',ii,tutorial_scripts(ii).name(1:end-2),tutorial_scripts(ii).name))
    end
    if status(ii)>=1
        if ~exist(fullfile('html',[tutorial_scripts(ii).name(1:end-1) options.format]),'file')
            link = publish(tutorial_scripts(ii).name,options);
        else
            link = fullfile('html',[tutorial_scripts(ii).name(1:end-1) options.format]);
        end
        disp(['       <a href="' link '">' link '</a>']);
    end
    close all
end

% delete figure made a one of the publish scripts
cd(fullfile(openearthtoolsroot,'tutorials'))
figures_to_delete = dir(fullfile(openearthtoolsroot,'tutorials','*.png'));
for ii = 1:length(figures_to_delete)
    delete(figures_to_delete(ii).name)
end