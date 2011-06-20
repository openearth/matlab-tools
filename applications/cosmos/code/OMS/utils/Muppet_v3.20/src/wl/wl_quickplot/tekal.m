function Out=tekal(cmd,varargin)
%TEKAL Read/write for Tekal files.
%   INFO = TEKAL('open',FILENAME) reads the specified Tekal file. If the
%   FILENAME is not specified you will be asked to select a file
%   interactively. The returned structure contains the metadata of the
%   Tekal file.
%
%   DATA = TEKAL('read',INFO,RECORD) reads the selected data record from
%   the specified file. The RECORD may be specified as integer (data block
%   number) or as block name (if that name is unique). In case RECORD is an
%   integer, you may select to read multiple records. In this case DATA
%   will be a cell array grouping all data blocks read.
%
%   INFO = TEKAL('write',FILENAME,DATA) writes the matrix DATA to a simple
%   plain Tekal file containing one data block called 'DATA'. The function
%   returns a structure INFO containing the metadata of the newly created
%   file.
%
%   NEWINFO = TEKAL('write',FILENAME,INFO) writes a more complete new Tekal
%   file based on the information in the INFO structure. INFO should be a
%   structure with at least a field called Field having two subfields Name
%   and Data. An optional subfield Comments will also be processed and
%   written to file.
%
%   Example
%      % Data for block 1
%      INFO.Field(1).Name = 'Magic';
%      INFO.Field(1).Data = magic(5);
%      % Data for block 2
%      INFO.Field(2).Name = 'Random';
%      INFO.Field(2).Data = rand(8,5,3,2);
%      INFO.Field(2).Comments = {'Note we can handle nD arrays too.'};
%      % write file
%      OUT = tekal('write','test.tek',INFO);
%
%      Random = tekal('read',OUT,'Random');
%      size(Random) % returns [8 5 3 2]
%
%   See also LANDBOUNDARY, TEKAL2TBA, QPFOPEN, QPREAD.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
