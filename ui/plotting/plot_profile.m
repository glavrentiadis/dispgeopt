function [figid] = plot_profile(data,figid)
%Plot raw profile

%create figure axes if not given;
if nargin < 2; figid = figure; end

%plot raw data
hold on
plot(data(:,1),data(:,2),'-',  'LineWidth',1,'Color',[.7 .7 .7]);
plot(data(:,1),data(:,2),'k+', 'LineWidth',2,'MarkerSize',10);
%format axes if figure handle not specified
if nargin < 2
    %plotting window size
    win_cnt  =    ( max(data(:,1:2)) + min(data(:,1:2)) ) / 2;
    win_size = max( max(data(:,1:2)) - min(data(:,1:2)) );
    win_ratio = 1.1;
    %window extents
    win_ext = win_cnt + 0.5 * win_ratio * win_size * [-1,-1;1,1];
    xlim(win_ext(:,1))
    ylim(win_ext(:,2))
    %add lables
    xlabel('X (m)');
    ylabel('Y (m)');
    grid on;
    % axis square;
    % axis equal
    % xlim('tight')
    % ylim('tight')
end

end