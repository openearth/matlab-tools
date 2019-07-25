function nesthd_wrihyd_dflowfmbc(fileOut,bnd,nfs_inf,bndval,add_inf)

% wrihyd_dflowfmbc  : writes hydrodynamic bc to a DFLOWFM bc file
%                     first beta version
%                     for now, only water level boundaries
%                              TK: 18/03/2019  Constituents added
%
%% Set some general parameters
no_pnt        = length(bnd.DATA);
no_times      = length(bndval);
no_layers     = nfs_inf.nolay;
thick         = nfs_inf.thick;

lstci         = -1;                                                        % Use lstci = -1 to incicate hydrodynamic bc (not very elegant)
if length(size(bndval(1).value)) == 3 lstci = nfs_inf.lstci; end

itdate        = datestr(nfs_inf.itdate,'yyyy-mm-dd HH:MM:SS');
[path,~,~]    = fileparts(fileOut);
if isempty(path) path = '.'; end

%% Switch orientation if overall model is delft3D or Waqua
if ~strcmpi(nfs_inf.from,'dfm')
    [bndval,thick] = nesthd_flipori(bndval,thick);
end

%% Determine vertical positions
pos(1)        = 0.5*thick(1);
for i_lay = 2: no_layers
    pos(i_lay) = pos(i_lay - 1) + 0.5*(thick(i_lay - 1) + thick(i_lay));
end

%% cycle over boundary points
for i_pnt = 1: no_pnt
    ext_force = [];
    l_act     =  0;
    for l = 1:max(1,lstci)
        if lstci >= 1
            if add_inf.genconc(l)

                %% Name of the constituent
                quantity = nfs_inf.namcon{l};
                l_act    = l_act + 1;
            end
        elseif lstci == -1

            %% Type of hydrodynnamic boundary
            if strcmpi(bnd.DATA(i_pnt).bndtype,'z')  quantity = 'waterlevel'; end
            if strcmpi(bnd.DATA(i_pnt).bndtype,'p')  quantity = 'uxuyadvectionvelocity'; end
            l_act = 1;
        end

        if lstci == -1 || (lstci >=1 && add_inf.genconc(l))
            %% Header information
            ext_force(l_act).Chapter                  = 'forcing';
            ext_force(l_act).Keyword.Name {1}         = 'Name';
            ext_force(l_act).Keyword.Value{1}         = bnd.Name{i_pnt};
            ext_force(l_act).Keyword.Name {end+1}     = 'Function';
            if strcmpi(quantity,'waterlevel') ||  strcmpi(add_inf.profile,'uniform')
                dav                                   = true;
                ext_force(l_act).Keyword.Value{end+1} = 'timeseries';
            elseif strcmpi(add_inf.profile,'3d-profile')
                dav                                   = false;
                ext_force(l_act).Keyword.Value{end+1} = 't3d';
            end

            ext_force(l_act).Keyword.Name {end+1}     = 'Time-interpolation';
            ext_force(l_act).Keyword.Value{end+1}     = 'linear';

            if  strcmpi(quantity,'waterlevel') &&  isfield(add_inf,'a0_dfm')
                ext_force(l_act).Keyword.Name {end+1} = 'Offset';
                ext_force(l_act).Keyword.Value{end+1} = num2str(add_inf.a0_dfm,'%12.3f');
            end

            if ~dav
                if strcmpi(nfs_inf.layer_model,'sigma-model')
                    ext_force(l_act).Keyword.Name {end+1} = 'Vertical position type         ';
                    ext_force(l_act).Keyword.Value{end+1} = 'percentage from bed';
                    format                                = repmat('%6.3f ',1,no_layers);
                    ext_force(l_act).Keyword.Name {end+1} = 'Vertical position specification';
                    ext_force(l_act).Keyword.Value{end+1} = sprintf(format,pos);
                else
                    error('Fixed or mixed layers not supported yet')
                end
            end

            ext_force(l_act).Keyword.Name {end+1} = 'Quantity';
            ext_force(l_act).Keyword.Value{end+1} = 'time';
            ext_force(l_act).Keyword.Name {end+1} = 'Unit';
            ext_force(l_act).Keyword.Value{end+1} = ['minutes since ' itdate];
            if dav
                ext_force(l_act).Keyword.Name {end+1} = 'Quantity';
                ext_force(l_act).Keyword.Value{end+1} = [quantity 'bnd'];
                ext_force(l_act).Keyword.Name {end+1} = 'Unit';
                ext_force(l_act).Keyword.Value{end+1} = 'kg/m3';
                if strcmpi(quantity,'waterlevel'           ) ext_force(l_act).Keyword.Value{end} = 'm'  ; end
                if strcmpi(quantity,'uxuyadvectionvelocity') ext_force(l_act).Keyword.Value{end} = 'm/s'; end
                if strcmpi(quantity,'salinity'             ) ext_force(l_act).Keyword.Value{end} = 'psu'; end
                if strcmpi(quantity,'temperature'          ) ext_force(l_act).Keyword.Value{end} = 'oC' ; end
            else
                for i_lay = 1: no_layers
                    ext_force(l_act).Keyword.Name {end+1} = 'Quantity';
                    ext_force(l_act).Keyword.Value{end+1} = [quantity 'bnd'];
                    ext_force(l_act).Keyword.Name {end+1} = 'Unit';
                    ext_force(l_act).Keyword.Value{end+1} = 'kg/m3';
                    if strcmpi(quantity,'waterlevel'           ) ext_force(l_act).Keyword.Value{end} = 'm'  ; end
                    if strcmpi(quantity,'uxuyadvectionvelocity') ext_force(l_act).Keyword.Value{end} = 'm/s'; end
                    if strcmpi(quantity,'salinity'             ) ext_force(l_act).Keyword.Value{end} = 'psu'; end
                    if strcmpi(quantity,'temperature'          ) ext_force(l_act).Keyword.Value{end} = 'oC' ; end
                    ext_force(l_act).Keyword.Name {end+1} = 'Vertical position';
                    ext_force(l_act).Keyword.Value{end+1} = num2str(i_lay,'%3i');
                end
            end

            %% Series information
            for i_time = 1: no_times
                ext_force(l_act).values{i_time,1} = (nfs_inf.times(i_time) - nfs_inf.itdate)*1440. + add_inf.timeZone*60.;    % minutes!
                if dav
                    ext_force(l_act).values(i_time,2) = {bndval(i_time).value(i_pnt,1,l)};
                    if lower(bnd.DATA(i_pnt).bndtype) == 'p' || lower(bnd.DATA(i_pnt).bndtype) == 'x'
                        ext_force(l).values(i_time,3) = {bndval(i_time).value(i_pnt,2,1)};
                    end
                else
                    for i_lay = 1: no_layers
                        ext_force(l_act).values(i_time,i_lay + 1) = {bndval(i_time).value(i_pnt,i_lay,l)};
                    end
                end
            end
        end
    end

    %% Write the series for induvidual support points, first time open file, after that append
    if i_pnt == 1
        dflowfm_io_extfile('write',fileOut,'ext_force',ext_force,'type','ini');
    else
        dflowfm_io_extfile('write',fileOut,'ext_force',ext_force,'type','ini','first',false);
    end
end
