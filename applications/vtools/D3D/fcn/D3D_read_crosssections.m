%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Reads:
%   -cross section definition file (FM or Sobek3)
%   -cross section location file (FM or Sobek3)
%
%INPUT
%   -path_csloc = path to the file to read
%
%OUTPUT
%   -cs_out = structure of cross-sections; struct array
%   -global_data = structure of [Global] block (if present); struct


function [cs_out, global_data]=D3D_read_crosssections(path_csloc)

%% TEST

if nargin==0
    D3D_test_find_file_type();
    return
end

%% UNIFIED SPECS LIST (all possible fields from all file types)

specs=get_unified_specs();

%% PARSE FILE

file_content=read_ascii(path_csloc);
[cs_out, global_data]=parse_file_content(file_content, specs);

end %main function

%%
function [cs_out, global_data]=parse_file_content(file_content, specs)
    ntags=size(specs,1);
    nlcsin=numel(file_content);

    % Initialize outputs
    cs_out=struct();
    global_data=struct();

    % Detect and parse [Initial] / [Parameter] blocks (iniField format)
    initial_indices=find(cellfun(@(x) strcmpi(strtrim(x),'[Initial]'), file_content));
    param_indices=find(cellfun(@(x) strcmpi(strtrim(x),'[Parameter]'), file_content));

    if ~isempty(initial_indices) || ~isempty(param_indices)
        cs_ini=struct([]);
        cs_par=struct([]);
        if ~isempty(initial_indices)
            cs_ini=parse_blocks(file_content, initial_indices, specs, nlcsin);
            for k=1:numel(cs_ini)
                cs_ini(k).blockType='initial';
            end
        end
        if ~isempty(param_indices)
            cs_par=parse_blocks(file_content, param_indices, specs, nlcsin);
            for k=1:numel(cs_par)
                cs_par(k).blockType='parameter';
            end
        end
        cs_out=merge_struct_arrays(cs_ini, cs_par);
        return;
    end

    % Parse [Definition] blocks if present
    def_indices=find(cellfun(@(x) contains(x,'[Definition]'), file_content));
    if ~isempty(def_indices)
        cs_def=parse_blocks(file_content, def_indices, specs, nlcsin);
        cs_out=cs_def;
    end

    % Parse [CrossSection] blocks if present
    cs_indices=find(cellfun(@(x) contains(x,'[CrossSection]'), file_content));
    if ~isempty(cs_indices)
        cs_loc=parse_blocks(file_content, cs_indices, specs, nlcsin);
        if isempty(fieldnames(cs_out))
            cs_out=cs_loc;
        else
            % Concatenate both definition and location blocks
            cs_out=[cs_out, cs_loc];
        end
    end

    % Parse [Global] block if present
    global_idx=find(cellfun(@(x) contains(x,'[Global]'), file_content), 1);
    if ~isempty(global_idx)
        kl2=global_idx+1;
        go=true;
        while go && kl2<=nlcsin
            str_loc2=file_content{kl2,1};
            str_aux_r=regexp(str_loc2,'\w+','match');
            if ~isempty(str_aux_r)
                tag_loc2=str_aux_r{1,1};
                for ktags=1:ntags
                    if strcmpi(tag_loc2,specs{ktags,1})
                        str_aux_split=regexp(str_loc2,'=','split');
                        if numel(str_aux_split)==2
                            str_value=str_aux_split{2};
                            str_aux_l3=regexp(str_value,specs{ktags,2},'match');
                            if ~isempty(str_aux_l3)
                                strconv=specs{ktags,3}(str_aux_l3);
                                global_data.(specs{ktags,1})=strconv;
                            end
                        end
                    end
                end
            end
            kl2=kl2+1;
            
            if kl2<=nlcsin
                str_next=file_content{kl2,1};
                if contains(str_next,'[')
                    go=false;
                end
            else
                go=false;
            end
        end
    end
end

