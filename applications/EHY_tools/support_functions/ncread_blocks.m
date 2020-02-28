function values = ncread_blocks(inputFile,varName,start,count,dims)

%% Identical to ncread however te speed up data is read in blocks (loop over variable 'time')
% Note that the handling of wanted indices is also done within this script, 
% it if therefore not the same as ncread without looping over blocks.

no_dims     = length(dims);
timeInd     = strmatch('time',{dims(:).name});

% allocate variable 'values' > also to get NaN's in e.g. non-existing stations
if no_dims == 1
    values = NaN(dims.sizeOut,1);
else
    values = NaN(dims.sizeOut);
end

% check if output is char or double 
infonc = ncinfo(inputFile,varName);
if strcmp(infonc.Datatype,'char')
   values = char(values);
end
    
if all(ismember({'start','count'},who)) && ~isempty(timeInd) % start and count specified, variable has time dimension
    
    nr_times      = dims(timeInd).size;
    nr_times_clip = count(timeInd);
    
    % devide in blocks
    filesize     = dir(inputFile);
    filesize     = filesize.bytes /(1024^3); %converted to Gb
    maxblocksize = 0.5; %Gb
    no_blocks    = ceil((nr_times_clip / nr_times) * (filesize / maxblocksize));
    bl_length    = ceil(nr_times_clip / no_blocks);
    
    if strcmp(dims(end).name,'-') && timeInd == no_dims-1
        % correction for 1D-data (was added by EHY_getmodeldata_optimiseDims for easier handling)
        no_dims = no_dims - 1;
    else
        % assuming timeInd == 1
        if timeInd ~= 1
            error(['timeInd is not last variable, ncread_blocks does not work correctly in that case' char(10) ...
                'Please contact Julien.Groenenboom@deltares.nl'])
        end
    end

    % cycle over blocks
    offset        = start(1) - 1;
    for i_block = 1:no_blocks
        bl_start                 = 1 + (i_block-1) * bl_length;
        bl_stop                  = min(i_block * bl_length, nr_times_clip);
        bl_int                   = bl_stop-bl_start+1;
        start(1)                 = bl_start + offset;
        count(1)                 = bl_int;
        
        % Make sure values_tmp has to correct dimensions (MATLAB
        % automatically squeezes if size(values_tmp,1) would have been 1
        for iC = 1:numel(count)
            tmp(iC).indexOut = 1:count(iC);
        end
        values_tmp = [];
        values_tmp(tmp(:).indexOut) = nc_varget(inputFile,varName,start-1,count);
        
        if no_dims == 1
            % probably [time]          = [time]
            values(bl_start:bl_stop,1) = values_tmp;
        elseif no_dims == 2
            values(bl_start:bl_stop,dims(2).indexOut) = values_tmp(:,dims(2).index);
        elseif no_dims == 3
            values(bl_start:bl_stop,dims(2).indexOut,dims(3).indexOut) = values_tmp(:,dims(2).index,dims(3).index);
        end
    end
    
    % correct for wanted time-indices in case of time-interval 
    % (works for 1D, 2D and 3D sized variable 'values')
    values = values(dims(timeInd).index,:,:);
    
elseif all(ismember({'start','count'},who)) && isempty(timeInd)  
    % start and count specified, variable has not a time dimension
    values_tmp = nc_varget(inputFile,varName,start-1,count);
    if strcmp(infonc.Datatype,'char'); values_tmp = values_tmp'; end
    values(dims.indexOut) = values_tmp(dims.index);
    
else
    % no start and count specified, regular ncread
    values_tmp = nc_varget(inputFile,varName);
    if strcmp(infonc.Datatype,'char'); values_tmp = values_tmp'; end
    values(dims.indexOut) = values_tmp(dims.index);
    
end
