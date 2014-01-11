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
    events = [java.nio.file.StandardWatchEventKinds.ENTRY_CREATE, java.nio.file.StandardWatchEventKinds.ENTRY_MODIFY];
    key = dir.register(watcher, events);
    events = watcher.take();
    
    handle(events);

    
end
