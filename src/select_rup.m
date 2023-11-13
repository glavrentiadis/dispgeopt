function [rup_loc,rup_zone_lim,rup_ax,figid] = select_rup(data,prj1_data,prj2_data,rup_azmth)
% Select rupture location 

%select rupture point method
[flag_rup_pt] = listdlg('ListString',{'Manual','Auto'}, ...
                        'PromptString','Determine rupture location:','Name','Rupture Location', ...
                        'SelectionMode','single','ListSize',[250,100]);
while true
    switch flag_rup_pt
        case 1 %manual
            [rup_loc,rup_zone_lim,rup_ax,figid] = determine_rup_manual(data,prj1_data,prj2_data);
            break
        case 2 %automatic
            [rup_loc,rup_zone_lim,rup_ax,figid] = determine_rup_auto(data,prj1_data,prj2_data,rup_azmth);
            %check results validity
            title({'Rupture location','(Enter, scape, or right click to accept, Esc to use manual approach)'})
            %record input
            [~,~,button] = ginput(1);
            if any([isempty(button), button==32, button==1])
                break
            else
                flag_rup_pt = 1;
                close(figid);
            end
    end
end

end