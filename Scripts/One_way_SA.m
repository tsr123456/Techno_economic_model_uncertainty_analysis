%% ------------------------------ Single Factor SA --------------------- %%
clear all
tic

%% Sensitivity analysis
step = 10;%number of steps for each side sensitivity analysis- choose n/2
step_total = step; 

%Import sensitvity analysis restrictions
[SENSI_NUM,SENSI_TXT,~] = xlsread('Control_Sheet_V3_0_1_uncertainty.xlsx','Assumptions','H60:O84');

%% Import all other factors from Excel sheet:
% All factors are imported using an excel sheet and 4 different matrices.
% The different matrixes are imported here, once. For multiple runs of the
% alter factors directly and do not reimport the factors each step (time
% issues).

global max_diameter 
max_diameter = 0.5;

I1_initial = zeros(130,3);
I2_initial = zeros(130,3);
I3_initial = zeros(130,10);
I4_initial = zeros(130*12);

I1_initial = xlsread('Control_Sheet_V3_0_1_uncertainty.xlsx','Matlab_input','C3:E132','basic');
I2_initial = xlsread('Control_Sheet_V3_0_1_uncertainty.xlsx','Matlab_input','H3:J132','basic');
I3_initial = xlsread('Control_Sheet_V3_0_1_uncertainty.xlsx','Matlab_input','M3:V132','basic');
I4_initial = xlsread('Control_Sheet_V3_0_1_uncertainty.xlsx','Matlab_input','Y3:AJ132','basic');


%% set all resutls matrices
Result_C_total_fu = zeros(step_total,SENSI_NUM(3,7));
Result_Rev_total_fu = zeros(step_total,SENSI_NUM(3,7));
Result_Profit_total = zeros(step_total,SENSI_NUM(3,7));
%%
%create x-axis sensitivity analysis: 
for v_1 = 1:SENSI_NUM(3,7) 
    values_sensi_low =linspace(SENSI_NUM(v_1,2),SENSI_NUM(v_1,1),step/2);
    values_sensi_high = linspace(SENSI_NUM(v_1,1),SENSI_NUM(v_1,3),step/2);
    values_sensi = [values_sensi_low values_sensi_high];
    values_sensi = reshape(values_sensi,step_total,1);
    X_sensi(:,v_1) = values_sensi;
end
%%
for v = 1: SENSI_NUM(3,7) % if only one variable should be changed, alter this in the excel script
    
%create vector for sensivity analysis 
x_sensi = X_sensi(:,v);

% set import matrices into initial state: 
I1 = I1_initial;
I2 = I2_initial;
I3 = I3_initial;
I4 = I4_initial; 

 
% Select correct scenario:
[length_sensi, ~] = size(SENSI_NUM);

% set values for scenarios
%{
for w=1:length_sensi 
 % replace sensitive variable from input matrix:
  if SENSI_NUM(w,4) == 1 % check for right input array to alter sensitive variables
    I1(SENSI_NUM(w,5),SENSI_NUM(w,6)) = SENSI_NUM(w,v_scenarios);
 elseif SENSI_NUM(w,4) == 4 % check for right input array to alter sensitive variables
    I4(SENSI_NUM(w,5),SENSI_NUM(w,6)) = SENSI_NUM(w,v_scenarios);
 else
     disp('No variable in Matrix found that can be altered. This calculation wont have any results. Change input input matrix in Excel sheet !!!!!!!!!')
  end
end

 %fu_cement_replacement = SENSI_CAP(v_scenarios);
%}
fu_cement_replacement = 272000;
%% Run sensitivity analysis

