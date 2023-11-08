function [disp_prof] = slip_profile_fun(s_array,s0,disp,k,c0,c1,c2,s_start)
% Analytic function for fitting slip profile
%   combination of logistic and hinge functions

% base
% disp_prof = c0 * ones(size(s_array)) + c1 * (s_array - s0);
disp_prof = c0 * ones(size(s_array)) + c1 * (s_array - s_start);
% logistic function
disp_prof = disp_prof + disp ./ (1 + exp(-(s_array - s0)/k) );
% hinge function
disp_prof = disp_prof + (c2-c1) * k * log(1+exp((s_array -s0)/k));

end
