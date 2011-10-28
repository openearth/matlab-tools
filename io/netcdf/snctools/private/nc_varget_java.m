function values = nc_varget_java (ncfile,varname,varargin)
% NC_VARGET_JAVA:  Java backend for nc_varget.

import ucar.nc2.dods.*     
import ucar.nc2.*          
                           
close_it = true;

% Try it as a local file.  If not a local file, try as
% via HTTP, then as dods
if isa(ncfile,'ucar.nc2.NetcdfFile')
	jncid = ncfile;
	close_it = false;
elseif isa(ncfile,'ucar.nc2.dods.DODSNetcdfFile')
	jncid = ncfile;
	close_it = false;
elseif exist(ncfile,'file')
    % non-opendap HTTP?
	jncid = NetcdfFile.open(ncfile);
else
	try 
		jncid = NetcdfFile.open ( ncfile );
	catch %#ok<CTCH>
		try
            jncid = snc_opendap_open(ncfile);
		catch %#ok<CTCH>
			error ( 'SNCTOOLS:nc_varget_java:fileOpenFailure', ...
				'Could not open ''%s'' with java backend.' , ncfile);
		end
	end
end

% Get the variable object
jvarid = jncid.findVariable(varname);
if isempty ( jvarid )
    error('snctools:varget:java:noSuchVariable', ...
	    'findVariable failed on variable ''%s'', file ''%s''.',...
        varname,ncfile);
end


varinfo = nc_getvarinfo_java ( jncid, jvarid );
var_size = varinfo.Size;

theDataType = jvarid.getDataType();
theDataTypeString = char ( theDataType.toString() ) ;

[start,count,stride] = get_indexing(jvarid,varinfo,varargin{:});

% If no data has been written to an unlimited variable, then there's 
% nothing to do.  Just return.
if prod(var_size) == 0
	values = [];
	return
end


read_method = determine_read_method(start,count,stride,varinfo);



% Finally!  Read the freakin' data.
try
    switch ( read_method )
        case 'GET_VAR1'
            % Read a scalar
            values = nc_var1_get_java ( jvarid, theDataTypeString );
    
        case 'GET_VAR'    
            % Read everything.
            values = nc_var_get_java ( jvarid, theDataTypeString );
    
        case 'GET_VARA'       
            % Read a contiguous subset
            values = nc_vara_get_java(jvarid,theDataTypeString,start,count);
    
        case 'GET_VARS'
        
            % Read a contiguous subset
            values = nc_vars_get_java(jvarid,theDataTypeString,start,count,stride);
    
        otherwise
        
            error ( 'SNCTOOLS_NC_VARGET:JAVA:badReadCase', ...
			    'Unhandled case, don''t know which read method to use.');  
        
    end
    
catch %#ok<CTCH>
	if close_it
    	close(jncid);
	end
    rethrow(lasterror); %#ok<LERR>
end

values = post_process(jvarid,theDataType,var_size,values);

% If we were passed a java file id, don't close it upon exit.
if close_it
	close ( jncid );
end


%--------------------------------------------------------------------------
function values = post_process(jvarid,theDataType,var_size,values)

values = handle_fill_value_java ( jvarid, theDataType, values );
values = handle_missing_value_java ( jvarid, theDataType, values );
values = handle_scaling_java ( jvarid, values );

% remove any singleton dimensions.
values = squeeze ( values );



% Permute?
if (numel(var_size) == 1) ...
        && (strcmp(theDataType,'String') || strcmp(theDataType,'char'))
    values = values';
elseif length(var_size) == 1
    values = values(:);
else
    preserve_fvd = nc_getpref('PRESERVE_FVD');
    if preserve_fvd
        pv = fliplr ( 1:length(var_size) );
        values = permute(values,pv);
    end
end                                                                                   


return








%--------------------------------------------------------------------------
function [start,count,stride] = get_indexing(jvarid,varinfo,varargin)

import ucar.nc2.dods.*     
import ucar.nc2.* 

theDimensions = jvarid.getDimensions();
nDims = theDimensions.size();


