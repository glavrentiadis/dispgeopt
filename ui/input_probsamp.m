function [samp_p] = input_probsamp()
% Dialog box for probability of projection point sampling
% 
% Output arguments:
%   samp_p (array[2]):   probability of projection point sampling

%number of samples
dlgtitle = 'Projection Point Input';
prompt = {'Sampling probability (side A):';'Sampling probability (side B):'};
dims   = [1 35; 1 35];
definput = {'0.8';'0.8'};
%projection point sampling dialog
samp_p = inputdlg(prompt, dlgtitle, dims, definput);
samp_p = cellfun(@(x) str2double(x), samp_p(1:2));

end