for w=1:step_total
      
 % replace sensitive variable from input matrix:
  if SENSI_NUM(v,4) == 1 % check for right input array to alter sensitive variables
    I1(SENSI_NUM(v,5),SENSI_NUM(v,6)) = x_sensi(w);
 elseif SENSI_NUM(v,4) == 2 % check for right input array to alter sensitive variables
    I2(SENSI_NUM(v,5),SENSI_NUM(v,6)) = x_sensi(w);
 elseif SENSI_NUM(v,4) == 4 % check for right input array to alter sensitive variables
    I4(SENSI_NUM(v,5),SENSI_NUM(v,6)) = x_sensi(w);
 else
     %disp('No variable in Matrix found that can be altered. This calculation wont have any results. Change input input matrix in Excel sheet !!!!!!!!!')
 end
 
run Mass_Balance_V3_0.m
run Energy_Balance_V3_0.m
run CapEx_V3_0.m
run OpEx_V3_0.m
run Revenue_Model_V3_0.m

% Calculate total costs & relative costs to produced Carbonate
Result_C_total_fu(w,v) = c_total/fu_cement_replacement; % in [EUR/tonne cement replacement]
Result_Rev_total_fu(w,v) = rev_total /fu_cement_replacement; % in [EUR/tonne cement replacement]
Result_Profit_total(w,v) = rev_total - c_total; % in[EUR/a]
end

end
disp ('Calculations are done.')

%% Run for initial  outcome: 

I1 = I1_initial;
I2 = I2_initial;
I3 = I3_initial;
I4 = I4_initial; 

% set values for scenarios------------------------------------------------
%{
for w=1:length_sensi 
 % replace sensitive variable from input matrix:
  if SENSI_NUM(w,4) == 1 % check for right input array to alter sensitive variables
    I1(SENSI_NUM(w,5),SENSI_NUM(w,6)) = SENSI_NUM(w,v_scenarios);
 elseif SENSI_NUM(w,4) == 4 % check for right input array to alter sensitive variables
    I4(SENSI_NUM(w,5),SENSI_NUM(w,6)) = SENSI_NUM(w,v_scenarios);
 else
     disp('No variable in Matrix found that can be altered. This calculation wont have any results. Change input input matrix in Excel sheet !!!!!!!!!')
  end
end
%}
%fu_cement_replacement = SENSI_CAP(v_scenarios);
fu_cement_replacement = 272000;

run Mass_Balance_V3_0.m
run Energy_Balance_V3_0.m
run CapEx_V3_0.m
run OpEx_V3_0.m
run Revenue_Model_V3_0.m

% Calculate total costs & relative costs to produced Carbonate
result_c_total_initial = c_total/fu_cement_replacement; % in [EUR/tonne cement replacement]
result_rev_initial = rev_total /fu_cement_replacement; % in [EUR/tonne cement replacement]
result_profit_inital = rev_total - c_total; % in[EUR/a]

toc
%% Calculate indicator for ranking--------------------------------------%%
Result_matrix = Result_C_total_fu./result_c_total_initial;
Result_highest_change_of_output = zeros (1, length(Result_matrix));
Ranks = zeros (length(Result_matrix),1);

 for i = 1: length(Result_matrix)
Result_highest_change_of_output (i) = max(abs(Result_matrix (:,i))-1);
 end
 Result_highest_change_of_output = reshape(Result_highest_change_of_output,[length(Result_matrix),1]);
 %%
 for i = 1: length(Result_matrix)
     % find rank of index of hihgest number
     [~,Ranks(i,:)] =ind2sub(size(Result_highest_change_of_output),max(Result_highest_change_of_output(:)));
     
     %delete highest number and repeat
     Result_highest_change_of_output(i,:) = nan;
 end 
     
%% Plot results --------------------------------------------------------%%
%create x axis direct:
for i_plot = 1: length(SENSI_NUM)
X_axis(:,i_plot) = (X_sensi(:,i_plot)./SENSI_NUM(i_plot))-1;
end

