function nesthd_wrihyd_dflowfmbc(fileOut,bnd,nfs_inf,bndval,add_inf)

% wrihyd_dflowfmbc  : writes hydrodynamic bc to a DFLOWFM bc file
%                     first beta version
%                     for now, only water level boundaries
%                              TK: 18/03/2019  Constituents added
%
%% Set some general parameters
no_pnt        = length(bnd.DATA);
no_times      = length(bndval);
lstci         = -1;
if length(size(bndval(1).value)) == 3 lstci = nfs_inf.lstci; end

itdate        = datestr(nfs_inf.itdate,'yyyy-mm-dd HH:MM:SS');
[path,~,~]    = fileparts(fileOut);
if isempty(path) path = '.'; end

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
        
        if l_act >= 1
            %% Header information
            ext_force(l_act).Chapter          = 'forcing';
            ext_force(l_act).Keyword.Name {1} = 'Name';
            ext_force(l_act).Keyword.Value{1} = bnd.Name{i_pnt};
            ext_force(l_act).Keyword.Name {2} = 'Function';
            ext_force(l_act).Keyword.Value{2} = 'timeseries';
            ext_force(l_act).Keyword.Name {3} = 'Time-interpolation';
            ext_force(l_act).Keyword.Value{3} = 'linear';
            ext_force(l_act).Keyword.Name {4} = 'Quantity';
            ext_force(l_act).Keyword.Value{4} = 'time';
            ext_force(l_act).Keyword.Name {5} = 'Unit';
            ext_force(l_act).Keyword.Value{5} = ['minutes since ' itdate];
            ext_force(l_act).Keyword.Name {6} = 'Quantity';
            ext_force(l_act).Keyword.Value{6} = [quantity 'bnd'];
            ext_force(l_act).Keyword.Name {7} = 'Unit';
            ext_force(l_act).Keyword.Value{7} = 'kg/m3';
            if strcmpi(quantity,'waterlevel'           ) ext_force(l_act).Keyword.Value{7} = 'm'  ; end
            if strcmpi(quantity,'uxuyadvectionvelocity') ext_force(l_act).Keyword.Value{7} = 'm/s'; end
            if strcmpi(quantity,'salinity'             ) ext_force(l_act).Keyword.Value{7} = 'psu'; end
            if strcmpi(quantity,'temperature'          ) ext_force(l_act).Keyword.Value{7} = 'oC' ; end
            
            %% Series information
            for i_time = 1: no_times
                ext_force(l_act).values{i_time,1} = (nfs_inf.times(i_time) - nfs_inf.itdate)*1440. + add_inf.timeZone*60.;    % minutes!
                ext_force(l_act).values(i_time,2) = {bndval(i_time).value(i_pnt,1,l)};
                if lower(bnd.DATA(i_pnt).bndtype) == 'p' || lower(bnd.DATA(i_pnt).bndtype) == 'x'
                    ext_force(l).values(i_time,3) = {bndval(i_time).value(i_pnt,2,1)};
                end
            end
        end
    end
    
    %% Write the series for induvidual support
    fileTmp = [path filesep 'tmp_' num2str(i_pnt,'%4.4i') '.bc'];
    dflowfm_io_extfile('write',fileTmp,'ext_force',ext_force,'type','ini');
end

%% Merge individual files
copyfile ([path filesep 'tmp_' num2str(1,'%4.4i') '.bc'],fileOut);

for i_pnt = 2: no_pnt
    tmp_series = [path filesep 'tmp_' num2str(i_pnt,'%4.4i') '.bc'];
    fid1       = fopen(fileOut,'a');
    fid2       = fopen(tmp_series,'r');
    while ~feof(fid2)
        tline = fgetl(fid2);
        fprintf(fid1,'%s\n',tline);
    end
    fclose(fid2);
    fclose(fid1);
end

delete([path filesep 'tmp_*.bc']);
