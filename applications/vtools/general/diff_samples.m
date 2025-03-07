function [dxy, xyz_diff] = diff_samples(xyz1, xyz2); 
% diff_samples compares xyz sets 
%
% by taking the difference of the nearest sample point 
% the last column contains the distance to the nearest point in xyz1
% 
% the first two colums are assumed to have x and y coordinates
assert(size(xyz1,2) == size(xyz2,2),...
    'number of columns in xyz1 and xyz2 are different')

Fidx = scatteredInterpolant(xyz1(:,1),xyz1(:,2),[1:size(xyz1,1)].','nearest');
idx1_new = int32(Fidx(xyz2(:,1),xyz2(:,2))); 
xyz_diff = xyz2 - xyz1(idx1_new,:); 
dxy = hypot(xyz2(:,1) - xyz1(idx1_new,1), xyz2(:,2) - xyz1(idx1_new,2)); 
end
