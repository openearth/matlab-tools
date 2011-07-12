function handles=ddb_readCycloneFile(handles,filename)

txt=ReadTextFile(filename);
npoi = 0;

handles.Toolbox(tb).Input.name='';
handles.Toolbox(tb).Input.initSpeed=0;
handles.Toolbox(tb).Input.initDir=0;

handles.Toolbox(tb).Input.trackT = floor(now);
handles.Toolbox(tb).Input.trackY = 0;
handles.Toolbox(tb).Input.trackX = 0;
handles.Toolbox(tb).Input.par1   = 0;
handles.Toolbox(tb).Input.par2   = 0;
handles.Toolbox(tb).Input.radius = 1000;

for i=1:length(txt)
    switch(lower(txt{i})),
        case{'name'}
            handles.Toolbox(tb).Input.name=txt{i+1};
        case{'inputoption'}
            handles.Toolbox(tb).Input.holland=str2double(txt{i+1});
        case{'initialeyespeed'}
            handles.Toolbox(tb).Input.initSpeed=str2double(txt{i+1});
        case{'initialeyedir'}
            handles.Toolbox(tb).Input.initDir=str2double(txt{i+1});
        case{'spiderwebradius'}
            handles.Toolbox(tb).Input.radius=str2double(txt{i+1});
        case{'trackdata'}
            npoi=npoi+1;
            dat=txt{i+1};
            tim=txt{i+2};
            handles.Toolbox(tb).Input.trackT(npoi) =datenum([dat tim],'yyyymmddHHMMSS');
            handles.Toolbox(tb).Input.trackY(npoi) =str2double(txt{i+3});
            handles.Toolbox(tb).Input.trackX(npoi) =str2double(txt{i+4});
            handles.Toolbox(tb).Input.par1(npoi)   =str2double(txt{i+5});
            handles.Toolbox(tb).Input.par2(npoi)   =str2double(txt{i+6});
    end
end
handles.Toolbox(tb).Input.nrTrackPoints=npoi;
