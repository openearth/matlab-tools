function oetpublish(fname,varargin)
%OETPUBLISH  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = oetpublish(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   oetpublish
%
%   See also 

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl	
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       P.O. 177
%       2600 MH Delft
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% Created: 08 May 2009
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Run publish function
publish(fname,varargin{:});

%% Retrieve name of published file
if ~isempty(varargin) && isstruct(varargin{1}) && any(strcmp(fieldnames(varargin{1}),'outputDir'))
    outputDir = varargin{1}.outputDir;
else
    outputDir = fileparts(which(fname));
end

if ~isempty(varargin) && isstruct(varargin{1}) && any(strcmp(fieldnames(varargin{1}),'format'))
    fm = varargin{1}.format;
elseif ~isempty(varargin) && ischar(varargin{1})
    fm = varargin{1};
else
    fm = 'html';
end

switch fm
    case 'latex'
        outfname = fullfile(outputDir,[fname,'.tex']);
    otherwise
        outfname = fullfile(outputDir,[fname,'.' fm]);
end

%% replace keywords in published files
fid = fopen(outfname);
str = fread(fid,'*char')';
fclose(fid);

str = strread(str,'%s',-1,'delimiter',char(10));

%%
% *#REF*
% replace #REF keywords (find references and replace)

id = find(~cellfun(@isempty,strfind(str,'#REF')));

for iid = 1:length(id)
    disp(str{id(iid),1});
    reftemp = str{id(iid),1}(strfind(str{id(iid),1},'#REF')+5:end);
    endid = min([strfind(reftemp,' '),strfind(reftemp,'*'),strfind(reftemp,'"'),strfind(reftemp,'<'),strfind(reftemp,'>'),strfind(reftemp,'='),strfind(reftemp,':'), length(reftemp)+1])-1;
    ref = reftemp(1:endid);
    if ismfunction(ref)
        repl = ['<a href="matlab: doc ' ref '">' ref '</a>'];
    elseif isfunction(which(ref))
        repl = ['<a href="matlab: doc('' #FCNREF' ref ''')">' ref '</a>'];
    else
       refloc = which(ref);
       if isempty(refloc)
           repl = ['###REF to document or function: ' ref ' was not found!!###'];
       else
           % TODO copy file or apply correct reference
           copyfile(refloc,outputDir);
           repl = ref;
       end
    end
    str{id(iid),1} = strrep(str{id(iid),1},['#REF ' ref],repl);
end

%% write the adapted file
finew = fopen(outfname,'w');
for iline = 1:length(str)
    fprintf(finew,'%s',[str{iline} char(10)]);
end
fclose(finew);

% TODO('Refresh all views and not only html')
%% If it is html, display the adapted file in the webbrowser

web(outfname,'-browser');


