function [Out1,Out2]=delwaq(cmd,varargin)
%DELWAQ Read/write Delwaq files.
%
%   Struct=DELWAQ('open','FileName')
%   opens the specified Delwaq HIS/MAP file, or
%   it opens the combination of Delwaq LGA and CCO files.
%
%   [Time,Data]=DELWAQ('read',Struct,Substance,Segment,TStep)
%   reads the specified substance (0 for all), specified
%   segment (0 for all) and specified time step (0 for all)
%   from the Delwaq HIS or MAP file.
%
%   Struct=DELWAQ('write','FileName',Header,SubstanceNames, ...
%            RefTime,Time,Data)
%   writes the data to a Delwaq MAP file. Substance names should
%   be specified as a cell array or char matrix. The reference
%   time should be empty (time=index) or a [1 2] matrix containing
%   the reference time (a MATLAB date value) and timestep (in
%   seconds). The size of the data matrix should be
%     NSubstance x NSegment x NTime.
%
%   Struct=DELWAQ('write','FileName',Header,SubstanceNames, ...
%            SegmentNames,RefTime,Time,Data)
%   writes the data to a Delwaq HIS file. Substance and segment names
%   should be specified as a cell array or char matrix. The size of
%   the data matrix should be
%       NSubstance x NSegment x NTime.
%   See also comments on RefTime above.
%
%   StructOut=DELWAQ('write',StructIn,Time,Data)
%   adds the data to a Delwaq HIS/MAP file. The size of the data
%   matrix should be
%       NSubstance x NSegment x NTime.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
