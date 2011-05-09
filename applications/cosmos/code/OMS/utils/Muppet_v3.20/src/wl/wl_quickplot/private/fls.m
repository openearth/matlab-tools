function [Out,FI2]=fls(cmd,varargin)
%FLS Read Delft-FLS and SOBEK2D incremental files.
%   FILEDATA = FLS('open',FILENAME) opens the specified Delft-FLS input
%   file (mdf file), incremental file, binary/ascii history file, or
%   cross-sections data file. In case of an mdf file, the function reads
%   and checks data from the file and scans the directory for simulation
%   output.
%
%   [DATA,FILEDATA] = FLS('inc',FILEDATA,FIELD,TIME) determines the data
%   (classes) for the selected FIELD at TIME from the incremental data
%   file. The routine returns the data and an updated FileData (contains
%   state at retrieved time for faster reading of data at later times).
%
%   INCDATA = FLS('inc',FILEDATA) loads incremental file into memory for
%   data analysis. Use INCANALYSIS to analyse the returned data structure.
%
%   TIMES = FLS('bin',FILEDATA,'T',TINDEX) determines the time in the
%   binary history file. If the time index TINDEX is not specified, all
%   available times will be returned.
%
%   DATA = FLS('bin',FILEDATA,FIELD,STATION,TINDEX) reads data for the
%   selected station at the specified time steps from the binary history
%   file, where FIELD equals 'S'(or 'Z'), 'U', 'V' or 'H' for water level,
%   velocity components in X and Y direction and water depth, respectively.
%   If the time index TINDEX is not specified, data is returned for all
%   time steps.
%
%   DATA = FLS('his',FILEDATA,STATION) reads all data for a station from
%   the ascii history file.
%
%   DATA = FLS('cross',FILEDATA,'T',TINDEX) reads time associated with the
%   specified time indices. If TINDEX is not specified, all available times
%   will be returned.
%
%   DATA = FLS('cross',FILEDATA,CROSSNR,TINDEX) reads data of specified
%   cross-section numbers at specified time indices. If TINDEX is not
%   specified, data is returned for all time steps.
%
%   DATA = FLS('bottom',FILEDATA,TIME) determines the bed level data at
%   indicated TIME based on the initial bed level and dam break data.
%
%   See also INCANALYSIS, SOBEK, ARCGRID, QPFOPEN, QPREAD.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
