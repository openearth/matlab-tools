% keep track of changes to a directory
function watch_directory(dirname, handle)
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
        event = events.get(i-1)
        matevents(i) = struct('kind', char(event.kind), 'context', char(event.context));
    end

    handle(matevents);


end
