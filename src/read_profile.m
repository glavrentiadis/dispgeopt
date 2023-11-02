function [data] = read_profile(fname_prof,flag_sort)
% Reads input file of gedolocated points defining the slip profile
%
% Input Arguments:
%   fname_prof (string): file name
%   flag_sort (boolean): sorting porfile on principal direction, optional
%
% Output Arguments:
%   data (mat[n_pt,5]): coordinates and uncertainty of profile's points
%
% Notes:
%   Column order and units: 
%       X    (m): x coordinate - easting
%       Y    (m): x coordinate - easting
%       Z    (m): vertical coordinate - elevation, optional
%       hstd (m): standard deviation of horizontal uncertainty, optional
%       vstd (m): standard deviation of vertical uncertainty, optional

%short input data
if nargin < 1; flag_sort = false; end

%read data
data = table2array(readtable(fname_prof));

%number of col
ncol = size(data,2);

%fill out missing coordinates
data(:,ncol+1:5) = NaN;
%use constant elev if not provided
if ncol < 3; data(:,3) = 0; end

if flag_sort
    %horizontal coordinates
    xy = data(:,1:2)';
    %correct for mean offset
    xy = xy - mean(xy,2);
    
    %compute principal direction 
    A = (xy);
    [V,~,~] = svd(xy);
    v = V(:,1); %normalized principal direction
    
    %rotation angles/matrix
    theta =  atan2(v(2),v(1));
    rot_mat = axis_rot(theta);
    
    %rotate profile in principal direction
    xy = rot_mat * xy;

    %sort displacement data
    [~,i_sort] = sort(xy(1,:));
    data = data(i_sort,:);
end

end