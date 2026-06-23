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
%Write path of <fpath_file> relative to <fpath_dir>

function fpath_rel=relative_path(fpath_file,fpath_dir)

%% TEST
if nargin==0
    run_tests();
    return
end

%% MAIN

% fpath_file='p:\dflowfm\projects\2022_improve_exner\04_documents\04_test_01\co\01_figures\morfac_test\MF_10_12.png';
% fpath_file='p:\dflowfm\projects\2022_improve_exner\06_simulations\02_runs\r612\MF_10_12.png';
% fpath_file='p:\dflowfm\projects\2022_improve_exner\06_simulations\02_runs\MF_10_12.png';
% fpath_dir ='p:\dflowfm\projects\2022_improve_exner\06_simulations\02_runs\r612\';

if strcmp(fpath_dir(end),'/') || strcmp(fpath_dir(end),'\')
    fpath_dir(end)='';
end

tok_file=regexp(fpath_file,filesep,'split');
tok_dir =regexp(fpath_dir ,filesep,'split');

%% find last common ancestor
ndir=numel(tok_dir);
kdir=0;
while kdir<ndir && strcmp(tok_file{1,kdir+1},tok_dir{1,kdir+1})
    kdir=kdir+1;
end
idx_comm=kdir+1;
idx_up=ndir-kdir;

%go up
if idx_up==0
    str_up='';
else
    str_up=repmat('../',1,idx_up);
end
%go down
str_down=fullfile(tok_file{idx_comm:end});

if isempty(str_up)
    fpath_rel=str_down;
else
    fpath_rel=fullfile(str_up,str_down);
end
fpath_rel=strrep(fpath_rel,'\','/'); %regardless of the system, write linux bars, as these are read correctly by D3D

end %function

%%
function run_tests()
    % Embedded testcases for relative_path function
    
    fprintf('\n=== TESTING relative_path ===\n\n');
    
    npass=0;
    nfail=0;
    
    % Test 1: Same directory
    try
        fprintf('Test 1: Same directory\n');
        result = relative_path('p:\project\work\data\file.xyz', ...
                               'p:\project\work\data');
        expected = 'file.xyz';
        assert(strcmp(result, expected), sprintf('expected %s, got %s', expected, result));
        fprintf('  Result: %s\n', result);
        npass=npass+1;
        fprintf('  PASS\n\n');
    catch ME
        fprintf('  FAIL: %s\n\n', ME.message);
        nfail=nfail+1;
    end
    
    % Test 2: Sibling directories
    try
        fprintf('Test 2: Sibling directories\n');
        result = relative_path('a\b\c', 'a\b\e');
        expected = '../c';
        assert(strcmp(result, expected), sprintf('expected %s, got %s', expected, result));
        fprintf('  Result: %s\n', result);
        npass=npass+1;
        fprintf('  PASS\n\n');
    catch ME
        fprintf('  FAIL: %s\n\n', ME.message);
        nfail=nfail+1;
    end
    
    % Test 3: File one level up
    try
        fprintf('Test 3: File one level up\n');
        result = relative_path('p:\project\work\run1\file.xyz', ...
                               'p:\project\work\run2');
        expected = '../run1/file.xyz';
        assert(strcmp(result, expected), sprintf('expected %s, got %s', expected, result));
        fprintf('  Result: %s\n', result);
        npass=npass+1;
        fprintf('  PASS\n\n');
    catch ME
        fprintf('  FAIL: %s\n\n', ME.message);
        nfail=nfail+1;
    end
    
    % Test 4: File in subdirectory
    try
        fprintf('Test 4: File in subdirectory\n');
        result = relative_path('a\b\c\x.txt', 'a\b');
        expected = 'c/x.txt';
        assert(strcmp(result, expected), sprintf('expected %s, got %s', expected, result));
        fprintf('  Result: %s\n', result);
        npass=npass+1;
        fprintf('  PASS\n\n');
    catch ME
        fprintf('  FAIL: %s\n\n', ME.message);
        nfail=nfail+1;
    end
    
    % Test 5: Deep nested path with different branches
    try
        fprintf('Test 5: Deep nested path with different branches\n');
        result = relative_path('p:\project\simulations\runs\run1\output.png', ...
                               'p:\project\simulations\runs\run1\');
        expected = 'output.png';
        assert(strcmp(result, expected), sprintf('expected %s, got %s', expected, result));
        fprintf('  Result: %s\n', result);
        npass=npass+1;
        fprintf('  PASS\n\n');
    catch ME
        fprintf('  FAIL: %s\n\n', ME.message);
        nfail=nfail+1;
    end
    
    % Test 6: File in directory higher in tree
    try
        fprintf('Test 6: File in directory higher in tree\n');
        result = relative_path('p:\project\simulations\runs\output.png', ...
                               'p:\project\simulations\runs\run1\');
        expected = '../output.png';
        assert(strcmp(result, expected), sprintf('expected %s, got %s', expected, result));
        fprintf('  Result: %s\n', result);
        npass=npass+1;
        fprintf('  PASS\n\n');
    catch ME
        fprintf('  FAIL: %s\n\n', ME.message);
        nfail=nfail+1;
    end
    
    fprintf('=== SUMMARY ===\n');
    fprintf('Passed: %d / Failed: %d\n', npass, nfail);
    
end %run_tests