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

function in_plot=gdm_read_json(fpath_json)

%% CHECK
if ~isfile(fpath_json)
    error('Configuration file not found: %s', fpath_json);
end

fid = fopen(fpath_json, 'r');
if fid == -1
    error('Could not open file: %s', fpath_json);
end

%% READ
raw = fread(fid, inf, 'uint8=>char')';
fclose(fid);

%% DECODE
try
    in_plot = jsondecode(raw);
catch ME
    error('Invalid JSON format in file "%s":\n%s', fpath_json, ME.message);
end

in_plot = decode_special_numbers_recursive(in_plot);

end %function

%%
%% FUNCTIONS
%%

function out = decode_special_numbers_recursive(in)

    if isstruct(in) && isfield(in,'json_type') ...
            && strcmp(in.json_type,'numeric_array')

        sz = double(in.size);
        flat = in.data;

        numeric_flat = zeros(numel(flat),1);

        for k = 1:numel(flat)
            val = flat{k};

            if ischar(val) || isstring(val)
                switch char(val)
                    case '__NaN__'
                        numeric_flat(k) = NaN;
                    case '__Inf__'
                        numeric_flat(k) = Inf;
                    case '__-Inf__'
                        numeric_flat(k) = -Inf;
                    otherwise
                        numeric_flat(k) = str2double(val);
                end
            else
                numeric_flat(k) = val;
            end
        end

        out = reshape(numeric_flat, sz);

    elseif isstruct(in)

        fn = fieldnames(in);
        out = struct();

        for i = 1:numel(fn)
            out.(fn{i}) = decode_special_numbers_recursive(in.(fn{i}));
        end

    elseif iscell(in)

        out = cell(size(in));
        for i = 1:numel(in)
            out{i} = decode_special_numbers_recursive(in{i});
        end

        out = restore_array_shape(out);

    elseif ischar(in) || isstring(in)

        out = decode_special_token(in);

    else
        out = in;
    end
end

function out = decode_special_token(in)

    s = char(in);

    switch s
        case '__NaN__'
            out = NaN;
        case '__Inf__'
            out = Inf;
        case '__-Inf__'
            out = -Inf;
        otherwise
            % Check for duration marker
            if startsWith(s, '__duration__:')
                durationStr = s(14:end); % Remove '__duration__:' prefix
                out = duration(durationStr);
            else
                out = in;
            end
    end
end

function out = restore_array_shape(in)

    out = in;

    if isempty(in)
        return;
    end

    % Case 1: vector of scalar numerics/logicals -> numeric vector
    if isvector(in) && all(cellfun(@(x) isnumeric(x) && isscalar(x), in(:)))
        out = cell2mat(in(:).');
        return;
    end

    % Case 1b: vector of scalar durations -> duration vector
    if isvector(in) && all(cellfun(@(x) isduration(x) && isscalar(x), in(:)))
        out = [in{:}];
        return;
    end

    % Case 2: vector of row-cells -> rebuild 2D matrix/cell array
    if isvector(in) && all(cellfun(@(x) (isnumeric(x) || islogical(x)) && isvector(x), in(:)))

        nrow = numel(in);
        ncol = numel(in{1});
        if ncol == 0
            out = zeros(nrow,0);
            return;
        end

        sameSize = all(cellfun(@(x) numel(x)==ncol, in(:)));
        if ~sameSize
            return;
        end

        out = zeros(nrow,ncol);
        for irow = 1:nrow
            out(irow,:) = reshape(double(in{irow}),1,[]);
        end

        return;
    end

    % Case 3: vector of row-cells -> rebuild 2D matrix/cell array
    if isvector(in) && all(cellfun(@(x) iscell(x) && isvector(x), in(:)))

        nrow = numel(in);
        ncol = numel(in{1});
        if ncol == 0
            out = cell(nrow,0);
            return;
        end

        sameSize = all(cellfun(@(x) numel(x)==ncol, in(:)));
        if ~sameSize
            return;
        end

        mat = cell(nrow,ncol);
        for irow = 1:nrow
            row = in{irow};
            for icol = 1:ncol
                mat{irow,icol} = row{icol};
            end
        end

        if all(cellfun(@(x) isnumeric(x) && isscalar(x), mat(:)))
            out = cell2mat(mat);
        else
            out = mat;
        end

        return;
    end

    % Case 4: 2D cell matrix of scalar numerics -> numeric matrix
    if ismatrix(in) && all(cellfun(@(x) isnumeric(x) && isscalar(x), in(:)))
        out = cell2mat(in);
    end

    % Case 5: 2D cell matrix of scalar durations -> duration matrix
    if ismatrix(in) && all(cellfun(@(x) isduration(x) && isscalar(x), in(:)))
        out = reshape([in{:}], size(in));
    end
end


