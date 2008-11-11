function [transectStruct] = jarkus2transect(filename)
    % Read a jarkus transect file
    
    % The file looks like this:
    
    %         15  1965     0     0     0  1210    46
    %    150  -2805      160  -3005      170  -4505      180  -9605      190  -9705   
    %    200 -11605      210 -13305      220 -14705      230 -16205      240 -17005   
    %  ...
    %    550 -34005      560 -33405      570 -33205      580 -33005      590 -34105   
    %    600 -35205    999999999999    999999999999    999999999999    999999999999   
    
    %     The first line is a header line for the following section.
    %     Multiple header, section combinations are stored in each file
    %     Each header, section combination defines a year of jarkus
    %     transect data
    
    %     The header line is 
    %     areacode, year, metre, dummy, dateTopo, dateBathy, n
    %     the numbers in the section are
    %     metrering (distance along the shoreline), height (surface elevation in NAP) with a code as the last digit.,
    %     The code is interpreted as
    %     Origin of the data (and combine 1,3 and 5):
    %     id=1 non-overlap beach data
    %     id=2 overlap beach data
    %     id=3 interpolation data (between beach and off shore)
    %     id=4 overlap off shore data
    %     id=5 non-overlap off shore data
    [pathstr, name, ext, versn] = fileparts(filename);
    fid =  fopen(filename);
    
    transectStruct = createtransectstruct();
    transectStruct = repmat(transectStruct, 1, 500);

    i = 0; % count starting by 0  
    while ~feof(fid)    % Statement is valid until the end of each area data file is reached
        % read index line 
        line = fscanf(fid,'%i',7);
        numbers = num2cell(line);
        if (length(numbers) ~= 7)
            error(['invalid line detected:' line]);
        end
        % create a new structure
        transect = createtransectstruct();
        [transect.areacode, transect.year, transect.metre, dummy, transect.dateTopo, transect.dateBathy, transect.n] = deal(numbers{:});
        transect.id = transect.areacode*1000000+transect.metre; %TODO: we need unique ids! Maybe find another way
        transect.areaname = name;
        % read data
        datapoints = fscanf(fid,'%f',[2 transect.n])';
        dummy = fgetl(fid);

        % we have to do a bit of cleaning up
        % - height -> strip of last digit, 
        % - combine different origins and remove non used data
        
        % the last digit in the 2nd number is a code. See createRayStruct
        % creation for definition
        origin = mod(abs(datapoints(:,2)), 10); % use last digit
        height = floor(datapoints(:,2) / 10) ; % bathymetry, set last digit to 0
        seawardDistance = datapoints(:,1); %length seaward
       
        %strip out data where origin is not 1,3,5
        keep_indices = origin == 1  | origin == 3 | origin == 5;
        transect.origin = origin(keep_indices);
        transect.seawardDistance = seawardDistance(keep_indices);
        transect.height = height(keep_indices);

        % store the results in the big array
        transectStruct(i+1) = transect;
        i = i + 1;
    end
    transectStruct(i+1:end) = [];
end
