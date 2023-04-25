%% Example Plots %%


%set color
%{
color2=[0.1986, 0.7214,0.6310];
color1=[0.9856,0.7372, 0.2537];
color3 = [0.0078    0.4471    0.7412];
color_area_neg =[0.9856,0.7372, 0.2537]; %[0.886, 0.250, 0.313];
color_area_pos = [0.1986 0.7214 0.6310];
%}
% colors for mSR

color1=[0.5098    0.6902    0.7804];
color3=[0.5020    0.0157    0.3098];
color2 = [0.985 0.7372  0.2537];
color_area_neg = color1;
color_area_pos = color2;

area_trans = 0.4;
size_font = 12;

Font_size_labels = 10; 
width = 0.4

%%OAT----------------------------------------------------------------------
%create data:
x  = [-0.15; -0.10; -0.05; 0.0; 0.05; 0.10; 0.15];
y(:,1) = x.*0.88;
y(:,2) = -x.*0.5;
y(:,3) = x.^2;
sorted_data_high = [y(7,3)  y(7,2) y(7,1)];
sorted_data_low = [y(1,3)  y(1,2) y(1,1) ];
sorted_labels = ['x_{3}'; 'x_{2}'; 'x_{1}'];
figure 
%plot high data (+15%)
h = barh(sorted_data_high,width);
h.FaceColor = color_area_pos;
h.FaceAlpha =0.5;

h.EdgeColor = color2;
%h.EdgeColor = 'none';

hold on
%plot low data (-15%)
h2 = barh(sorted_data_low, width);
h2.FaceColor = color_area_neg;
h2.FaceAlpha =0.5;
h2.EdgeColor = color1;
%h2.EdgeColor = 'none';
xlim([-0.17 0.17])

bh = get(h,'BaseLine');
set(bh,'BaseValue',0);
title('One at a time')
set(gca,'yticklabel',sorted_labels)
set(gca,'Ytick',1:3,'YTickLabel',1:3)
set(gca,'yticklabel',sorted_labels)
xlabel('Change in output')
set(gca,'FontSize',12) 


%% one way sensitivity analysis
plotstyle={'-s','-+', '-o','--s','--+','--o',':s', ':+',':o','-.s','-.+','-.o','-^','-d', '-h','--^','--d','--h',':^', ':d',':h','-.^','-.d','-.h'}; % no marker
labels = ['x_{1}'; 'x_{2}'; 'x_{3}'];

figure

%set the color sheme for the figure:
colors = [color1; color2; color3]; %o,g, b
a = axes('ColorOrder',colors);

hold on
for i = 1:3
ph = plot(x,y(:,i), plotstyle{i}, 'LineWidth',2, 'MarkerSize',5);
end
ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
title('One-Way')
legend(labels,'Location','EastOutside')

% create labels:
text(min(x), 0, 'Change in output', 'Rotation',90, 'VerticalAlignment','bottom', 'HorizontalAlignment','center','FontSize',14)
text(0, -0.15, 'Change in input', 'VerticalAlignment','top', 'HorizontalAlignment','center','FontSize',14)

xlim( [-0.15 0.15])
ylim([-0.15 0.15])
set(gca,'FontSize',12) 
hold off;
box on

%% Two-way
plotstyle={'-s','-+', '-o','--s','--+','--o',':s', ':+',':o','-.s','-.+','-.o','-^','-d', '-h','--^','--d','--h',':^', ':d',':h','-.^','-.d','-.h'}; % no marker
labels = ['x_{1}'; 'x_{2}'; 'x_{3}'];

figure
multiway = tiledlayout(3,1)

% Two Way -----------------------------------------------------------

%create data: 
x  = [-0.15; -0.10; -0.05; 0.0; 0.05; 0.10; 0.15];
z(:,1) = x.*0.88;
y(:,2) = -x.*0.5;
[X_mesh, Y_mesh] = meshgrid(x,x);
f_1=@(x_1,x_2) x_1.*0.88-x_2.*0.5;
Z_mesh = f_1(X_mesh,Y_mesh);

f_2=@(x_1,x_3) x_1.*0.88+x_3.^2;
Z_mesh_2 = f_2(X_mesh, Y_mesh);

f_3= @(x_2,x_3) x_2.*(-0.5)+x_3.^2;
Z_mesh_3 = f_3(X_mesh, Y_mesh);


%plot data:
nexttile
contour (X_mesh,Y_mesh,Z_mesh,8); 
xlabel('Value of X_{1}', 'FontSize',12)
ylabel('Value of X_{2}','FontSize',12)
caxis manual
caxis([-0.40 0.25])

hold on 

nexttile
contour (X_mesh,Y_mesh, Z_mesh_2, 8);
xlabel('Value of X_{1}', 'FontSize',12)
ylabel('Value of X_{3}','FontSize',12)
caxis manual
caxis([-0.40 0.25])


nexttile
contour (X_mesh,Y_mesh, Z_mesh_3, 8);
xlabel('Value of X_{2}', 'FontSize',12)
ylabel('Value of X_{3}','FontSize',12)


colormap(winter)
shading interp
caxis manual
caxis([-0.40 0.25])

title(multiway,'Multi-Ways','FontSize',12)

hold off

%% Scatter plot
figure
graph_tiles = tiledlayout(1,3);

nexttile
%create data
x = linspace(1,100,200);
x_2 = x./100;
x_3 = x./50;
x = reshape(x,[],1);
b = rand(200,1);
scat_1 = 2.*x+b.*100;
scat_2 = -1.5.*x+b.*200+50;
scat_3 = b.*250+x/5;

%plot
plot_1 = scatter(x,scat_1,15,color1,'filled');
ylim([0,300])
xlabel ('x_{1}','FontSize', size_font);
box on
hold on
nexttile

plot_2 = scatter(x_2,scat_2,15,color1,'filled');
ylim([0,300])
xlabel ('x_{2}','FontSize', size_font);
box on
hold on
nexttile

plot_3 = scatter(x_3,scat_3,15,color1,'filled');
ylim([0,300])
xlabel ('x_{3}','FontSize', size_font);


box on
hold off
xlabel(graph_tiles,'Value of input variable', 'FontSize',size_font)
ylabel(graph_tiles,'Value of output','FontSize',size_font)
graph_tiles.TileSpacing = 'compact';