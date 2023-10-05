function [data] = read_profile(fname_prof)
% Reads input file of gedolocated points defining the slip profile
%
% Input Arguments:
%   fname_prof (string): file name
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

%read data
data = table2array(readtable(fname_prof));

%number of col
ncol = size(data,2);

%fill out missing coordinates
data(:,ncol+1:5) = NaN;
%use constant elev if not provided
if ncol < 3; data(:,3) = 0; end

end