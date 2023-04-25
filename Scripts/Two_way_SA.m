%% ----------------------% Multiple Way SA %----------------------%%

%% ------------------------------ One at a time Sensitivity Analysis--------------------- %%
clear all
tic

addpath(genpath('C:\Users\TSR\Desktop\matlab_March_2020\updated Model\TEA_Model V3_0_01 - Uncertainty analysis paper'))

%% Sensitivity analysis
%Import sensitvity analysis restrictions
[SENSI_NUM,SENSI_TXT,~] = xlsread('Control_Sheet_V3_0_1_uncertainty.xlsx','SA','M3:S24');
%[SENSI_NUM,SENSI_TXT,~] = xlsread('Control_Sheet_V3_0_1_uncertainty.xlsx','SA','B3:H24');% for all variables

[number_var,~] = size(SENSI_NUM);


%%
step = 10;%number of steps for each side sensitivity analsis
runs = factorial(number_var)/(factorial(number_var-2)*factorial(2));  %n! / ((n - m)! * m!)  with n number of eleemnts, and m number of elements in one pair (=2)


%% import for script
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
Result_C_total_fu = zeros(step,runs);
Result_Profit_total = zeros(step,runs);
X_sensi = zeros(step,number_var);
X_analysis = zeros(step^2,runs);
Y_analysis = zeros(step^2,runs);
Label_analysis = cell(runs,1);
Label_analysis_x = cell(runs,1);
Label_analysis_y = cell(runs,1);
%%
%create x-axis and y-axis sensitivity analysis: 
for v_1 = 1: number_var 
   values_sensi =linspace(SENSI_NUM(v_1,2),SENSI_NUM(v_1,3),step);
   values_sensi = reshape(values_sensi,[],1);
   X_sensi(:,v_1) = values_sensi; 
end

%% calculate Two at a time SA
%running indices:
i_analysis = 1 ; % first position in the list of variables
ii_analysis = 2; % second position in the list of variables
%%
for v = 1: runs % run for each set of two variables once
 
% set import matrices into initial state: 
I1 = I1_initial;
I2 = I2_initial;
I3 = I3_initial;
I4 = I4_initial; 

%create X and Y vectors for sensivity analysis
X = X_sensi(:,i_analysis);
Y = X_sensi(:,ii_analysis);

%create samples for the sensitivty analysis
[X_mesh,Y_mesh] = meshgrid (X,Y);
X_analysis(:,v) = reshape(X_mesh, [],1);
Y_analysis(:,v) = reshape(Y_mesh, [],1);
Label_analysis(v,1) = strcat(SENSI_TXT(i_analysis,1),' & ',SENSI_TXT(ii_analysis,1));
Label_analysis_x(v,1) = SENSI_TXT(i_analysis,1);
Label_analysis_y(v,1) = SENSI_TXT(ii_analysis,1);

% Select correct scenario:
fu_cement_replacement = 272000;

%% Run sensitivity analysis
[l_x_analysis, ~] = size(X_analysis);
for iii=1:l_x_analysis
      
% replace sensitive X variable from input matrix:
  if SENSI_NUM(i_analysis,4) == 1 % check for right input array to alter sensitive variables
    I1(SENSI_NUM(i_analysis,5),SENSI_NUM(i_analysis,6)) = X_analysis(iii,v);
 elseif SENSI_NUM(i_analysis,4) == 2 % check for right input array to alter sensitive variables
    I2(SENSI_NUM(i_analysis,5),SENSI_NUM(i_analysis,6)) = X_analysis(iii,v);
 elseif SENSI_NUM(i_analysis,4) == 4 % check for right input array to alter sensitive variables
    I4(SENSI_NUM(i_analysis,5),SENSI_NUM(i_analysis,6)) = X_analysis(iii,v);
 else
     %disp('No variable in Matrix found that can be altered. This calculation wont have any results. Change input input matrix in Excel sheet !!!!!!!!!')
  end
 
% replace sensitive Y variable from input matrix:
if SENSI_NUM(ii_analysis,4) == 1 % check for right input array to alter sensitive variables
    I1(SENSI_NUM(ii_analysis,5),SENSI_NUM(ii_analysis,6)) = Y_analysis(iii,v);
 elseif SENSI_NUM(ii_analysis,4) == 2 % check for right input array to alter sensitive variables
    I2(SENSI_NUM(ii_analysis,5),SENSI_NUM(ii_analysis,6)) = Y_analysis(iii,v);
 elseif SENSI_NUM(ii_analysis,4) == 4 % check for right input array to alter sensitive variables
    I4(SENSI_NUM(ii_analysis,5),SENSI_NUM(ii_analysis,6)) = Y_analysis(iii,v);
 else
     %disp('No variable in Matrix found that can be altered. This calculation wont have any results. Change input input matrix in Excel sheet !!!!!!!!!')
  end
 
 
