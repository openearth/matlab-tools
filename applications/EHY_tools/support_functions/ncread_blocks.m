function values = ncread_blocks(inputFile,varName,start,count,dims)

%% Identical to ncread however te speed up data is read in blocks (loop over variable 'time')
% Note that the handling of wanted indices is done within this script, 
% it if therefore not the same as ncread without looping over blocks.

no_dims     = length(dims);
order       = no_dims:-1:1;
timeInd     = strmatch('time',{dims(:).name});

% allocate variable 'values' > also to get NaN's in e.g. non-existing stations
if no_dims == 1
    values = NaN(dims.sizeOut,1);
else
    values = NaN(dims(order).sizeOut);
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
    
    % assuming timeInd==length(dims)
    if timeInd ~= length(dims)
        error(['timeInd is not last variable, ncread_blocks does not work correctly in that case' char(10) ...
            'Please contact Julien Groenenboom or Theo van der Kaaij'])
    end
       
    % cycle over blocks
    offset        = start(end) - 1;
    for i_block = 1:no_blocks
        bl_start                 = 1 + (i_block-1) * bl_length;
        bl_stop                  = min(i_block * bl_length, nr_times_clip);
        bl_int                   = bl_stop-bl_start+1;
        start(end)               = bl_start + offset;
        count(end)               = bl_int;
        if no_dims == 1
            % probably [time]          = [time]
            values(bl_start:bl_stop,1) = ncread(inputFile,varName,start,count);
        elseif no_dims == 2
            values_tmp = ncread(inputFile,varName,start,count);
            % probably [time,station]                 = [station,time]
            values(bl_start:bl_stop,dims(1).indexOut) = permute(values_tmp(dims(1).index,:),order);
        elseif no_dims == 3
            values_tmp = ncread(inputFile,varName,start,count);
            % probably [time,station,layer]                            = [layer,station,time]
            values(bl_start:bl_stop,dims(2).indexOut,dims(1).indexOut) = permute(values_tmp(dims(1).index,dims(2).index,:),order);
        end
    end
    
    % correct for wanted time-indices in case of time-interval 
    % (works for 1D, 2D and 3D sized variable 'values')
    values = values(dims(timeInd).index,:,:);
    
elseif all(ismember({'start','count'},who)) && isempty(timeInd)  % start and count specified, variable has not a time dimension
    values_tmp = ncread(inputFile,varName,start,count);
    values(dims(order).indexOut) = values_tmp(dims.index);
    
else
    % no start and count specified, regular ncread
    values_tmp = ncread(inputFile,varName);
    values(dims(order).indexOut) = values_tmp(dims.index);
end
