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
% Unit test to compare multiple pairs of folders (text + NetCDF)
% Collects all differences and reports them at the end

classdef test_floris_to_fm < matlab.unittest.TestCase

    properties
        folder_pairs  % cell array of {folder_1, folder_2} pairs
        allowed_extensions = {'.bc', '.ini', '.xml', '.ext', '.mdu', '.bat', '.sh', '.nc'};
    end

    methods(TestMethodSetup)
        function setup_folder_pairs(test_case)
            % Define folder pairs to compare
            test_case.folder_pairs = {
                % {'folder1a', 'folder2a'}, 
                {'p:\11211900-002-floris-to-fm\06_simulations\03_testbench\01_input\r001\floris.cfg', 'p:\11211900-002-floris-to-fm\06_simulations\03_testbench\02_references\r001\'}
            };
        end
    end

    methods(Test)
        function test_all_allowed_files_multiple_pairs(test_case)
            all_differing_files = {};

            % Create folder where tests are temporary stored
            fdir_work=pwd;
            fdir_test=fullfile(fdir_work,'test_tmp');
            mkdir_check(fdir_test)

            % Loop over all folder pairs
            for p = 1:numel(test_case.folder_pairs)
                fpath_cfg = test_case.folder_pairs{p}{1};
                folder_2 = test_case.folder_pairs{p}{2};

                % Run conversion
                fdir_out=fullfile(fdir_test,sprintf('r%03d',p));
                floris_to_fm(fpath_cfg,'fdir_out',fdir_out,'write',1);

                % Compare folders
                differing_files = test_floris_to_fm.compare_folder_files(fdir_out, folder_2, test_case.allowed_extensions);
                if ~isempty(differing_files)
                    header = sprintf('Differences in folder pair: %s vs %s', fdir_out, folder_2);
                    all_differing_files{end+1} = header;
                    all_differing_files = cat(2,all_differing_files,differing_files); 
                end
            end

            % Assert all files are identical
            if ~isempty(all_differing_files)
                diff_report = strjoin(all_differing_files, '\n\n');
                test_case.assertFail(sprintf('Some files differ across folder pairs:\n\n%s', diff_report));
            end
        end
    end

methods(Static)
    function differing_files = compare_folder_files(folder_1, folder_2, allowed_extensions)
        % Helper function to compare files in one folder pair
        differing_files = {};
        all_files = dir(fullfile(folder_1, '**', '*.*'));

        % Filter only files (exclude directories)
        all_files = all_files(~[all_files.isdir]);

        % Loop over all files and check extensions
        for k = 1:numel(all_files)
            [~, ~, ext] = fileparts(all_files(k).name);
            if ~ismember(lower(ext), allowed_extensions)
                continue; % skip files not in allowed extensions
            end

            % Full path in folder_1
            file_1_full = fullfile(all_files(k).folder, all_files(k).name);
            relative_path = strrep(file_1_full, [folder_1], '');
            file_2_full = fullfile(folder_2, relative_path);
            if isfolder(file_1_full)
                continue
            end

            % Check existence
            if ~isfile(file_2_full)
                differing_files{end+1} = sprintf('Missing in folder_2: %s', relative_path);
                continue;
            end

            % Compare based on extension
            is_equal = true;
            if strcmpi(ext, '.nc')
                is_equal = NC_compare(file_1_full, file_2_full);
                if ~is_equal
                    differing_files{end+1} = sprintf('NetCDF files differ: %s', relative_path);
                end
            else
                [is_equal, diff_lines] = compare_text_files(file_1_full, file_2_full);
                if ~is_equal && ~isempty(diff_lines)
                    first_diff_str = sprintf('File1: %s\nFile2: %s', diff_lines(1,1), diff_lines(1,2));
                    differing_files{end+1} = sprintf('Files differ: %s\n%s', relative_path, first_diff_str);
                end
            end
        end
    end
end
end