run Mass_Balance_V3_0.m
run Energy_Balance_V3_0.m
run CapEx_V3_0.m
run OpEx_V3_0.m
run Revenue_Model_V3_0.m

% Calculate total costs & relative costs to produced Carbonate
Result_C_total_fu(iii,v) = c_total/fu_cement_replacement; % in [EUR/tonne cement replacement]
Result_Profit_total(iii,v) = rev_total - c_total; % in[EUR/a]
end

%advance index for next two-way analysis: 
ii_analysis = ii_analysis+1 ; %Advance second index one step

if ii_analysis== number_var+1 %check if you already reached end of the end of the list
    i_analysis = i_analysis+1; %advance first index by one
   ii_analysis = i_analysis+1; %set new second index one after the new first index (i+1);
end


end
disp ('Calculations are done.')
toc

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

%% Plot results --------------------------------------------------------%%
figure
clf;
graph_tiles = tiledlayout(5,3); % Requires R2019b or later
%graph_tiles = tiledlayout(10,22); % Requires R2019b or later


%change scale for X_sio2:
for i_change = 1:5
X_analysis(:,i_change) = X_analysis(:,i_change)/0.2; % adapt to content in scm not in cement => always check this line
end

%define color bar limits for all plots: 
bottom = min(min(Result_C_total_fu)./result_c_total_initial)-1; 
top = max(max(Result_C_total_fu)./result_c_total_initial)-1;

%define color map: 
 
