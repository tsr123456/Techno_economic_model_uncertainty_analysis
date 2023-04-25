% Plot comparison Uncertainty Characterisaion methods *

load Comparison.mat

%% Set colors

green = '#33B8A1'; 
blue = '#0098C8';
yellow = '#FBBC41';
red = '#FE8A7F';
hex = [green; blue;yellow;red];
colors = sscanf(hex','#%2x%2x%2x',[3,size(hex,1)]).' / 255;% create color map


%%
figure
clf

t = tiledlayout(6,1);
t.TileSpacing = 'compact';
t.Padding = 'compact'; 

%plot histogram
ax1 = nexttile ([5 1]);
hold on

plot_uniform = histogram(Results_uniform,'DisplayStyle','bar','linewidth', 2);
plot_max_pess = histogram(Result_max_pess,'DisplayStyle','bar','linewidth', 2);
plot_max = histogram(Results_max,'DisplayStyle','bar','linewidth', 2);
plot_hawer = histogram (Results_Hawer,'DisplayStyle','bar','linewidth', 2);


plot_uniform.EdgeColor  = 'none';
plot_max_pess.EdgeColor = 'none';
plot_max.EdgeColor = 'none';
plot_hawer.EdgeColor = 'none';

plot_uniform.FaceColor  = colors(1,:);
plot_max_pess.FaceColor = colors(2,:);
plot_max.FaceColor = colors(3,:);
plot_hawer.FaceColor = colors(4,:);

plot_uniform.FaceAlpha  = 0.15;
plot_max_pess.FaceAlpha = 0.15;
plot_max.FaceAlpha = 0.15;
plot_hawer.FaceAlpha = 0.15;


plot_uniform_line = histogram(Results_uniform,'DisplayStyle','stairs','linewidth', 2);
plot_max_pess_line = histogram(Result_max_pess,'DisplayStyle','stairs','linewidth', 2);
plot_max_line = histogram(Results_max,'DisplayStyle','stairs','linewidth', 2);
plot_hawer_line = histogram (Results_Hawer,'DisplayStyle','stairs','linewidth', 2);

plot_uniform_line.EdgeColor  = colors(1,:);
plot_max_pess_line.EdgeColor = colors(2,:);
plot_max_line.EdgeColor = colors(3,:);
plot_hawer_line.EdgeColor = colors(4,:);

h = [plot_hawer_line,plot_max_line,plot_max_pess_line,plot_uniform_line];
legend(h,append('Hawer: µ=',num2str(mean(Results_Hawer))),append('Maximum Entropy (opt.): µ=',num2str(mean(Results_max))),append('Maximum Entropy (pess.): µ=',num2str(mean(Result_max_pess))),append('Uniform: µ=',num2str(mean(Results_uniform))));
set(ax1,'xticklabel',[])

%xlabel('Levelised cost of product in [€/t_{SCM}]', 'FontSize',12)
ylabel('Frequency', 'FontSize',12)

box on

%plot confidence interval
ax2 = nexttile([1 1]);

%Calulate 95% confidence intervals
confidence_uniform = quantile(Results_uniform,[0.025 0.975]);
confidence_max_pess = quantile(Result_max_pess,[0.025 0.975]);
confidence_max = quantile(Results_max,[0.025 0.975]);
confidence_hawer = quantile(Results_Hawer,[0.025 0.975]);
%plot bars
hold on

%Add lines
plot(confidence_uniform,[1 1],'linewidth', 2 ,'color', colors(1,:), 'Marker','none', 'MarkerFaceColor', 'none') % colors(1,:) )
plot(confidence_max_pess,[2 2],'linewidth', 2,'color', colors(2,:), 'Marker','none', 'MarkerFaceColor','none') % colors(2,:))
plot(confidence_max,[3 3],'linewidth', 2,'color', colors(3,:), 'Marker','none', 'MarkerFaceColor','none') % colors(3,:))
plot(confidence_hawer,[4 4],'linewidth', 2,'color', colors(4,:),'Marker','none', 'MarkerFaceColor','none') % colors(4,:))
ylim([0.5 4.5])

%Add points
k= 0.35%distance to middle
plot([confidence_uniform(1) confidence_uniform(1)],[1-k 1+k],'linewidth', 2 ,'color', colors(1,:), 'Marker','none', 'MarkerFaceColor', 'none') % colors(1,:) )
plot([confidence_max_pess(1) confidence_max_pess(1)],[2-k 2+k],'linewidth', 2,'color', colors(2,:), 'Marker','none', 'MarkerFaceColor','none') % colors(2,:))
plot([confidence_max(1) confidence_max(1)],[3-k 3+k],'linewidth', 2,'color', colors(3,:), 'Marker','none', 'MarkerFaceColor','none') % colors(3,:))
plot([confidence_hawer(1) confidence_hawer(1)],[4-k 4+k],'linewidth', 2,'color', colors(4,:),'Marker','none', 'MarkerFaceColor','none') % colors(4,:))

plot([confidence_uniform(2) confidence_uniform(2)],[1-k 1+k],'linewidth', 2 ,'color', colors(1,:), 'Marker','none', 'MarkerFaceColor', 'none') % colors(1,:) )
plot([confidence_max_pess(2) confidence_max_pess(2)],[2-k 2+k],'linewidth', 2,'color', colors(2,:), 'Marker','none', 'MarkerFaceColor','none') % colors(2,:))
plot([confidence_max(2) confidence_max(2)],[3-k 3+k],'linewidth', 2,'color', colors(3,:), 'Marker','none', 'MarkerFaceColor','none') % colors(3,:))
plot([confidence_hawer(2) confidence_hawer(2)],[4-k 4+k],'linewidth', 2,'color', colors(4,:),'Marker','none', 'MarkerFaceColor','none') % colors(4,:))


xlabel('Levelised cost of product in [€/t_{SCM}]', 'FontSize',12)
%ylabel('95% \newline confidence \newline interval', 'FontSize',12)

yh = ylabel('confidence','FontSize',12);
set(yh,'Units','Normalized');
ylabPos = get(yh,'Position');
text(ylabPos(1),ylabPos(2),'95%',  'Units','Normalized',  'HorizontalAlignment','center', 'Vert','bottom', 'Rotation',90,'FontSize',12)


set(ax2,'yticklabel',[])
set(ax2,'ytick',[])              %remove ticks
box on



%link axes
linkaxes([ax1 ax2],'x')
