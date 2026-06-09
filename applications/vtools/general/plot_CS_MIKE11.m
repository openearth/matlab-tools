%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Plot cross-sections parsed by read_CS_MIKE11: one figure per cross-section
%with two subplots:
%   left  - original y/z profile (raw + filtered markers)
%   right - zwRiver comparison (zw from yz vs zw from file)
%
%This function is intended to be used together with read_CS_MIKE11, which
%parses the MIKE11 TXT file and returns the sections struct.
%
%INPUTS
%   sections  - parsed section struct returned by read_CS_MIKE11
%   csd       - struct array returned by read_CS_MIKE11 (zwRiver definitions)
%   csl       - struct array returned by read_CS_MIKE11 (locations)
%   fdir_png  - optional output folder for PNG files

function plot_CS_MIKE11(sections, csd, csl, fdir_png)

if nargin < 3
    error('plot_CS_MIKE11:missingInputs', 'Expected at least 3 inputs: sections, csd, csl.')
end

ncs = numel(sections);
if ncs ~= numel(csd)
    error('plot_CS_MIKE11:mismatch', ...
        'Number of sections (%d) differs from csd entries (%d).', ...
        ncs, numel(csd))
end
if ncs ~= numel(csl)
    error('plot_CS_MIKE11:mismatch', ...
        'Number of sections (%d) differs from csl entries (%d).', ...
        ncs, numel(csl))
end

if nargin < 4 || isempty(fdir_png)
    fdir_png = fullfile(pwd, 'plots_CS_MIKE11');
end
if exist(fdir_png, 'dir') ~= 7
    mkdir(fdir_png);
end

fprintf('plot_CS_MIKE11: plotting %d cross-sections to PNG in:\n  %s\n', ncs, fdir_png);

name_counts = containers.Map('KeyType', 'char', 'ValueType', 'int32');

for kcs = 1:ncs
    sec = sections(kcs);
    def = csd(kcs);

    if isnan(sec.section_id)
        sid_str = '(no ID)';
    else
        sid_str = num2str(sec.section_id, '%d');
    end
    fig_title = sprintf('%s  ch = %.0f m  ID = %s', sec.branch, sec.chainage, sid_str);

    fig = figure('Name', fig_title, 'NumberTitle', 'off', 'Visible', 'off');

    % ---- subplot 1: original y/z profile ----
    ax1 = subplot(1, 2, 1);
    hold(ax1, 'on')

    plot(ax1, sec.y_raw, sec.z_raw, '-', 'Color', [0.2 0.4 0.8], 'DisplayName', 'profile (raw)')

    if ~isempty(sec.y_removed)
        plot(ax1, sec.y_removed, sec.z_removed, 'x', ...
            'Color', [0.85 0.1 0.1], 'MarkerSize', 8, 'LineWidth', 1.5, ...
            'DisplayName', 'filtered point')
    end

    unique_codes = unique(sec.code_raw(sec.code_raw ~= 0));
    marker_styles = {'o', 's', '^', 'd', 'v', 'p', 'h'};
    for kcode = 1:numel(unique_codes)
        c = unique_codes(kcode);
        idx = sec.code_raw == c;
        ms = marker_styles{mod(kcode - 1, numel(marker_styles)) + 1};
        plot(ax1, sec.y_raw(idx), sec.z_raw(idx), ms, ...
            'MarkerSize', 7, 'LineWidth', 1.5, ...
            'DisplayName', sprintf('<#%d>', c))
    end
    if ~isempty(unique_codes) || ~isempty(sec.y_removed)
        legend(ax1, 'Location', 'north')
    end

    xlabel(ax1, 'Distance along cross-section [m]')
    ylabel(ax1, 'Elevation [m AD]')
    title(ax1, 'Original profile (y/z)')

    if isfield(def, 'xMainLeft') && isfield(def, 'xMainRight')
        xline(ax1, def.xMainLeft, '--', 'Color', [0.85 0.2 0.2], 'LineWidth', 1.2, ...
            'DisplayName', 'main left');
        xline(ax1, def.xMainRight, '--', 'Color', [0.2 0.6 0.2], 'LineWidth', 1.2, ...
            'DisplayName', 'main right');

        z_left = profile_z_at_x(def.xMainLeft, sec.y, sec.z);
        z_right = profile_z_at_x(def.xMainRight, sec.y, sec.z);

        if isfinite(z_left)
            plot(ax1, def.xMainLeft, z_left, 'o', ...
                'MarkerSize', 6, 'LineWidth', 1.0, ...
                'MarkerEdgeColor', [0.85 0.2 0.2], 'MarkerFaceColor', [1 1 1], ...
                'HandleVisibility', 'off');
            text(ax1, def.xMainLeft, z_left, sprintf(' z=%.2f', z_left), ...
                'Color', [0.85 0.2 0.2], 'FontSize', 8, 'VerticalAlignment', 'bottom');
        end

        if isfinite(z_right)
            plot(ax1, def.xMainRight, z_right, 'o', ...
                'MarkerSize', 6, 'LineWidth', 1.0, ...
                'MarkerEdgeColor', [0.2 0.6 0.2], 'MarkerFaceColor', [1 1 1], ...
                'HandleVisibility', 'off');
            text(ax1, def.xMainRight, z_right, sprintf(' z=%.2f', z_right), ...
                'Color', [0.2 0.6 0.2], 'FontSize', 8, 'VerticalAlignment', 'bottom');
        end
    end

    if isfield(def, 'mainWidth') && isfield(def, 'fp1Width') && isfield(def, 'fp2Width')
        txt = sprintf('fp1 = %.1f\nmain = %.1f\nfp2 = %.1f', ...
            def.fp1Width, def.mainWidth, def.fp2Width);
        text(ax1, 0.02, 0.02, txt, 'Units', 'normalized', ...
            'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', ...
            'BackgroundColor', 'w', 'Margin', 2, 'FontSize', 8, 'Interpreter', 'none');
    end

    grid(ax1, 'on')
    box(ax1, 'on')

    % ---- subplot 2: zw comparison ----
    ax2 = subplot(1, 2, 2);
    hold(ax2, 'on')

    has_yz_trace = isfield(def, 'zwWidthsFromYZ') && isfield(def, 'zwLevelsFromYZ') && ...
        ~isempty(def.zwWidthsFromYZ) && ~isempty(def.zwLevelsFromYZ);
    has_file_trace = isfield(def, 'zwWidthsFromFile') && isfield(def, 'zwLevelsFromFile') && ...
        ~isempty(def.zwWidthsFromFile) && ~isempty(def.zwLevelsFromFile);

    if has_yz_trace
        plot(ax2, def.zwWidthsFromYZ, def.zwLevelsFromYZ, '-o', ...
            'MarkerSize', 3, 'DisplayName', 'zw from yz')
    else
        plot(ax2, def.flowWidths, def.levels, '-o', 'MarkerSize', 3, 'DisplayName', 'zw in csd')
    end

    if has_file_trace
        plot(ax2, def.zwWidthsFromFile, def.zwLevelsFromFile, '--d', ...
            'MarkerSize', 3, 'DisplayName', 'zw from file')
    else
        fprintf('plot_CS_MIKE11: warning no file zw data for chainage=%8.3f\n', sec.chainage);
    end

    if isfield(def, 'mainWidth')
        xline(ax2, def.mainWidth, '--', 'Color', [0.85 0.2 0.2], 'LineWidth', 1.2, ...
            'DisplayName', 'main width');
    end

    legend(ax2, 'Location', 'north')
    xlabel(ax2, 'Width [m]')
    ylabel(ax2, 'Level [m AD]')
    title(ax2, 'zw comparison (yz vs file)')

    grid(ax2, 'on')
    box(ax2, 'on')

    apply_shared_limits(ax1, ax2, 0.35);

    sgtitle(fig_title, 'Interpreter', 'none')

    branch_str = regexprep(strtrim(sec.branch), '[^A-Za-z0-9_.-]', '_');
    chainage_str = sprintf('%012.3f', sec.chainage);
    base_name = sprintf('%s_%s', branch_str, chainage_str);

    if isKey(name_counts, base_name)
        name_counts(base_name) = name_counts(base_name) + 1;
    else
        name_counts(base_name) = int32(1);
    end
    name_idx = name_counts(base_name);

    if name_idx == 1
        png_name = sprintf('%s.png', base_name);
    else
        png_name = sprintf('%s_dup%02d.png', base_name, name_idx);
    end

    fpath_png = fullfile(fdir_png, png_name);
    print(fig, fpath_png, '-dpng', '-r200');
    close(fig);

    fprintf('plot_CS_MIKE11: %4d/%4d  wrote %s\n', kcs, ncs, png_name);