%% COsts
figure
plotstyle={'-s','-+', '-o','--s','--+','--o',':s', ':+',':o','-.s','-.+','-.o','-^','-d', '-h','--^','--d','--h',':^', ':d',':h','-.^','-.d','-.h'}; % with marker
colorstyle = 	{[0 0.4470 0.7410], [0.8500 0.3250 0.0980], [0.9290 0.6940 0.1250],  [0.4940 0.1840 0.5560], [0.4660 0.6740 0.1880], [0.3010 0.7450 0.9330], [0.6350 0.0780 0.1840]}; 
 
%define colors: 
color_red = [ 1.0000    0.8314    0.8314];
color_yellow = [ 1.0000    0.9490    0.7412];
color_green = [   0.8902    0.945    0.8275];

color_red_txt = [1.00 0.063 0.063];
color_yellow_txt = [1.00 0.812 0.047];
color_green_txt = [0.518 0.761 0.243];


clf; 
hold on
graph_tiles = tiledlayout(2,2);

%Font size
Font_size_labels = 10;
size_font = 12;

%Line size
line_width = 1.5;
marker_size = 3.5;

%Ticks
xtick=[-10 -5 0  5 10];
ytick=[-10 -5 0  5 10];

%limits 
xlimits_set = [-15 15];
ylimits_set = [-10 10];

%%--------------------- Process parameter--------------------------------------%%
% Add boxes:
ax1 = nexttile;
%define limits for the boxes:
y_box_red = -10.95;
y_box_yellow = -5;
y_box_green = -2.5;
y_box_yellow_2 = 2.5;
y_box_red_2 = 5;

height_box_red = 6; 
height_box_yellow = 2.5; 
height_box_green = 5; 
height_box_red_2 = 5.95; 
%red
red_box = rectangle('Parent',ax1,'Position',[-14.95 y_box_red 29.9 height_box_red],'FaceColor',color_red,'EdgeColor','none'); % Plots the rectangle [x y w h]
%yellow
yellow_box = rectangle('Parent',ax1,'Position',[-14.95 y_box_yellow 29.9 height_box_yellow],'FaceColor',color_yellow,'EdgeColor','none'); % Plots the rectangle
%green
green_box = rectangle('Parent',ax1,'Position',[-14.95 y_box_green 29.9 height_box_green],'FaceColor',color_green,'EdgeColor','none'); % Plots the rectangle

%red 2
red_box_2 = rectangle('Parent',ax1,'Position',[-14.95 y_box_red_2 29.9 height_box_red_2],'FaceColor',color_red,'EdgeColor','none'); % Plots the rectangle [x y w h]
%yellow 2
yellow_box_2 = rectangle('Parent',ax1,'Position',[-14.95 y_box_yellow_2 29.9 height_box_yellow],'FaceColor',color_yellow,'EdgeColor','none'); % Plots the rectangle

set(ax1 ,'Layer', 'Top')%bring to the front
box on
% Plot results

hold on
    for i=1:9  % a loop, plot y1 against each column of X
      ph(i) = plot(X_axis(:,i)*100,((Result_C_total_fu(:,i)./result_c_total_initial).*100)-100, plotstyle{i},'LineWidth',line_width, 'MarkerSize',marker_size);
    if i<= length(colorstyle)
          j=i;
      elseif i> length(colorstyle) && i<= (2*length(colorstyle))
          j= i-length(colorstyle);
      elseif i > (2*length(colorstyle)) && i<= (3*length(colorstyle))
          j= i - (2*length(colorstyle));
      elseif i > (3*length(colorstyle)) && i<= (4*length(colorstyle))
          j= i - (3*length(colorstyle));
    end
      ph(i).Color = colorstyle{j};
    end

ytickformat('percentage');
xtickformat('percentage');
xlim( xlimits_set)
ylim( ylimits_set)
xticks(xtick)
yticks(ytick)
set(gca,'FontSize',Font_size_labels) 

hold off;

%define colors: 
color_red = [ 1.0000    0.8314    0.8314];
color_yellow = [ 1.0000    0.9490    0.7412];
color_green = [   0.8902    0.945    0.8275];

