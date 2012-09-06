function struct2xml(filename, s, varargin)
%STRUCT2XML  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   struct2xml(filename, s)
%
%   Input:
%   filename =
%   s        =
%
%
%
%
%   Example
%   struct2xml
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
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
% Created: 27 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%

% Writes Matlab structure s to xml file
%
% e.g.
%
% s.name.value='csm';
% s.name.type='char';
% s.size.value=4;
% s.size.type='int';
% s.station(1).station.name.value='hallo!';
% s.station(1).station.name.type='char';
% s.station(1).station.lon.value=58;
% s.station(1).station.lon.type='real';
% s.station(2).station.name.value='haha';
% s.station(2).station.name.type='char';
% s.station(2).station.lon.value=53;
% s.station(2).station.lon.type='real';
% struct2xml('test.xml',s,'includeattributes',1);
%
% or :
%
% s.name='csm';
% s.size=4;
% s.station(1).station.name='hallo!';
% s.station(1).station.lon=58;
% s.station(2).station.name='haha';
% s.station(2).station.lon=53;
% struct2xml('test.xml',s,'includeattributes',0);

nindent=2;
includeattributes=0;

for ii=1:length(varargin)
  if ischar(varargin{ii})
    switch lower(varargin{ii})
      case{'includeattributes'}
        includeattributes=varargin{ii+1};
      case{'nindent'}
        nindent=varargin{ii+1};
    end
  end
end

fid=fopen(filename,'wt');
fprintf(fid,'%s\n','<?xml version="1.0"?>');
fprintf(fid,'%s\n','<root>');
splitstruct(fid,s,1,nindent,includeattributes);
fprintf(fid,'%s\n','</root>');
fclose(fid);

%%
function splitstruct(fid,s,ilev,nindent,includeattributes)
fnames=fieldnames(s);
iopt=1;
for k=1:length(fnames)  
  if ~isstruct(s.(fnames{k}))
    % End node without attributes
    write2xml(fid,s,fnames{k},ilev,nindent,includeattributes)
  elseif isfield(s.(fnames{k}),'value') && ~isstruct(s.(fnames{k}).value) && includeattributes
    % End node with attributes
    write2xml(fid,s,fnames{k},ilev,nindent,includeattributes)
  else
    switch iopt
      case 0
        fprintf(fid,'%s\n',[repmat(' ',1,ilev*nindent) '<' fnames{k} '>']);
        ilev=ilev+1;
        for j=1:length(s.(fnames{k}))
          splitstruct(fid,s.(fnames{k})(j),ilev,nindent,iopt);
        end
        ilev=ilev-1;
        fprintf(fid,'%s\n',[repmat(' ',1,ilev*nindent) '</' fnames{k} '>']);
      case 1
        for j=1:length(s.(fnames{k}))
          if isstruct(s.(fnames{k})(j).(fnames{k}))
            fprintf(fid,'%s\n',[repmat(' ',1,ilev*nindent) '<' fnames{k} '>']);
            ilev=ilev+1;
            splitstruct(fid,s.(fnames{k})(j).(fnames{k}),ilev,nindent,includeattributes);
            ilev=ilev-1;
            fprintf(fid,'%s\n',[repmat(' ',1,ilev*nindent) '</' fnames{k} '>']);
          else
            % End node without attributes
            write2xml(fid,s.(fnames{k})(j),fnames{k},ilev,nindent,includeattributes)
          end
        end
    end
  end
end

%%
function write2xml(fid,s,fldname,ilev,nindent,includeattributes)
% Write end node
if includeattributes
  v=s.(fldname).value;
  fldnames=fieldnames(s.(fldname));
  attstr='';
  for j=1:length(fldnames)
    switch lower(fldnames{j})
      case{'value','format'}
      otherwise
        attstr=[attstr ' ' fldnames{j} '="' s.(fldname).(fldnames{j}) '"'];
    end
  end
  tp=s.(fldname).type;
else
  v=s.(fldname);
  if ischar(v)
      tp='char';
  else
      tp='real';
  end
  attstr='';
end
str1=[repmat(' ',1,ilev*nindent) '<' fldname attstr '>'];
switch lower(tp)
    case{'char'}
        str2=v;
    case{'int'}
        str2=num2str(v);
    case{'real'}
        if length(v)>1
            % Vector
            if isfield(s.(fldname),'format')
                fmt=s.(fldname).format;
            else
                fmt='%0.3f';
            end
            str2=num2str(v,[fmt ',']);
            str2=num2str(v,[fmt ',']);
            str2=str2(1:end-1);
%            str2=strrep(str2,' ','');
        else            
            str2=num2str(v);
        end
    case{'date'}
        str2=datestr(v,'yyyymmdd HHMMSS');
end
str3=['</' fldname '>'];
fprintf(fid,'%s%s%s\n',str1,str2,str3);
