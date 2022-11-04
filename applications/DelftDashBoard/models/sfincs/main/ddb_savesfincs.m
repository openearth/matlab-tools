function ddb_savesfincs(opt)

switch lower(opt)
    case{'save'}
        
        ddb_sfincs_save_input;
                
    case{'saveall'}

        % Attribute files
        ddb_sfincs_save_attribute_files;
        
        % sfincs.inp
        ddb_sfincs_save_input;
        
end
