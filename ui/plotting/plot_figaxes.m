function [figid] = plot_figaxes(data)
%Plot figure axes

%create figure axes
figid = figure;
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
axis square;
axis equal
hold on 

end