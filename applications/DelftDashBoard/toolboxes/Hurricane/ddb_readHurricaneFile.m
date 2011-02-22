function handles=ddb_readHurricaneFile(handles,filename)

txt=ReadTextFile(filename);
npoi = 0;

handles.Toolbox(tb).Input.name='';

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
        case{'trackdata'}
            npoi=npoi+1;
            dat=txt{i+1};
            tim=txt{i+2};
            handles.Toolbox(tb).Input.date(npoi)=datenum([dat tim],'yyyymmddHHMMSS');
            handles.Toolbox(tb).Input.trY(npoi) =str2double(txt{i+3});
            handles.Toolbox(tb).Input.trX(npoi) =str2double(txt{i+4});
            handles.Toolbox(tb).Input.par1(npoi)=str2double(txt{i+5});
            handles.Toolbox(tb).Input.par2(npoi)=str2double(txt{i+6});
    end
end
handles.Toolbox(tb).Input.nrPoint=npoi;
