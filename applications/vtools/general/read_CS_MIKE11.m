%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Parse the 2000 cross-section survey (TXT + SHP) and return D3D FM 1D
%cross-section definition (csd) and location (csl) structures that are
%compatible with D3D_io_input('write', ...).
%
%The y/z profile from the raw survey is converted to the zwRiver tabulated
%format (levels vs. widths) required by D-Flow FM 1D.
%
%This function is paired with plot_CS_MIKE11. It parses MIKE11 TXT content
%once and returns the parsed sections so plotting does not re-parse files.
%
%INPUTS
%   fpath_cs_txt  - path to CrossSection_RawData_Red+DuongRiver_servey2000.txt
%   fpath_cs_shp  - path to the cross-section shapefile (.shp), optional
%                   if empty/missing, branchId falls back to TXT branch names
%   fpath_log     - optional path to read log output
%   zw_mode       - optional zw source mode for csd table:
%                     'auto'      -> use PROCESSED DATA zw if available, else yz->zw
%                     'processed' -> force PROCESSED DATA zw (error if missing)
%                     'computed'  -> force yz->zw
%   branch_filter - optional branch name filter (char/string/cellstr),
%                   case-insensitive exact match against section branch names
%   manual_opts   - optional struct controlling interactive manual limits:
%                     .enabled     logical, default false
%                     .saveFile    path to MAT file with stored picks
%                     .forceRepick logical, default false
%                   In headless/batch mode, saved picks are still reused;
%                   if no saved pick exists, automatic detection is used.
%
%SELF-TEST
%   read_CS_MIKE11('__selftest__', rootFolder)
%   Runs built-in smoke tests against the current project dataset.
%
%OUTPUTS
%   sections - struct array of parsed cross-section survey blocks (already
%              filtered/cleaned), intended for direct plotting by
%              plot_CS_MIKE11 without re-parsing the TXT file.
%   csd  - struct array (ncs x 1) of cross-section definitions (zwRiver type):
%            .id           unique string ID
%            .type         'zwRiver'
%            .thalweg      0 (DATUM = 0 in source file)
%            .numLevels    number of z-w table entries
%            .levels       monotonically increasing water levels [m AD] (row vector)
%            .flowWidths   flow width at each level [m] (row vector)
%            .totalWidths  total width at each level [m] (row vector)
%            .frictionIds  'Main'
%   csl  - struct array (ncs x 1) of cross-section locations:
%            .id           unique string ID
%            .branchId     branch identifier (from shapefile CS_BrName)
%            .chainage     distance along branch [m]
%            .x            optional map x-coordinate [m], if available
%            .y            optional map y-coordinate [m], if available
%            .shift        0
%            .definitionId reference to the matching csd.id

function [csd, csl, sections] = read_CS_MIKE11(fpath_cs_txt, fpath_cs_shp, fpath_log, zw_mode, branch_filter, manual_opts)

if nargin >= 1 && ischar(fpath_cs_txt) && strcmpi(strtrim(fpath_cs_txt), '__selftest__')
    if nargin >= 2
        test_read_CS_MIKE11_current_file(fpath_cs_shp);
    else
        test_read_CS_MIKE11_current_file(pwd);
    end
    csd = [];
    csl = [];
    sections = [];
    return
end

if nargin < 2
    fpath_cs_shp = '';
end

if nargin < 3 || isempty(fpath_log)
    [fdir_txt, ~, ~] = fileparts(fpath_cs_txt);
    fpath_log = fullfile(fdir_txt, sprintf('read_CS_MIKE11_%s.log', datestr(now, 'yyyymmdd_HHMMSS')));
end
if nargin < 4 || isempty(zw_mode)
    zw_mode = 'auto';
end
if nargin < 5
    branch_filter = [];
end
if nargin < 6 || isempty(manual_opts)
    manual_opts = struct();
end
zw_mode = lower(strtrim(zw_mode));
if ~ismember(zw_mode, {'auto', 'processed', 'computed'})
    error('read_CS_MIKE11:invalidZwMode', ...
        'Invalid zw_mode "%s". Expected auto | processed | computed.', zw_mode)
end

mkdir_check(fileparts(fpath_log));
fid_log = fopen(fpath_log, 'wt');
if fid_log < 0
    error('read_CS_MIKE11:logOpenFail', ...
        'Cannot open read log file:\n  %s', fpath_log)
end
cleanup_log = onCleanup(@() close_log_file(fid_log)); %#ok<NASGU>

log_printf(fid_log, 'read_CS_MIKE11: read log file:\n  %s\n', fpath_log);

manual_opts = normalize_manual_opts(manual_opts, fpath_log);
manual_state = struct('picks', load_manual_picks(manual_opts.saveFile));

%% Validate inputs

if exist(fpath_cs_txt, 'file') ~= 2
    error('read_CS_MIKE11:missingFile', ...
        'Cross-section TXT file not found:\n  %s', fpath_cs_txt)
end
if ~isempty(fpath_cs_shp) && exist(fpath_cs_shp, 'file') ~= 2
    error('read_CS_MIKE11:missingFile', ...
        'Cross-section SHP file not found:\n  %s', fpath_cs_shp)
end

%% Parse TXT blocks

sections = parse_cs_txt(fpath_cs_txt, fid_log);
sections = apply_branch_filter(sections, branch_filter);
ncs = numel(sections);
if ncs == 0
    if isempty(branch_filter)
        error('read_CS_MIKE11:noCrossSections', ...
            'No cross-section blocks found in:\n  %s', fpath_cs_txt)
    else
        if ischar(branch_filter) || (isstring(branch_filter) && isscalar(branch_filter))
            req_str = char(branch_filter);
        else
            req = cellstr(string(branch_filter));
            req_str = strjoin(req, ', ');
        end
        error('read_CS_MIKE11:noBranchesSelected', ...
            'No cross-sections left after branch filter (%s).', req_str)
    end
end

%% Read shapefile attributes from the companion DBF

has_shp = ~isempty(fpath_cs_shp);
if has_shp
    [shp_attrs, shp_xy] = read_shp_with_D3D_io_input(fpath_cs_shp, fid_log);
else
    shp_attrs = struct();
    shp_xy = {};
    log_printf(fid_log, 'read_CS_MIKE11: no shapefile provided, branchId defaults to TXT branch names.\n');
end

%% Build csd and csl structures

csd(ncs, 1) = struct();
csl(ncs, 1) = struct();

log_printf(fid_log, 'read_CS_MIKE11: reading %d cross-sections...\n', ncs);

