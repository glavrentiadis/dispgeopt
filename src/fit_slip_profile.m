function [param,c_horiz,v_horiz,s_prof] = fit_slip_profile(disp_data,prj1_c,prj1_v,prj2_c,prj2_v,side1_idx,side2_idx,flag_fit,lambda)
% Fits raw profile to slip_profile analytical function 
%   
% Input Arguments:
%   disp_data (mat[n_pt,3 or 5]): coordinates and uncertainty of profile's points
%   prj1_c (array[3]):            constant offset (side A)
%   prj1_v (array[3]):            projection vector (side A)
%   prj2_c (array[3]):            constant offset (side A)
%   prj2_v (array[3]):            projection vector (side A)
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

%default input
if nargin < 6; side1_idx = nan; end
if nargin < 7; side2_idx = nan; end
if nargin < 8; flag_fit = 1;    end
if nargin < 9; lambda   = 1e-3; end

%aveage projection
prj_c = mean([prj1_c,prj2_c],2);
prj_v = mean([prj1_v,prj2_v],2); 
prj_v = prj_v/norm(prj_v);

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

%prifle function
% parameter order: s0,disp,k,c0,c1,c2
fun_prof = @(param,xdata) slip_profile(xdata,param(1),param(2),param(3),param(4),param(5),param(6));

%seed values, lower and upper bounds
param_0  = [0,                         disp_data_h(end,2),  1,   0,   0,   0];
param_lb = [min(disp_data_h(:,1)), min(disp_data_h(:,2)),  0,  -inf,-1,  -1];
param_ub = [max(disp_data_h(:,1)), max(disp_data_h(:,2)),  inf,+inf, 1,  +1];
if ~any(isnan([side1_idx;side2_idx]))
    min_side1 = min( disp_data_h(side1_idx,1) );
    max_side1 = max( disp_data_h(side1_idx,1) ); 
    min_side2 = min( disp_data_h(side2_idx,1) );
    max_side2 = max( disp_data_h(side2_idx,1) );
    if min_side2 - max_side1 > 0
        param_lb(1) = max_side1;
        param_ub(1) = min_side2;
    elseif  min_side1 - max_side2 > 0
        param_lb(1) = max_side2;
        param_ub(1) = min_side1;
    end
end

%fit profile
switch flag_fit
    case 1
        %least squares fit
        lsq_opt = optimoptions('lsqcurvefit','Display','off');
        param1 = lsqcurvefit(fun_prof,param_0,disp_data_h(:,1),disp_data_h(:,2),param_lb,param_ub,[],[],[],[],[],lsq_opt);
    case 2
        %objective function
        fun_obj = @(param) norm(disp_data_h(:,2) - fun_prof(param,disp_data_h(:,1))) - lambda*param(3)^2 ;
        %constrained optimization
        fmin_opt = optimoptions('fmincon','Display','off');
        param = fmincon(fun_obj,param_0,[],[],[],[],param_lb,param_ub,[],fmin_opt);
end

%compute fit profile
s_prof = linspace(min(disp_data_h(:,1)),max(disp_data_h(:,1)))';
s_prof(:,2) = fun_prof(param,s_prof);
%rotate and shift to orignial reference system
s_prof = s_prof / rot_mat' + c_horiz';


end