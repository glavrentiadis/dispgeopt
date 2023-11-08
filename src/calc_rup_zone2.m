function [rup_zone,rup_pt,rup_ax] = calc_rup_zone2(s_param,s_c,s_v,prj1_c,prj1_v,prj2_c,prj2_v,rup_azmth,thres)
% Determine rupture zone given far-field slip threshold
%
% Input Arguments:
%   s_param (array[6]):         profile fit parameters [s0,disp,k,c0,c1,c2,s_str]
%   s_c (array[2]):             constant offset (slip profile - horizontal)
%   s_v (array[2]):             projection vector (slip profile - horizontal)
%   prj1_c (array[3]):          constant offset (side A)
%   prj1_v (array[3]):          projection vector (side A)
%   prj2_c (array[3]):          constant offset (side A)
%   prj2_v (array[3]):          projection vector (side A)
%   rup_azmth (real):           rupture azimuth angle (m)
%   thres (real):               far-field disp threshold for rupture zone
%
% Output Arguments:
%   rup_zone (max[2*n_pt,2]):   rupture zone outline
%   rup_pt (array[2]):          rupture center point
%   rup_ax (array[2]):          rupture principal axes

%number of points for slip desensitization
n_pt = 50;

%rotate second side projection if points in oposite direction
if dot(prj1_v,prj2_v) < 0; prj2_v =-1*prj2_v; end

%default input
if nargin < 8; thres = 0.05; end
assert(thres>0 && thres<1,'Invalid range for thres')

%side threshold
thres = thres/2;

%rupture range sigmoid reference system
rz_min = s_param(1) - s_param(3) * log(1/thres    - 1);
rz_max = s_param(1) - s_param(3) * log(1/(1-thres)- 1);

%rupture profile and zone 
rup_prof      = linspace(rz_min,rz_max,n_pt)';
rup_prof(:,2) = slip_profile_fun(rup_prof,s_param(1),s_param(2),s_param(3),s_param(4),s_param(5),s_param(6),s_param(7));
rup_lims      = [rz_min;rz_max];
rup_lims(:,2) = slip_profile_fun(rup_lims,s_param(1),s_param(2),s_param(3),s_param(4),s_param(5),s_param(6),s_param(7));

%rotation angles/matrix
theta =  atan2(s_v(2),s_v(1));
rot_mat = axis_rot(-theta);

%rotate and shift to orignial reference system
rup_prof = rup_prof * rot_mat' + s_c';
rup_lims = rup_lims * rot_mat' + s_c';
% %rupture center point
% rup_pt = mean(rup_prof,1)';

%rupture zone
rz_lim1 = calc_rup_edge(rup_lims,prj1_v,prj1_c,rup_azmth);
rz_lim2 = calc_rup_edge(rup_lims,prj2_v,prj2_c,rup_azmth);
rup_zone = [rz_lim1;flipud(rz_lim2);rz_lim1(1,:)];
%rupture center point
rup_pt = mean(rup_zone(1:end-1,:),1)';

%rupture zone, principal axes
rup_ax = [rz_max-rz_min,0;0,s_param(2)]; rup_ax =  sqrt(2)/norm(rup_ax) * rup_ax;
rup_ax = rot_mat * rup_ax;

end

function rup_lim = calc_rup_edge(rup_lim,prj_v,prj_c,rup_azmth)
%compute rupture edge on projection line

%horizontal projection and shift
prj_v = prj_v(1:2)/norm(prj_v);
prj_c = prj_c(1:2);

%perpendicular axis
if nargin < 4
    prj_u = [-prj_v(2);prj_v(1)];
else
    rup_theta = deg2rad(90 - rup_azmth);
    prj_u = [cos(rup_theta);sin(rup_theta)];
end

%projection matrix inverse
prj_inv = inv([prj_v,prj_u]);

%along projection distance for each side
t = prj_inv(1,:)*(rup_lim'-prj_c);

%rupture limits on pojection lineaperture points
rup_lim = (t.*prj_v + prj_c)';

end