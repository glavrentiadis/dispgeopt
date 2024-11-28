function [feature_loc,figid] = select_feature_loc(data, prj_data, polygon_data, side_name, side_color)
%UI for selecting feature location
%
% Input Arguments:
%   data           (mat[n_all,5]):  geolocated points
%   prj_data       (mat[n_prj,5]):  master projection data
%   polygon_data   (mat[n_pol,2]):  selection polygon
%   side_name      (string):        name for side to select points
%   side_color     (string):        color for selected points
%
% Output Arguments:
%   feature_loc    (array[2]):      feature location
%   figid          (handle):        figure handle showing selected feature

%default input
if nargin < 4; side_name=''; 
else           side_name = [' for side ',side_name];
end
if nargin < 5; side_color = 'k'; end

%plot rupture data
figid = plot_profile(data);
%selected points
[figid, hl1] = plot_points_select(prj_data,figid,side_color);
%selection polygon
hl2 = plot(polygon_data(:,1),polygon_data(:,2),'k--o');

%feature location prompt
title({'Select feature closest location',side_name})
sprintf('Select feature closest location%s (left-click to select).',side_name);
feature_loc = zeros(2,1);
[feature_loc(1), feature_loc(2)] = ginput(1);

%plot rupture location
hl3 = plot(feature_loc(1),feature_loc(2),'o','Color',side_color,'MarkerFaceColor',side_color,'MarkerSize',8);
legend([hl3],{'Feature Location'});

end