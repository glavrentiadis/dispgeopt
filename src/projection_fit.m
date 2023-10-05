function [c,v,t_lim,fun_prj] = projection_fit(prj_pt)
% UI to load slip profile
%
% Input Arguments:
%   prj_pt (mat[3,n_pt]): projection points' coordinates
%
% Output Arguments:
%   c (array[3]): constant offset
%   v (array[3]): projection vector
%   t_lim (array[2]): projection range
%   fun_prj [fun handle]: projection function


%reshape coordinates
if size(prj_pt,2) == 3
    xyz = prj_pt';
elseif size(prj_pt,1) == 3
    xyz = prj_pt;
else
    error('Incorrect dimension size')
end

%mean offset
c = mean(xyz,2);

%compute principal direction 
A = (xyz-c);
[V,~,~] = svd(xyz-c);
v = V(:,1); %normalized principal direction

%projection range
t = v'*A;
t_lim = [min(t),max(t)];

%projection function
fun_prj = @(t) (c + v*t)';

end