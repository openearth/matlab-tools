function handles=ddb_readHurricaneFile(handles,filename)

txt=ReadTextFile(filename);
npoi = 0;

handles.Toolbox(tb).Input.Name='';

for i=1:length(txt)
    switch(lower(txt{i})),
        case{'name'}
            handles.Toolbox(tb).Input.Name=txt{i+1};
        case{'inputoption'}
            handles.Toolbox(tb).Input.Holland=str2double(txt{i+1});
        case{'initialeyespeed'}
            handles.Toolbox(tb).Input.InitSpeed=str2double(txt{i+1});
        case{'initialeyedir'}
            handles.Toolbox(tb).Input.InitDir=str2double(txt{i+1});
        case{'trackdata'}
            npoi=npoi+1;
            dat=txt{i+1};
            tim=txt{i+2};
            handles.Toolbox(tb).Input.Date(npoi)=datenum([dat tim],'yyyymmddHHMMSS');
            handles.Toolbox(tb).Input.TrY(npoi) =str2double(txt{i+3});
            handles.Toolbox(tb).Input.TrX(npoi) =str2double(txt{i+4});
            handles.Toolbox(tb).Input.Par1(npoi)=str2double(txt{i+5});
            handles.Toolbox(tb).Input.Par2(npoi)=str2double(txt{i+6});
    end
end
handles.Toolbox(tb).Input.NrPoint=npoi;
