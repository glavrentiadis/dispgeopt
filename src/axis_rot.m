function [rot_mat] = axis_rot(theta,flag3D)
%axis_rot returns the reference system rotation matrix around z axis
%reference: https://en.wikipedia.org/wiki/Rotation_of_axes_in_two_dimensions

%default inputs
if nargin < 2; flag3D = false; end 

%rotation matrix
rot_mat 	 = eye(2+flag3D);
rot_mat(1:2,1:2) = [ cos(theta), sin(theta);
           	    -sin(theta), cos(theta) ];

end