%%
function cs_out=parse_blocks(file_content, block_indices, specs, nlcsin)
    % Helper function to parse a list of blocks ([Definition] or [CrossSection])
    ntags=size(specs,1);
    
    if isempty(block_indices)
        cs_out=struct();
        return;
    end
    
    % First pass: parse all blocks and collect unique field names
    all_blocks=cell(numel(block_indices),1);
    all_fields_cell={};
    
    for kb=1:numel(block_indices)
        kl=block_indices(kb);
        kl2=kl+1;
        go=true;
        block_struct=struct();
        
        while go && kl2<=nlcsin
            str_loc2=file_content{kl2,1};
            str_aux_r=regexp(str_loc2,'\w+','match');
            
            if ~isempty(str_aux_r)
                tag_loc2=str_aux_r{1,1};
                
                for ktags=1:ntags
                    if strcmpi(tag_loc2,specs{ktags,1})
                        str_aux_split=regexp(str_loc2,'=','split');
                        if numel(str_aux_split)==2
                            str_value=str_aux_split{2};
                            str_aux_l3=regexp(str_value,specs{ktags,2},'match');
                            if ~isempty(str_aux_l3)
                                strconv=specs{ktags,3}(str_aux_l3);
                                block_struct.(specs{ktags,1})=strconv;
                                % Track field name
                                if ~any(strcmp(all_fields_cell, specs{ktags,1}))
                                    all_fields_cell{end+1}=specs{ktags,1};
                                end
                            end
                        end
                    end
                end
            end
            
            kl2=kl2+1;
            
            if kl2<=nlcsin
                str_next=file_content{kl2,1};
                if contains(str_next,'[')
                    go=false;
                end
            else
                go=false;
            end
        end
        
        all_blocks{kb}=block_struct;
    end
    
    % Build output struct array with all fields from all blocks
    cs_out=struct();
    for kb=1:numel(all_blocks)
        for kf=1:numel(all_fields_cell)
            if isfield(all_blocks{kb}, all_fields_cell{kf})
                cs_out(kb).(all_fields_cell{kf})=all_blocks{kb}.(all_fields_cell{kf});
            else
                cs_out(kb).(all_fields_cell{kf})=[];
            end
        end
    end
    
end
%%
function strconv=parse_first(str_aux_r)

strconv=str_aux_r{1,1};

end %parse_first

function strconv=parse_double(str_aux_r)

strconv=str2double(str_aux_r);

end %parse_double

function strconv=parse_integer(str_aux_r)

strconv=str2double(str_aux_r);
if numel(strconv)>1
    strconv=strconv(1);
end

end %parse_integer

%%
function find_file_type(path_csloc)

% Detect file type by checking [General] block fileType field,
% or auto-detect by presence of [Definition] or [CrossSection] blocks.
%
% INPUT:
%   path_csloc = path to file
%
% BEHAVIOR:
%   1. Check for [General] block with fileType field
%      - If fileType=crossDef --> Definitions file
%      - If fileType=crossLoc --> Locations file
%      - Unrecognized --> error
%   2. If no [General], auto-detect by block content:
%      - [Definition] found --> Definitions file
%      - [CrossSection] found --> Locations file
%      - Neither --> error

file_content=read_ascii(path_csloc);

% Look for [General] block
general_idx=find(cellfun(@(x) contains(x,'[General]'), file_content), 1);

if ~isempty(general_idx)
    % Search for fileType field in [General] block
    kl=general_idx+1;
    found_filetype=false;
    
    while kl<=numel(file_content) && ~found_filetype
        str_loc=file_content{kl,1};
        
        % Stop at next block
        if contains(str_loc,'[') && ~contains(str_loc,'[General]')
            break;
        end
        
        if contains(str_loc,'fileType')
            % Extract fileType value
            parts=strsplit(str_loc,'=');
            if numel(parts)==2
                ftype=strtrim(parts{2});
                if strcmpi(ftype,'crossDef')
                    fprintf('Detected file type: crossDef (Definitions)\n');
                    return;
                elseif strcmpi(ftype,'crossLoc')
                    fprintf('Detected file type: crossLoc (Locations)\n');
                    return;
                else
                    error('Unknown fileType in [General] block: %s', ftype);
                end
            end
            found_filetype=true;
        end
        kl=kl+1;
    end
end

% Auto-detect by block content
has_definition=any(cellfun(@(x) contains(x,'[Definition]'), file_content));
has_crosssection=any(cellfun(@(x) contains(x,'[CrossSection]'), file_content));

if has_definition
    fprintf('Auto-detected: [Definition] block found --> crossDef (Definitions)\n');
