function ddb_UnibestCL_pushSaveMdaAs(varargin)      

handles = getHandles;

MDAdata = handles.Model(md).Input.MDAdata;
reference_line = [MDAdata.X MDAdata.Y];

[filename, pathname] = uiputfile('*.mda', 'Select MDA File','');
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    ii=findstr(filename,'.mda');
%             handles.Model(md).Input(ad).Runid=filename(1:ii-1);
    handles.Model(md).Input.MDAfile=filename;
    MDAfile = handles.Model(md).Input.MDAfile;
    ddb_writeMDA2(MDAfile,reference_line,MDAdata.Y1,MDAdata.Y2,MDAdata.nrgridcells)
end    
