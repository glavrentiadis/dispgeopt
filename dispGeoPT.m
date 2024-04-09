function dispGeoPT()
% Main function for computing slip displacement from geolocated points
close all;

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
[data,prof_name,dir_inpt] = open_profile(true);
prof_fname = sprintf('%s',strrep(prof_name,' ','_'));

%select output
[dir_out,dir_fig] = select_output_folder(dir_inpt,prof_fname);

%points to exclude
[data,figid] = remove_points(data);
close(figid)

%select analysis
flag_analysis = input_analysis();
if isempty(flag_analysis); return; end

%analysis
switch flag_analysis
    case 1 %deterministic analysis
        [disp_net,disp_horiz,disp_vert,apert_width,df_summary,fname_prof_analysis] = ...
            analysis_deterministic(prof_name,prof_fname,data,dir_out,dir_fig);
    case 2 %probabilistic analysis
        [disp_net,disp_horiz,disp_vert,apert_width,df_summary,fname_prof_analysis] = ...
            analysis_probabilistic(prof_name,prof_fname,data,dir_out,dir_fig);
    case 3 %uncertainty quantification
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
    %generate report 
    report = generate_report(flag_analysis,prof_name,disp_net,disp_horiz,disp_vert,apert_width);
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
    %generate report 
    report = generate_report(flag_analysis,prof_name,disp_net,disp_horiz,disp_vert,apert_width, ...
                             rank_unc_idx,names_samp_cmp);
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

%print report
%screen
for r = report; fprintf(r{1}); end
%plain file
fileid = fopen([dir_out,fname_prof_analysis,'_summary_out','.txt'],'w');
for r = report; fprintf(fileid, report{1}); end
fclose(fileid);

end