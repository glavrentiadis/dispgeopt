function [wsize_info] = input_prjwinsize(flag_det)
% Dialog box for projection window paramameters
% 
% Output arguments:
%   wsize_info:   window size information (mean, std)

%default inputs
if nargin < 1; flag_det = fale; end

%projection window
dlgtitle = 'Projection Window Dimensions Input';
prompt = {'Window mean size (m):';'Window standard deviation (m):'};
dims   = [1 35; 1 35];
if flag_det
    definput = {'15.0';'0.0'};
else
    definput = {'15.0';'2.5'};
end
%projection window size dialog
wsize_info = inputdlg(prompt, dlgtitle, dims, definput);
wsize_info = cellfun(@(x) str2double(x), wsize_info);

end