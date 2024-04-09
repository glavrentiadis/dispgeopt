function [data,prof_name,fpath] = open_profile(flag_sort)
%UI to load slip profile
%
% Input Arguments:
%   flag_sort (boolean): sorting porfile on principal direction
%
% Output Arguments:
%   data (mat[n_pt,5]): coordinates and uncertainty of profile's points
%   prof_name (string): profile name
%   fpath (string):     file path

%short input data
if nargin < 1; flag_sort = false; end

%file extension
f_ext = {'*.txt;*.csv', 'Slip Profile Files (*.txt,*.csv)'
         '*.txt',       'Text Files (*.txt)';
         '*.csv',       'CSV Files (*.csv)';
         '*.*',         'All Files (*.*)'};

%ui file selection 
[fname, fpath] = uigetfile(f_ext, 'Select Profile to Read');
if fname == 0; error('User canceled the operation.'); end

%profile name
prof_name = fname(1:max(strfind(fname,'.'))-1);
prof_name   = strrep(prof_name,'_',' ');

%read profile
data = read_profile(fullfile(fpath,fname),flag_sort);


end