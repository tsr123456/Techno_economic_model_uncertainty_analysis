%% ------------------------------ One at a time Sensitivity Analysis--------------------- %%
clear all
tic

%% Sensitivity analysis
step = 2;%number of steps fyor each side sensitivity analsis

%Import sensitvity analysis restrictions (+-15%)
[SENSI_NUM,SENSI_TXT,~] = xlsread('Control_Sheet_V3_0_1_uncertainty.xlsx','Assumptions','H60:O84');

%Import sensitivity analysis restrictions [min, max]
%[SENSI_NUM,SENSI_TXT,~] = xlsread('Control_Sheet_V3_0_1_uncertainty.xlsx','SA','B27:I48');


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
Result_C_total_fu = zeros(step,SENSI_NUM(3,7));
Result_Rev_total_fu = zeros(step,SENSI_NUM(3,7));
Result_Profit_total = zeros(step,SENSI_NUM(3,7));

[runs_analysis, ~] = size(SENSI_NUM); % determine number of runs

%create x-axis sensitivity analysis: 
for v_1 = 1:runs_analysis
    values_sensi_low =SENSI_NUM(v_1,2);
    values_sensi_high = SENSI_NUM(v_1,3);
    values_sensi = [values_sensi_low values_sensi_high];
    values_sensi = reshape(values_sensi,step,1);
    X_sensi(:,v_1) = values_sensi;
end

%% calculate One at a time SA values:

for v = 1: runs_analysis % if only one variable should be changed, replace this
    
%create vector for sensivity analysis 
x_sensi = X_sensi(:,v);

% set import matrices into initial state: 
I1 = I1_initial;
I2 = I2_initial;
I3 = I3_initial;
I4 = I4_initial; 

 
% Select correct scenario:
[length_sensi, ~] = size(SENSI_NUM);

fu_cement_replacement = 272000;
%% Run sensitivity analysis

for w=1:step
      
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


%% Plot results --------------------------------------------------------%%

%create labels
labels = SENSI_TXT(2:end,1);
data = Result_C_total_fu./result_c_total_initial-1;

%sort data
[~, new_indices] = sort(sum(abs(data))); % sorts in *ascending* order
sorted_data_low = data(1,new_indices);
sorted_data_high = data(2,new_indices);
sorted_data = [sorted_data_low;sorted_data_high];
sorted_labels = labels(new_indices); 

%set color
color2=[0.1986, 0.7214,0.6310]; % Hex: #f8dca4
color1=[0.9856,0.7372, 0.2537]; %Hex: #99dbd1
color_area_neg =[0.9856,0.7372, 0.2537]; %[0.886, 0.250, 0.313];
color_area_pos = [0.1986 0.7214 0.6310];
area_trans = 0.4;
size_font = 14;


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
y_box_red = 20.5;
y_box_yellow = 11.5;
y_box_green = 0; 

height_box_red = 3; 
height_box_yellow = 9; 
height_box_green = 11.5; 


%red
red_box = rectangle('Parent',axes1,'Position',[-15 y_box_red 30 height_box_red],'FaceColor',color_red,'EdgeColor','none'); % Plots the rectangle
%yellow
yellow_box = rectangle('Parent',axes1,'Position',[-15 y_box_yellow 30 height_box_yellow],'FaceColor',color_yellow,'EdgeColor','none'); % Plots the rectangle
%green
green_box = rectangle('Parent',axes1,'Position',[-15 y_box_green 30 height_box_green],'FaceColor',color_green,'EdgeColor','none'); % Plots the rectangle
set(axes1 ,'Layer', 'Top')%bring to the front

% insert line
bh = xline(0,'--');

%set axis limits: 
xticks([-15 -10 -5 0 5 10 15])
xlim([-15 15])

% insert text description: 

%get axis location:
ax = gca;
AxesPos = get(ax, 'position'); %Output [AxesPos" contains 4 values:  AxesPos(1:4) = left position, bottom position, Axes width, Axes height.  (see the first figure, above).  I'll name these [Ax_xpos,  Ax_ypos,  Ax_width, Ax_height]
xscale = get(ax, 'xlim' );%xscale contains [xmin, xmax], 
yscale = get(ax, 'ylim');% yscale contains [ymin, ymax].

%red box annotation: 
position_high_x = (xscale(2)+0.001 - xscale(1))/(xscale(2)-xscale(1))* AxesPos(3)+AxesPos(1);
position_high_y = (y_box_red + 5 - yscale(1))/(yscale(2)-yscale(1))* AxesPos(4)+AxesPos(2);
Text_red = annotation('textbox', [position_high_x, position_high_y, 0, 0], 'string', 'High', 'FontSize', 14,'Color',color_red_txt);

%red box annotation:
position_high_x = (xscale(2)+0.001 - xscale(1))/(xscale(2)-xscale(1))* AxesPos(3)+AxesPos(1);
position_high_y = (y_box_yellow+ 8 - yscale(1))/(yscale(2)-yscale(1))* AxesPos(4)+AxesPos(2);
Text_yellow = annotation('textbox', [position_high_x, position_high_y, 0, 0], 'string', 'Medium', 'FontSize', 14,'Color',color_yellow_txt);

%yellow box annotation: 
position_high_x = (xscale(2)+0.001 - xscale(1))/(xscale(2)-xscale(1))* AxesPos(3)+AxesPos(1);
position_high_y = (y_box_green+ 10 - yscale(1))/(yscale(2)-yscale(1))* AxesPos(4)+AxesPos(2);
Text_yellow = annotation('textbox', [position_high_x, position_high_y, 0, 0], 'string', 'Low', 'FontSize', 14,'Color',color_green_txt);


%plot high data (+15%): 
h = barh(sorted_data_high.*100);
h.FaceColor = color_area_pos;
h.FaceAlpha =0.5;
h.EdgeColor = color2;

hold on
%plot low data (-15%):
h2 = barh(sorted_data_low.*100,'r');
h2.FaceColor = color_area_neg;
h2.FaceAlpha =0.5;
h2.EdgeColor = color1;

%Add labels:
set(gca,'yticklabel',sorted_labels)
set(gca,'Ytick',[1:length(sorted_labels)],'YTickLabel',[1:length(sorted_labels)])
set(gca,'yticklabel',sorted_labels)
xlabel('Change of levelised cost of product')
xtickformat('percentage')


plots_ident = [h2; h];
legend(plots_ident,'-15%', '+15%','Location','NorthOutside','Orientation','Horizontal','NumColumns', 2)

ylim([0 length(sorted_labels)+1])

set(gca,'FontSize',14)


box on



