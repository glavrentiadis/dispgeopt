function [win_info] = input_prjwinlin()
% Dialog box for projection window paramameters
% based on feature linearity
%
% Output arguments:
%   win_info:   window linearity information (min pt, min lenght, min corr)

%projection window
dlgtitle = 'Projection Window Dimensions Input';
prompt = {'Minimum number of points:';'Minimum feature lenght (m):';'Minimum feature linear correlation:'};
dims   = [1 45; 1 45; 1 45];
definput = {'4';'2.5';'0.8'};
%projection window linearity dialog
win_info = inputdlg(prompt, dlgtitle, dims, definput);
win_info = cellfun(@(x) str2double(x), win_info );

end