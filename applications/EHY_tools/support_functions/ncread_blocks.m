function values = ncread_blocks(inputFile,varName,start,count)

%% Identical to ncread however te speed up data is read in blocks
%  Function can be removed if ncread is speeded up for large datasets 
if all(ismember({'start','count'},who))
    offset        = start(end) - 1;
    nr_times_clip = count(end);
    
    % general information (reconstruct nr_times_clip)
    infonc          = ncinfo(inputFile);
    variablesOnFile = {infonc.Variables.Name};
    nr_var          = get_nr(variablesOnFile,varName);
    dimensions      = fliplr(infonc.Variables(nr_var).Size);
    nr_times        = dimensions(1);
    if isinf(nr_times_clip) nr_times_clip = nr_times; end
    
    % devide in blocks
    filesize     = dir(inputFile);
    filesize     = filesize.bytes /(1024^3); %converted to Gb
    maxblocksize = 0.5; %Gb
    nr_blocks    = ceil((nr_times_clip / nr_times) * (filesize / maxblocksize));
    bl_length    = ceil(nr_times_clip / nr_blocks);
    
    % allocate variable 'values'
    if length(dimensions)==1
        values=zeros([nr_times_clip 1])*NaN;
    elseif length(count) >= 2
        values = zeros([fliplr(dimensions(2:end)) nr_times_clip])*NaN;
        if length(count) == 2 && ~isinf(count(1))
            values = zeros(count(1),nr_times_clip)*NaN;
        elseif length(count) == 3 && ~isinf(count(2))
            values = zeros(dimensions(end),count(2),nr_times_clip)*NaN;
        end
    end
      
    % cycle over blocks
    for i_block = 1: nr_blocks
        bl_start                 = 1 + (i_block-1) * bl_length;
        bl_stop                  = min(i_block * bl_length, nr_times_clip);
        bl_int                   = bl_stop-bl_start+1;
        start(end)               = bl_start + offset;
        count(end)               = bl_int;
        if length(start)     == 1
            values(bl_start:bl_stop,1)   = ncread(inputFile,varName,start,count);
        elseif length(start)     == 2
            values(:,bl_start:bl_stop)   = ncread(inputFile,varName,start,count);
        elseif length(start) == 3
            values(:,:,bl_start:bl_stop) = ncread(inputFile,varName,start,count);
        end
    end
    
else
    % no start and count specified, normal reading
    values = ncread(inputFile,varName);
end
