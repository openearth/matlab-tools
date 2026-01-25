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
% Photo Move, Rename, and Change Timestamp
% Moves images from input folder to output folder, renames them to a standardized
% format (yyyymmdd_HHMMSS.jpg), and updates their EXIF metadata timestamps.
%
% SYNTAX:
%   photo_move_rename_change_timestamp(inputFolder, outputFolder)
%
% INPUTS:
%   inputFolder  - Path to folder containing images to process
%   outputFolder - Path to destination folder for renamed images
%
% REQUIREMENTS:
%   * ExifTool must be installed and accessible at: c:\Programs\exiftool\exiftool.exe
%   * Download from: https://exiftool.org/
%   * ExifTool is required to update EXIF DateTimeOriginal metadata without quality loss
%
% SUPPORTED FILENAME PATTERNS:
%   1. IMGyyyymmddhhMMss.jpg         -> yyyymmdd_HHMMSS.jpg
%   2. IMGyyyymmddhhMMss_xx.jpg      -> yyyymmdd_HHMMSS.jpg  
%   3. IMG-yyyymmdd-somestring.jpg   -> yyyymmdd_000000.jpg
%   4. * yyyy-mm-dd at hh.mm.ss *.jpg -> yyyymmdd_HHMMSS.jpg
%
% EXAMPLE:
%   photo_move_rename_change_timestamp('C:\Photos\Input', 'C:\Photos\Output')
%
% NOTES:
%   - Only processes .jpg, .jpeg, and .png files
%   - Handles duplicate filenames by appending _1, _2, etc.
%   - Updates EXIF DateTimeOriginal field based on extracted timestamp
%
function photo_move_rename_change_timestamp(inputFolder, outputFolder)

    % Ensure output folder exists
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
    end

    % List all files in input folder
    files = dir(fullfile(inputFolder, '*.*'));
    
    % Loop through each file
    for k = 1:length(files)
        if files(k).isdir
            continue; % Skip directories
        end
        
        [~, name, ext] = fileparts(files(k).name);
        ext = lower(ext); % Normalize extension
        
        % Only process image files (jpg/jpeg/png)
        if ~ismember(ext, {'.jpg', '.jpeg', '.png'})
            continue;
        end
        
        originalFile = fullfile(inputFolder, files(k).name);
        newFileName = '';
        
        %% Pattern 1: IMGyyyymmddhhMMss.jpg
        token = regexp(name, '^IMG(\d{14})$', 'tokens');
        if ~isempty(token)
            dt = token{1}{1};
            newFileName = [dt(1:8) '_' dt(9:14) '.jpg'];
        end
        
        %% Pattern 2: IMGyyyymmddhhMMss_xx.jpg
        if isempty(newFileName)
            token = regexp(name, '^IMG(\d{14})_.*$', 'tokens');
            if ~isempty(token)
                dt = token{1}{1};
                newFileName = [dt(1:8) '_' dt(9:14) '.jpg'];
            end
        end
        
        %% Pattern 3: IMG-yyyymmdd-somestring.jpg
        if isempty(newFileName)
            token = regexp(name, '^IMG-(\d{8})-.*$', 'tokens');
            if ~isempty(token)
                dt = token{1}{1};
                % Default time if not in filename
                newFileName = [dt '_000000.jpg'];
            end
        end
        
        %% Pattern 4: somestring yyyy-mm-dd at hh.mm.ss somestring.jpg
        if isempty(newFileName)
            token = regexp(name, '(\d{4})-(\d{2})-(\d{2}) at (\d{2})\.(\d{2})\.(\d{2})', 'tokens');
            if ~isempty(token)
                t = token{1};
                newFileName = sprintf('%s%s%s_%s%s%s.jpg', t{1}, t{2}, t{3}, t{4}, t{5}, t{6});
            end
        end
        
        %% If a new filename was created, move the file
        if ~isempty(newFileName)
            destFile = fullfile(outputFolder, newFileName);
            % Handle duplicate filenames
            counter = 1;
            while exist(destFile, 'file')
                [~, baseName, ext] = fileparts(newFileName);
                destFile = fullfile(outputFolder, sprintf('%s_%d%s', baseName, counter, ext));
                counter = counter + 1;
            end
            
            fprintf('Changed: %s -> %s\n', files(k).name, newFileName);
        else
            newFileName = files(k).name; % Keep original name
            destFile = fullfile(outputFolder, newFileName);
            fprintf('Not changed: %s\n', files(k).name);
        end

        %% Move and Rename Timestamp Update
        movefile(originalFile, destFile);
        update_photo_timestamp(destFile, newFileName);
    end

end

%% Update Photo Timestamp Function
% Updates the EXIF DateTimeOriginal metadata of a photo based on the datetime in its filename
% Filename format: yyyymmdd_HHMMSS.jpg
function update_photo_timestamp(filePath, fileName)
    
    % Extract datetime from filename (format: yyyymmdd_HHMMSS.jpg)
    [~, name, ~] = fileparts(fileName);
    token = regexp(name, '^(\d{8})_(\d{6})$', 'tokens');
    
    if isempty(token)
        fprintf('Could not extract datetime from filename: %s\n', fileName);
        return;
    end
    
    % Parse the datetime components
    dateStr = token{1}{1}; % yyyymmdd
    timeStr = token{1}{2}; % HHMMSS
    
    year = str2double(dateStr(1:4));
    month = str2double(dateStr(5:6));
    day = str2double(dateStr(7:8));
    hour = str2double(timeStr(1:2));
    minute = str2double(timeStr(3:4));
    second = str2double(timeStr(5:6));
    
    % Create datetime object
    dt = datetime(year, month, day, hour, minute, second);
    
    % Format for EXIF: 'yyyy:MM:dd HH:mm:ss'
    exifDateTimeStr = datestr(dt, 'yyyy:mm:dd HH:MM:SS');
    
    try
        % Read existing EXIF data
        info = imfinfo(filePath);
        
        % Create a temporary file for the updated image
        [filePath_dir, filePath_name, filePath_ext] = fileparts(filePath);
        tempFile = fullfile(filePath_dir, [filePath_name '_temp' filePath_ext]);
        
        % Copy the file
        copyfile(filePath, tempFile);
        
        % Use exiftool if available (requires exiftool to be installed)
        % Otherwise, use MATLAB's built-in capabilities (limited)
        exiftool_cmd = sprintf('c:\\Programs\\exiftool\\exiftool.exe -DateTimeOriginal="%s" -overwrite_original "%s"', ...
                               exifDateTimeStr, filePath);
        [status, ~] = system(exiftool_cmd);
        
        if status == 0
            fprintf('Updated timestamp for: %s\n', fileName);
        else
            fprintf('Warning: Could not update timestamp for %s (exiftool not found or failed)\n', fileName);
        end
        
        % Clean up temp file if it exists
        if exist(tempFile, 'file')
            delete(tempFile);
        end
        
    catch ME
        fprintf('Error updating timestamp for %s: %s\n', fileName, ME.message);
    end
    
end
