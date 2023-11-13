function dispGeoPT()
% Main function for computing slip displacement from geolocated points

%libraries
addpath('./src/')
addpath('./src/sampling/')
addpath('./src/optimfun/')
addpath('./ui/')
addpath('./ui/plotting')

%figure properties
set(0,'defaultAxesFontSize',13)
set(0,'DefaultAxesFontName','Arial')
set(0, 'DefaultTextFontName', 'Arial');
set(0,'DefaultLegendFontSize',12)

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
        [disp_net,disp_horiz,disp_vert,apert_width,df_summary,fname_prof_analysis] = ...
            analysis_deterministic(prof_name,prof_fname,data,dir_out,dir_fig);
    case 2
        [disp_net,disp_horiz,disp_vert,apert_width,df_summary,fname_prof_analysis] = ...
            analysis_probabilistic(prof_name,prof_fname,data,dir_out,dir_fig);
    case 3
        [names_samp_cmp,disp_net,disp_horiz,disp_vert,apert_width,df_summary,fname_prof_analysis,rank_unc_idx] = ...
            analysis_uncrtquantification(prof_name,prof_fname,data,dir_out,dir_fig);
end

%deterministic and probabilistic analysis
if flag_analysis < 3
    %summarize displacement data
    df_disp_net    = summarize_disp_data(disp_net,   'disp_net',    [0.05,0.16,0.50,0.84,0.95]);
    df_disp_horiz  = summarize_disp_data(disp_horiz, 'disp_horiz',  [0.05,0.16,0.50,0.84,0.95]);
    df_disp_vert   = summarize_disp_data(disp_vert,  'disp_vert',   [0.05,0.16,0.50,0.84,0.95]);
    df_apert_width = summarize_disp_data(apert_width,'apert_width', [0.05,0.16,0.50,0.84,0.95]);
    df_disp        = [df_disp_net,df_disp_horiz,df_disp_vert,df_apert_width];
    %save displacement statistic
    writetable(df_disp,[dir_out,fname_prof_analysis,'_summary_disp','.csv'],'WriteRowNames',true)
    %report 
    fprintf([repmat('=',1,80),'\nProfile Name: %s\n\n'],prof_name)
    switch flag_analysis
        case 1
            fprintf('Measured Displacement:\n')
            fprintf('\tNet (mean, min, max):\t\t %.2fm, %.2fm, %.2fm\n',           mean(disp_net),    min(disp_net),    max(disp_net))
            fprintf('\tHorizontal (mean, min, max):\t %.2fm, %.2fm, %.2fm\n',      mean(disp_horiz),  min(disp_horiz),  max(disp_horiz))
            fprintf('\tVertical (mean, min, max):\t %.2fm, %.2fm, %.2fm\n',        mean(disp_vert),   min(disp_vert),   max(disp_vert))
            fprintf('Aperture\n\tWdith (mean, min, max):\t %.2fm, %.2fm, %.2fm\n', mean(apert_width), min(apert_width), max(apert_width))
        case 2
            fprintf('Measured Displacement:\n')
            fprintf('\tNet (mean, std, min, max):\t\t %.2fm, %.2fm, %.2fm, %.2fm\n',             mean(disp_net),    std(disp_net),    min(disp_net),    max(disp_net))
            fprintf('\tHorizontal (mean, std, min, max):\t %.2fm, %.2fm, %.2fm, %.2fm\n',        mean(disp_horiz),  std(disp_horiz),  min(disp_horiz),  max(disp_horiz))
            fprintf('\tVertical (mean, std, min, max):\t\t %.2fm, %.2fm, %.2fm, %.2fm\n',        mean(disp_vert),   std(disp_vert),   min(disp_vert),   max(disp_vert))
            fprintf('Aperture\n\tWdith (mean, std, min, max):\t\t %.2fm, %.2fm, %.2fm, %.2fm\n', mean(apert_width), std(apert_width), min(apert_width), max(apert_width))      
    end
    fprintf([repmat('=',1,80),'\n'])

    %plot displacement distributions
    %net displacement
    fig_title = [prof_name,': Net Displacement'];
    figid = plot_disp_distribution(disp_net,fig_title);
    saveas(figid,[dir_fig,fname_prof_analysis,'_disp_net','.png'])
    savefig(figid,[dir_fig,fname_prof_analysis,'_disp_net','.fig'])
    %horizontal displacement
    fig_title = [prof_name,': Horizontal Displacement'];
    figid = plot_disp_distribution(disp_horiz,fig_title);
    saveas(figid,[dir_fig,fname_prof_analysis,'_disp_horiz','.png'])
    savefig(figid,[dir_fig,fname_prof_analysis,'_disp_horiz','.fig'])
    %vertical displacement
    fig_title = [prof_name,': Vertical Displacement'];
    figid = plot_disp_distribution(disp_vert,fig_title);
    saveas(figid,[dir_fig,fname_prof_analysis,'_disp_vert','.png'])
    savefig(figid,[dir_fig,fname_prof_analysis,'_disp_vert','.fig'])
