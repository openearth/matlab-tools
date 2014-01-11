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
    import java.nio.file.*

    import java.nio.file.StandardWatchEventKinds.*
    filesystem = FileSystems.getDefault();
    % hack to get path
    dir = filesystem.getPath(dirname, {''});

    if ~dir.isAbsolute() 
        warning(['Dirname should be absolute.']);
        warning(['Got: ', dirname, ' which refers to', char(dir.toAbsolutePath())]);
        return
    end
    watcher = filesystem.newWatchService();
    events = [...
            java.nio.file.StandardWatchEventKinds.ENTRY_CREATE,  ...
            java.nio.file.StandardWatchEventKinds.ENTRY_MODIFY,  ...
            java.nio.file.StandardWatchEventKinds.ENTRY_DELETE,  ...
            ];
    key = dir.register(watcher, events);
    
    % blocks, add poll with a timeout and timeunits if required
    keyframe = watcher.take();

    events = keyframe.pollEvents();
    matevents = struct('kind',[], 'context',[]);
    for i=1:events.size
        event = events.get(i-1);
        matevents(i) = struct('kind', char(event.kind), 'context', char(event.context));
    end
    
    watcher.close();
    events = matevents;
    

end
