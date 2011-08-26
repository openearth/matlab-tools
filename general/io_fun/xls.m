classdef xls
    %XLS  fast, object oriented, reading and writing of xls files
    %
    %   Still in beta
    %
    %   Methods for class xls:
    %   close  open   read   write  
    %
    %   Example
    %   xls
    %
    %   See also
    
    %% Copyright notice
    %   --------------------------------------------------------------------
    %   Copyright (C) 2011 Van Oord Dredging and Marine Contractors BV
    %       Thijs Damsma
    %
    %       tda@vanoord.com
    %
    %       Watermanweg 64
    %       3067 GG
    %       Rotterdam
    %       The Netherlands
    %
    %   This library is free software: you can redistribute it and/or modify
    %   it under the terms of the GNU General Public License as published by
    %   the Free Software Foundation, either version 3 of the License, or
    %   (at your option) any later version.
    %
    %   This library is distributed in the hope that it will be useful,
    %   but WITHOUT ANY WARRANTY; without even the implied warranty of
    %   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    %   GNU General Public License for more details.
    %
    %   You should have received a copy of the GNU General Public License
    %   along with this library.  If not, see <http://www.gnu.org/licenses/>.
    %   --------------------------------------------------------------------
    
    % This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
    % OpenEarthTools is an online collaboration to share and manage data and
    % programming tools in an open source, version controlled environment.
    % Sign up to recieve regular updates of this function, and to contribute
    % your own tools.
    
    %% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
    % Created: 26 Aug 2011
    % Created with Matlab version: 7.12.0.62 (R2011a)
    
    % $Id$
    % $Date$
    % $Author$
    % $Revision$
    % $HeadURL$
    % $Keywords: $
    
    properties(GetAccess = 'public', SetAccess = 'private')
        % define the properties of the class here, (like fields of a struct)
        excel;
        filename;
        workbook;
        data_written;
    end
    methods
        % methods, including the constructor are defined in this block
        function obj = xls(filename)
            if nargin ~= 1
                error('only input filename')
            end
            % class constructor
            if ~exist(filename,'file')
                error('file could not be found')
            end
            fid = fopen(filename);
            if fid <2
                error('file could not be opened')
            end
            fclose(fid);
            % use the absolute path for filename
            if isempty(strfind(filename,'.'))
                obj.filename     = which(filename);
            else % append a '.' to make which look for a file is there is no '.' in the filename
                obj.filename     = which([filename '.']);
            end
            obj.data_written = false;
        end
        function obj = open(obj)
            obj.excel = actxserver('excel.application');
            % open workbook
            obj.excel.DisplayAlerts = 0;
            obj.workbook = obj.excel.workbooks.Open(obj.filename);
        end
        function obj = close(obj)
            if obj.data_written
                obj.workbook.Save;
            end
            obj.excel.Quit;
            obj.excel.delete;
        end
        function data = read(obj,sheet,range)
            TargetSheet = get(obj.excel.sheets,'item',sheet);
            %Activate silently fails if the sheet is hidden
            set(TargetSheet, 'Visible','xlSheetVisible');
            % activate worksheet
            Activate(TargetSheet);
            Select(Range(obj.excel,range));
            DataRange = get(obj.excel,'Selection');
            data = DataRange.Value;
        end
        function obj = write(obj,data,sheet,range)
            if obj.workbook.ReadOnly ~= 0
                %This means the file is probably open in another process.
                error('MATLAB:xlswrite:LockedFile', 'The file %s is not writable.  It may be locked by another process.', file);
            end
            TargetSheet = get(obj.excel.sheets,'item',sheet);
            %Activate silently fails if the sheet is hidden
            set(TargetSheet, 'Visible','xlSheetVisible');
            % activate worksheet
            Activate(TargetSheet);
            Select(Range(obj.excel,range));
            if iscell(data)
                % ok
            else
                data = num2cell(data);
                [data{cellfun(@isnan,data)}] = deal([]);
            end
            % Export data to selected region.
            set(obj.excel.selection,'Value',data);
            obj.data_written = true;
        end
    end
end