for kcs = 1:ncs
    sec = sections(kcs);

    def_id = sprintf('CS_%04d', kcs);
    loc_id = sprintf('CSL_%04d', kcs);

    % Build both zw sources and then select the csd source by mode.
    [lev_yz, fw_yz] = yz_to_zw(sec.y, sec.z, fid_log);
    lev_file = sec.zw_level_file;
    fw_file = sec.zw_width_file;
    [lev, fw, src_used] = select_zw_source(lev_yz, fw_yz, lev_file, fw_file, zw_mode, sec, fid_log);
    [width_info, manual_state] = compute_widths(sec, lev, fw, fid_log, manual_opts, manual_state);

    % Cross-section definition (zwRiver tabulated format)
    csd(kcs).id          = def_id;
    csd(kcs).type        = 'zwRiver';
    csd(kcs).thalweg     = 0;       % DATUM = 0 in source file
    csd(kcs).numLevels   = numel(lev);
    csd(kcs).levels      = lev;     % row vector
    csd(kcs).flowWidths  = fw;      % row vector
    csd(kcs).totalWidths = fw;      % no storage/floodplain distinction
    csd(kcs).frictionIds = 'Main';
    csd(kcs).zwLevelsFromYZ = lev_yz;
    csd(kcs).zwWidthsFromYZ = fw_yz;
    csd(kcs).zwLevelsFromFile = lev_file;
    csd(kcs).zwWidthsFromFile = fw_file;
    csd(kcs).zwSourceUsed = src_used;
    csd(kcs).topoId = sec.topo_id;
    csd(kcs).mainWidth   = width_info.mainWidth;
    csd(kcs).fp1Width    = width_info.fp1Width;
    csd(kcs).fp2Width    = width_info.fp2Width;
    csd(kcs).xMainLeft   = width_info.xMainLeft;
    csd(kcs).xMainRight  = width_info.xMainRight;
    csd(kcs).widthSource = width_info.source;
    csd(kcs).widthMode = width_info.mode;
    csd(kcs).widthConfidence = width_info.confidence;

    % Cross-section location
    if has_shp
        branch_id = lookup_branch(sec, shp_attrs);
    else
        branch_id = sec.branch;
    end
    csl(kcs).id           = loc_id;
    csl(kcs).branchId     = branch_id;
    csl(kcs).chainage     = sec.chainage;
    [sec_x, sec_y] = lookup_xy(sec, shp_attrs, shp_xy);
    csl(kcs).x            = sec_x;
    csl(kcs).y            = sec_y;
    csl(kcs).shift        = 0;
    csl(kcs).definitionId = def_id;

    if ~isfinite(sec_x) || ~isfinite(sec_y)
        log_printf(fid_log, ['read_CS_MIKE11: warning missing XY for section ' ...
            '(branch=%s, chainage=%8.3f, section=%g).\n'], ...
            sec.branch, sec.chainage, sec.section_id);
    end

    if isnan(sec.section_id)
        sid_str = 'no-id';
    else
        sid_str = sprintf('%d', sec.section_id);
    end
    log_printf(fid_log, ['read_CS_MIKE11: %4d/%4d  chainage=%8.3f  section=%s ' ...
        'topo=%g zwSource=%s\n'], ...
        kcs, ncs, sec.chainage, sid_str, sec.topo_id, src_used);
end

log_printf(fid_log, 'read_CS_MIKE11: done.\n');

end %function read_CS_MIKE11

%% =========================================================================

function [levels, widths] = yz_to_zw(y, z, fid_log)
%YZ_TO_ZW  Convert a y/z cross-section profile to a zwRiver level-width table.
%
%  Uses thalweg-connected inundated width. For each stage h, this function
%  finds all wetted intervals z(y) <= h and keeps only the interval that is
%  hydraulically connected to the thalweg (deepest point).
%
%  INPUT
%    y  - horizontal distances along the cross-section [m], strictly
%         increasing, length >= 2
%    z  - bed elevations at each y [m], same length as y
%
%  OUTPUT
%    levels  - row vector of unique, sorted water-surface levels [m AD]
%    widths  - row vector of thalweg-connected inundated widths [m]

y = y(:);
z = z(:);

[y, z, n_dup] = collapse_duplicate_y(y, z);
if n_dup > 0
    log_printf(fid_log, 'read_CS_MIKE11: collapsed %d duplicate y points in yz->zw conversion.\n', n_dup);
end

if numel(y) < 2
    levels = unique(z)';
    widths = zeros(size(levels));
    return
end

levels = unique(z)';   % row vector, sorted ascending
n_lev  = numel(levels);
widths = zeros(1, n_lev);

z_min = min(z);
idx_min = find(abs(z - z_min) <= max(1e-12, eps(max(abs(z)))));
x_thal = mean(y(idx_min));
tol_h = max(1e-10, eps(max(abs(z))) * 10);

for ki = 1:n_lev
    h = levels(ki);
    intervals = wet_intervals_at_stage(y, z, h, tol_h);
    if isempty(intervals)
        widths(ki) = 0;
        continue
    end

    idx_conn = connected_interval_index(intervals, x_thal);
    if isempty(idx_conn)
        widths(ki) = 0;
    else
        widths(ki) = max(intervals(idx_conn, 2) - intervals(idx_conn, 1), 0);
    end
end

% zwRiver expects non-decreasing width with increasing level.
if any(diff(widths) < 0)
    n_fix = sum(diff(widths) < 0);
    widths = cummax(widths);
    log_printf(fid_log, 'read_CS_MIKE11: adjusted %d non-monotonic zw widths using cummax.\n', n_fix);
end

log_printf(fid_log, ['read_CS_MIKE11: yz->zw computed using thalweg-connected ' ...
    'inundated widths.\n']);

end %function yz_to_zw

%% =========================================================================

function [y_u, z_u, n_dup] = collapse_duplicate_y(y, z)
%COLLAPSE_DUPLICATE_Y  Merge repeated y positions for stable interpolation.

[y_u, ~, ic] = unique(y, 'stable');
n_dup = numel(y) - numel(y_u);

if n_dup <= 0
    z_u = z;
    return
end

z_u = zeros(size(y_u));
for k = 1:numel(y_u)
    z_u(k) = min(z(ic == k));
end

end %function collapse_duplicate_y

%% =========================================================================

function intervals = wet_intervals_at_stage(y, z, h, tol_h)
%WET_INTERVALS_AT_STAGE  Wetted x-intervals for piecewise-linear profile.

x_breaks = y;

for kj = 1:numel(y) - 1
    y1 = y(kj);
    y2 = y(kj + 1);
    z1 = z(kj);
    z2 = z(kj + 1);

    if (z1 - h) * (z2 - h) < 0
        xc = y1 + (h - z1) * (y2 - y1) / (z2 - z1);
        x_breaks(end + 1, 1) = xc; %#ok<AGROW>
    end
end

x_breaks = sort(x_breaks(:));
x_breaks = unique(x_breaks);

if numel(x_breaks) < 2
    intervals = zeros(0, 2);
    return
end

x_mid = 0.5 * (x_breaks(1:end-1) + x_breaks(2:end));
z_mid = interp1(y, z, x_mid, 'linear', 'extrap');
wet = z_mid <= (h + tol_h);

if ~any(wet)
    intervals = zeros(0, 2);
    return
end

intervals = zeros(0, 2);
k = 1;
while k <= numel(wet)
    if ~wet(k)
        k = k + 1;
        continue
    end
    k0 = k;
    while k <= numel(wet) && wet(k)
        k = k + 1;
    end
    intervals(end + 1, :) = [x_breaks(k0), x_breaks(k)]; %#ok<AGROW>
end

end %function wet_intervals_at_stage

%% =========================================================================

function idx_conn = connected_interval_index(intervals, x_thal)
%CONNECTED_INTERVAL_INDEX  Interval index containing thalweg x-position.

idx_conn = find(intervals(:, 1) <= x_thal & x_thal <= intervals(:, 2), 1, 'first');
if ~isempty(idx_conn)
    return
end

dist = zeros(size(intervals, 1), 1);
for k = 1:size(intervals, 1)
    if x_thal < intervals(k, 1)
        dist(k) = intervals(k, 1) - x_thal;
    elseif x_thal > intervals(k, 2)
        dist(k) = x_thal - intervals(k, 2);
    else
        dist(k) = 0;
    end
end

[~, idx_conn] = min(dist);

end %function connected_interval_index

%% =========================================================================

