function [param,c_horiz,v_horiz,s_prof] = fit_slip_profile(disp_data,prj1_c,prj1_v,prj2_c,prj2_v)
% Fits raw profile to slip_profile analytical function 
%   
% Input Arguments:
%   disp_data (mat[n_pt,3 or 5]): coordinates and uncertainty of profile's points
%   prj1_c (array[3]):            constant offset (side A)
%   prj1_v (array[3]):            projection vector (side A)
%   prj2_c (array[3]):            constant offset (side A)
%   prj2_v (array[3]):            projection vector (side A)
%
% Output Arguments:
%   param (array[5]):             profile fit parameters [s0,disp,k,c0,c1,c2]
%   c_horiz (array[2]):           constant offset (slip profile - horizontal)
%   v_horiz (array[2]):           projection vector (slip profile - horizontal)
%   s_prof (mat[100,2]):          fitted slip profile

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
theta   = acos( dot(v_horiz,[1,0]) );
rot_mat = axis_rot(theta);

%profile rotation
disp_data_h = disp_data_h * rot_mat;

%prifle function
% parameter order: s0,disp,k,c0,c1,c2
fun_prof = @(param,xdata) slip_profile(xdata,param(1),param(2),param(3),param(4),param(5),param(6));

%seed values, lower and upper bounds
param0 = [0,disp_data_h(end,2),5,0,0,0];

%fit profile
lsq_opt = optimoptions('lsqcurvefit','Display','off');
param = lsqcurvefit(fun_prof,param0,disp_data_h(:,1),disp_data_h(:,2));

%compute fit profile
s_prof = linspace(min(disp_data_h(:,1)),max(disp_data_h(:,1)))';
s_prof(:,2) = fun_prof(param,s_prof);
%rotate and shift to orignial reference system
s_prof = s_prof / rot_mat + c_horiz';


end