%vec = [-0.15;    -0.125;   -0.1;       -0.05;      0;      0.05;       0.1;       0.15;        0.2];%set limits
%hex = ['#B2F39E';'#9CEEB6';'#f5f5f5';'#e3e3e3';'#bfbfbf';'#b54141';'#b51919';'#8a1212';]; %set colors min to max
vec = [-0.15;   -0.125;   -0.1;   -0.075;    -0.05;  -0.025;    0;  0.025;    0.05;   0.075;    0.1;  0.125;     0.15];%;      0.2; 0.225];%set limits
%{
reds = ['#bf6b6b' ; '#ba5050'; '#b63535'; '#b11b1b'; '#ae0909'];
greys = ['#f5f5f5';'#ececec';'#e3e3e3';'#dadada';'#d1d1d1';'#cdcdcd';'#c4c4c4';'#bfbfbf'];
greens = ['#B2F39E';'#9CEEB6';'#c5edd2'];
%}
reds = ['#ba5050'; '#b11b1b'; '#ae0909'];%['#bf6b6b' 
greys = ['#ececec';'#e3e3e3';'#dadada';'#d1d1d1'];
yellows_high = ['#FFBA66';'#FBBC41';]; %['#ffd5a1';
yellows_low = ['#ffe0ba';'#ffead1'];
greens = ['#138A93';'#33B8A1';];

hex = [greens; yellows_low; greys; yellows_high; reds]; %set colors min to max
map = sscanf(hex','#%2x%2x%2x',[3,size(hex,1)]).' / 255;% create color map


i_plot_result = 1;

for i_plot = 1:runs %runs
%reshape matrices to fit surface plot
X_plot = reshape(X_analysis(:,i_plot),[step, step]);
Y_plot = reshape (Y_analysis(:,i_plot),[step,step]);
Z_plot = reshape ((Result_C_total_fu(:,i_plot)./result_c_total_initial -1),[step,step]);

Max_Z(i_plot) =max( max(abs(Z_plot))); % calculate maximum increase for all combinations. 
%create axes for each plot:
%ax(i_plot) = axes;

plot_axis(i_plot) = nexttile;
%plot(i_plot) =  surf(X_plot,Y_plot,Z_plot); %surface plot
%surfc(X_plot,Y_plot,Z_plot); %surface & contour plot
contourf(X_plot,Y_plot,Z_plot)
%plot(i_plot) =  mesh(X_plot,Y_plot,Z_plot);
%plot3(X_plot,Y_plot,Z_plot);

title(Label_analysis(i_plot))
xlabel(Label_analysis_x(i_plot))
ylabel(Label_analysis_y(i_plot))
%ztickformat('percentage');
set(gca,'FontSize',8)
set(gca,'zlim',[-0.15 0.15])


dif_color_each_plot = 0 ; %set it to 1 if diffrent colormap should be selected via limits. 
%change color maps if combination is extreme
if dif_color_each_plot ==1
if min(min(Z_plot))<-0.10  || max(max(Z_plot))>0.15
    colormap(plot_axis(i_plot),hot(12))
else
    colormap(plot_axis(i_plot),parula(12))
end
else
     colormap(plot_axis(i_plot),map)
end
shading interp

  
if min(min(Z_plot))<-0.10  || max(max(Z_plot))>0.10
    Result_high_impact_combinations(i_plot_result,:) = [Label_analysis(i_plot) min(min(Z_plot)) max(max(Z_plot))];
    i_plot_result = i_plot_result+1;
end

%set limits to color bar: 
caxis manual
caxis([-0.15 0.175])
%axis off
end

%xlabel(graph_tiles,'Value of Input variable', 'FontSize',10)
%ylabel(graph_tiles,'Change in Levelised costs of production','FontSize',10)


%plot as individual figure
plot_indi = 1 ; % set to one if you want individual plots

%define color bar limits for all plots: 
bottom = min(min(Result_C_total_fu)./result_c_total_initial)-1; 
top = max(max(Result_C_total_fu)./result_c_total_initial)-1;


if plot_indi == 1
for i_plot = 1:1 %runs
%reshape matrices to fit surface plot
X_plot = reshape(X_analysis(:,i_plot),[step, step]);
Y_plot = reshape (Y_analysis(:,i_plot),[step,step]);
Z_plot = reshape (Result_C_total_fu(:,i_plot),[step,step]);

figure
%plot_indi(i_plot) =  surf(X_plot,Y_plot,Z_plot); %surface plot
%surfc(X_plot,Y_plot,Z_plot); %surface & contour plot
contourf (X_plot,Y_plot,Z_plot); 
%contourf(X_plot,Y_plot,Z_plot)
%plot(i_plot) =  mesh(X_plot,Y_plot,Z_plot);

title(Label_analysis(i_plot))
xlabel(Label_analysis_x(i_plot))
ylabel(Label_analysis_y(i_plot))
set(gca,'FontSize',8)
set(gca,'zlim',[120 150])
colormap(map)
shading interp

cb = colorbar;
%set limits to color bar: 
caxis manual
caxis([-0.15 0.175])
end
end
sound(sin(2*pi*1000*(0:1/4000:20/1000)),4000)
%{









%% Costs
%create x axis direct:
for i_plot = 1: length(SENSI_NUM)
X_axis(:,i_plot) = (X_sensi(:,i_plot)./SENSI_NUM(i_plot))-1;
end

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
color2=[0.1986, 0.7214,0.6310];
color1=[0.9856,0.7372, 0.2537];
color_area_neg =[0.9856,0.7372, 0.2537]; %[0.886, 0.250, 0.313];
color_area_pos = [0.1986 0.7214 0.6310];
area_trans = 0.4;
size_font = 14;

figure 
%plot high data (+15%) 
h = barh(sorted_data_high);
h.FaceColor = color_area_pos;
h.FaceAlpha =0.5;
h.EdgeColor = color2;

hold on
%plot low data (-15%)
h2 = barh(sorted_data_low,'r')
h2.FaceColor = color_area_neg;
h2.FaceAlpha =0.5;
h2.EdgeColor = color1;

bh = get(h,'BaseLine');
set(bh,'BaseValue',0);
title('Sensitivities')
set(gca,'yticklabel',sorted_labels)
set(gca,'Ytick',[1:length(sorted_labels)],'YTickLabel',[1:length(sorted_labels)])
set(gca,'yticklabel',sorted_labels)
xlabel('Change of LCOP')
xticks([-0.15 -0.10 -0.05 0 0.05 0.1 0.15])
xlim([-0.15 0.15])

%saveas(gcf,'SA.png')
 
%% Profit
%create x axis direct:
for i_plot = 1: length(SENSI_NUM)
X_axis(:,i_plot) = (X_sensi(:,i_plot)./SENSI_NUM(i_plot))-1;
end

%create labels
labels = SENSI_TXT(2:end,1);
data = Result_Profit_total/result_profit_inital-1;

%sort data
[~, new_indices] = sort(sum(abs(data))); % sorts in *ascending* order
sorted_data_low = data(1,new_indices);
sorted_data_high = data(2,new_indices);
sorted_data = [sorted_data_low;sorted_data_high];
sorted_labels = labels(new_indices); 

%set color
color2=[0.1986, 0.7214,0.6310];
color1=[0.9856,0.7372, 0.2537];
color_area_neg =[0.9856,0.7372, 0.2537]; %[0.886, 0.250, 0.313];
color_area_pos = [0.1986 0.7214 0.6310];
area_trans = 0.4;
size_font = 14;

figure 
%plot high data (+15%) 
h = barh(sorted_data_high);
h.FaceColor = color_area_pos;
h.FaceAlpha =0.5;
h.EdgeColor = color2;

hold on
%plot low data (-15%)
h2 = barh(sorted_data_low,'r')
h2.FaceColor = color_area_neg;
h2.FaceAlpha =0.5;
h2.EdgeColor = color1;

bh = get(h,'BaseLine');
set(bh,'BaseValue',0);
title('Sensitivities')
set(gca,'yticklabel',sorted_labels)
set(gca,'Ytick',[1:length(sorted_labels)],'YTickLabel',[1:length(sorted_labels)])
set(gca,'yticklabel',sorted_labels)
xlabel('Change of profit')
%xticks([-0.15 -0.10 -0.05 0 0.05 0.1 0.15])
%xlim([-0.15 0.15])

%saveas(gcf,'CO2.png')

%}