function sections = parse_cs_txt(fpath, fid_log)
%PARSE_CS_TXT  Read all cross-section blocks from the raw TXT survey file.
%
%  Blocks are separated by lines of '*' characters.  Each block contains:
%    line 1  : year (2000)
%    line 2  : branch name (e.g. DUONG)
%    line 3  : chainage [m]
%    keyword : SECTION ID  (followed by numeric ID or blank line)
%    keyword : PROFILE N   (followed by N data rows)
%      data row format: y  z  roughness  <#class>  0  0.000  0
%
%  Returns a struct array with fields:
%    .topo_id        double top identifier from line 1 of each block
%    .branch         char  branch name from line 2 of each block
%    .chainage       double chainage [m] from line 3 of each block
%    .section_id     double SECTION ID (NaN if blank)
%    .y              double(:,1) horizontal distances [m]
%    .z              double(:,1) elevations [m]
%    .zw_level_file  row vector of processed-data levels
%    .zw_width_file  row vector of processed-data widths

% Read all lines
fid = fopen(fpath, 'r');
raw = {};
while ~feof(fid)
    raw{end+1, 1} = fgetl(fid); %#ok<AGROW>
end
fclose(fid);
nlines = numel(raw);

% Detect section starts by the expected 3-line header pattern:
%   line 1: topo_id (numeric)
%   line 2: branch name (contains letters)
%   line 3: chainage (numeric)
block_starts = [];
for kl = 1:nlines - 3
    l1 = strtrim(raw{kl});
    l2 = strtrim(raw{kl + 1});
    l3 = strtrim(raw{kl + 2});
    l4 = strtrim(raw{kl + 3});

    is_num_1 = ~isnan(str2double(l1));
    is_num_3 = ~isnan(str2double(l3));
    has_letters_l2 = ~isempty(regexp(l2, '[A-Za-z]', 'once'));

    if is_num_1 && is_num_3 && has_letters_l2 && strcmpi(l4, 'COORDINATES')
        block_starts(end + 1, 1) = kl; %#ok<AGROW>
    end
end

if isempty(block_starts)
    sections = struct('topo_id',{},'branch',{},'chainage',{},'section_id',{}, ...
        'x_coord',{},'y_coord',{},'y',{},'z',{},'code',{}, ...
        'zw_level_file',{},'zw_width_file',{}, ...
        'y_raw',{},'z_raw',{},'code_raw',{},'y_removed',{},'z_removed',{});
    return
end

block_ends_excl = [block_starts(2:end); nlines + 1];

nblocks = numel(block_starts);

% Pre-allocate with empty defaults
empty_sec = struct('topo_id',NaN,'branch','','chainage',NaN,'section_id',NaN, ...
    'x_coord',NaN,'y_coord',NaN,'y',[],'z',[],'code',[], ...
    'zw_level_file',[],'zw_width_file',[], ...
    'y_raw',[],'z_raw',[],'code_raw',[],'y_removed',[],'z_removed',[]);
sections(nblocks, 1) = empty_sec;
for kb = 1:nblocks
    sections(kb) = empty_sec;
end

for kb = 1:nblocks
    i1 = block_starts(kb);
    i2 = block_ends_excl(kb) - 1;
    blk = raw(i1:i2);
    nbl = numel(blk);

    if nbl < 3, continue; end

    sections(kb).topo_id  = str2double(strtrim(blk{1}));
    sections(kb).branch   = strtrim(blk{2});
    sections(kb).chainage = str2double(strtrim(blk{3}));

    % Scan for keywords
    for kl = 1:nbl - 1
        kw = strtrim(blk{kl});

        if strcmpi(kw, 'SECTION ID')
            sid_str = strtrim(blk{kl + 1});
            if ~isempty(sid_str)
                sections(kb).section_id = str2double(sid_str);
            end

        elseif strcmpi(kw, 'COORDINATES')
            for kd = kl + 1:nbl
                row_str = strtrim(blk{kd});
                if isempty(row_str)
                    continue
                end
                if startsWith(row_str, '*') || ...
                        strcmpi(row_str, 'DATUM') || ...
                        strcmpi(row_str, 'FLOW DIRECTION') || ...
                        strcmpi(row_str, 'PROTECT DATA') || ...
                        startsWith(upper(row_str), 'PROFILE') || ...
                        strcmpi(row_str, 'SECTION ID') || ...
                        strcmpi(row_str, 'PROCESSED DATA')
                    break
                end

                vals = sscanf(row_str, '%f');
                if numel(vals) >= 2
                    sections(kb).x_coord = vals(1);
                    sections(kb).y_coord = vals(2);
                    break
                end
            end

        elseif strcmpi(kw, 'PROCESSED DATA')
            z_file = [];
            w_file = [];

            for kd = kl + 1:nbl
                row_str = strtrim(blk{kd});
                if isempty(row_str)
                    continue
                end
                if startsWith(row_str, '*') || ...
                        strcmpi(row_str, 'DATUM') || ...
                        strcmpi(row_str, 'COORDINATES') || ...
                        strcmpi(row_str, 'FLOW DIRECTION') || ...
                        strcmpi(row_str, 'PROTECT DATA') || ...
                        startsWith(upper(row_str), 'PROFILE') || ...
                        strcmpi(row_str, 'SECTION ID')
                    break
                end

                vals = sscanf(row_str, '%f');
                if numel(vals) >= 4
                    z_file(end + 1, 1) = vals(1); %#ok<AGROW>
                    w_file(end + 1, 1) = vals(4); %#ok<AGROW>
                end
            end

            if ~isempty(z_file)
                [z_file_u, ia] = unique(z_file, 'stable');
                w_file_u = w_file(ia);

                if any(diff(z_file_u) < 0)
                    [z_file_u, isrt] = sort(z_file_u);
                    w_file_u = w_file_u(isrt);
                end
                if any(diff(w_file_u) < 0)
                    n_fix_file = sum(diff(w_file_u) < 0);
                    w_file_u = cummax(w_file_u);
                    log_printf(fid_log, ['read_CS_MIKE11: adjusted %d non-monotonic file zw widths ' ...
                        '(chainage=%8.3f).\n'], n_fix_file, sections(kb).chainage);
                end

                sections(kb).zw_level_file = z_file_u';
                sections(kb).zw_width_file = w_file_u';
            end

        elseif startsWith(kw, 'PROFILE')
            % Extract point count from "PROFILE  N"
            tok = regexp(kw, '\d+', 'match');
            if isempty(tok), continue; end
            npts = str2double(tok{1});

            y_vec = nan(npts, 1);
            z_vec = nan(npts, 1);
            code_vec = zeros(npts, 1);
            for kp = 1:npts
                row_idx = kl + kp;
                if row_idx > nbl, break; end
                row_str = strtrim(blk{row_idx});
                tok_code = regexp(row_str, '<#(\d+)>', 'tokens', 'once');
                if ~isempty(tok_code)
                    code_vec(kp) = str2double(tok_code{1});
                end
                % Remove roughness-class tokens "<#N>" before numeric scan
                row_str = regexprep(row_str, '<#\d+>', '');
                vals = sscanf(row_str, '%f');
                if numel(vals) >= 2
                    y_vec(kp) = vals(1);
                    z_vec(kp) = vals(2);
                end
            end

            valid = ~isnan(y_vec);
            y_tmp = y_vec(valid);
            z_tmp = z_vec(valid);
            c_tmp = code_vec(valid);

            sections(kb).y_raw = y_tmp;
            sections(kb).z_raw = z_tmp;
            sections(kb).code_raw = c_tmp;

            if ~isempty(y_tmp)
                keep = [true; diff(y_tmp) > 0];
                n_drop = sum(~keep);
                if n_drop > 0
                    sections(kb).y_removed = y_tmp(~keep);
                    sections(kb).z_removed = z_tmp(~keep);
                    if isnan(sections(kb).section_id)
                        sid_msg = 'no-id';
                    else
                        sid_msg = sprintf('%d', sections(kb).section_id);
                    end
                    log_printf(fid_log, ['read_CS_MIKE11: filtered %d non-monotonic y points ' ...
                        '(chainage=%8.3f, section=%s).\n'], ...
                        n_drop, sections(kb).chainage, sid_msg);
                end
                y_tmp = y_tmp(keep);
                z_tmp = z_tmp(keep);
                c_tmp = c_tmp(keep);
            end

            sections(kb).y = y_tmp;
            sections(kb).z = z_tmp;
            sections(kb).code = c_tmp;
            break % PROFILE is always the last keyword of interest per block
        end
    end
