function [int_s] = intersect_projection(prj_c,prj_v,rup_xy,rup_azmth)
% Compute rupture-projection intersection
%
% Input Arguments:
%   prj_c (array[3]): projection line pivot point
%   prj_v (array[3]): projection lineve vector
%   rup_xy (array[3]): rupture pivot point
%   rup_azmth (real): rupture azimuth angle (m)
% 
% Output Arguments:
%   int_s (array[3]): intersection point rupture-projection

%counter-clockwise rupture angle with -axis
rup_theta = 90 - rup_azmth;

%convert angle to radians
rup_theta = deg2rad(rup_theta);

%horizontal rupture vector
rup_v = [cos(rup_theta);sin(rup_theta)];

%projection-rupture intersection (2d space)
[~,prj_t] = intersect_lines2d(prj_c(1:2),prj_v(1:2),rup_xy,rup_v);

%intersection point
int_s = prj_c + prj_t*prj_v;

end