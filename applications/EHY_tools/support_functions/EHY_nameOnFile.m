function newName = EHY_nameOnFile(inputFile,varName)

% get modelType and typeOfModelFileDetail
modelType                  = EHY_getModelType(inputFile);
[~, typeOfModelFileDetail] = EHY_getTypeOfModelFile(inputFile);

% for Delft3D 4, IMPLIC and SOBEK3
if strcmpi(varName,'sal')          varName = 'salinity'   ; end
if strcmpi(varName,'tem')          varName = 'temperature'; end
if strcmpi(varName,'waterlevel'  ) varName = 'wl'         ; end
if strcmpi(varName,'waterdepth'  ) varName = 'wd'         ; end
if strcmpi(varName,'water depth' ) varName = 'wd'         ; end
        
newName = varName;

switch typeOfModelFileDetail
    case 'his_nc'
        %% Get the name of varName as specified on the history file of a simulation       
        switch modelType
            case 'dfm'
                if strcmpi(varName,'wl'         ) newName = 'waterlevel'   ; end
                if strcmpi(varName,'wd'         ) newName = 'waterdepth'   ; end
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
                if strcmpi(varName,'salinity'   ) newName = 'sa1'        ; end
                if strcmpi(varName,'temperature') newName = 'tem1'       ; end
                if strcmpi(varName,'uv'         ) newName = 'ucx'        ; end
                if strcmpi(varName,'wd'         ) newName = 'waterdepth' ; end
                
                % to deal with old/new variable names like tem1 vs. mesh2d_tem1 
                infonc = ncinfo(inputFile);
                if ~nc_isvar(inputFile,newName)
                    ind = find(~cellfun(@isempty,strfind(lower({infonc.Variables.Name}),newName)));
                    if ~isempty(ind)
                        newName = infonc.Variables(ind).Name;
                    else
                        error(['Could not find variable ''' varName ''' on provided file']);
                    end
                end
        end
end