switch(numel(varargin))
    case 0
        start = zeros(1,nDims);
        count = varinfo.Size;
        stride = ones(1,nDims);
    case 2
        start = varargin{1};
        count = varargin{2};
        stride = ones(1,nDims);
    case 3
        start = varargin{1};
        count = varargin{2};
        stride = varargin{3};        
    otherwise
        error('SNCTOOLS:wrongNumberOfInputs','Wrong number of inputs.');
end

if isempty(varinfo.Dimension)
    % It's a singleton variable.
	start = 0;
	count = 1;
	return
end



% If the user had set non-positive numbers (or inf) in "count", then
% we replace them with what we need to get the
% rest of the variable.
negs = find((count<0) | isinf(count));
if any(negs)
if isempty(stride)
    count(negs) =        varinfo.Xize(negs) - start(negs);
else
    count(negs) = floor((varinfo.Size(negs) - start(negs))./stride(negs));
end
end


% Java expects in C-style order.
preserve_fvd = nc_getpref('PRESERVE_FVD');
if preserve_fvd
    start = fliplr(start);
    count = fliplr(count);
    stride = fliplr(stride);
end




%--------------------------------------------------------------------------
function values = nc_var1_get_java ( jvarid, theDataTypeString )
% NC_VAR1_GET_JAVA:  reads a scalar.

switch ( theDataTypeString )

    case 'char'
        values = jvarid.read();
        values = char ( values.toString() );

    case 'String'
        jdata = jvarid.read();
        values = snc_pp_strings(jvarid,jdata,1);
        
    case { 'double', 'float', 'int', 'short', 'byte' }
        values = jvarid.readScalarDouble();

    otherwise
        error ('SNCTOOLS:nc_varget:var1:java:unhandledDatatype', ...
            'unhandled datatype ''%s''', theDataTypeString );
    
end
    
    
return



%--------------------------------------------------------------------------
function values = nc_var_get_java ( jvarid, theDataTypeString )
% NC_VAR_GET_JAVA:  reads the entire variable

