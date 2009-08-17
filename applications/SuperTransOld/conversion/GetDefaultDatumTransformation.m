function [transcodes,ireverse,crscode_interm]=GetDefaultDatumTransformation(crs1,crs2,DefaultDatumTransformation)
%GETDEFAULTDATUMTRANSFORMATION  get default datum transformation
%
% [transcodes,ireverse,crscode_interm]=GetDefaultDatumTransformation(crs1,crs2,DefaultDatumTransformation)
%
%See also: 

transcodes     = [NaN NaN];
ireverse       = [NaN NaN];
crscode_interm = NaN;

crscodes            = DefaultDatumTransformation.crscodes;
default_transcodes  = DefaultDatumTransformation.transcodes;
default_ireverse    = DefaultDatumTransformation.ireverse;
default_intermcodes = DefaultDatumTransformation.interm;

i1=find(crscodes==crs1);
i2=find(crscodes==crs2);

transcodes     = default_transcodes (i1,i2,:);
ireverse       = default_ireverse   (i1,i2,:);
crscode_interm = default_intermcodes(i1,i2,:);
