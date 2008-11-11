function [transect] = createtransectstruct()
    % Create a transect structure with default values
    
    % this should be a general transect structure not specific to 1
    % dataset. It will be preferably replaced by 1 or more classdefs if
    % enough people have matlab versions which will allow it to just work (tm). 
    
    % start creating a single transect structure
    % TODO: find better names for these variables.
    
    transect.areacode = 0;
    transect.areaname = '';
    transect.year = 0;
    transect.metre = 0;
    transect.dateTopo = 0;
    transect.dateBathy = 0;
    transect.n = 0;
    % this is jarkus specific.... should be moved to another entity 
    % Origin of the data (and combine 1,3 and 5):
    % id=1 non-overlap beach data
    % id=2 overlap beach data
    % id=3 interpolation data (between beach and off shore)
    % id=4 overlap off shore data
    % id=5 non-overlap off shore data
    transect.origin = []; % vector of origin codes 
    % Seaward distance from pole;
    transect.seawardDistance = [];
    % Height
    transect.height = [];
    transect.id = 0;
end