color_red_txt = [1.00 0.063 0.063];
color_yellow_txt = [1.00 0.812 0.047];
color_green_txt = [0.518 0.761 0.243];


%%---------------------Capital expenditures--------------------------------------%%

ax2 = nexttile;
%define limits for the boxes:
y_box_red = -10.95;
y_box_yellow = -5;
y_box_green = -2.5;
y_box_yellow_2 = 2.5;
y_box_red_2 = 5;

height_box_red = 6; 
height_box_yellow = 2.5; 
height_box_green = 5; 
height_box_red_2 = 5.95; 
%red
red_box = rectangle('Parent',ax2,'Position',[-14.95 y_box_red 29.9 height_box_red],'FaceColor',color_red,'EdgeColor','none'); % Plots the rectangle [x y w h]
%yellow
yellow_box = rectangle('Parent',ax2,'Position',[-14.95 y_box_yellow 29.9 height_box_yellow],'FaceColor',color_yellow,'EdgeColor','none'); % Plots the rectangle
%green
green_box = rectangle('Parent',ax2,'Position',[-14.95 y_box_green 29.9 height_box_green],'FaceColor',color_green,'EdgeColor','none'); % Plots the rectangle

%red 2
red_box_2 = rectangle('Parent',ax2,'Position',[-14.95 y_box_red_2 29.9 height_box_red_2],'FaceColor',color_red,'EdgeColor','none'); % Plots the rectangle [x y w h]
%yellow 2
yellow_box_2 = rectangle('Parent',ax2,'Position',[-14.95 y_box_yellow_2 29.9 height_box_yellow],'FaceColor',color_yellow,'EdgeColor','none'); % Plots the rectangle

set(ax2 ,'Layer', 'Top')%bring to the front
box on

hold on
    for i=10:16  % a loop, plot y1 against each column of X
      ph(i) = plot(X_axis(:,i)*100,((Result_C_total_fu(:,i)./result_c_total_initial).*100)-100, plotstyle{i}, 'LineWidth',line_width, 'MarkerSize',marker_size);
    if i<= length(colorstyle)
          j=i;
      elseif i> length(colorstyle) && i<= (2*length(colorstyle))
          j= i-length(colorstyle);
      elseif i > (2*length(colorstyle)) && i<= (3*length(colorstyle))
          j= i - (2*length(colorstyle));
      elseif i > (3*length(colorstyle)) && i<= (4*length(colorstyle))
          j= i - (3*length(colorstyle));
    end
      ph(i).Color = colorstyle{j};
    end

ytickformat('percentage');
xtickformat('percentage');
xlim( xlimits_set)
ylim( ylimits_set)
xticks(xtick)
yticks(ytick)
set(gca,'FontSize',Font_size_labels) 
hold off;

%%---------------------Prices of utilities and feedstocks--------------------------------------%%

ax3 = nexttile;

%define limits for the boxes:
y_box_red = -10.95;
y_box_yellow = -5;
y_box_green = -2.5;
y_box_yellow_2 = 2.5;
y_box_red_2 = 5;

height_box_red = 6; 
height_box_yellow = 2.5; 
height_box_green = 5; 
height_box_red_2 = 5.95; 
%red
red_box = rectangle('Parent',ax3,'Position',[-14.95 y_box_red 29.9 height_box_red],'FaceColor',color_red,'EdgeColor','none'); % Plots the rectangle [x y w h]
%yellow
yellow_box = rectangle('Parent',ax3,'Position',[-14.95 y_box_yellow 29.9 height_box_yellow],'FaceColor',color_yellow,'EdgeColor','none'); % Plots the rectangle
%green
green_box = rectangle('Parent',ax3,'Position',[-14.95 y_box_green 29.9 height_box_green],'FaceColor',color_green,'EdgeColor','none'); % Plots the rectangle

