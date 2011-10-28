function snc_validate_idx(start,count,stride,nvdims)
%SNC_VALIDATE_IDX
%    We need to check the lengths of the index vectors before calling the
%    netCDF library.  A bad length can confuse the mex-file, and it's really 
%    not the mex-file's responsibility to do this.  We can't do this when 
%    parsing the input arguments since we need the number of dimensions 
%    corresponding to the input variable.

if ~isempty(start) && (numel(start) ~= nvdims)
    error ( 'SNCTOOLS:snc_validate_idx:badStartIndex', ...
        'The length of the start index vector (%d) does not equal the number of dimensions (%d).', ...
        numel(start), nvdims);
end
if ~isempty(count) && (numel(count) ~= nvdims)
    error ( 'SNCTOOLS:snc_validate_idx:badCountIndex', ...
        'The length of the count vector (%d) does not equal the number of dimensions (%d)', ...
        numel(count), nvdims);
end
if ~isempty(stride) && (numel(stride) ~= nvdims)
    error ( 'SNCTOOLS:snc_validate_idx:badStrideIndex', ...
        'The length of the start index vector (%d) does not equal the number of dimensions (%d)', ...
        numel(stride), nvdims);
end

%
% Don't bother if any of COUNT == 0
if prod(double(count)) == 0 % e.g. GEBCO dimension variable is int16
    error ( 'SNCTOOLS:snc_validate_idx:badCountIndex', ...
	    'retrieval request was for 0 elements.' );  
end


return






