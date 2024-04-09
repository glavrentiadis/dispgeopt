function [report] = generate_report(flag_analysis,prof_name,disp_net,disp_horiz,disp_vert,apert_width, ...
                                    rank_unc_idx,names_samp_cmp)
%generate_report output a simple text report of the fundamental statistical parameters

report = {sprintf([repmat('=',1,80),'\nProfile Name: %s\n\n'],prof_name)};
switch flag_analysis
    case 1
        report = [report, {sprintf('Measured Displacement:\n')}];
        report = [report, {sprintf('\tNet (mean, min, max):\t\t %.2fm, %.2fm, %.2fm\n',           mean(disp_net),    min(disp_net),    max(disp_net))}];
        report = [report, {sprintf('\tHorizontal (mean, min, max):\t %.2fm, %.2fm, %.2fm\n',      mean(disp_horiz),  min(disp_horiz),  max(disp_horiz))}];
        report = [report, {sprintf('\tVertical (mean, min, max):\t %.2fm, %.2fm, %.2fm\n',        mean(disp_vert),   min(disp_vert),   max(disp_vert))}];
        report = [report, {sprintf('Aperture\n\tWdith (mean, min, max):\t %.2fm, %.2fm, %.2fm\n', mean(apert_width), min(apert_width), max(apert_width))}];
    case 2
        report = [report, {sprintf('Measured Displacement:\n')}];
        report = [report, {sprintf('\tNet (mean, std, min, max):\t\t %.2fm, %.2fm, %.2fm, %.2fm\n',             mean(disp_net),    std(disp_net),    min(disp_net),    max(disp_net))}];
        report = [report, {sprintf('\tHorizontal (mean, std, min, max):\t %.2fm, %.2fm, %.2fm, %.2fm\n',        mean(disp_horiz),  std(disp_horiz),  min(disp_horiz),  max(disp_horiz))}];
        report = [report, {sprintf('\tVertical (mean, std, min, max):\t\t %.2fm, %.2fm, %.2fm, %.2fm\n',        mean(disp_vert),   std(disp_vert),   min(disp_vert),   max(disp_vert))}];
        report = [report, {sprintf('Aperture\n\tWdith (mean, std, min, max):\t\t %.2fm, %.2fm, %.2fm, %.2fm\n', mean(apert_width), std(apert_width), min(apert_width), max(apert_width))}];
    case 3
        for c = rank_unc_idx
            report = [report, {sprintf([repmat(' ---  ',1,13),'\n'],prof_name)}];
            report = [report, {sprintf('%s Uncertainty, Measured Displacement:\n', names_samp_cmp{c})}];
            report = [report, {sprintf('\tNet (mean, std, min, max):\t\t %.2fm, %.2fm, %.2fm, %.2fm\n',             mean(disp_net{c}),    std(disp_net{c}),    min(disp_net{c}),    max(disp_net{c}))}];
            report = [report, {sprintf('\tHorizontal (mean, std, min, max):\t %.2fm, %.2fm, %.2fm, %.2fm\n',        mean(disp_horiz{c}),  std(disp_horiz{c}),  min(disp_horiz{c}),  max(disp_horiz{c}))}];
            report = [report, {sprintf('\tVertical (mean, std, min, max):\t\t %.2fm, %.2fm, %.2fm, %.2fm\n',        mean(disp_vert{c}),   std(disp_vert{c}),   min(disp_vert{c}),   max(disp_vert{c}))}];
            report = [report, {sprintf('Aperture\n\tWdith (mean, std, min, max):\t\t %.2fm, %.2fm, %.2fm, %.2fm\n', mean(apert_width{c}), std(apert_width{c}), min(apert_width{c}), max(apert_width{c}))}];
        end
end
report = [report, {sprintf([repmat('=',1,80),'\n'])}];



end