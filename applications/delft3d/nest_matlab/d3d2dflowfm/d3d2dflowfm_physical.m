function mdu = d3d2dflowfm_physical(mdf, mdu, ~)

% d3d2dflowfm_physical : Get physical information out of the mdf structure and set in the mdu structure

mdu.Filwnd          = '';

mdu.physics.Ag      = mdf.ag;
mdu.physics.Rhomean = mdf.rhow;

if strcmpi(mdf.sub1(1),'S') mdu.physics.Salinity = true; end

if strcmpi(mdf.sub1(3),'W')
    if strcmpi(mdf.wnsvwp,'N')
        %
        % Uniform wind
        if simona2mdf_fieldandvalue(mdf,'filwnd')
            [~,name,~] = fileparts(mdf.filwnd);
            mdu.Filwnd = [name '_unstruc.wnd'];
        end
    else
        %
        % Space varying wind (to implement yet)
    end
end
