function [df_disp] = summarize_disp_data(disp_array, col_name, prcnt)
% summarize displacement data

%default percentiles
if nargin < 2; col_name = 'disp'; end 
if nargin < 3; prcnt    = (0.05:0.05:0.95); end

%summary statistics
disp_mean   = mean(disp_array);
disp_median = median(disp_array);
disp_std    = std(disp_array);
disp_min    = min(disp_array);
disp_max    = max(disp_array);
%convert percentile to vector array
prcnt = reshape(prcnt,length(prcnt),1);

%quantiles
disp_prcnt  = quantile(disp_array,prcnt);
%quantile names
rname_prcnt = arrayfun(@(p) sprintf('prcnt_%02.0f',round(p*100)), prcnt, 'UniformOutput',false);

%summarize disp data
df_disp = table([disp_mean;disp_median;disp_std;disp_min;disp_max;disp_prcnt], ...
                'VariableNames', {col_name}, ...
                'RowNames', [{'mean','median','std','min','max'}';rname_prcnt]);

end