elseif has_crosssection
    fprintf('Auto-detected: [CrossSection] block found --> crossLoc (Locations)\n');
else
    error('Cannot identify file type: no [Definition] or [CrossSection] block found');
end

end %find_file_type

%%
function D3D_test_find_file_type()
    % Embedded test function with hardcoded test data only.
    % No external files/repositories are referenced here.

    fprintf('\n=== TESTING D3D_read_crosssections (HARDCODED DATA) ===\n\n');

    specs=get_unified_specs();

    % Hardcoded datasets
    test_names={
        'crossDef_with_global_and_scientific';
        'crossLoc_fm_style';
        'crossLoc_sobek_style';
        'yz_definition';
        'xyz_definition';
        'tabulated_flags_definition'
    };

    test_data={
        { ...
            '[General]'; 'fileType = crossDef'; '[Global]'; 'leveeTransitionHeight = 4.000000e+02'; ...
            '[Definition]'; 'id = CSD_1'; 'type = zwRiver'; 'thalweg = 0'; 'numLevels = 2'; ...
            'levels = 1.0 2.0'; 'flowWidths = 10.0 20.0'; 'totalWidths = 10.0 20.0'; 'frictionIds = Main;FloodPlain1;FloodPlain2' ...
        };
        { ...
            '[General]'; 'fileType = crossLoc'; '[CrossSection]'; ...
            'id = CSL_1'; 'branchId = BR_1'; 'chainage = 100'; 'shift = 0'; 'definitionId = CSD_1' ...
        };
        { ...
            '[CrossSection]'; 'id = 2153'; 'branchid = Maasmond'; 'chainage = 0.000'; ...
            'name = Maasmond_0'; 'shift = 0.000'; 'definition = 2153' ...
        };
        { ...
            '[Definition]'; 'id = SYN1'; 'type = yz'; 'thalweg = 0'; 'yzCount = 3'; ...
            'yCoordinates = 0 10 20'; 'zCoordinates = 5 4 6'; 'conveyance = segmented'; 'sectionCount = 1'; 'frictionIds = Main' ...
        };
        { ...
            '[Definition]'; 'id = XYZ1'; 'type = xyz'; 'thalweg = 0'; 'xyzCount = 2'; ...
            'xCoordinates = 1 2'; 'yCoordinates = 3 4'; 'zCoordinates = 5 6'; 'conveyance = segmented'; 'sectionCount = 1'; 'frictionIds = Main' ...
        };
        { ...
            '[Definition]'; 'id = 2153'; 'type = tabulated'; 'thalweg = 0.000'; 'numLevels = 2'; ...
            'levels = -26.40000 -22.62000'; 'flowWidths = 42.00000 369.00000'; 'totalWidths = 42.00000 369.00000'; ...
            'sd_crest = 5.290'; 'sd_flowArea = 271.000'; 'sd_totalArea = 28.000'; 'sd_baseLevel = 3.790'; ...
            'main = 1193.000'; 'floodPlain1 = 17.000'; 'floodPlain2 = 0.000'; 'groundlayerUsed = 0'; 'groundlayer = 0.000'; 'isShared = 1' ...
        }
    };

    npass=0;
    nfail=0;

    for kt=1:numel(test_data)
        try
            fprintf('Test %d: %s\n', kt, test_names{kt});
            file_content=reshape(test_data{kt}, [], 1);
            [cs_out, global_data]=parse_file_content(file_content, specs);

            fprintf('  Parsed %d cross-sections\n', numel(cs_out));
            if ~isempty(global_data)
                fprintf('  Found [Global] block with %d fields\n', numel(fieldnames(global_data)));
            end
            if ~isempty(cs_out) && isfield(cs_out(1),'id')
                fprintf('  First ID: %s\n', to_char(cs_out(1).id));
            end

            npass=npass+1;
            fprintf('  PASS\n\n');
        catch ME
            fprintf('  ERROR: %s\n', ME.message);
            nfail=nfail+1;
            fprintf('  FAIL\n\n');
        end
    end

    fprintf('=== SUMMARY (cross-section tests) ===\n');
    fprintf('Passed: %d / Failed: %d\n', npass, nfail);

    %% iniField assertion tests
    fprintf('\n=== iniField TESTS ===\n\n');
    nipass=0;
    nifail=0;

    % --- iniField test 1: basic [Initial] block ---
    try
        fprintf('iniField test 1: basic [Initial] block\n');
        fc={ ...
            '[Initial]'; 'quantity = bedlevel'; 'dataFile = dep.xyz'; ...
            'dataFileType = sample'; 'interpolationMethod = averaging'; 'averagingType = nearestNb'};
        [cs, ~]=parse_file_content(fc, specs);
        assert(numel(cs)==1,                              'expected 1 entry');
        assert(strcmp(cs(1).blockType,'initial'),         'blockType must be ''initial''');
        assert(strcmp(cs(1).quantity,'bedlevel'),         'quantity mismatch');
        assert(strcmp(cs(1).dataFile,'dep.xyz'),          'dataFile mismatch');
        assert(strcmp(cs(1).dataFileType,'sample'),       'dataFileType mismatch');
        assert(strcmp(cs(1).interpolationMethod,'averaging'), 'interpolationMethod mismatch');
        assert(strcmp(cs(1).averagingType,'nearestNb'),   'averagingType mismatch');
        nipass=nipass+1;
        fprintf('  PASS\n\n');
    catch ME
        fprintf('  FAIL: %s\n\n', ME.message);
        nifail=nifail+1;
    end

    % --- iniField test 2: basic [Parameter] block ---
    try
        fprintf('iniField test 2: basic [Parameter] block\n');
        fc={ ...
            '[Parameter]'; 'quantity = frictionCoefficient'; 'dataFile = manning.xyz'; ...
            'dataFileType = sample'; 'interpolationMethod = triangulation'};
        [cs, ~]=parse_file_content(fc, specs);
        assert(numel(cs)==1,                                    'expected 1 entry');
        assert(strcmp(cs(1).blockType,'parameter'),             'blockType must be ''parameter''');
        assert(strcmp(cs(1).quantity,'frictionCoefficient'),    'quantity mismatch');
        assert(strcmp(cs(1).dataFile,'manning.xyz'),            'dataFile mismatch');
        assert(strcmp(cs(1).interpolationMethod,'triangulation'), 'interpolationMethod mismatch');
        nipass=nipass+1;
        fprintf('  PASS\n\n');
    catch ME
        fprintf('  FAIL: %s\n\n', ME.message);
        nifail=nifail+1;
    end

    % --- iniField test 3: mixed [Initial] and [Parameter] blocks (ini.ini content) ---
    try
        fprintf('iniField test 3: mixed [Initial] and [Parameter] blocks\n');
        fc={ ...
            '[General]'; 'fileVersion = 2.00'; 'fileType = iniField'; ...
            '[Initial]'; 'quantity = bedlevel';        'dataFile = dep.xyz'; 'dataFileType = sample'; 'interpolationMethod = averaging'; 'averagingType = nearestNb'; ...
            '[Initial]'; 'quantity = initialWaterLevel'; 'dataFile = dep.xyz'; 'dataFileType = sample'; 'interpolationMethod = averaging'; 'averagingType = nearestNb'; ...
            '[Initial]'; 'quantity = initialVelocityX'; 'dataFile = dep.xyz'; 'dataFileType = sample'; 'interpolationMethod = averaging'; 'averagingType = nearestNb'; ...
            '[Initial]'; 'quantity = initialVelocityY'; 'dataFile = dep.xyz'; 'dataFileType = sample'; 'interpolationMethod = averaging'; 'averagingType = nearestNb'; ...
            '[Parameter]'; 'quantity = frictionCoefficient'; 'dataFile = manning.xyz'; 'dataFileType = sample'; 'interpolationMethod = triangulation'};
        [cs, ~]=parse_file_content(fc, specs);
        assert(numel(cs)==5,                                'expected 5 entries');
        n_initial=sum(strcmp({cs.blockType},'initial'));
        n_param  =sum(strcmp({cs.blockType},'parameter'));
        assert(n_initial==4,                                'expected 4 initial entries');
        assert(n_param==1,                                  'expected 1 parameter entry');
        assert(strcmp(cs(1).quantity,'bedlevel'),            'first entry quantity mismatch');
        assert(strcmp(cs(5).blockType,'parameter'),         'last entry must be parameter');
        assert(strcmp(cs(5).quantity,'frictionCoefficient'),'last entry quantity mismatch');
        nipass=nipass+1;
        fprintf('  PASS\n\n');
    catch ME
        fprintf('  FAIL: %s\n\n', ME.message);
        nifail=nifail+1;
    end

    % --- iniField test 4: optional fields ---
    try
        fprintf('iniField test 4: optional fields (operand, averagingRelSize, averagingNumMin, averagingPercentile, extrapolationMethod, locationType)\n');
        fc={ ...
            '[Initial]'; 'quantity = bedlevel'; 'dataFile = dep.xyz'; ...
            'dataFileType = polygon'; 'interpolationMethod = averaging'; ...
            'operand = O'; 'averagingType = mean'; 'averagingRelSize = 1.01'; ...
            'averagingNumMin = 2'; 'averagingPercentile = 0.5'; ...
            'extrapolationMethod = yes'; 'locationType = 2d'; 'value = -5.0'};
        [cs, ~]=parse_file_content(fc, specs);
        assert(numel(cs)==1,                                  'expected 1 entry');
        assert(strcmp(cs(1).operand,'O'),                     'operand mismatch');
        assert(strcmp(cs(1).averagingType,'mean'),            'averagingType mismatch');
        assert(abs(cs(1).averagingRelSize - 1.01) < 1e-10,   'averagingRelSize mismatch');
        assert(cs(1).averagingNumMin == 2,                    'averagingNumMin mismatch');
        assert(abs(cs(1).averagingPercentile - 0.5) < 1e-10, 'averagingPercentile mismatch');
        assert(strcmp(cs(1).extrapolationMethod,'yes'),       'extrapolationMethod mismatch');
        assert(strcmp(cs(1).locationType,'2d'),               'locationType mismatch');
        assert(abs(cs(1).value - (-5.0)) < 1e-10,            'value mismatch');
        nipass=nipass+1;
        fprintf('  PASS\n\n');
    catch ME
        fprintf('  FAIL: %s\n\n', ME.message);
        nifail=nifail+1;
    end

    fprintf('=== SUMMARY (iniField tests) ===\n');
    fprintf('Passed: %d / Failed: %d\n', nipass, nifail);

