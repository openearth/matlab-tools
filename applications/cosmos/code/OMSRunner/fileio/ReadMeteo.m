function hm=ReadMeteo(hm)

dirname=[hm.MainDir 'meteo' filesep];

noset=0;

fname=[dirname 'meteo.dat'];
txt=ReadTextFile(fname);

% Read Meteo

hm.Meteo=[];

for i=1:length(txt)

    switch lower(txt{i}),
        case {'meteo'},
            noset=noset+1;
            hm.Meteo(noset).LongName=txt{i+1};
            hm.Meteo(noset).XLim=[];
            hm.Meteo(noset).YLim=[];
        case {'type'},
            hm.Meteo(noset).Type=txt{i+1};
        case {'location'},
            hm.Meteo(noset).Location=txt{i+1};
        case {'name'},
            hm.Meteo(noset).Name=txt{i+1};
        case {'timestep'},
            hm.Meteo(noset).TimeStep=str2double(txt{i+1});
        case {'cycleinterval'},
            hm.Meteo(noset).CycleInterval=str2double(txt{i+1});
        case {'delay'},
            hm.Meteo(noset).Delay=str2double(txt{i+1});
        case {'xlim'},
            hm.Meteo(noset).XLim(1)=str2double(txt{i+1});
            hm.Meteo(noset).XLim(2)=str2double(txt{i+2});
        case {'ylim'},
            hm.Meteo(noset).YLim(1)=str2double(txt{i+1});
            hm.Meteo(noset).YLim(2)=str2double(txt{i+2});
        case {'source'},
            hm.Meteo(noset).source=txt{i+1};
    end

end

hm.NrMeteoDatasets=noset;

for i=1:hm.NrMeteoDatasets
    hm.MeteoNames{i}=hm.Meteo(i).Name;
    hm.Meteo(i).tLastAnalyzed=rounddown(now-hm.Meteo(i).Delay/24,hm.Meteo(i).CycleInterval/24);
end
