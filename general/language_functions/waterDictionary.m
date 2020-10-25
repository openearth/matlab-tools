function string=waterDictionary (id,un,lan,varargin)

%  First attempt for language support in scripting
%  Allowing for easy creation of figures in different languages
%
%  Based upon and inspired by labels4all from Victor (Thanks Victor!)
%  Extending language support can be done by adding/modifying the file waterDictionary.csv
%
%  input:
%  id  - Identification code for the parameter (we might in future as well use the english name for that;
%                                               not now not to mess up our current projects!
%  un  - 1 for m, 1/1000 for km, NaN for nothing
%  lan - the language for the reulting string (en  -english, nl - dutch, es - spanisch)
%
%% Initialise
OPT.addUnit       = true;
OPT               = setproperty(OPT,varargin);
[pathDict,~,~]    = fileparts(mfilename('fullpath'));

%% Load the dictionary
data       = simona2mdu_csvread([pathDict filesep 'waterDictionary.csv']);
header     = data(1    ,:);
dictionary = data(2:end,:);

%% Find the right columns
colUnit = get_nr(header,'Unit');
colLang = get_nr(header,lan   );

%% Find the right row
rowVar  = get_nr(dictionary(:,1),id);

%% Construct the final string
string = dictionary{rowVar,colLang};

%% Add the Unit
if OPT.addUnit
    unit = dictionary{rowVar,colUnit};
    if ~isempty(unit) 
        if ~isempty(un) && un == 1/1000 && strcmp(unit,'m') unit = ['k' unit]; end
        string = [string ' [' unit ']'];
    end
end
