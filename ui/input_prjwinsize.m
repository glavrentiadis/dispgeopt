function [wsize_info] = input_prjwinsize()
% Dialog box for projection window paramameters
% 
% Output arguments:
%   wsize_info:   window size information (mean, std)

%number of samples
dlgtitle = 'Projection Window Input';
prompt = {'Window mean size (m):';'Window standard deviation (m):'};
dims   = [1 35; 1 35];
definput = {'15';'2.5'};
%projection point sampling dialog
wsize_info = inputdlg(prompt, dlgtitle, dims, definput);
wsize_info = cellfun(@(x) str2double(x), wsize_info);

end