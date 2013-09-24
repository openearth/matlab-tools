function iok=ddb_check_write_extfile(handles)

iok=0;

if handles.Model(md).Input.nrboundaries>0 || ~isempty(handles.Model(md).Input.spiderwebfile)
    iok=1;
end