end

%uncertainty quantification
if flag_analysis == 3
    df_disp = table();
    for c = 1:length(names_samp_cmp)
        cn_samp_c = strrep(lower(names_samp_cmp{c}),' ','_');
        %summarize displacement data
        df_disp_net    = summarize_disp_data(disp_net{c},   ['disp_net_',cn_samp_c],    [0.05,0.16,0.50,0.84,0.95]);
        df_disp_horiz  = summarize_disp_data(disp_horiz{c}, ['disp_horiz',cn_samp_c],  [0.05,0.16,0.50,0.84,0.95]);
        df_disp_vert   = summarize_disp_data(disp_vert{c},  ['disp_vert',cn_samp_c],   [0.05,0.16,0.50,0.84,0.95]);
        df_apert_width = summarize_disp_data(apert_width{c},['apert_width',cn_samp_c], [0.05,0.16,0.50,0.84,0.95]);
        df_disp        = [df_disp,df_disp_net,df_disp_horiz,df_disp_vert,df_apert_width];
    end
    %save displacement statistic
    writetable(df_disp,[dir_out,fname_prof_analysis,'_summary_disp','.csv'],'WriteRowNames',true)
    %report 
    fprintf([repmat('=',1,80),'\nProfile Name: %s\n\n'],prof_name)
    for c = rank_unc_idx
            fprintf([repmat(' ---  ',1,13),'\n'],prof_name)
            fprintf('%s Uncertainty, Measured Displacement:\n', names_samp_cmp{c})
            fprintf('\tNet (mean, std, min, max):\t\t %.2fm, %.2fm, %.2fm, %.2fm\n',             mean(disp_net{c}),    std(disp_net{c}),    min(disp_net{c}),    max(disp_net{c}))
            fprintf('\tHorizontal (mean, std, min, max):\t %.2fm, %.2fm, %.2fm, %.2fm\n',        mean(disp_horiz{c}),  std(disp_horiz{c}),  min(disp_horiz{c}),  max(disp_horiz{c}))
            fprintf('\tVertical (mean, std, min, max):\t\t %.2fm, %.2fm, %.2fm, %.2fm\n',        mean(disp_vert{c}),   std(disp_vert{c}),   min(disp_vert{c}),   max(disp_vert{c}))
            fprintf('Aperture\n\tWdith (mean, std, min, max):\t\t %.2fm, %.2fm, %.2fm, %.2fm\n', mean(apert_width{c}), std(apert_width{c}), min(apert_width{c}), max(apert_width{c}))      
    end
    fprintf([repmat('=',1,80),'\n'])

    %plot displacement distributions
    for c = 1:length(names_samp_cmp)
        prof_samp_fname = sprintf('%s_samp_%s',fname_prof_analysis ...
            ,strrep( lower(names_samp_cmp{c}), ' ', '_') );
        title_samp = sprintf('Sampling: %s',names_samp_cmp{c});
        %net displacement
        fig_title = {[prof_name,': Net Displacement'],title_samp};
        figid = plot_disp_distribution(disp_net{c},fig_title);
        saveas(figid,[dir_fig,prof_samp_fname,'_disp_net','.png'])
        savefig(figid,[dir_fig,prof_samp_fname,'_disp_net','.fig'])
        %horizontal displacement
        fig_title = {[prof_name,': Horizontal Displacement'],title_samp};
        figid = plot_disp_distribution(disp_horiz{c},fig_title);
        saveas(figid,[dir_fig,prof_samp_fname,'_disp_horiz','.png'])
        savefig(figid,[dir_fig,prof_samp_fname,'_disp_horiz','.fig'])
        %vertical displacement
        fig_title = {[prof_name,': Vertical Displacement'],title_samp};
        figid = plot_disp_distribution(disp_vert{c},fig_title);
        saveas(figid,[dir_fig,prof_samp_fname,'_disp_vert','.png'])
        savefig(figid,[dir_fig,prof_samp_fname,'_disp_vert','.fig'])
    end
end

end