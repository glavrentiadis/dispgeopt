function [s1_orj_idx,s2_orj_idx,dist_mat] = find_side_origin(side1_data,side2_data)
%find_side_origin Find side origins based on minimum distance

%initialize distance matrix
dist_mat = nan(size(side1_data,1), size(side2_data,1));

%compute distance between all points
for j = 1:size(side1_data,1)
    dist_mat(j,:) = vecnorm(side1_data(j,1:3) - side2_data(:,1:3), 2,2);
end

%find origin of each side base on minimum distance
[~, orj_idx] = min(dist_mat(:));
[s1_orj_idx,s2_orj_idx] = ind2sub(size(dist_mat), orj_idx);

end