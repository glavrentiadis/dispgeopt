function [i_slc] = select_feature_window(side_data, prjwin_params, flag_out_lgi, ref_coor)
%select_feature_window Select Points Based on Feature Window Conditions
%
% Input arguments:
%   side_data:                  displacement data
%   prjwin_params:              projection parameters
%       prjwin_params(1):           mean window size
%       prjwin_params(2):           sd of window size
%   flag_out_lgi (optional):    flag for output type 
%                                   false (default): return index array
%                                   true:            return logic array
%   ref_coor (optional):        reference point coordinates
% Output arguments:
%   i_slc:                      inidces fo selected points

%default return opton
if nargin < 3; flag_out_lgi=False; end
if nargin > 3 && ~isan(ref_coor); flag_det = True;
else;                             flag_det = False;
end

%pick reference point
if flag_det %deterministic case (find closest point)
    [~,i_ref] = min(vecnorm(side_data(:,1:2) - ref_coor,2,2));
    %window mid-point
    w_mt = side_data(i_ref,6);
else        %probabilistic case (randomly sample reference point)
    wt = rand(); %weighting
    %window mid-point
    w_mt = (1-wt)*min(side_data(:,6)) + wt * max(side_data(:,6));
end

%window size
if prjwin_params(2) < 1e-6
    wsize = prjwin_params(1);
else
    wsize = abs(normrnd(prjwin_params(1),prjwin_params(2)));
    wsize = max(wsize, 1);
end

%window position (start, end)
w_s = w_mt - wsize/2;
w_e = w_mt + wsize/2;

%selected points
i_slc = and(w_s <= side_data(:,6), side_data(:,6) <= w_e);

%convert to logic array
if ~flag_out_lgi
    i_slc = find(i_slc);
end

end


