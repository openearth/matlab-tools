%WATCH_DIRECTORY watch directory for file changes
%
% When the file system supports it, this function will listen to the
% dirname directory for new, modified and deleted files. This is done using the
% java nio api, which is only supported in java 1.7 and up, os it will not
% work for all matlab versions. Once an event is generated the function
% returns the event and possibly other events at the same time, the function then
% stops watching the directory. 
%
% syntax:
% [events] = watch_directory(dirname)
%
% input:
% dirname = a directory (absolute path) which is watched
%
% output:
% events = a structure in the format {'kind': 'EVENT_TYPE', 'context':
% 'filename'}
%
% example:
% watch_directory(fullfile(pwd, '.'))
%
% See also: fullfile, ls

function [events] = watch_directory(dirname)

    % Import java classes that we need
    import java.nio.file.*
    import java.nio.file.StandardWatchEventKinds.*
    
    % Filesystem is OS specific
    filesystem = FileSystems.getDefault();
    
    % hack to get path (expects 2 arguments, due to java ellipsis)
    dir = filesystem.getPath(dirname, {''});

    % Java does not know about the current dir in matlab, so we always want
    % an absolute path
    if ~dir.isAbsolute() 
        warning(['Dirname should be absolute.']);
        warning(['Got: ', dirname, ' which refers to', char(dir.toAbsolutePath())]);
        return
    end
    % Start a watchservice, which can be used for listening
    watcher = filesystem.newWatchService();
    % subscribe to these events
    events = [...
            java.nio.file.StandardWatchEventKinds.ENTRY_CREATE,  ...
            java.nio.file.StandardWatchEventKinds.ENTRY_MODIFY,  ...
            java.nio.file.StandardWatchEventKinds.ENTRY_DELETE,  ...
            ];
    % start watching
    key = dir.register(watcher, events);
    
    % blocks, add poll with a timeout and timeunits if required
    keyframe = watcher.take();

    % get the array of events
    events = keyframe.pollEvents();
    % put them in a matlab struct, can this be done easier???
    matevents = struct('kind',[], 'context',[]);
    % loop manually
    for i=1:events.size
        % java is 0 based
        event = events.get(i-1);
        % and matlab is 1 based, explicitly convert to char 
        matevents(i) = struct('kind', char(event.kind), 'context', char(event.context));
    end
    % stop listening otherwise the computer slows down (MS virus checker goes
    % crazy)
    watcher.close();
    % return the events
    events = matevents;
    

end
