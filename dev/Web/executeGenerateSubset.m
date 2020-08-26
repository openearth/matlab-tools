function executeGenerateSubset(inputJson, debug)
%Function to execute the generation subset functionallity
if debug == 1
    try
        conf = Configuration;
        currentDate = datestr(now, 'dd-mmm-yyyy_HH-MM-SS');
        debug = 0;
        if isdir(fullfile(conf.DEBUG_FOLDER));
            save([fullfile(conf.DEBUG_FOLDER) 'executeGenerateSubset' '_' currentDate '.mat']);
        else
            mkdir(fullfile(conf.DEBUG_FOLDER));
            save([fullfile(conf.DEBUG_FOLDER) 'executeGenerateSubset' '_' currentDate '.mat']);
        end;
    catch
        sct = lasterror;
        errordlg([sct.message ' Error. The debug file could not be saved.']);
        return;
    end
end;

myFile = loadjson(inputJson);

switch myFile.dataType
    case 'selection'
        selections = myFile.selections;
        
        sizeSelections = size(selections);
        
        %prelocate values; remember if you add values to the json add them
        %to this struct
        options(sizeSelections(2)) = struct('isLoop', false, 'selectionType', 'coordinate', 'reduceDim', false, 'useMinValue', false,...
                                            'useMaxValue', false, 'interval', 1, 'isCoordinate', true, 'subsetType', '',...
                                            'start', '', 'end', '', 'isIndex', false, 'loopInterval', '', 'filesSelected', '',...
                                            'file', '', 'subsetName', '');
        %Selection
        for i=1:sizeSelections(2)
            fieldsInSelection = fieldnames(selections{i});
            for kk=1:numel(fieldsInSelection)
               options(i).(fieldsInSelection{kk}) = selections{i}.(fieldsInSelection{kk});
            end
            
            if strcmpi(selections{i}.selectionType, 'coordinate')
                options(i).isCoordinate = true;
                options(i).isIndex = false;
            else
                options(i).isCoordinate = false;
                options(i).isIndex = true;
            end
            
            options(i) = Util.setDefaultNumberField(options(i), 'start');
            options(i) = Util.setDefaultNumberField(options(i), 'end');
            options(i) = Util.setDefaultNumberField(options(i), 'interval');
            options(i) = Util.setDefaultNumberField(options(i), 'useMinValue');
            options(i) = Util.setDefaultNumberField(options(i), 'useMaxValue');
            options(i) = Util.setDefaultNumberField(options(i), 'isCoordinate');
            options(i) = Util.setDefaultNumberField(options(i), 'isIndex');
            options(i) = Util.setDefaultNumberField(options(i), 'isLoop');
            options(i) = Util.setDefaultNumberField(options(i), 'reduceDim');
            options(i) = Util.setDefaultNumberField(options(i), 'loopInterval');
            
            %Add the source info to each option
            if ~isfield(myFile.source, 'selectedFiles') || ~isfield(myFile.source, 'source') || ~isfield(myFile.source, 'subsetName')
                errordlg('Error. Please check your selection');
                return;
            end

            options(i).filesSelected = myFile.source.selectedFiles;
            options(i).file          = myFile.source.source;
            options(i).subsetName    = myFile.source.subsetName;
            
            options(i).dataType = 'selection';
        end;
        
    case 'interpolation'
        temp = myFile.data;
        coefficients = temp.coefficients;
        
        data = [];
        for i=1:length(coefficients)-1 %to avoid the empty field from the web table
            names{i} = coefficients{i}.name;
            
            switch temp.interpType
                case 'point'
                    %you will get a matrix [x y]
                    data = [data;coefficients{i}.x coefficients{i}.y];
                case 'transect'
                    %you will get a matrix [xstart xend ystart yend dx]
                    data = [data;coefficients{i}.xStart coefficients{i}.xEnd coefficients{i}.yStart coefficients{i}.yEnd coefficients{i}.dx];
                    
                case 'area'
                    %you will get a matrix [xstart xend ystart yend dx dy]
                    data = [data;coefficients{i}.xStart coefficients{i}.xEnd coefficients{i}.yStart coefficients{i}.yEnd coefficients{i}.dx coefficients{i}.dy];
                    
            end
        end
        
        %transform the layer selection if the user select multiple layers
        if isfield(temp, 'layer')
            elements = regexp(temp.layer,' ','split');
            layer = str2double(elements)';
            temp.layer = layer;
        end
        
        %transform the layer selection if the user select multiple layers
        if isfield(temp, 'extraValues')
            elements = regexp(temp.extraValues,' ','split');
            extraValues = str2double(elements)';
            temp.extraValues = extraValues;
        end
        
        if isfield(temp, 'minValue')
            temp.minValue = str2double(temp.minValue);
        end
        
        if isfield(temp, 'maxValue')
            temp.maxValue = str2double(temp.maxValue);
        end
        
        temp.coefficients = data;
        temp.coefficientsNames = names';
        
        %Add the source info to each option
        if ~isfield(myFile.source, 'selectedFiles') || ~isfield(myFile.source, 'source') || ~isfield(myFile.source, 'subsetName')
            errordlg('Error. Please check your selection');
            return;
        end

        temp.filesSelected = myFile.source.selectedFiles;
        temp.file          = myFile.source.source;
        temp.subsetName    = myFile.source.subsetName;
        
        options = temp;
        
        options.dataType = 'interpolation';        
end;

WebDataset.generateSubset(options);

end