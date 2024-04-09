function [dir_out,dir_fig] = select_output_folder(path,sub_dir_out)
%select folder for saving output files

%default inputs
if nargin < 1; path = './.'; end
if nargin < 2; sub_dir_out = ''; end

%ui for main output folder selection
dir_out = uigetdir(path,'Select Output Folder');
dir_out = [dir_out,'/',sub_dir_out,'/'];
%create main output directory
if not(isfolder(dir_out)); mkdir(dir_out); end

%figures directory
if nargout > 1
    %figure output directory
    dir_fig = [dir_out,'figures/'];
    %create figures output directory
    if not(isfolder(dir_fig)); mkdir(dir_fig); end
end

end