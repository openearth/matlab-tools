function varargout=dflowfm_io_bnd(cmd,fname,varargin)

%  DFLOWFM_IO_bnd : reads or writes pli files
%% Switch read/write

switch lower(cmd)

    %% Extract boundary information from the pli's
    case 'read'
        type_bnd = nesthd_det_filetype(fname);
        switch type_bnd
            case 'pli'
                filelist{1} = fname;
                bndtype{1}  = 'z';
            otherwise

                %% Create list of pli files out of the ext file or the mdu file
                [path,~,~] = fileparts(fname);
                switch type_bnd
                    case 'mdu'
                        mdu = dflowfm_io_mdu(fname);
                        fname = [path filesep mdu.external_forcing.ExtForceFile];
                end

                ext     = dflowfm_io_extfile('read',fname);
                i_file  = 0;
                for i_ext = 1: length(ext)
                    if ~isempty(strfind(ext(i_ext).quantity,'bnd'        )) && ...
                        isempty(strfind(ext(i_ext).quantity,'salinity'   )) && ...
                        isempty(strfind(ext(i_ext).quantity,'temperature'))
                        i_file = i_file + 1;
                        if ~isempty(path)
                            filelist{i_file} = [path filesep ext(i_ext).filename];
                        else
                            filelist{i_file} = [ext(i_ext).filename];
                        end
                        
                        if ~isempty(strfind(ext(i_ext).quantity,'waterlevel'))
                           bndtype{i_file} = 'z';
                        elseif ~isempty(strfind(ext(i_ext).quantity,'velocity')) && isempty(strfind(ext(i_ext).quantity,'normalvelocity'))
                           bndtype{i_file} = 'c';
                        elseif ~isempty(strfind(ext(i_ext).quantity,'neumann'))
                           bndtype{i_file} = 'n';
                        elseif ~isempty(strfind(ext(i_ext).quantity,'uxuyadvectionvelocitybnd '))
                           bndtype{i_file} = 'p';
                        end
                    end
                end
        end

        %% Get the name of the pli and the (x,y) coordinate pairs
        no_bnd = 0;
        for i_file = 1: length(filelist)
            [~,name,~] = fileparts(filelist{i_file});
            tmp = dflowfm_io_xydata('read',filelist{i_file});
            X        = cell2mat(tmp.DATA(:,1));
            Y        = cell2mat(tmp.DATA(:,2));
            for i_pnt = 1: length(X)
               no_bnd            = no_bnd + 1;
               out.DATA(no_bnd).X        = X(i_pnt);
               out.DATA(no_bnd).Y        = Y(i_pnt);
               out.DATA(no_bnd).bndtype  = bndtype{i_file};
               out.DATA(no_bnd).datatype = 't';
               out.Name{no_bnd}          = [name '_' num2str(i_pnt,'%4.4i')];
            end
        end

        varargout = {out};

    case 'write'

        %% To implement
end

