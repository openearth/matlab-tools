function test_nc_attget_neg(ncfile)

v = version('-release');
switch(v)
    case { '14','2006a','2006b'}
        fprintf('No negative tests run on %s...  ',v);
        return
end
test_retrieveNonExistingAttribute ( ncfile );

return;







%--------------------------------------------------------------------------
function test_retrieveNonExistingAttribute ( ncfile )

global ignore_eids;

try
	nc_attget ( ncfile, 'z_double', 'test_double_att' );
catch me
    if ignore_eids
        return
    end
    switch(me.identifier)
        case { 'MATLAB:netcdf:inqAtt:attributeNotFound', ...
                'MATLAB:netcdf:inqAtt:enotatt:attributeNotFound', ...
                'SNCTOOLS:NC_ATTGET:MEXNC:INQ_ATTTYPE', ...
                'SNCTOOLS:attget:hdf4:findattr', ...
                'SNCTOOLS:attget:java:attributeNotFound'}
            return
        otherwise
            rethrow(me);
    end
                
end
error('failed');










