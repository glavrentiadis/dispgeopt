function [dir_out,dir_fig] = select_output_folder(path)
%select folder for saving output files

%default inputs
if nargin < 1; path = './.'; end

%ui for main output folder selection
dir_out = uigetdir(path,'Select Output Folder');
%create main output directory
if not(isfolder(dir_out)); mkdir(dir_out); end
dir_out = [dir_out,'/'];

%figures directory
if nargout > 1
    %figure output directory
    dir_fig = [dir_out,'figures/'];
    %create figures output directory
    if not(isfolder(dir_fig)); mkdir(dir_fig); end
end

end