end

% Keep only blocks that produced a usable PROFILE.
has_profile = arrayfun(@(s) ~isempty(s.y) && ~isempty(s.z), sections);
sections = sections(has_profile);

end %function parse_cs_txt

%% =========================================================================

function sections = apply_branch_filter(sections, branch_filter)
%APPLY_BRANCH_FILTER  Keep only sections whose branch is in the requested list.

if isempty(branch_filter) || isempty(sections)
    return
end

if ischar(branch_filter) || (isstring(branch_filter) && isscalar(branch_filter))
    req = {char(branch_filter)};
else
    req = cellstr(string(branch_filter));
end
req_norm = lower(strtrim(req));

sec_br = arrayfun(@(s) lower(strtrim(s.branch)), sections, 'UniformOutput', false);
keep = ismember(sec_br, req_norm);
sections = sections(keep);

end %function apply_branch_filter

%% =========================================================================

function [lev, fw, src_used] = select_zw_source(lev_yz, fw_yz, lev_file, fw_file, zw_mode, sec, fid_log)
%SELECT_ZW_SOURCE  Pick which zw table is used for csd based on mode.

has_file = ~isempty(lev_file) && ~isempty(fw_file);

switch zw_mode
    case 'processed'
        if ~has_file
            error('read_CS_MIKE11:missingProcessedZw', ...
                'Missing PROCESSED DATA zw for chainage %8.3f (section %g).', ...
                sec.chainage, sec.section_id)
        end
        lev = lev_file;
        fw = fw_file;
        src_used = 'processed';

    case 'computed'
        lev = lev_yz;
        fw = fw_yz;
        src_used = 'computed';

    otherwise % auto
        if has_file
            lev = lev_file;
            fw = fw_file;
            src_used = 'processed';
        else
            lev = lev_yz;
            fw = fw_yz;
            src_used = 'computed';
            log_printf(fid_log, ['read_CS_MIKE11: missing PROCESSED DATA zw, fallback to yz->zw ' ...
                '(chainage=%8.3f).\n'], sec.chainage);
        end
end

end %function select_zw_source

%% =========================================================================

function branch_id = lookup_branch(sec, shp_attrs)
%LOOKUP_BRANCH  Return the branch name for a parsed TXT section.
%
%  Strategy:
%   1. Match by SECTION ID (TXT) → CS_ID (shapefile), numeric comparison.
%   2. Fallback: nearest chainage in shapefile within 1 m tolerance.
%   3. Last resort: use the branch name stored in the TXT block.

branch_id = sec.branch; % default

n_shp = numel(shp_attrs.CS_ID);
tol_ch = 1; % [m] chainage tolerance for fallback

% Primary: match by numeric section ID
if ~isnan(sec.section_id)
    for ks = 1:n_shp
        cs_id_num = str2double(shp_attrs.CS_ID{ks});
        if ~isnan(cs_id_num) && cs_id_num == sec.section_id
            br = strtrim(shp_attrs.CS_BrName{ks});
            if ~isempty(br)
                branch_id = br;
            end
            return
        end
    end
end

% Fallback: chainage matching
ch_shp = cellfun(@str2double, shp_attrs.CS_Ch);
[min_diff, idx_min] = min(abs(ch_shp - sec.chainage));
if min_diff <= tol_ch
    br = strtrim(shp_attrs.CS_BrName{idx_min});
    if ~isempty(br)
        branch_id = br;
    end
end

end %function lookup_branch

%% =========================================================================

function [x_coord, y_coord] = lookup_xy(sec, shp_attrs, shp_xy)
%LOOKUP_XY  Return map x/y for a parsed TXT section when available.
%
%  Strategy:
%   1. Use COORDINATES parsed from TXT block.
%   2. Fallback to shapefile DBF x/y-like fields, matched by section ID.
%   3. Fallback to shapefile polyline midpoint from D3D_io_input geometry.

x_coord = NaN;
y_coord = NaN;

if isfield(sec,'x_coord') && isfield(sec,'y_coord') && ...
        isfinite(sec.x_coord) && isfinite(sec.y_coord)
    x_coord = sec.x_coord;
    y_coord = sec.y_coord;
    return
end

if isempty(fieldnames(shp_attrs))
    return
end

idx = lookup_shp_record_index(sec, shp_attrs);
if ~isfinite(idx)
    return
end

x_field = find_dbf_field(shp_attrs, {'CS_X','X','XCOORD','X_COORD','EASTING'});
y_field = find_dbf_field(shp_attrs, {'CS_Y','Y','YCOORD','Y_COORD','NORTHING'});

if ~isempty(x_field)
    x_val = str2double(shp_attrs.(x_field){idx});
    if isfinite(x_val)
        x_coord = x_val;
    end
end
if ~isempty(y_field)
    y_val = str2double(shp_attrs.(y_field){idx});
    if isfinite(y_val)
        y_coord = y_val;
    end
end

if (~isfinite(x_coord) || ~isfinite(y_coord)) && ~isempty(shp_xy) && idx <= numel(shp_xy)
    [x_geo, y_geo] = polyline_midpoint_xy(shp_xy{idx});
    if isfinite(x_geo) && isfinite(y_geo)
        x_coord = x_geo;
        y_coord = y_geo;
    end
end

end %function lookup_xy

%% =========================================================================

function idx = lookup_shp_record_index(sec, shp_attrs)
%LOOKUP_SHP_RECORD_INDEX  Find matching DBF record index for a TXT section.

idx = NaN;

if ~isfield(shp_attrs,'CS_ID') || ~isfield(shp_attrs,'CS_Ch')
    return
end

n_shp = numel(shp_attrs.CS_ID);

if ~isnan(sec.section_id)
    for ks = 1:n_shp
        cs_id_num = str2double(shp_attrs.CS_ID{ks});
        if ~isnan(cs_id_num) && cs_id_num == sec.section_id
            idx = ks;
            return
        end
    end
end

ch_shp = cellfun(@str2double, shp_attrs.CS_Ch);
[min_diff, idx_min] = min(abs(ch_shp - sec.chainage));
if min_diff <= 1
    idx = idx_min;
end

end %function lookup_shp_record_index

%% =========================================================================

function fname = find_dbf_field(shp_attrs, candidate_names)
%FIND_DBF_FIELD  Find first matching DBF attribute name (case-insensitive).

fname = '';
all_names = fieldnames(shp_attrs);

for k = 1:numel(candidate_names)
    km = find(strcmpi(all_names, candidate_names{k}), 1, 'first');
    if ~isempty(km)
        fname = all_names{km};
        return
    end
end

end %function find_dbf_field

%% =========================================================================

function [shp_attrs, shp_xy] = read_shp_with_D3D_io_input(fpath_cs_shp, fid_log)
%READ_SHP_WITH_D3D_IO_INPUT  Read shapefile geometry+attributes via D3D_io_input.