end

fprintf('plot_CS_MIKE11: done.\n');

end %function plot_CS_MIKE11

%% =========================================================================

function apply_shared_limits(ax1, ax2, top_frac)
%APPLY_SHARED_LIMITS  Force same x/y limits on yz and zw subplots.

x1 = xlim(ax1);
x2 = xlim(ax2);
y1 = ylim(ax1);
y2 = ylim(ax2);

x_shared = [min([x1(1), x2(1)]), max([x1(2), x2(2)])];
y_shared = [min([y1(1), y2(1)]), max([y1(2), y2(2)])];

y_span = y_shared(2) - y_shared(1);
if ~isfinite(y_span) || y_span <= 0
    y_span = max(abs(y_shared(2)), 1);
end
y_shared(2) = y_shared(2) + top_frac * y_span;

xlim(ax1, x_shared);
xlim(ax2, x_shared);
ylim(ax1, y_shared);
ylim(ax2, y_shared);

end %function apply_shared_limits

%% =========================================================================

function zq = profile_z_at_x(xq, y, z)
%PROFILE_Z_AT_X  Interpolate profile elevation at x using monotonic profile.

zq = NaN;
if isempty(y) || isempty(z) || numel(y) < 2 || numel(y) ~= numel(z)
    return
end

y = y(:);
z = z(:);

if xq < y(1) || xq > y(end)
    return
end

idx = find(y(1:end-1) <= xq & xq <= y(2:end), 1, 'first');
if isempty(idx)
    [~, idx_near] = min(abs(y - xq));
    zq = z(idx_near);
    return
end

y1 = y(idx);
y2 = y(idx + 1);
z1 = z(idx);
z2 = z(idx + 1);

if y2 == y1
    zq = 0.5 * (z1 + z2);
else
    t = (xq - y1) / (y2 - y1);
    zq = z1 + t * (z2 - z1);
end

end %function profile_z_at_x
