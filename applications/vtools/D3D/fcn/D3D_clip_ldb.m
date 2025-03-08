function ldb = D3D_clip_ldb(ldb,xc,yc,d); 
% D3D_clip_ldb - clip ldb around xc, yc with a distance d
    ldb(~(ldb(:,2) > yc - d & ldb(:,2) < yc + d & ldb(:,1) > xc - d & ldb(:,1) < xc + d),:) = NaN;
    idxnan = find(isnan(ldb(:,1)));
    idxnandrop = find(diff(idxnan) == 1);
    ldb(idxnan(idxnandrop),:) = [];
end