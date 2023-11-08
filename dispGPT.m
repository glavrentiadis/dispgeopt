function dispGPT()
% Main function for computing slip displacement from geolocated points

%libraries
addpath('./src/')
addpath('./src/sampling/')
addpath('./src/optimfun/')
addpath('./ui/')
addpath('./ui/plotting')

%load file
[data,prof_name] = open_profile(true);
prof_fname = sprintf('%s',strrep(prof_name,' ','_'));

%select output
[dir_out,dir_fig] = select_output_folder();

%points to exclude
[data,figid] = remove_points(data);
close(figid)

%select analysis
flag_analysis = input_analysis();
if isempty(flag_analysis); return; end

%analysis
switch flag_analysis
    case 1
        [disp_net,disp_horiz,disp_vert,apert_width,df_summary] = analysis_deterministic(prof_name,prof_fname,data,dir_out,dir_fig);
    case 2
        [disp_net,disp_horiz,disp_vert,apert_width,df_summary] = analysis_probabilistic(prof_name,prof_fname,data,dir_out,dir_fig);
    case 3
        
end

if flag_analysis < 3
    %summarize displacement data
    df_disp_net    = summarize_disp_data(disp_net,   'disp_net',    [0.05,0.16,0.50,0.84,0.95]);
    df_disp_horiz  = summarize_disp_data(disp_horiz, 'disp_horiz',  [0.05,0.16,0.50,0.84,0.95]);
    df_disp_vert   = summarize_disp_data(disp_vert,  'disp_vert',   [0.05,0.16,0.50,0.84,0.95]);
    df_apert_width = summarize_disp_data(apert_width,'apert_width', [0.05,0.16,0.50,0.84,0.95]);
    df_disp        = [df_disp_net,df_disp_horiz,df_disp_vert,df_apert_width];
    %save displacement statistic
    writetable(df_disp,[dir_out,prof_fname,'_summary_disp','.csv'],'WriteRowNames',true)
    %report 
    fprintf([repmat('=',1,80),'\n'])
    switch flag_analysis
        case 1
            fprintf('Measured Displacement:\n')
            fprintf('\tNet (mean, min, max):\t\t %.2fm, %.2fm, %.2fm\n',           mean(disp_net),    min(disp_net),    max(disp_net))
            fprintf('\tHorizontal (mean, min, max):\t %.2fm, %.2fm, %.2fm\n',      mean(disp_horiz),  min(disp_horiz),  max(disp_horiz))
            fprintf('\tVertical (mean, min, max):\t %.2fm, %.2fm, %.2fm\n',        mean(disp_vert),   min(disp_vert),   max(disp_vert))
            fprintf('Aperture\n\tWdith (mean, min, max):\t %.2fm, %.2fm, %.2fm\n', mean(apert_width), min(apert_width), max(apert_width))
        case 2

    end
    fprintf([repmat('=',1,80),'\n'])

    %plot displacement distributions
    %net displacement
    fig_title = [prof_name,': net displacement'];
    figid = plot_disp_distribution(disp_net,fig_title);
    saveas(figid,[dir_fig,prof_fname,'_disp_net','.png'])
    %horizontal displacement
    fig_title = [prof_name,': horizontal displacement'];
    figid = plot_disp_distribution(disp_horiz,fig_title);
    saveas(figid,[dir_fig,prof_fname,'_disp_horiz','.png'])
    %vertical displacement
    fig_title = [prof_name,': vertical displacement'];
    figid = plot_disp_distribution(disp_vert,fig_title);
    saveas(figid,[dir_fig,prof_fname,'_disp_vert','.png'])
end

end