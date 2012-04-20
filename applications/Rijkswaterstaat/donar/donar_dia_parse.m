function D = donar_dia_parse(D, varargin)
%DONAR_DIA_PARSE  Parses a DIA struct and tries to interpret the results
%
%   Parses a DIA struct resulting from the donar_dia_read function and
%   tries to interpret the results. It mainly tries to define some axes
%   corresponding to the data. Using these axes it also splits data (!) to
%   fit the axes. Of course, this is the wrong way around, but most likely
%   the file does not contain enough meta data to do it otherwise. It also
%   creates a lookup table to filter data more easily.
%
%   Syntax:
%   D = donar_dia_parse(D, varargin)
%
%   Input:
%   D         = Result structure from donar_dia_read function
%   varargin  = none
%
%   Output:
%   D         = Input structure with additional info on axes and look-up
%               table
%
%   Example
%   D = donar_dia_parse(D)
%
%   See also donar_dia_read, donar_dia_view

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
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
% Created: 20 Apr 2012
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% parse dia struct

for i = 1:length(D.data)

    d = D.data(i);

    % parse time
    try
        
        % convert time strings to date numbers
        D.data(i).time.time_from    = datenum([d.RKS.TYD{1:2}],'yyyymmddhhMM');
        D.data(i).time.time_to      = datenum([d.RKS.TYD{3:4}],'yyyymmddhhMM');

        switch d.RKS.TYD{6}
            case 'sec'
                f = 60*60*24;
            case 'min'
                f = 60*24;
        end

        D.data(i).time.dt           = str2double(d.RKS.TYD{5})/f;
    end
    
    % parse axes
    try
        t = D.data(i).time;
        
        % build time axes
        D.data(i).axes.time         = t.time_from:t.dt:t.time_to;
        
        sz = size(D.data(i).WRD.data2,2);
        
        if sz > 1
            
            % guess the frequency axis based on the number of frequency
            % bins
            switch sz
                case 50
                    f = .001.*[30:10:500];
                    s = [0 1 1];
                case 96
                    f = .001.*[30:10:500];
                    s = [0 0];
                case 101
                    f = .001.*[2.5 10:10:990];
                    s = [0 1];
            end

            D.data(i) = split_frequency_data(D.data(i),f,s);
        end
    end
end

%% create a look-up index based on W3H meta data

D.parameters = read_block(D,'W3H');

end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function D = split_frequency_data(D,f,s)
    n = length(f);
                
    D.axes.frequency    = f;
    
    c = 0;
    W = struct('data1',D.WRD.data1);
    for i = 1:length(s)
        if s(i) == 0; s(i) = n; end;
        
        W.(sprintf('data%d',i+1)) = D.WRD.data2(:,c+[1:s(i)]);
        
        c = c+s(i);
    end
    
    D.WRD = W;
end

function v = read_block(D,block)
    s = cellfun(@fieldnames,{D.data.(block)},'UniformOutput',false)';
    s = unique(cat(1,s{:}));

    v = struct();
    for i = 1:length(s)
        try
            v.(s{i}) = read_parameter(D,s{i});
        end
    end
end

function v = read_parameter(D,par)
    [u,~,j] = unique(cellfun(@(x)read_existsing_fields(x,par),{D.data.W3H},'UniformOutput',false));
    
    val = genvarname(cellfun(@(x)regexprep(x,'\W','_'),u,'UniformOutput',false));
    ind = cellfun(@(x)find(j==x),num2cell(unique(j)),'UniformOutput',false);
    
    v = struct( ...
        'values',   {u},    ...
        'indices',  {j},    ...
        'combined', cell2struct(ind,val,2));
end

function v = read_existsing_fields(x,field)
    v = 'UNKNOWN';
    if isfield(x,field)
        v = [x.(field){1}];
    end
end