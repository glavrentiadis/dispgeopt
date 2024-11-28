function [i_slc] = select_feature_linear(side_data, prj_params, flag_out_lgi, ref_coor)
%select_feature_linear Select Points Based on Linear Feature Conditions
%
% Input arguments:
%   side_data:          displacement data
%   prj_params:         projection parameters
%       prj_params(1):     minimum number of points
%       prj_params(2):     minimum feature length
%       prj_params(3):     minimum pearson linear correlation coefficient
%   flag_out_lgi:       flag for output type 
%                          false (default): return index array
%                          true:            return logic array
%   ref_coor:           reference point coordinates
% Output arguments:
%   i_slc:              inidces fo selected points

%default return opton
if nargin < 3; flag_out_lgi=False; end
if (nargin > 3 && ~all(isnan(ref_coor))); flag_det = true;
else;                                     flag_det = false;
end

%pick reference point
if flag_det %deterministic case (find closest point)
    ref_coor  = reshape(ref_coor,[1,length(ref_coor)]);
    [~,i_ref] = min(vecnorm(side_data(:,1:2) - ref_coor,2,2));
else        %probabilistic case (randomly sample reference point)
    i_ref = randi(size(side_data,1));
end
ref_pt = side_data(i_ref,:);

%identify candidate points
i_cand = find(side_data(:,6) >= ref_pt(6));

%feature properties
[f_len, f_corr] = feature_parameters(side_data(i_cand,:));

%if conditions unmet uselect furthest point
while ~all([length(i_cand) > prj_params(1), f_len >= prj_params(2), f_corr >= prj_params(3)])
    %point to remove from feature to remove
    [~,i2rm] = max(side_data(i_cand,6));
    i_cand(i2rm) = [];

    %exit loop if empty candidate list
    if isempty(i_cand); break; end
    
    %update feature properties
    [f_len, f_corr] = feature_parameters(side_data(i_cand,:));
end

%convert to logic array
if flag_out_lgi
    i_slc = false(size(side_data,1));
    i_slc(i_cand) = true;
else
    i_slc = i_cand;
end

end

function [feat_len,feat_corr] = feature_parameters(feature_data)

    %feature lenght
    feat_len  = max(feature_data(:,6)) - min(feature_data(:,6));

    %feature correlation
    feat_corr = abs( corr(feature_data(:,1), feature_data(:,2)) );
end