%red 2
red_box_2 = rectangle('Parent',ax3,'Position',[-14.95 y_box_red_2 29.9 height_box_red_2],'FaceColor',color_red,'EdgeColor','none'); % Plots the rectangle [x y w h]
%yellow 2
yellow_box_2 = rectangle('Parent',ax3,'Position',[-14.95 y_box_yellow_2 29.9 height_box_yellow],'FaceColor',color_yellow,'EdgeColor','none'); % Plots the rectangle

set(ax3 ,'Layer', 'Top')%bring to the front
box on

hold on
    for i=17:21  % a loop, plot y1 against each column of X
      ph(i) = plot(X_axis(:,i)*100,((Result_C_total_fu(:,i)./result_c_total_initial).*100)-100, plotstyle{i}, 'LineWidth',line_width, 'MarkerSize',marker_size);
    if i<= length(colorstyle)
          j=i;
      elseif i> length(colorstyle) && i<= (2*length(colorstyle))
          j= i-length(colorstyle);
      elseif i > (2*length(colorstyle)) && i<= (3*length(colorstyle))
          j= i - (2*length(colorstyle));
      elseif i > (3*length(colorstyle)) && i<= (4*length(colorstyle))
          j= i - (3*length(colorstyle));
    end
      ph(i).Color = colorstyle{j};    
    end

ytickformat('percentage');
xtickformat('percentage');
xlim( xlimits_set)
ylim( ylimits_set)
xticks(xtick)
yticks(ytick)
set(gca,'FontSize',Font_size_labels) 
hold off;

%%---------------------General assumption--------------------------------------%%

ax4 = nexttile;

%define limits for the boxes:
y_box_red = -10.95;
y_box_yellow = -5;
y_box_green = -2.5;
y_box_yellow_2 = 2.5;
y_box_red_2 = 5;

height_box_red = 6; 
height_box_yellow = 2.5; 
height_box_green = 5; 
height_box_red_2 = 5.95; 
%red
red_box = rectangle('Parent',ax4,'Position',[-14.95 y_box_red 29.9 height_box_red],'FaceColor',color_red,'EdgeColor','none'); % Plots the rectangle [x y w h]
%yellow
yellow_box = rectangle('Parent',ax4,'Position',[-14.95 y_box_yellow 29.9 height_box_yellow],'FaceColor',color_yellow,'EdgeColor','none'); % Plots the rectangle
%green
green_box = rectangle('Parent',ax4,'Position',[-14.95 y_box_green 29.9 height_box_green],'FaceColor',color_green,'EdgeColor','none'); % Plots the rectangle

%red 2
red_box_2 = rectangle('Parent',ax4,'Position',[-14.95 y_box_red_2 29.9 height_box_red_2],'FaceColor',color_red,'EdgeColor','none'); % Plots the rectangle [x y w h]
%yellow 2
yellow_box_2 = rectangle('Parent',ax4,'Position',[-14.95 y_box_yellow_2 29.9 height_box_yellow],'FaceColor',color_yellow,'EdgeColor','none'); % Plots the rectangle

set(ax4 ,'Layer', 'Top')%bring to the front
box on

hold on
    for i=22:22  % a loop, plot y1 against each column of X
      ph(i) = plot(X_axis(:,i)*100,((Result_C_total_fu(:,i)./result_c_total_initial).*100)-100, plotstyle{i}, 'LineWidth',line_width, 'MarkerSize',marker_size);
    if i<= length(colorstyle)
          j=i;
      elseif i> length(colorstyle) && i<= (2*length(colorstyle))
          j= i-length(colorstyle);
      elseif i > (2*length(colorstyle)) && i<= (3*length(colorstyle))
          j= i - (2*length(colorstyle));
      elseif i > (3*length(colorstyle)) && i<= (4*length(colorstyle))
          j= i - (3*length(colorstyle));
    end
      ph(i).Color = colorstyle{j};    
    end

