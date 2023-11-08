function [n_samp] = input_nsamples()
% Dialog box for number of samples
% 
% Output arguments:
%   n_samp (double):   number of samples

%number of samples
dlgtitle = 'Sampling info';
prompt = {'Number of samples:'};
dims = [1 35];
definput = {'10000'};
%number of samples dialog
n_samp = inputdlg(prompt, dlgtitle, dims, definput);
n_samp = str2double(n_samp{1});

end