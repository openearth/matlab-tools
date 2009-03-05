function W = knmi_potwind_multi(fnames,varargin)
%KNMI_POTWIND_MULTI   read multiple knmi_potwind files
%
% read multiple knmi_potwind files and make one timeseries 
% over overlapping data.
%
% syntax indentical to that of KNMI_POTWIND, except that the
% filename is a cellstr with multiple file names.
%
% Example: make one time series of the following 3 K13 time series:
%
% W = knmi_potwind_multi({'s252.asc'        ,... % from http://www.knmi.nl/samenw/hydra/index.html
%                         'potwind_252_1991',... % http://www.knmi.nl/klimatologie/onderzoeksgegevens/potentiele_wind/
%                         'potwind_252_2001'});  % http://www.knmi.nl/klimatologie/onderzoeksgegevens/potentiele_wind/
%
% KNMI_POTWIND_MULTI checks for non-compatible timeseries (e.g. different station names).
%
% An extra field 'file' is added that gives the file sequenc enumber form which 
% each data point has been taken.
%
% Note that for each file only the data untill the first datenum in 
% the subsequent file are used. The last file supplied is totally 
% returned.
%
%See also: KNMI_POTWIND

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl	
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   -------------------------------------------------------------------

%% read all
%% ---------------------------

   for ii=1:length(fnames)
   w(ii) = knmi_potwind(fnames{ii},varargin{:}); 
   end

   % w(1) = knmi_potwind('.\s252.asc'        ); % from http://www.knmi.nl/samenw/hydra/index.html
   % w(2) = knmi_potwind('.\potwind_252_1991'); % http://www.knmi.nl/klimatologie/onderzoeksgegevens/potentiele_wind/
   % w(3) = knmi_potwind('.\potwind_252_2001'); % http://www.knmi.nl/klimatologie/onderzoeksgegevens/potentiele_wind/

%% Set result equal to first file
%% and delete array fields
%% ---------------------------

   W               = w(1);
   W.DD            = [];
   W.QQD           = [];
   W.UP            = [];
   W.QUP           = [];
   W.datenum       = [];
   W.file          = [];
   
   W.filename      = [];
   W.filedate      = [];
   W.filebytes     = [];
   W.roughness     = [];
   W.version       = [];
   W.read_at       = [];
   
%% merge,where later overwrites earlier
%% ---------------------------

   w(4).datenum = Inf; % add axtra dummy file to allow processing of last file in loop
   
   for ii=[1:length(w)-1]
   
      %% Copy relevant non-overlapping parts of time series
      %% ---------------------------

      mask            = w(ii).datenum < min(w(ii+1).datenum);

      W.DD            = [W.DD(:)'         w(ii).DD(     mask)']';
      W.QQD           = [W.QQD(:)'        w(ii).QQD(    mask)']';
      W.UP            = [W.UP(:)'         w(ii).UP(     mask)']';
      W.QUP           = [W.QUP(:)'        w(ii).QUP(    mask)']';
      W.datenum       = [W.datenum(:)'    w(ii).datenum(mask)']';
      W.file          = [W.file(:)' ii+0.*w(ii).datenum(mask)']'; % 1 for 1st file, 2 for 2nd etc.

      %% Check all     meta-info that is non unique per file
      %% ---------------------------

     %if ~strcmpi        (w(ii).comments,w(1).comments        ); error('meta-info on unique for comments        ');end %          comments: {1x22 cell}
      if ~strcmpi(   w(ii).stationnumber,w(1).stationnumber   ); error('meta-info on unique for stationnumber   ');end %     stationnumber: '252'
      if ~strcmpi(     w(ii).stationname,w(1).stationname     ); error('meta-info on unique for stationname     ');end %       stationname: 'K13'
      if ~isequal(            w(ii).xpar,w(1).xpar            ); error('meta-info on unique for xpar            ');end %              xpar: 10240
      if ~isequal(            w(ii).ypar,w(1).ypar            ); error('meta-info on unique for ypar            ');end %              ypar: 583356
      if ~isequal(             w(ii).lon,w(1).lon             ); error('meta-info on unique for lon             ');end %               lon: 3.22
      if ~isequal(             w(ii).lat,w(1).lat             ); error('meta-info on unique for lat             ');end %               lat: 53.218
      if ~isequal(          w(ii).height,w(1).height          ); error('meta-info on unique for height          ');end %            height: 73.8
      if ~strcmpi(            w(ii).over,w(1).over            ); error('meta-info on unique for over            ');end %              over: 'WATER'
      if ~strcmpi(        w(ii).timezone,w(1).timezone        ); error('meta-info on unique for timezone        ');end %          timezone: 'GMT'
      if ~strcmpi(     w(ii).DD_longname,w(1).DD_longname     ); error('meta-info on unique for DD_longname     ');end %       DD_longname: 'WIND DIRECTION IN DEGREES NORTH'
      if ~strcmpi(    w(ii).QQD_longname,w(1).QQD_longname    ); error('meta-info on unique for QQD_longname    ');end %      QQD_longname: 'QUALITY CODE DD'
      if ~strcmpi(     w(ii).UP_longname,w(1).UP_longname     ); error('meta-info on unique for UP_longname     ');end %       UP_longname: 'POTENTIAL WIND SPEED IN M/S'
      if ~strcmpi(    w(ii).QUP_longname,w(1).QUP_longname    ); error('meta-info on unique for QUP_longname    ');end %      QUP_longname: 'QUALITY CODE UP'
      if ~strcmpi(w(ii).datenum_longname,w(1).datenum_longname); error('meta-info on unique for datenum_longname');end %  datenum_longname: 'days since 00:00 Jan 0 0000'
      if ~strcmpi(        w(ii).UP_units,w(1).UP_units        ); error('meta-info on unique for UP_units        ');end %          UP_units: 'm/s'
      if ~strcmpi(       w(ii).QQD_units,w(1).QQD_units       ); error('meta-info on unique for QQD_units       ');end %         QQD_units: 'm/s'
      if ~strcmpi(        w(ii).DD_units,w(1).DD_units        ); error('meta-info on unique for DD_units        ');end %          DD_units: '[-1,0,2,3,6,7,100,990]'
      if ~strcmpi(       w(ii).QUP_units,w(1).QUP_units       ); error('meta-info on unique for QUP_units       ');end %         QUP_units: '[-1,0,2,3,6,7,100,990]'
      if ~strcmpi(   w(ii).datenum_units,w(1).datenum_units   ); error('meta-info on unique for datenum_units   ');end %     datenum_units: 'day'
      if ~strcmpi(        w(ii).iomethod,w(1).iomethod        ); error('meta-info on unique for iomethod        ');end %          iomethod: [1x80 char]
      if ~isequal(        w(ii).iostatus,w(1).iostatus        ); error('meta-info on unique for iostatus        ');end %          iostatus: 1

      %% Copy  remaing meta-info that is     unique per file
      %% ---------------------------

      W.filename{ii}  = w(ii).filename ;
      W.filedate{ii}  = w(ii).filedate ;
      W.filebytes{ii} = w(ii).filebytes;
      W.roughness{ii} = w(ii).roughness;
      W.version{ii}   = w(ii).version;
      W.read_at{ii}   = w(ii).read_at;
   
   end
   
%% EOF