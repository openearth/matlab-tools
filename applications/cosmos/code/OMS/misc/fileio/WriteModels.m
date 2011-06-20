function WriteModels(hm,varargin)

i1=[];
i2=[];

if nargin==1
    i1=1;
    i2=hm.NrModels;
else
    for i=1:hm.NrModels
        if strcmpi(hm.Models(i).Name,varargin{1})
            i1=i;
            i2=i;
        end
    end
end

if ~isempty(i1)

    for i=i1:i2

        dirname=[hm.ModelDirectory 'models\' hm.Models(i).Continent '\' hm.Models(i).Name];
        system(['md ' dirname]);

        fname=[dirname '\' hm.Models(i).Name '.dat'];

        fid=fopen(fname,'wt');

        fprintf(fid,'%s\n',['Model "' hm.Models(i).Name '"']);
        fprintf(fid,'%s\n',['   Type        "' hm.Models(i).Type '"']);
        fprintf(fid,'%s\n',['   Name        ' hm.Models(i).Name]);
        fprintf(fid,'%s\n',['   Runid       ' hm.Models(i).Runid]);
        fprintf(fid,'%s\n',['   Location    ' num2str(hm.Models(i).Location(1)) ' ' num2str(hm.Models(i).Location(2))]);
        fprintf(fid,'%s\n',['   Continent   "' hm.Models(i).Continent '"']);
        fprintf(fid,'%s\n',['   Size        ' num2str(hm.Models(i).Size)]);
        fprintf(fid,'%s\n',['   XLim        ' num2str(hm.Models(i).XLim(1)) ' ' num2str(hm.Models(i).XLim(2))]);
        fprintf(fid,'%s\n',['   YLim        ' num2str(hm.Models(i).YLim(1)) ' ' num2str(hm.Models(i).YLim(2))]);
        fprintf(fid,'%s\n',['   Priority    ' num2str(hm.Models(i).Priority)]);
        if hm.Models(i).Nested
            fprintf(fid,'%s\n',['   Nested      "' hm.Models(i).NestModel '"']);
        end
        if hm.Models(i).WaveNested
            fprintf(fid,'%s\n',['   WaveNested  "' hm.Models(i).WaveNestModel '"']);
        end
        fprintf(fid,'%s\n',['   SpinUpTime  ' num2str(hm.Models(i).SpinUp)]);
        fprintf(fid,'%s\n',['   RunTime     ' num2str(hm.Models(i).RunTime)]);
        fprintf(fid,'%s\n',['   TimeStep    ' num2str(hm.Models(i).TimeStep)]);
        fprintf(fid,'%s\n',['   MapTimeStep ' num2str(hm.Models(i).MapTimeStep)]);
        fprintf(fid,'%s\n',['   HisTimeStep ' num2str(hm.Models(i).HisTimeStep)]);
        fprintf(fid,'%s\n',['   ComTimeStep ' num2str(hm.Models(i).ComTimeStep)]);
        if hm.Models(i).UseMeteo
            fprintf(fid,'%s\n',['   UseMeteo    yes']);
        else
            fprintf(fid,'%s\n',['   UseMeteo    no']);
        end
        for j=1:hm.Models(i).NrStations
            fprintf(fid,'%s\n',['   Station "' hm.Models(i).Stations(j).Name2 '"']);
            fprintf(fid,'%s\n',['      StName          "' hm.Models(i).Stations(j).Name1 '"']);
            fprintf(fid,'%s\n',['      StLocation      ' num2str(hm.Models(i).Stations(j).Location(1)) ' ' num2str(hm.Models(i).Stations(j).Location(2))]);
            if ~isempty(hm.Models(i).Stations(j).MN)
                fprintf(fid,'%s\n',['      StMN            ' num2str(hm.Models(i).Stations(j).MN(1)) ' ' num2str(hm.Models(i).Stations(j).MN(2))]);
            end
            for k=1:hm.Models(i).Stations(j).NrParameters
                fprintf(fid,'%s\n',['      Parameter ' hm.Models(i).Stations(j).Parameters(k).Name]);                
                if hm.Models(i).Stations(j).Parameters(k).PlotCmp
                    str='yes';
                else
                    str='no';
                end
                fprintf(fid,'%s\n',['         PlotCmp     ' str]);
                %
                if hm.Models(i).Stations(j).Parameters(k).PlotObs
                    str='yes';
                else
                    str='no';
                end
                fprintf(fid,'%s\n',['         PlotObs     ' str]);
                if ~strcmpi(hm.Models(i).Stations(j).Parameters(k).ObsCode,'none')
                    fprintf(fid,'%s\n',['         ObsCode     ' hm.Models(i).Stations(j).Parameters(k).ObsCode]);
                end
                %
                if hm.Models(i).Stations(j).Parameters(k).PlotPrd
                    str='yes';
                else
                    str='no';
                end
                fprintf(fid,'%s\n',['         PlotPrd     ' str]);
                if ~strcmpi(hm.Models(i).Stations(j).Parameters(k).PrdCode,'none')
                    fprintf(fid,'%s\n',['         PrdCode     ' hm.Models(i).Stations(j).Parameters(k).PrdCode]);
                end
                fprintf(fid,'%s\n','      EndParameter');
            end
            fprintf(fid,'%s\n',['   EndStation']);
        end
        for j=1:hm.Models(i).NrAreas
            fprintf(fid,'%s\n',['   Area    "' hm.Models(i).Areas(j).Name '"']);
            fprintf(fid,'%s\n',['      AreaName   "' hm.Models(i).Areas(j).Name '"']);
            fprintf(fid,'%s\n',['      AreaXLim   ' num2str(hm.Models(i).Areas(j).XLim(1)) ' ' num2str(hm.Models(i).Areas(j).XLim(2))]);
            fprintf(fid,'%s\n',['      AreaYLim   ' num2str(hm.Models(i).Areas(j).YLim(1)) ' ' num2str(hm.Models(i).Areas(j).YLim(2))]);
            if hm.Models(i).Areas(j).PlotWL
                str='yes';
            else
                str='no';
            end
            fprintf(fid,'%s\n',['      AreaPlotWL ' str]);
            if hm.Models(i).Areas(j).PlotVel
                str='yes';
            else
                str='no';
            end
            fprintf(fid,'%s\n',['      AreaPlotVel ' str]);
            if hm.Models(i).Areas(j).PlotVelMag
                str='yes';
            else
                str='no';
            end
            fprintf(fid,'%s\n',['      AreaPlotVelMag ' str]);
            if hm.Models(i).Areas(j).PlotHs
                str='yes';
            else
                str='no';
            end
            fprintf(fid,'%s\n',['      AreaPlotHs ' str]);
            if hm.Models(i).Areas(j).PlotTp
                str='yes';
            else
                str='no';
            end
            fprintf(fid,'%s\n',['      AreaPlotTp ' str]);
            fprintf(fid,'%s\n',['   EndArea']);
        end
        fprintf(fid,'%s\n',['EndModel']);
        fclose(fid);
        %fprintf(fid,'%s\n','');
    end

end