shp_attrs = struct();
shp_xy = {};

shp_in = D3D_io_input('read', fpath_cs_shp, 'read_val', true);

if isfield(shp_in,'xy') && isstruct(shp_in.xy) && isfield(shp_in.xy,'XY')
    shp_xy = shp_in.xy.XY;
end

if isfield(shp_in,'val_names') && isfield(shp_in,'val')
    ncol = min(numel(shp_in.val_names), numel(shp_in.val));
    for kc = 1:ncol
        raw_name = shp_in.val_names{kc};
        if isstring(raw_name)
            raw_name = char(raw_name);
        end
        if ~ischar(raw_name)
            continue
        end

        tok = regexp(raw_name, ':', 'split');
        fld = strtrim(tok{end});
        if isempty(fld)
            continue
        end

        col = shp_in.val{kc};
        if ~isstruct(col) || ~isfield(col,'Val')
            continue
        end
        shp_attrs.(fld) = col.Val;
    end
end

if isempty(fieldnames(shp_attrs))
    [fdir_shp, fname_shp, ~] = fileparts(fpath_cs_shp);
    fpath_dbf = fullfile(fdir_shp, [fname_shp '.dbf']);
    shp_attrs = read_dbf_attrs(fpath_dbf);
    log_printf(fid_log, ['read_CS_MIKE11: D3D_io_input returned no attributes; ' ...
        'fallback to DBF parser for %s.\n'], fpath_dbf);
end

end %function read_shp_with_D3D_io_input

%% =========================================================================

function [x_mid, y_mid] = polyline_midpoint_xy(xy)
%POLYLINE_MIDPOINT_XY  Midpoint between first and last valid polyline vertex.

x_mid = NaN;
y_mid = NaN;

if isempty(xy) || ~isnumeric(xy) || size(xy,2) < 2
    return
end

good = isfinite(xy(:,1)) & isfinite(xy(:,2));
xy = xy(good,:);
if isempty(xy)
    return
end

p1 = xy(1,1:2);
p2 = xy(end,1:2);
x_mid = 0.5 * (p1(1) + p2(1));
y_mid = 0.5 * (p1(2) + p2(2));

end %function polyline_midpoint_xy

%% =========================================================================

function attrs = read_dbf_attrs(fpath_dbf)
%READ_DBF_ATTRS  Read attribute columns from a dBASE III+ (.dbf) file.
%
%  Does not require the Mapping Toolbox.  All field values are returned as
%  trimmed strings in a struct of cell arrays:
%    attrs.FIELD_NAME{k}  =  string value for record k

if exist(fpath_dbf, 'file') ~= 2
    error('read_CS_MIKE11:missingDbf', 'DBF file not found:\n  %s', fpath_dbf)
end

fid = fopen(fpath_dbf, 'rb', 'l'); % little-endian byte order
if fid < 0
    error('read_CS_MIKE11:dbfOpen', 'Cannot open DBF file:\n  %s', fpath_dbf)
end

% Parse fixed header (32 bytes)
fread(fid, 4, 'uint8');                 % version + last-update date
num_records = fread(fid, 1, 'uint32');  % number of records
header_size = fread(fid, 1, 'uint16');  % total header size in bytes
record_size = fread(fid, 1, 'uint16');  %#ok<NASGU> total record size in bytes (incl. delete flag)
fread(fid, 20, 'uint8');               % reserved bytes

