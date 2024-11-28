function [param,c_horiz,v_horiz,s_prof,s_pt] = determine_proj_sides(disp_data,flag_fit,lambda)
% Fits slip_profile analytical function to raw data using average projection 
%   
% Input Arguments:
%   disp_data (mat[n_pt,3 or 5]): coordinates and uncertainty of profile's points
%   prj_c (array[3]):            constant offset (side A)
%   prj_v (array[3]):            projection vector (side A)
%   flag_fit:                     flag for fitting alogrithm
%                                   1: least squares fit
%                                   2: regularized regression
%   lambda (double):              regularization penalty
%
% Output Arguments:
%   param (array[5]):             profile fit parameters [s0,disp,k,c0,c1,c2]
%   c_horiz (array[2]):           constant offset (slip profile - horizontal)
%   v_horiz (array[2]):           projection vector (slip profile - horizontal)
%   s_prof (mat[100,2]):          fitted slip profile
%   s_pt (array[2]):              fitted rupture point

%default input
if nargin < 6; side1_idx = nan; end
if nargin < 7; side2_idx = nan; end
if nargin < 8; flag_fit = 1;    end
if nargin < 9; lambda   = 1e-3; end

%compute original principal projection (entire profile)
[prj_c,prj_v] = projection_fit(disp_data(:,1:3)); 

%horizontal projection component
c_horiz = prj_c(1:2);
v_horiz = prj_v(1:2);
v_horiz = v_horiz/norm(v_horiz);
%profile shift
disp_data_h = disp_data(:,1:2) - c_horiz';

%rotation angles/matrix
theta =  atan2(v_horiz(2),v_horiz(1));
rot_mat = axis_rot(theta);

%profile rotation
disp_data_h = disp_data_h * rot_mat';
%profile width
d_min = min(disp_data_h(:,2));
d_max = max(disp_data_h(:,2));
d_width = d_max - d_min;
%disp values start and end of profile
[s_str,j_s] = min(disp_data_h(:,1));
d_str = disp_data_h(j_s,2);
[s_end,j_e] = max(disp_data_h(:,1));
d_end = disp_data_h(j_e,2);

%profile function
% parameter order: s0,disp,k,c0,c1,c2
fun_prof = @(param,xdata) slip_profile_fun(xdata,param(1),param(2),param(3),param(4),param(5),param(6),s_str);

%seed values, lower and upper bounds
dw_scl = 1;
param_0  = [0.0,                    d_end-d_str,          1,   d_str,  0,   0];
param_lb = [min(disp_data_h(:,1)), -dw_scl*d_width,       0.1, d_min, -1,  -1];
param_ub = [max(disp_data_h(:,1)), +dw_scl*d_width,       inf, d_max,  1,  +1];

%fit profile
switch flag_fit
    case 1
        %least squares fit
        lsq_opt = optimoptions('lsqcurvefit','Display','off');
        param = lsqcurvefit(fun_prof,param_0,disp_data_h(:,1),disp_data_h(:,2),param_lb,param_ub,[],[],[],[],[],lsq_opt);
    case 2
        %objective function
        fun_obj = @(param) norm(disp_data_h(:,2) - fun_prof(param,disp_data_h(:,1))) - lambda*param(3)^2 ;
        %constrained optimization
        fmin_opt = optimoptions('fmincon','Display','off');
        param = fmincon(fun_obj,param_0,[],[],[],[],param_lb,param_ub,[],fmin_opt);
end
param(7) = s_str; 

%compute fit profile
s_prof = linspace(min(disp_data_h(:,1)),max(disp_data_h(:,1)))';
s_prof(:,2) = fun_prof(param,s_prof);
%rotate and shift to orignial reference system
s_prof = s_prof / rot_mat' + c_horiz';

%central rupture point
s_pt = [param(1),fun_prof(param,param(1))];
%rotate and shift to orignial reference system
s_pt = s_pt / rot_mat' + c_horiz';

end