end %D3D_test_find_file_type

%%
function specs=get_unified_specs()
    % Regex patterns for numeric and string matching
    str_dec='[+-]?([0-9]+\.?[0-9]*|\.[0-9]+)([eE][+-]?[0-9]+)?';  % decimal + scientific notation
    str_char_one='\w+([.-]?\w+)*';
    str_char_list='\w+([.-]?\w+)*(;\w+([.-]?\w+)*)*';

    % Unified specs: {fieldname, regex_pattern, @parse_function}
    % No case/type discrimination; all fields parsed if present
    specs={ ...
        % Common fields (all block types)
        'id'              ,str_char_one                 ,@parse_first  ; ...
        'type'            ,str_char_one                 ,@parse_first  ; ...
        'thalweg'         ,str_dec             ,@parse_double ; ...
        % Definition/zwRiver type (zw table)
        'numLevels'       ,'\d+'               ,@parse_integer; ...
        'levels'          ,str_dec             ,@parse_double ; ...
        'flowWidths'      ,str_dec             ,@parse_double ; ...
        'totalWidths'     ,str_dec             ,@parse_double ; ...
        % Extended widths (FM style)
        'mainWidth'       ,str_dec             ,@parse_double ; ...
        'fp1Width'        ,str_dec             ,@parse_double ; ...
        'fp2Width'        ,str_dec             ,@parse_double ; ...
        % New Sobek3 fields (tabulated type with detailed levee/floodplain info)
        'sd_crest'        ,str_dec             ,@parse_double ; ...
        'sd_flowArea'     ,str_dec             ,@parse_double ; ...
        'sd_totalArea'    ,str_dec             ,@parse_double ; ...
        'sd_baseLevel'    ,str_dec             ,@parse_double ; ...
        'main'            ,str_dec             ,@parse_double ; ...
        'floodPlain1'     ,str_dec             ,@parse_double ; ...
        'floodPlain2'     ,str_dec             ,@parse_double ; ...
        % Levee fields (FM style)
        'leveeCrestLevel' ,str_dec             ,@parse_double ; ...
        'leveeFlowArea'   ,str_dec             ,@parse_double ; ...
        'leveeTotalArea'  ,str_dec             ,@parse_double ; ...
        'leveeBaseLevel'  ,str_dec             ,@parse_double ; ...
        % XYZ/YZ/Rectangle types
        'xyzCount'        ,'\d+'               ,@parse_double; ...
        'yzCount'         ,'\d+'               ,@parse_double; ...
        'xCoordinates'    ,str_dec             ,@parse_double; ...
        'yCoordinates'    ,str_dec             ,@parse_double; ...
        'zCoordinates'    ,str_dec             ,@parse_double; ...
        'width'           ,str_dec             ,@parse_double; ...
        'height'          ,str_dec             ,@parse_double; ...
        'closed'          ,str_char_one                 ,@parse_first ; ...
        % Conveyance and friction
        'conveyance'      ,str_char_one                 ,@parse_first ; ...
        'sectionCount'    ,'\d+'               ,@parse_double; ...
        'frictionIds'     ,str_char_list                ,@parse_first  ; ...
        'frictionPositions',str_dec            ,@parse_double; ...
        % Sobek3 location fields
        'branchid'        ,str_char_one                 ,@parse_first ; ...
        'branchId'        ,str_char_one                 ,@parse_first ; ...
        'chainage'        ,str_dec             ,@parse_double; ...
        'shift'           ,str_dec             ,@parse_double; ...
        'name'            ,str_char_one                 ,@parse_first ; ...
        % FM location fields
        'definitionId'    ,str_char_one                 ,@parse_first ; ...
        'definition'      ,str_char_one                 ,@parse_first ; ...
        % Additional flags
        'isShared'        ,'\d+'               ,@parse_double ; ...
        'groundlayerUsed' ,'\d+'               ,@parse_double ; ...
        'groundlayer'     ,str_dec             ,@parse_double ; ...
        'singleValuedZ'   ,str_char_one                 ,@parse_first ; ...
        % Global fields
        'leveeTransitionHeight',str_dec          ,@parse_double ; ...
        % iniField blocks ([Initial] / [Parameter])
        'quantity'             ,str_char_one       ,@parse_first  ; ...
        'dataFile'             ,str_char_one       ,@parse_first  ; ...
        'dataFileType'         ,str_char_one       ,@parse_first  ; ...
        'interpolationMethod'  ,str_char_one       ,@parse_first  ; ...
        'operand'              ,'\S+'              ,@parse_first  ; ...
        'averagingType'        ,str_char_one       ,@parse_first  ; ...
        'averagingRelSize'     ,str_dec            ,@parse_double ; ...
        'averagingNumMin'      ,'\d+'              ,@parse_integer; ...
        'averagingPercentile'  ,str_dec            ,@parse_double ; ...
        'extrapolationMethod'  ,str_char_one       ,@parse_first  ; ...
        'locationType'         ,str_char_one       ,@parse_first  ; ...
        'value'                ,str_dec            ,@parse_double ; ...
        'frictionType'         ,str_char_one       ,@parse_first  ; ...
        'tracerFallVelocity'   ,str_dec            ,@parse_double ; ...
        'tracerDecayTime'      ,str_dec            ,@parse_double ; ...
    };
end

%%
function merged=merge_struct_arrays(arr1, arr2)
% Merge two struct arrays that may have different field sets.
% Missing fields in each array are filled with [].
    if isempty(arr1)
        merged=arr2;
        return;
    end
    if isempty(arr2)
        merged=arr1;
        return;
    end
    f1=fieldnames(arr1);
    f2=fieldnames(arr2);
    missing_in_1=setdiff(f2, f1);
    missing_in_2=setdiff(f1, f2);
    for k=1:numel(arr1)
        for kf=1:numel(missing_in_1)
            arr1(k).(missing_in_1{kf})=[];
        end
    end
    for k=1:numel(arr2)
        for kf=1:numel(missing_in_2)
            arr2(k).(missing_in_2{kf})=[];
        end
    end
    merged=[arr1, arr2];
end %merge_struct_arrays

%%
function out=to_char(v)
    if isnumeric(v)
        out=num2str(v);
    else
        out=v;
    end
end
