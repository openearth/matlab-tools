function newName = EHY_nameOnFile(inputFile,varName)

newName                    = varName;

modelType                  = EHY_getModelType(inputFile);
[~, typeOfModelFileDetail] = EHY_getTypeOfModelFile(inputFile);

switch typeOfModelFileDetail
    case 'his_nc'
        %% Get the name of varName as specified on the history file of a simulation       
        if strcmpi(varName,'sal'         ) newName = 'salinity'   ; end
        if strcmpi(varName,'tem'         ) newName = 'temperature'; end
        
        switch modelType
            case 'dfm'
                if strcmpi(varName,'wl'         ) newName = 'waterlevel'   ; end
                if strcmpi(varName,'wd'         ) newName = 'waterdepth'   ; end
                if strcmpi(varName,'water depth') newName = 'waterdepth'   ; end
                if strcmpi(varName,'uv'         ) newName = 'x_velocity'   ; end
                if strcmpi(varName,'Zcen'       ) newName = 'zcoordinate_c'; end
                if strcmpi(varName,'Zint'       ) newName = 'zcoordinate_w'; end
                if strcmpi(varName,'Zcen_cen'   ) newName = 'zcoordinate_c'; end
                if strcmpi(varName,'Zcen_int'   ) newName = 'zcoordinate_w'; end

        end
        
    case {'map_nc','fou_nc'}
        %% Get the name of varName as specified on the map file of a simulation
        switch modelType
            case 'dfm'
                if strcmpi(varName,'wl'         ) newName = 's1'         ; end
                if strcmpi(varName,'waterlevel' ) newName = 's1'         ; end
                if strcmpi(varName,'sal'        ) newName = 'sa1'        ; end
                if strcmpi(varName,'tem'        ) newName = 'tem1'       ; end
                if strcmpi(varName,'uv'         ) newName = 'ucx'        ; end
                if strcmpi(varName,'wd'         ) newName = 'waterdepth' ; end
                if strcmpi(varName,'water depth') newName = 'waterdepth' ; end
                
                % to deal with old/new variable names like tem1 vs. mesh2d_tem1 
                infonc = ncinfo(inputFile);
                if ~nc_isvar(inputFile,newName)
                    ind = find(~cellfun(@isempty,strfind({infonc.Variables.Name},newName)));
                    if ~isempty(ind)
                        newName = infonc.Variables(ind).Name;
                    else
                        error(['Could not find variable ''' varName ''' on provided file']);
                    end
                end
        end
end
