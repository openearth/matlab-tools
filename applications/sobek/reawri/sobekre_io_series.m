function [varargout] = sobekre_io_series(cmd,varargin)

%% Function: reads or writes a SOBEK Time series file
switch cmd

    %% Read the file
    case ('read')
        filename  = varargin{1};
        SERIES.Time  = [];
        SERIES.Value = [];

        %% Specify format for datenum
        format = 'yyyymmdd  HHMMSS';

        %% open file
        fid = fopen(filename);

        %% read the series
        i_time = 0;
        line   = fgetl(fid);
        while ~feof(fid)
            i_time               = i_time + 1;
            result               = sscanf(line,'"%d/%d/%d;%d:%d:%d"%f');
            SERIES.Time (i_time) = datenum ([num2str(result(1),'%4.4i') num2str(result(2),'%2.2i') num2str(result(3),'%2.2i') '  ' ...
                                             num2str(result(4),'%2.2i') num2str(result(5),'%2.2i') num2str(result(6),'%2.2i') ], format);
            SERIES.Value(i_time) = result(7);
            line           = fgetl(fid);
        end

        %% Close the file
        fclose(fid);

        varargout = {SERIES};
    %% Write the file
    case ('write')
        filename = varargin{1};
        SERIES   = varargin{2};

        % remainder still to do
end
