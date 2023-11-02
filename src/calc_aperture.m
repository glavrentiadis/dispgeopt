function [aper_width,aper1_pt,aper2_pt] = calc_aperture(prj1_data,prj2_data,prj_v,prj_c,rup_azmth)
% compute aperture width on pjection direction 

%projection points of two sides
prj1_data = prj1_data(:,1:2);
prj2_data = prj2_data(:,1:2);

%horizontal projection and shift
prj_v = prj_v(1:2)/norm(prj_v);
prj_c = prj_c(1:2);

%perpendicular axis
if nargin < 5
    prj_u = [-prj_v(2);prj_v(1)];
else
    rup_theta = deg2rad(90 - rup_azmth);
    prj_u = [cos(rup_theta);sin(rup_theta)];
end

%projection matrix inverse
prj_inv = inv([prj_v,prj_u]);

%along projection distance for each side
t1_array = prj_inv(1,:)*(prj1_data'-prj_c);
t2_array = prj_inv(1,:)*(prj2_data'-prj_c);

%find aperture points
if min(t2_array) > max(t1_array)
    [t1, i_t1] = max(t1_array);
    [t2, i_t2] = min(t2_array);
elseif min(t1_array) > max(t2_array)
    [t1, i_t1] = min(t1_array);
    [t2, i_t2] = max(t2_array);
end

%aperture width
aper_width = abs(t1-t2);
%aperture points
aper1_pt = t1*prj_v + prj_c;
aper2_pt = t2*prj_v + prj_c;

end