ytickformat('percentage');
xtickformat('percentage');
xlim( xlimits_set)
ylim( ylimits_set)
xticks(xtick)
yticks(ytick)
set(gca,'FontSize',Font_size_labels) 
hold off;

% Add X and Y labels for the entire graph
xlabel(graph_tiles,'Change in input', 'FontSize',size_font)
ylabel(graph_tiles,'Change in levelised cost of product','FontSize',size_font)
graph_tiles.TileSpacing = 'compact';


%% profit alone

figure
clf

hold on
    for i=1:length(SENSI_NUM)  % a loop, plot y1 against each column of X
      ph(i) = plot(X_axis(:,i)*100,((Result_Profit_total(:,i)./result_profit_inital).*100)-100, plotstyle{i}, 'LineWidth',1, 'MarkerSize',4);
    end
    title('Direct,profit')
xlabel('Change in variable','FontSize',Font_size_labels)
ylabel('Change in profit','FontSize',Font_size_labels)
ytickformat('percentage');
xtickformat('percentage');
xlim( [-15 15])
ylim([-15 15])
%xticks([-15 0 15])
%yticks([-50 0 50])
set(gca,'FontSize',12) 
hold off

legend(SENSI_TXT(2:SENSI_NUM(3,7)+1,1),'Location','NorthOutside','Orientation','Horizontal','NumColumns', 6);
lh.Layout.Tile = 'North'; % <----- relative to tiledlayou

%% cost alone
%insert background boxes
figure1 = figure;
axes1 = axes('Parent', figure1);
hold(axes1,'on');


%define colors: 
color_red = [ 1.0000    0.8314    0.8314];
color_yellow = [ 1.0000    0.9490    0.7412];
color_green = [   0.8902    0.945    0.8275];

color_red_txt = [1.00 0.063 0.063];
color_yellow_txt = [1.00 0.812 0.047];
color_green_txt = [0.518 0.761 0.243];


%define limits for the boxes:
y_box_red = -10.95;
y_box_yellow = -5;
y_box_green = -2.5;
y_box_yellow_2 = 2.5;
y_box_red_2 = 5;

height_box_red = 6; 
height_box_yellow = 2.5; 
height_box_green = 5; 
height_box_red_2 = 5.95; 
%red
red_box = rectangle('Parent',axes1,'Position',[-14.95 y_box_red 29.9 height_box_red],'FaceColor',color_red,'EdgeColor','none'); % Plots the rectangle [x y w h]
%yellow
yellow_box = rectangle('Parent',axes1,'Position',[-14.95 y_box_yellow 29.9 height_box_yellow],'FaceColor',color_yellow,'EdgeColor','none'); % Plots the rectangle
%green
green_box = rectangle('Parent',axes1,'Position',[-14.95 y_box_green 29.9 height_box_green],'FaceColor',color_green,'EdgeColor','none'); % Plots the rectangle

%red 2
red_box_2 = rectangle('Parent',axes1,'Position',[-14.95 y_box_red_2 29.9 height_box_red_2],'FaceColor',color_red,'EdgeColor','none'); % Plots the rectangle [x y w h]
%yellow 2
yellow_box_2 = rectangle('Parent',axes1,'Position',[-14.95 y_box_yellow_2 29.9 height_box_yellow],'FaceColor',color_yellow,'EdgeColor','none'); % Plots the rectangle



set(axes1 ,'Layer', 'Top')%bring to the front

% insert text description: 

