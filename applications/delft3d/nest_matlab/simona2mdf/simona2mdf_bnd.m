function mdf = simona2mdf_bnd(S,mdf,name_mdf)

% simona2mdf_bnd : gets all boundary related information out of the parsed siminp (S)

% Start with the boundary definition!

bnd = simona2mdf_bnddef(S);

% If open boundaries exist, write boundary definition and retrieve
% harmonic data, time series data and astronomical data respectively

if ~isempty(bnd)
    mdf.filbnd = [name_mdf '.bnd'];
    delft3d_io_bnd('write',mdf.filbnd,bnd);
    mdf.filbnd = simona2mdf_rmpath(mdf.filbnd);

    bch = simona2mdf_bch(S,bnd);
    if ~isempty(bch)
        mdf.filbch = [name_mdf '.bch'];
        delft3d_io_bch('write',mdf.filbch,bch);
        mdf.filbch = simona2mdf_rmpath(mdf.filbch);
    end

    bct = simona2mdf_bct(S,bnd,mdf);
    if ~isempty(bct)
        mdf.filbct = [name_mdf '.bct'];
        ddb_bct_io('write',mdf.filbct,bct);
        mdf.filbct = simona2mdf_rmpath(mdf.filbct);
    end

    bcq = simona2mdf_bcq(S,bnd);
    if ~isempty(bcq)
        mdf.filbcq = [name_mdf '.bcq'];
        ddb_io_bct('write',mdf.filbcq,bcq);
        mdf.filbcq = simona2mdf_rmpath(mdf.filbcq);
    end

    bca = simona2mdf_bca(S,bnd);
    if ~isempty(bca)
        mdf.filana = [name_mdf '.bca'];
        delft3d_io_bca('write',mdf.filana,bca);
        mdf.filana = simona2mdf_rmpath(mdf.filana);
    end
end