raw_data = jvarid.read();
switch(theDataTypeString)
    case 'String'
        n = jvarid.getShape();
        sz = double(n');
        values = snc_pp_strings(jvarid,raw_data,sz);

    otherwise
        
        values = copyToNDJavaArray(raw_data);
        switch ( theDataTypeString )
            case 'char'
                %
            case {'double','float','int','short','byte'}
                values = double(values);
                
            otherwise
                error ( 'SNCTOOLS:nc_varget:var:unhandledDatatype', ...
                    'unhandled datatype ''%s''', theDataTypeString );
                
        end
end
return







    

%--------------------------------------------------------------------------
function values = nc_vara_get_java(jvarid,theDataTypeString,start,count)
% NC_VARA_GET_JAVA:  reads a contiguous subset

jdata = jvarid.read(start, count);
switch ( theDataTypeString )
    case 'char'
        values = copyToNDJavaArray(jdata);
    case { 'double', 'float', 'int', 'short', 'byte' }
        values = copyToNDJavaArray(jdata);
        values = double ( values );
    case 'String'
        values = snc_pp_strings(jvarid,jdata,count);
        
    otherwise
        error('SNCTOOLS:nc_varget:vara:java:unhandledDatatype', ...
            'unhandled datatype ''%s''', theDataTypeString );
        
end
return
    







%--------------------------------------------------------------------------
function values = nc_vars_get_java(jvarid,theDataTypeString,start,count,stride)
% NC_VARS_GET_JAVA:  reads a strided subset

% Have to use the method with the section selector.
% "1:2,10,:,1:100:10"
extent = start + count.*stride-1;
section_selector = '';
for j = 1:length(start)
    section_selector = sprintf ( '%s,%d:%d:%d', ...
        section_selector, start(j), extent(j), stride(j) );
end

% Get rid of the first comma.
section_selector(1) = [];

values = jvarid.read(section_selector);
switch ( theDataTypeString )
    case 'char'
        values = copyToNDJavaArray(values);
    case 'String'
        values = snc_pp_strings(jvarid,values,count);
        
    case { 'double', 'float', 'int', 'short', 'byte' }
        values = copyToNDJavaArray(values);
        values = double ( values );
    otherwise
        error ( 'SNCTOOLS:nc_varget:vars:java', ...
            'unhandled datatype ''%s''', theDataTypeString );
    
end
    
    
return










%--------------------------------------------------------------------------
function read_method = determine_read_method(start,count,stride,varinfo)
% Determine the read method that we will instruct java to use in order to
% properly read in the netCDF data.

% If a singleton, then use GET_VAR1.  This is only because some 
% opendap-enabled mexnc clients have trouble using GET_VAR on 
% singletons.  It is annoying to have to do this, but it works just as
% well.
if isempty(varinfo.Dimension)
	read_method = 'GET_VAR1';
	return
end


if isempty(start) && isempty(count) && isempty(stride)
    read_method = 'GET_VAR';
elseif ~isempty(start) && ~isempty(count) && isempty(stride)
    read_method = 'GET_VARA';
elseif ~isempty(start) && ~isempty(count) && ~isempty(stride)
    read_method = 'GET_VARS';
else
    error ( 'SNCTOOLS:NC_VARGET:JAVA:undeterminedReadCase', ...
            'Could not determine intended read method.' );
end







%--------------------------------------------------------------------------
function values = handle_fill_value_java ( jvarid, var_type, values )
%  If there is a fill value, then replace such values with NaN.

% Handle the fill value, if any.  Change those values into NaN.
fillvalue_att = jvarid.findAttribute ( '_FillValue' );
if ~isempty(fillvalue_att)
    att_dtype = fillvalue_att.getDataType();
    if ~strcmp(char(att_dtype.toString()), char(var_type.toString()))
        warning('SNCTOOLS:nc_varget:java:fillValueMismatch', ...
            'The _FillValue attribute datatype is incorrect.  The _FillValue attribute will not be honored.');
        return
    end
    
    switch ( char ( var_type.toString() ) )
        case 'char'
            % For now, do nothing.  Does a fill value even make sense with char
            % data?  If it does, please tell me so.
            
        case { 'double', 'float', 'long', 'short', 'byte' }
            fill_value = fillvalue_att.getNumericValue().doubleValue();
            values = double(values);
            values(values==fill_value) = NaN;
            
    end
end









%--------------------------------------------------------------------------
function values = handle_missing_value_java ( jvarid, theDataType, values )
% If there is a missing value, then replace such values with NaN.

% If there is a fill value attribute, then that had precedence.  Do nothing.
fvatt = jvarid.findAttribute ( '_FillValue' );
if ~isempty(fvatt)
    return
end

%
% Handle the missing value, if any.  Change those values into NaN.
missing_value_att = jvarid.findAttribute ( 'missing_value' );
if ~isempty(missing_value_att)
    att_dtype = missing_value_att.getDataType();
    if ~strcmp(char(att_dtype.toString()), char(theDataType.toString()))
        warning('SNCTOOLS:nc_varget:java:missingValueMismatch', ...
            'The missing_value attribute datatype is incorrect.  The missing_value attribute will not be honored.');
        return
    end
    
    values = double(values);
    switch ( char ( theDataType.toString() ) )
        case 'char'
            % For now, do nothing.  Does a fill value even make sense with
            % char data?  Matlab doesn't allow for NaNs in character arrays.
            
        case { 'double', 'float', 'long', 'short', 'byte' }
            missing_value = missing_value_att.getNumericValue().doubleValue();
            values(values==missing_value) = NaN;
            
    end
end

return













%--------------------------------------------------------------------------
function values = handle_scaling_java ( jvarid, values )
% If there is a scale factor and/or  add_offset attribute, convert the data
% to double precision and apply the scaling.

% Handle the scale factor and add_offsets. 
scale_factor_att = jvarid.findAttribute ( 'scale_factor' );
add_offset_att = jvarid.findAttribute ( 'add_offset' );

% Return early if we don't have either one.
if isempty(scale_factor_att) && isempty(add_offset_att)
    return
end

if ~isempty(scale_factor_att)
    scale_factor = scale_factor_att.getNumericValue().doubleValue();
else
    scale_factor = 1.0;
end

if ~isempty(add_offset_att)
    add_offset = add_offset_att.getNumericValue().doubleValue();
else
    add_offset = 0.0;
end

values = double(values) * scale_factor + add_offset;

return