%get axis location:
ax = gca;
AxesPos = get(ax, 'position'); %Output [AxesPos" contains 4 values:  AxesPos(1:4) = left position, bottom position, Axes width, Axes height.  (see the first figure, above).  I'll name these [Ax_xpos,  Ax_ypos,  Ax_width, Ax_height]
xscale = get(ax, 'xlim' );%xscale contains [xmin, xmax], 
yscale = get(ax, 'ylim');% yscale contains [ymin, ymax].


%red box annotation: 
position_high_x = (xscale(2)+0.001 - xscale(1))/(xscale(2)-xscale(1))* AxesPos(3)+AxesPos(1);
position_high_y = (y_box_red+(-8+height_box_red)/2 - yscale(1))/(yscale(2)-yscale(1))* AxesPos(4)+AxesPos(2);
Text_red = annotation('textbox', [position_high_x, position_high_y, 0, 0], 'string', 'High', 'FontSize', 14,'Color',color_red_txt);

%yellow box annotation:
position_high_x = (xscale(2)+0.001 - xscale(1))/(xscale(2)-xscale(1))* AxesPos(3)+AxesPos(1);
position_high_y = (y_box_yellow+(-8+height_box_yellow)/2 - yscale(1))/(yscale(2)-yscale(1))* AxesPos(4)+AxesPos(2);
Text_yellow = annotation('textbox', [position_high_x, position_high_y, 0, 0], 'string', 'Medium', 'FontSize', 14,'Color',color_yellow_txt);

%green box annotation: 
position_high_x = (xscale(2)+0.001 - xscale(1))/(xscale(2)-xscale(1))* AxesPos(3)+AxesPos(1);
position_high_y = (y_box_green+(-8+height_box_green)/2 - yscale(1))/(yscale(2)-yscale(1))* AxesPos(4)+AxesPos(2);
Text_green = annotation('textbox', [position_high_x, position_high_y, 0, 0], 'string', 'Low', 'FontSize', 14,'Color',color_green_txt);

% yellow box annotation 2: 
position_high_x = (xscale(2)+0.001 - xscale(1))/(xscale(2)-xscale(1))* AxesPos(3)+AxesPos(1);
position_high_y = (y_box_yellow_2+(-8+height_box_yellow)/2 - yscale(1))/(yscale(2)-yscale(1))* AxesPos(4)+AxesPos(2);
Text_yellow_2 = annotation('textbox', [position_high_x, position_high_y, 0, 0], 'string', 'Medium', 'FontSize', 14,'Color',color_yellow_txt);


%red box annotation: 
position_high_x = (xscale(2)+0.001 - xscale(1))/(xscale(2)-xscale(1))* AxesPos(3)+AxesPos(1);
position_high_y = (y_box_red_2+(-8+height_box_red)/2 - yscale(1))/(yscale(2)-yscale(1))* AxesPos(4)+AxesPos(2);
Text_red_2 = annotation('textbox', [position_high_x, position_high_y, 0, 0], 'string', 'High', 'FontSize', 14,'Color',color_red_txt);



hold on
    for i=1:length(SENSI_NUM)  % a loop, plot y1 against each column of X
      ph(i) = plot(X_axis(:,i)*100,((Result_C_total_fu(:,i)./result_c_total_initial).*100)-100, plotstyle{i}, 'LineWidth',1, 'MarkerSize',4);
    end
    %title('One-way')

ytickformat('percentage');
xtickformat('percentage');
xlim( [-15 15])
ylim([-11 11])
%xticks([-15 0 15])
yticks([-10 -5 0  5 10])
set(gca,'FontSize',14) 

% set axis:

ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';

% create labels:
text(-16, 0, 'Change in levelised cost of product', 'Rotation',90, 'VerticalAlignment','bottom', 'HorizontalAlignment','center','FontSize',14)
text(0, -11, 'S', 'VerticalAlignment','top', 'HorizontalAlignment','center','FontSize',14)
%put a box
box on
%Change in input SRCC S \delta
%put axis to the front
set(gca,'Layer','top')

hold off

legend(SENSI_TXT(2:SENSI_NUM(3,7)+1,1),'Location','NorthOutside','Orientation','Horizontal','NumColumns', 4);
lh.Layout.Tile = 'North'; % <----- relative to tiledlayou
%}
