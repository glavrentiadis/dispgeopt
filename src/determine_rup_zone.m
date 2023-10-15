function [rup_zone] = determine_rup_zone(s_param,s_c,s_v,thres)
% Determine rupture zone given far-field slip threshold
%
% Input Arguments:
%   s_param (array[5]):     profile fit parameters [s0,disp,k,c0,c1,c2]
%   s_c (array[2]):         constant offset (slip profile - horizontal)
%   s_v (array[2]):         projection vector (slip profile - horizontal)
%   thres (real):           far-field disp threshold for rupture zone
%
% Output Arguments:
%   rup_zone (max[2*n_pt,2]): rupture zone outline

%number of points for slip desensitization
n_pt = 50;

%default input
if nargin < 4; thres = 0.05; end
assert(thres>0 && thres<1,'Invalid range for thres')

%side threshold
thres = thres/2;

%rupture range sigmoid reference system
rz_min = s_param(1) - s_param(3) * log(1/thres    - 1);
rz_max = s_param(1) - s_param(3) * log(1/(1-thres)- 1);

%rupture zone lower and upper limits
rz_ll = linspace(rz_min,rz_max,n_pt)';
rz_ul = linspace(rz_max,rz_min,n_pt)';
rz_ll(:,2) = slip_profile(rz_ll,s_param(1),0,s_param(3),s_param(4),           s_param(5),s_param(6));
rz_ul(:,2) = slip_profile(rz_ul,s_param(1),0,s_param(3),s_param(4)+s_param(2),s_param(5),s_param(6));

%rupture zone outline
rup_zone = [rz_ll;rz_ul;rz_ll(1,:)];

%rotation angles/matrix
theta   = acos( dot(s_v,[1,0]) );
rot_mat = axis_rot(-theta);

%rotate and shift to orignial reference system
rup_zone = rup_zone * rot_mat + s_c';

end