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
%

function gdm_save_json(fid_log,in_plot,simdef)

% Encode 
in_plot=encode_special_numbers_recursive(in_plot);

% Convert to JSON string (preserve array/cell shape)
jsonStr=jsonencode_preserve_shape(in_plot);

% Write JSON string to file
ksave=1; %You would like it to be `in_plot.sim_ref` but it may have not been defined.
fdir_json=fullfile(simdef(ksave).D3D.dire_sim,'json');
mkdir_check(fdir_json);
fname_json=sprintf('D3D_plot_config_%s.json',now_chr());
fpath_json=fullfile(fdir_json,fname_json);


fid=fopen(fpath_json, 'w');
if fid == -1
    error('Could not open file for writing: %s', fpath_json);
end

fwrite(fid, jsonStr, 'char');
fclose(fid);

messageOut(fid_log,sprintf('JSON configuration written to: %s\n', fpath_json));

end %function

%%
%% FUNCTIONS
%%

function s = jsonencode_preserve_shape(in)
    indentUnit = '  ';
    s = encode_json_value(in,0,indentUnit);
end

function s = encode_json_value(v,level,indentUnit)

    if isstruct(v)

        if isempty(v)
            s = '[]';
        elseif isscalar(v)
            fn = fieldnames(v);
            if isempty(fn)
                s = '{}';
                return;
            end

            parts = cell(1,numel(fn));
            for k = 1:numel(fn)
                key = jsonencode(fn{k});
                val = encode_json_value(v.(fn{k}),level+1,indentUnit);
                parts{k} = [indent(level+1,indentUnit) key ': ' val];
            end

            s = ['{' newline ...
                 strjoin(parts,[',' newline]) ...
                 newline indent(level,indentUnit) '}'];
        else
            s = encode_by_shape(size(v), ...
                @(idx) encode_json_value(v(idx),level+1,indentUnit), ...
                level,indentUnit);
        end

    elseif iscell(v)

        s = encode_by_shape(size(v), ...
            @(idx) encode_json_value(v{idx},level+1,indentUnit), ...
            level,indentUnit);

    elseif isnumeric(v) || islogical(v)

        if isempty(v)
            s = '[]';
        elseif isscalar(v)
            s = jsonencode(v);
        else
            s = encode_by_shape(size(v), @(idx) jsonencode(v(idx)), ...
                level,indentUnit);
        end

    elseif isstring(v)

        if isempty(v)
            s = '[]';
        elseif isscalar(v)
            s = jsonencode(char(v));
        else
            s = encode_by_shape(size(v), @(idx) jsonencode(char(v(idx))), ...
                level,indentUnit);
        end

    elseif ischar(v)

        if size(v,1) <= 1
            s = jsonencode(v);
        else
            rows = cell(1,size(v,1));
            for irow = 1:size(v,1)
                rows{irow} = jsonencode(v(irow,:));
            end
            s = encode_vector_values(rows,level,indentUnit);
        end

    elseif isduration(v)

        if isempty(v)
            s = '[]';
        elseif isscalar(v)
            s = jsonencode(['__duration__:' char(v)]);
        else
            s = encode_by_shape(size(v), @(idx) jsonencode(['__duration__:' char(v(idx))]), ...
                level,indentUnit);
        end

    else

        s = jsonencode(v);
    end
end

function s = encode_by_shape(sz, elementEncoder, level, indentUnit)

    if prod(sz) == 0
        s = '[]';
        return;
    end

    if numel(sz) == 1
        nrow = sz(1);
        ncol = 1;
    else
        nrow = sz(1);
        ncol = sz(2);
    end

    if nrow == 1 || ncol == 1

        n = nrow*ncol;
        elems = cell(1,n);
        for i = 1:n
            elems{i} = elementEncoder(i);
        end
        s = encode_vector_values(elems,level,indentUnit);

    else

        rows = cell(1,nrow);
        for irow = 1:nrow
            rowElems = cell(1,ncol);
            for icol = 1:ncol
                idx = sub2ind([nrow,ncol],irow,icol);
                rowElems{icol} = elementEncoder(idx);
            end
            rows{irow} = [indent(level+1,indentUnit) '[' strjoin(rowElems,', ') ']'];
        end
        s = ['[' newline ...
             strjoin(rows,[',' newline]) ...
             newline indent(level,indentUnit) ']'];

    end
end

function s = encode_vector_values(elems,level,indentUnit)

    if isempty(elems)
        s = '[]';
        return;
    end

    lines = cell(size(elems));
    for i = 1:numel(elems)
        lines{i} = [indent(level+1,indentUnit) elems{i}];
    end

    s = ['[' newline ...
         strjoin(lines,[',' newline]) ...
         newline indent(level,indentUnit) ']'];
end

function s = indent(level,indentUnit)
    s = repmat(indentUnit,1,level);
end

function out = encode_special_numbers_recursive(in)

    if isnumeric(in)

        if isscalar(in)
            if isnan(in)
                out = "__NaN__";
            elseif isinf(in) && in > 0
                out = "__Inf__";
            elseif isinf(in) && in < 0
                out = "__-Inf__";
            else
                out = in;
            end
        else
            % Convert numeric array to cell to allow mixed content
            out = arrayfun(@encode_special_numbers_recursive, in, ...
                           'UniformOutput', false);
        end

    elseif isstruct(in)

        fn = fieldnames(in);
        out = struct();

        for i = 1:numel(fn)
            out.(fn{i}) = encode_special_numbers_recursive(in.(fn{i}));
        end

    elseif iscell(in)

        if ismatrix(in) && size(in,1) > 1 && size(in,2) > 1
            % Keep 2D cell-array structure as JSON array-of-arrays
            nrow = size(in,1);
            ncol = size(in,2);
            out = cell(1,nrow);

            for irow = 1:nrow
                rowCell = cell(1,ncol);
                for icol = 1:ncol
                    rowCell{icol} = encode_special_numbers_recursive(in{irow,icol});
                end
                out{irow} = rowCell;
            end
        else
            out = cell(size(in));
            for i = 1:numel(in)
                out{i} = encode_special_numbers_recursive(in{i});
            end
        end

    elseif isduration(in)

        % Convert duration values to marked character strings
        if isscalar(in)
            out = ['__duration__:' char(in)];
        else
            out = arrayfun(@(x) ['__duration__:' char(x)], in, 'UniformOutput', false);
        end

    else
        out = in;
    end
end

%%

% function out = encode_special_numbers_recursive(in)

%     if isnumeric(in)

%         if any(~isfinite(in(:)))

%             out = struct();
%             out.json_type = 'numeric_array';
%             out.size = size(in);

%             flat = in(:);
%             data = cell(numel(flat),1);

%             for k = 1:numel(flat)
%                 v = flat(k);
%                 if isnan(v)
%                     data{k} = '__NaN__';
%                 elseif isinf(v) && v > 0
%                     data{k} = '__Inf__';
%                 elseif isinf(v) && v < 0
%                     data{k} = '__-Inf__';
%                 else
%                     data{k} = v;
%                 end
%             end

%             out.data = data;

%         else
%             out = in;
%         end

%     elseif isstruct(in)

%         fn = fieldnames(in);
%         out = struct();

%         for i = 1:numel(fn)
%             out.(fn{i}) = encode_special_numbers_recursive(in.(fn{i}));
%         end

%     elseif iscell(in)

%         out = cell(size(in));
%         for i = 1:numel(in)
%             out{i} = encode_special_numbers_recursive(in{i});
%         end

%     else
%         out = in;
%     end
% end

