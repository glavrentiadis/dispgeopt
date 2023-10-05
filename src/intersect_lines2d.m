function [s,t1,t2] = intersect_lines2d(c1,v1,c2,v2)
% Copute intersection point and projection lengths (2D space)
%
% Input Arguments:
%   c1 (array[2]): pivot point of first line
%   v1 (array[2]): projection vector of first line
%   c2 (array[2]): pivot point of second line
%   v2 (array[2]): projection point of second line
% 
% Output Arguments:
%   s (array[2]): intersection point
%   t1 (real): projection lenght from v1
%   t2 (real): projection length from v2

%compute projection lengths
T = [v1,-v2]\(c2-c1);
t1 = T(1);
t2 = T(2);

%intersection point
s = c1 + t1*v1;

end