% Parse field descriptors (each 32 bytes), stopping at the 0x0D terminator
fields = struct('name', {}, 'len', {});
while ftell(fid) < header_size - 1
    name_bytes = fread(fid, 11, 'uint8'); % null-padded field name
    fread(fid, 1, 'uint8');              % field type (treat all as string)
    fread(fid, 4, 'uint8');              % reserved
    field_len = fread(fid, 1, 'uint8'); % field length in bytes
    fread(fid, 15, 'uint8');            % decimal count + reserved
    name = deblank(char(name_bytes(name_bytes > 0)'));
    if isempty(name), break; end
    n = numel(fields) + 1;
    fields(n).name = name;
    fields(n).len  = field_len;
end

% Seek to the first data record
fseek(fid, header_size, 'bof');

% Initialise output struct
nf = numel(fields);
attrs = struct();
for kf = 1:nf
    attrs.(fields(kf).name) = cell(num_records, 1);
end

% Read all records
for kr = 1:num_records
    fread(fid, 1, 'uint8'); % delete flag (0x20 = valid, 0x2A = deleted)
    for kf = 1:nf
        raw_chars = fread(fid, fields(kf).len, '*char')';
        attrs.(fields(kf).name){kr} = strtrim(raw_chars);
    end
end

fclose(fid);

end %function read_dbf_attrs

%% =========================================================================

function log_printf(fid_log, varargin)
%LOG_PRINTF  Print to command window and optional log file.

fprintf(varargin{:});

if ~isempty(fid_log) && isnumeric(fid_log) && fid_log > 0
    fprintf(fid_log, varargin{:});
end

end %function log_printf

%% =========================================================================

function close_log_file(fid_log)
%CLOSE_LOG_FILE  Close read log file if open.

if ~isempty(fid_log) && isnumeric(fid_log) && fid_log > 0
    fclose(fid_log);
end

end %function close_log_file

%% =========================================================================

function manual_opts = normalize_manual_opts(manual_opts, fpath_log)
%NORMALIZE_MANUAL_OPTS  Apply defaults for interactive manual picking.

if ~isstruct(manual_opts)
    error('read_CS_MIKE11:manualOptsType', 'manual_opts must be a struct.')
end

if ~isfield(manual_opts, 'enabled') || isempty(manual_opts.enabled)
    manual_opts.enabled = false;
end
if ~isfield(manual_opts, 'forceRepick') || isempty(manual_opts.forceRepick)
    manual_opts.forceRepick = false;
end

[fdir_log, ~, ~] = fileparts(fpath_log);
if ~isfield(manual_opts, 'saveFile') || isempty(manual_opts.saveFile)
    manual_opts.saveFile = fullfile(fdir_log, 'manual_main_limits.mat');
end

manual_opts.enabled = logical(manual_opts.enabled);
manual_opts.forceRepick = logical(manual_opts.forceRepick);

end %function normalize_manual_opts

%% =========================================================================

function picks = load_manual_picks(fpath)
%LOAD_MANUAL_PICKS  Read stored manual picks from MAT file.

picks = struct('key', {}, 'branch', {}, 'chainage', {}, 'xLeft', {}, 'xRight', {}, 'updatedAt', {});

if isempty(fpath) || exist(fpath, 'file') ~= 2
    return
end

s = load(fpath, 'picks');
if isfield(s, 'picks') && isstruct(s.picks)
    picks = s.picks;
end

end %function load_manual_picks

%% =========================================================================

function save_manual_picks(fpath, picks)
%SAVE_MANUAL_PICKS  Persist manual picks to MAT file.

if isempty(fpath)
    return
end

mkdir_check(fileparts(fpath));
save(fpath, 'picks');

end %function save_manual_picks

%% =========================================================================

function key = section_manual_key(sec)
%SECTION_MANUAL_KEY  Stable key used for stored manual picks.

branch = upper(strtrim(sec.branch));
branch = regexprep(branch, '[^A-Z0-9_.-]', '_');
key = sprintf('%s__%012.3f', branch, sec.chainage);

end %function section_manual_key

%% =========================================================================

function [pick, idx] = find_manual_pick(picks, key)
%FIND_MANUAL_PICK  Find stored pick by section key.

pick = [];
idx = [];
if isempty(picks)
    return
end

keys = {picks.key};
idx = find(strcmp(keys, key), 1, 'first');
if ~isempty(idx)
    pick = picks(idx);
end

end %function find_manual_pick

%% =========================================================================

function [x_left, x_right, is_ok] = prompt_manual_limits(sec, x_env_left, x_env_right)
%PROMPT_MANUAL_LIMITS  Interactive picker for main-channel limits on yz profile.

is_ok = false;
x_left = NaN;
x_right = NaN;

fig_name = sprintf('Manual main limits: %s %.3f', sec.branch, sec.chainage);
fig = figure('Name', fig_name, 'NumberTitle', 'off', 'Visible', 'on');
cleanup_fig = onCleanup(@() close_if_valid(fig)); %#ok<NASGU>

while true
    clf(fig)
    ax = axes('Parent', fig);
    hold(ax, 'on')
    plot(ax, sec.y, sec.z, '-k', 'LineWidth', 1.2)
    if ~isempty(sec.code)
        idxmk = sec.code > 0;
        if any(idxmk)
            plot(ax, sec.y(idxmk), sec.z(idxmk), 'ob', 'MarkerSize', 5)
        end
    end
    xline(ax, x_env_left, '--', 'Color', [0.6 0.6 0.6]);
    xline(ax, x_env_right, '--', 'Color', [0.6 0.6 0.6]);
    grid(ax, 'on')
    xlabel(ax, 'Distance [m]')
    ylabel(ax, 'Elevation [m AD]')
    title(ax, sprintf('%s ch=%.3f | click LEFT then RIGHT limit', sec.branch, sec.chainage), 'Interpreter', 'none')

    [x_click, ~, btn] = ginput(2);
    if numel(x_click) < 2 || any(btn ~= 1)
        choice = menu('Manual picking cancelled. What next?', 'Cancel section', 'Retry');
        if choice == 2
            continue
        end
        return
    end

    x_click = sort(x_click(:));
    xl = max(x_click(1), x_env_left);
    xr = min(x_click(2), x_env_right);

    if ~isfinite(xl) || ~isfinite(xr) || xr <= xl
        choice = menu('Invalid limits selected.', 'Retry', 'Cancel section');
        if choice == 1
            continue
        end
        return
    end

    xline(ax, xl, '--r', 'LineWidth', 1.5)
    xline(ax, xr, '--g', 'LineWidth', 1.5)
    txt = sprintf('Selected width = %.3f m', xr - xl);
    text(ax, 0.02, 0.02, txt, 'Units', 'normalized', 'BackgroundColor', 'w')

    choice = menu('Accept selected limits?', 'Accept', 'Reclick', 'Cancel section');
    if choice == 1
        x_left = xl;
        x_right = xr;
        is_ok = true;
        return
    elseif choice == 2
        continue
    else
        return
    end
end

end %function prompt_manual_limits

%% =========================================================================

function close_if_valid(fig)
%CLOSE_IF_VALID  Close figure handle if still valid.

if ~isempty(fig) && ishghandle(fig)
    close(fig);
end

end %function close_if_valid

%% =========================================================================

function [width_info, manual_state] = compute_widths(sec, levels, widths, fid_log, manual_opts, manual_state)
%COMPUTE_WIDTHS  Derive main-channel and floodplain widths.

y = sec.y(:);
z = sec.z(:);
c = sec.code(:);

x_start = y(1);
x_end = y(end);

idx2 = find(c == 2, 1, 'first');
if ~isempty(idx2)
    x_thal = y(idx2);
else
    [~, idx_minz] = min(z);
    x_thal = y(idx_minz);
end

idx8 = find(c == 8, 1, 'first');
idx16 = find(c == 16, 1, 'first');
idx1 = find(c == 1, 1, 'first');
idx4 = find(c == 4, 1, 'first');

has_8_16 = ~isempty(idx8) && ~isempty(idx16);
has_1_4 = ~isempty(idx1) && ~isempty(idx4);
mode_info = struct('mode', 'hybrid_interior', 'confidence', 0.5, ...
    'useDirect', false, 'xLeft', NaN, 'xRight', NaN);

if has_8_16
    x_pair = sort([y(idx8), y(idx16)]);
    x_left_main = x_pair(1);
    x_right_main = x_pair(2);
    src = 'marker_8_16';
    mode_info.mode = 'marker_8_16';
    mode_info.confidence = 1.0;
else
    if has_1_4
        env = sort([y(idx1), y(idx4)]);
        x_env_left = env(1);
        x_env_right = env(2);
    else
        x_env_left = x_start;
        x_env_right = x_end;
    end

    if manual_opts.enabled
        sec_key = section_manual_key(sec);
        [pick, pick_idx] = find_manual_pick(manual_state.picks, sec_key);
        reuse_pick = ~isempty(pick) && ~manual_opts.forceRepick;
        manual_applied = false;

        if reuse_pick
            x_left_main = max(min(pick.xLeft, x_env_right), x_env_left);
            x_right_main = max(min(pick.xRight, x_env_right), x_env_left);
            if x_right_main > x_left_main
                src = 'manual_saved';
                mode_info.mode = 'manual_saved';
                mode_info.confidence = 1.0;
                mode_info.useDirect = true;
                mode_info.xLeft = x_left_main;
                mode_info.xRight = x_right_main;
                manual_applied = true;
            end
        end

        if ~manual_applied
            if usejava('desktop')
                [x_left_main, x_right_main, is_ok] = prompt_manual_limits(sec, x_env_left, x_env_right);
                if ~is_ok
                    error('read_CS_MIKE11:manualCancelled', ...
                        'Manual selection cancelled for branch %s chainage %.3f.', sec.branch, sec.chainage)
                end

                pick_rec = struct('key', sec_key, 'branch', sec.branch, 'chainage', sec.chainage, ...
                    'xLeft', x_left_main, 'xRight', x_right_main, 'updatedAt', datestr(now, 31));
                if isempty(pick_idx)
                    manual_state.picks(end+1) = pick_rec; %#ok<AGROW>
                else
                    manual_state.picks(pick_idx) = pick_rec;
                end
                save_manual_picks(manual_opts.saveFile, manual_state.picks);

                src = 'manual_click';
                mode_info.mode = 'manual_click';
                mode_info.confidence = 1.0;
                mode_info.useDirect = true;
                mode_info.xLeft = x_left_main;
                mode_info.xRight = x_right_main;
                manual_applied = true;
            else
                log_printf(fid_log, ['read_CS_MIKE11: manual mode requested but no graphics desktop ' ...
                    '(chainage=%8.3f). Falling back to auto detection.\n'], sec.chainage);
            end
        end

        if ~manual_applied
            x_thal = max(min(x_thal, x_env_right), x_env_left);

            env_w = max(x_env_right - x_env_left, 0);
            [target_main, src, mode_info] = detect_main_width_hybrid(sec, levels, widths, ...
                x_env_left, x_env_right, x_thal, has_1_4);
            target_main = max(min(target_main, env_w), 0);

            if isfield(mode_info, 'useDirect') && mode_info.useDirect
                x_left_main = mode_info.xLeft;
                x_right_main = mode_info.xRight;
            elseif strcmp(mode_info.mode, 'marker_1_4_envelope')
                x_left_main = x_env_left;
                x_right_main = x_env_right;
            else
                [x_left_main, x_right_main] = width_about_thalweg(x_thal, target_main, x_env_left, x_env_right);
            end
        end
    else
        x_thal = max(min(x_thal, x_env_right), x_env_left);

        env_w = max(x_env_right - x_env_left, 0);
        [target_main, src, mode_info] = detect_main_width_hybrid(sec, levels, widths, ...
            x_env_left, x_env_right, x_thal, has_1_4);
        target_main = max(min(target_main, env_w), 0);

        if isfield(mode_info, 'useDirect') && mode_info.useDirect
            x_left_main = mode_info.xLeft;
            x_right_main = mode_info.xRight;
        elseif strcmp(mode_info.mode, 'marker_1_4_envelope')
            x_left_main = x_env_left;
            x_right_main = x_env_right;
        else
            [x_left_main, x_right_main] = width_about_thalweg(x_thal, target_main, x_env_left, x_env_right);
        end
    end
end

if has_1_4
    env = sort([y(idx1), y(idx4)]);
    x_left_main = max(x_left_main, env(1));
    x_right_main = min(x_right_main, env(2));
end

if x_left_main > x_thal || x_right_main < x_thal
    x_left_main = min(x_left_main, x_thal);
    x_right_main = max(x_right_main, x_thal);
    log_printf(fid_log, ['read_CS_MIKE11: adjusted main-channel bounds to include thalweg ' ...
        '(chainage=%8.3f).\n'], sec.chainage);
end

main_w = max(x_right_main - x_left_main, 0);
fp1_w = max(x_left_main - x_start, 0);
fp2_w = max(x_end - x_right_main, 0);

width_info = struct( ...
    'xMainLeft', x_left_main, ...
    'xMainRight', x_right_main, ...
    'mainWidth', main_w, ...
    'fp1Width', fp1_w, ...
    'fp2Width', fp2_w, ...
    'source', src, ...
    'mode', mode_info.mode, ...
    'confidence', mode_info.confidence);

log_printf(fid_log, ['read_CS_MIKE11: widths (chainage=%8.3f): ' ...
    'fp1=%8.3f main=%8.3f fp2=%8.3f source=%s\n'], ...
    sec.chainage, fp1_w, main_w, fp2_w, src);

end %function compute_widths

%% =========================================================================

function [target_main, src, mode_info] = detect_main_width_hybrid(sec, levels, widths, x_env_left, x_env_right, x_thal, has_1_4)
%DETECT_MAIN_WIDTH_HYBRID  Hybrid main-width detector with calibrated DA behavior.

env_w = max(x_env_right - x_env_left, 0);
mode_info = struct('mode', 'hybrid_interior', 'confidence', 0.5);
mode_info.useDirect = false;
mode_info.xLeft = NaN;
mode_info.xRight = NaN;

if env_w <= 0
    target_main = 0;
    src = 'degenerate_env';
    mode_info.mode = 'marker_1_4_envelope';
    mode_info.confidence = 1.0;
    return
end

% Non-hardcoded decision: combine zw knickpoint and yz valley-shape evidence.
[target_zw, zw_info] = detect_main_width_from_zw(levels, widths);
[target_yz, yz_info] = detect_main_width_from_yz(sec.y, sec.z, x_thal, x_env_left, x_env_right);

target_zw = max(min(target_zw, env_w), 0);
target_yz = max(min(target_yz, env_w), 0);

zw_ratio = target_zw / max(env_w, eps);
yz_ratio = target_yz / max(env_w, eps);

yz_reliable = yz_info.valid && yz_info.depthRatio >= 0.12 && yz_info.symmetry >= 0.25;
zw_early_jump = zw_info.valid && zw_info.jumpPosFrac <= 0.30;

if has_1_4 && yz_info.hasShoulders
    shoulder_w = yz_info.xRightShoulder - yz_info.xLeftShoulder;
    if isfinite(shoulder_w) && shoulder_w >= 0.20 * env_w && shoulder_w <= 0.85 * env_w
        target_main = shoulder_w;
        src = 'hybrid_yz_shoulders';
        mode_info.mode = 'yz_shoulders';
        mode_info.confidence = 0.72;
        mode_info.useDirect = true;
        mode_info.xLeft = yz_info.xLeftShoulder;
        mode_info.xRight = yz_info.xRightShoulder;
        return
    end
end

if has_1_4 && (~yz_reliable && (zw_early_jump || zw_ratio >= 0.90))
    target_main = env_w;
    src = 'hybrid_1_4_envelope';
    mode_info.mode = 'marker_1_4_envelope';
    mode_info.confidence = 0.75;
    return
end

if has_1_4 && zw_early_jump && yz_ratio < 0.45 && yz_info.symmetry < 0.45
    target_main = env_w;
    src = 'hybrid_1_4_early_jump';
    mode_info.mode = 'marker_1_4_envelope';
    mode_info.confidence = 0.70;
    return
end

if ~yz_reliable
    target_main = target_zw;
    src = 'hybrid_zw_only';
    mode_info.mode = 'hybrid_interior';
    mode_info.confidence = 0.55;
    return
end

if ~zw_info.valid || target_zw <= 0
    target_main = target_yz;
    src = 'hybrid_yz_only';
    mode_info.mode = 'hybrid_interior';
    mode_info.confidence = 0.60;
    return
end

target_main = 0.90 * target_yz + 0.10 * target_zw;

if has_1_4 && yz_ratio >= 0.90 && zw_ratio >= 0.90
    target_main = env_w;
    src = 'hybrid_1_4_from_both';
    mode_info.mode = 'marker_1_4_envelope';
    mode_info.confidence = 0.65;
elseif has_1_4 && yz_ratio >= 0.88 && ~zw_early_jump
    target_main = env_w;
    src = 'hybrid_1_4_from_yz';
    mode_info.mode = 'marker_1_4_envelope';
    mode_info.confidence = 0.62;
else
    src = 'hybrid_blend';
    mode_info.mode = 'hybrid_interior';
    mode_info.confidence = 0.60;
end

end %function detect_main_width_hybrid

%% =========================================================================

function [target_main, yz_info] = detect_main_width_from_yz(y, z, x_thal, x_env_left, x_env_right)
%DETECT_MAIN_WIDTH_FROM_YZ  Estimate interior valley width from profile curvature.

yz_info = struct('valid', false, 'depthRatio', 0, 'symmetry', 0, ...
    'hasShoulders', false, 'xLeftShoulder', NaN, 'xRightShoulder', NaN);

yy = y(:)';
zz = z(:)';
if numel(yy) < 5 || numel(yy) ~= numel(zz)
    target_main = NaN;
    return
end

in_env = yy >= x_env_left & yy <= x_env_right;
yy = yy(in_env);
zz = zz(in_env);
if numel(yy) < 5
    target_main = NaN;
    return
end

% Smooth mildly to reduce noisy local curvature flips.
zzs = movmean(zz, 3);

[~, idx_thal_local] = min(abs(yy - x_thal));
left_idx = 1:idx_thal_local;
right_idx = idx_thal_local:numel(yy);
if numel(left_idx) < 2 || numel(right_idx) < 2
    target_main = NaN;
    return
end

z_thal = zzs(idx_thal_local);

[~, idx_left_peak_rel] = max(zzs(left_idx));
[~, idx_right_peak_rel] = max(zzs(right_idx));
idx_left_peak = left_idx(idx_left_peak_rel);
idx_right_peak = right_idx(idx_right_peak_rel);

left_depth = zzs(idx_left_peak) - z_thal;
right_depth = zzs(idx_right_peak) - z_thal;

if ~isfinite(left_depth) || ~isfinite(right_depth)
    target_main = NaN;
    return
end

depth_ref = 0.85 * min(left_depth, right_depth);
if depth_ref <= 0
    target_main = NaN;
    return
end

z_span = max(zzs) - min(zzs);
if isfinite(z_span) && z_span > 0
    yz_info.depthRatio = min(left_depth, right_depth) / z_span;
end
yz_info.symmetry = min(left_depth, right_depth) / max(max(left_depth, right_depth), eps);

z_target = z_thal + depth_ref;

idx_left_cross = find(zzs(1:idx_thal_local) >= z_target, 1, 'last');
idx_right_cross_rel = find(zzs(idx_thal_local:end) >= z_target, 1, 'first');
if isempty(idx_left_cross) || isempty(idx_right_cross_rel)
    target_main = NaN;
    return
end
idx_right_cross = idx_thal_local + idx_right_cross_rel - 1;

x_left = yy(idx_left_cross);
x_right = yy(idx_right_cross);
target_depth = max(x_right - x_left, 0);

% Alternative detector for dike-like profiles: use strongest slope breaks
% around the thalweg to estimate the channel shoulders.
dx = diff(yy);
g = diff(zzs) ./ max(dx, eps);
xmid = 0.5 * (yy(1:end-1) + yy(2:end));
env_w = max(x_env_right - x_env_left, eps);

left_mask = xmid < x_thal;
right_mask = xmid > x_thal;
target_slope = NaN;
if any(left_mask) && any(right_mask)
    g_left = g(left_mask);
    x_left_mid = xmid(left_mask);
    g_right = g(right_mask);
    x_right_mid = xmid(right_mask);

    gLmin = min(g_left);
    gRmax = max(g_right);

    if isfinite(gLmin) && isfinite(gRmax) && gLmin < -0.01 && gRmax > 0.01
        % Keep strong slopes but prefer those closest to thalweg and avoid
        % outer-edge dike flanks that over-widen the main channel.
        left_strong = find(g_left <= 0.35 * gLmin & x_left_mid > (x_env_left + 0.08 * env_w));
        right_strong = find(g_right >= 0.35 * gRmax & x_right_mid < (x_env_right - 0.08 * env_w));

        if isempty(left_strong)
            [~, iL] = min(g_left);
        else
            iL = left_strong(end);
        end
        if isempty(right_strong)
            [~, iR] = max(g_right);
        else
            iR = right_strong(1);
        end

        xL_slope = x_left_mid(iL);
        xR_slope = x_right_mid(iR);
        if xR_slope > xL_slope
            target_slope = xR_slope - xL_slope;
            yz_info.hasShoulders = true;
            yz_info.xLeftShoulder = xL_slope;
            yz_info.xRightShoulder = xR_slope;
        end
    end
end

if isfinite(target_slope) && target_slope > 0
    % Prefer slope-based shoulders for dike-shaped sections while avoiding
    % unrealistically narrow picks by blending with depth-based width.
    target_main = max(0.65 * target_slope + 0.35 * target_depth, target_depth * 0.80);
else
    target_main = target_depth;
end

yz_info.valid = isfinite(target_main) && target_main > 0;

end %function detect_main_width_from_yz

%% =========================================================================

function [target_main, zw_info] = detect_main_width_from_zw(levels, widths)
%DETECT_MAIN_WIDTH_FROM_ZW  Detect floodplain-onset knickpoint from zw curve.

zw_info = struct('valid', false, 'jumpPosFrac', 1);

wlev = levels(:)';
w = widths(:)';
if isempty(w)
    target_main = 0;
    return
end
if numel(w) < 4 || numel(wlev) ~= numel(w)
    target_main = w(end);
    return
end

dlev = diff(wlev);
dlev(abs(dlev) < eps) = eps;
slope = diff(w) ./ dlev;

jump = diff(slope);
if isempty(jump)
    target_main = w(end);
    return
end

max_jump = max(jump);
if ~isfinite(max_jump) || max_jump <= 0
    target_main = w(end);
    return
end

idx_jump = find(jump >= 0.45 * max_jump & jump > 0, 1, 'first');
if isempty(idx_jump)
    [~, idx_jump] = max(jump);
end

idx_target = min(max(idx_jump + 1, 1), numel(w));
target_main = w(idx_target);
zw_info.valid = isfinite(target_main) && target_main > 0;
zw_info.jumpPosFrac = idx_target / max(numel(w), 1);

if ~isempty(levels) && numel(levels) == numel(w)
    % Keep detector tied to level progression; no extra action needed here,
    % but this guards against future misuse with inconsistent inputs.
end

end %function detect_main_width_from_zw

%% =========================================================================

function [x_left, x_right] = width_about_thalweg(x_thal, target_width, x_env_left, x_env_right)
%WIDTH_ABOUT_THALWEG  Place target width around thalweg within envelope.

left_cap = max(x_thal - x_env_left, 0);
right_cap = max(x_env_right - x_thal, 0);

left_w = min(target_width / 2, left_cap);
right_w = min(target_width / 2, right_cap);

remaining = target_width - (left_w + right_w);
if remaining > 0
    left_spare = left_cap - left_w;
    add_left = min(remaining, left_spare);
    left_w = left_w + add_left;
    remaining = remaining - add_left;
end
if remaining > 0
    right_spare = right_cap - right_w;
    add_right = min(remaining, right_spare);
    right_w = right_w + add_right;
end

x_left = x_thal - left_w;
x_right = x_thal + right_w;

end %function width_about_thalweg

%% =========================================================================

function test_read_CS_MIKE11_current_file(froot)
%TEST_READ_CS_MIKE11_CURRENT_FILE  Smoke tests for the current project dataset.
%
% Usage:
%   test_read_CS_MIKE11_current_file('c:\Users\chavarri\OneDrive - Stichting Deltares\all\projects\00_codes\VI-182_RRB_scripts')
%   test_read_CS_MIKE11_current_file(pwd)

if nargin < 1 || isempty(froot)
    froot = pwd;
end

fpath_cs_txt = fullfile(froot, 'context', 'CrossSection_RawData_Red+DuongRiver_servey2000.txt');
fpath_cs_shp = fullfile(froot, 'context', 'Cross sections_shp', 'Cross sections.shp');

assert(exist(fpath_cs_txt, 'file') == 2, 'TXT test input not found.');

fpath_log_1 = fullfile(tempdir, sprintf('read_CS_MIKE11_test_with_shp_%s.log', datestr(now, 'yyyymmdd_HHMMSSFFF')));
[csd1, csl1] = read_CS_MIKE11(fpath_cs_txt, fpath_cs_shp, fpath_log_1);
assert(~isempty(csd1) && ~isempty(csl1), 'Expected non-empty outputs with shapefile.');
assert(numel(csd1) == numel(csl1), 'csd/csl length mismatch with shapefile.');
assert(all(arrayfun(@(s) isfield(s, 'mainWidth') && isfield(s, 'fp1Width') && isfield(s, 'fp2Width'), csd1)), ...
    'Width fields missing in csd (with shapefile).');

fpath_log_2 = fullfile(tempdir, sprintf('read_CS_MIKE11_test_no_shp_%s.log', datestr(now, 'yyyymmdd_HHMMSSFFF')));
[csd2, csl2] = read_CS_MIKE11(fpath_cs_txt, [], fpath_log_2);
assert(~isempty(csd2) && ~isempty(csl2), 'Expected non-empty outputs without shapefile.');
assert(numel(csd2) == numel(csl2), 'csd/csl length mismatch without shapefile.');
assert(all(~cellfun(@isempty, {csl2.branchId})), 'Expected branchId fallback from TXT branch names.');

fprintf('test_read_CS_MIKE11_current_file: PASS\n');

end %function test_read_CS_MIKE11_current_file
