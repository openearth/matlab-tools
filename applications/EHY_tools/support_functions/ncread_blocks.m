function values = ncread_blocks(inputFile,varName,start,count)

%% Identical to ncread however te speed up data is read in blocks (loop over variable 'time')
%  Function can be removed if ncread is speeded up for large datasets 

dims        = EHY_getDimsInfo(inputFile,varName);
no_dims     = length(dims);
timeInd     = strmatch('time',{dims(:).name});

if all(ismember({'start','count'},who)) && ~isempty(timeInd)
    
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
    
    % allocate variable 'values'
    if numel(count) == 1
        values = NaN(count,1);
    else
        values = NaN(count);
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
            values(bl_start:bl_stop,1)   = ncread(inputFile,varName,start,count);
        elseif no_dims == 2
            values(:,bl_start:bl_stop)   = ncread(inputFile,varName,start,count);
        elseif no_dims == 3
            values(:,:,bl_start:bl_stop) = ncread(inputFile,varName,start,count);
        end
    end
    
else
    % no start and count specified, normal reading
    values = ncread(inputFile,varName);
end
