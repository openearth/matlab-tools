function Out=tekal(cmd,varargin)
% TEKAL File operations for Tekal files
%
%     FileInfo=TEKAL('open',FileName)
%        Reads the specified file.
%     Data=TEKAL('read',FileInfo,DataRecordNr)
%        Reads a data record from the specified file.
%
%     FileInfo=TEKAL('write',FileName,Data)
%        Writes the matrix Data to a Tekal file in a
%        block called 'DATA'.
%     NewFileInfo=TEKAL('write',FileName,FileInfo)
%        Writes a Tekal file based on the information
%        in the FileInfo. FileInfo should be a structure
%        with at least a field Field having two subfields
%        Name and Data. For example
%          FI.Field(1).Name='B001';
%          FI.Field(1).Data=Data1;
%          FI.Field(2).Name='B002';
%          FI.Field(2).Data=Data2;
%        An optional subfield Comments will also be processed
%        and written to file.

% (c) copyright 1997-2001 H.R.A.Jagers
%                         University of Twente / WL | Delft Hydraulics
%                         The Netherlands
%                         bert.jagers@wldelft.nl

% V1.00.** (  /  /1997): created and modified
% V1.01.00 ( 1/ 6/2001): added support for comments (* column i: xxx)
% V1.02.00 (17/ 6/2001): corrected and extended support for annotations,
%                        made reading more robust (accepts spaces, comma's,
%                        tabs as separators in the file)
% V1.03.00 (24/ 8/2001): Extended the help of the write option and
%                        implemented writing 3D matrices and Comments
% V1.03.01 (31/ 8/2003): annotation files, row/columns reversed


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
