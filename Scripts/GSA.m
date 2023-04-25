%% ----------------------% UQ_lab_test_TEA_V3_0_1 %----------------------%%


%%---------------------------------- Important!!-----------------------%%%
% Below insert the path to the UQlab folder.
%The script was developed using UQLab v1.4.0

warning('off','all');
rmpath(genpath('C:INSERT PATH OF UQLAB FOLDER HERE'));
warning('on','all');
%%-----------------------------------------------------------------------%%%

clearvars
rng(10000000,'twister')
uqlab


%% Select what analysis ot do:
sobol = 0;
scatter_analysis = 1; 
rank_correlation = 0;
spearman_rank_correlation = 0;
borgonovo = 0;

%% Select PDF selction style:
pdf_hawer = 0;
pdf_uniform = 0;
pdf_max_entropie = 1;
pdf_max_entropie_pessimistic = 0;
pdf_functionalization = 0; 


%% load Model Input matrices-----------------------------------------------
global I1_initial
global I2_initial
global I3_initial
global I4_initial
global MonteCarlo_Para

I1_initial = zeros(130,3);
I2_initial = zeros(130,3);
I3_initial = zeros(130,10);
I4_initial = zeros(130*12);

I1_initial = xlsread('Control_Sheet_V3_0_1_uncertainty.xlsx','Matlab_input','C3:E132','basic');
I2_initial = xlsread('Control_Sheet_V3_0_1_uncertainty.xlsx','Matlab_input','H3:J132','basic');
I3_initial = xlsread('Control_Sheet_V3_0_1_uncertainty.xlsx','Matlab_input','M3:V132','basic');
I4_initial = xlsread('Control_Sheet_V3_0_1_uncertainty.xlsx','Matlab_input','Y3:AJ132','basic');


if pdf_hawer ==1
MonteCarlo_Para = xlsread('Monte_Carlo_Input_UQ.xlsx','Hawer','B2:K22','basic'); % import parameters for the montecarlo simulation
[~,SENSI_TXT,~] = xlsread('Monte_Carlo_Input_UQ.xlsx','Hawer','A2:A22','basic');
elseif pdf_uniform ==1
MonteCarlo_Para = xlsread('Monte_Carlo_Input_UQ.xlsx','Uniform','B2:K22','basic'); % import parameters for the montecarlo simulation        
[~,SENSI_TXT,~] = xlsread('Monte_Carlo_Input_UQ.xlsx','Uniform','A2:A22','basic');
elseif pdf_max_entropie ==1
MonteCarlo_Para = xlsread('Monte_Carlo_Input_UQ.xlsx','Max_Entropie','B2:L22','basic'); % import parameters for the montecarlo simulation   
[~,SENSI_TXT,~] = xlsread('Monte_Carlo_Input_UQ.xlsx','Max_Entropie','A2:L22','basic');
elseif pdf_max_entropie_pessimistic ==1
MonteCarlo_Para = xlsread('Monte_Carlo_Input_UQ.xlsx','Max_Entropie_pessimistic','B2:K22','basic'); % import parameters for the montecarlo simulation   
[~,SENSI_TXT,~] = xlsread('Monte_Carlo_Input_UQ.xlsx','Max_Entropie_pessimistic','A2:A22','basic');
end

% for the functionalization of the model
if pdf_functionalization ==1
    MonteCarlo_Para = xlsread('Monte_Carlo_Input_UQ.xlsx','Functionalization','B2:K22','basic'); % import parameters for the montecarlo simulation
[~,SENSI_TXT,~] = xlsread('Monte_Carlo_Input_UQ.xlsx','Functionalization','A2:A22','basic');
end    


%Min_Max_MonteCarlo_Para = xlsread('Control_Sheet_V3_0_1_uncertainty.xlsx','Assumptions','J61:K74');
%location_parameters = xlsread('Control_Sheet_V3_0_1_uncertainty.xlsx','Assumptions','L61:N74');

%% UQ Lab model:-----------------------------------------------------------
tic

%Specify the function in the options for the MODEL object:
Model1Opts.mFile = 'CondensedModel_UQ_LAB_V3_0';

%Create the MODEL object:
myModel_mFile = uq_createModel(Model1Opts);

%% specify variables-------------------------------------------------------

[MonteCarlo_Para_number, ~] = size (MonteCarlo_Para);

for ii = 1:MonteCarlo_Para_number
    if MonteCarlo_Para(ii,4)== 1 % check and create uniform distribution
      InputOpts.Marginals(ii).Type = 'Uniform';
    InputOpts.Marginals(ii).Parameters = [MonteCarlo_Para(ii,1) MonteCarlo_Para(ii,2)];
    InputPts.Marginals(ii).Bounds = [MonteCarlo_Para(ii,5) MonteCarlo_Para(ii,6)];
    end
    
    if MonteCarlo_Para(ii,4)== 2 %check and create normal distribution
      InputOpts.Marginals(ii).Type = 'Gaussian';
    InputOpts.Marginals(ii).Parameters = [MonteCarlo_Para(ii,1) MonteCarlo_Para(ii,2)];
    InputPts.Marginals(ii).Bounds = [MonteCarlo_Para(ii,5) MonteCarlo_Para(ii,6)];
    end
    
    if MonteCarlo_Para(ii,4)== 3 %check and create log normal 
      InputOpts.Marginals(ii).Type = 'LogNormal';
    InputOpts.Marginals(ii).Parameters = [MonteCarlo_Para(ii,1) MonteCarlo_Para(ii,2)];
    InputPts.Marginals(ii).Bounds = [MonteCarlo_Para(ii,5) MonteCarlo_Para(ii,6)];
    end
    
    if MonteCarlo_Para(ii,4)== 4 %check and create triangular distribution 
      InputOpts.Marginals(ii).Type = 'Triangular';
    InputOpts.Marginals(ii).Parameters = [MonteCarlo_Para(ii,1) MonteCarlo_Para(ii,2) MonteCarlo_Para(ii,3)];
    InputPts.Marginals(ii).Bounds = [MonteCarlo_Para(ii,5) MonteCarlo_Para(ii,6)];
    end
    if MonteCarlo_Para(ii,4)== 5 %check and create beta distribution
      InputOpts.Marginals(ii).Type = 'Beta';
    InputOpts.Marginals(ii).Parameters = [MonteCarlo_Para(ii,1) MonteCarlo_Para(ii,2)];
    InputPts.Marginals(ii).Bounds = [(MonteCarlo_Para(ii,5)/MonteCarlo_Para(ii,11)) (MonteCarlo_Para(ii,6)/MonteCarlo_Para(ii,11))];
    end
    
end

%Create an INPUT object based on the marginals:
myInput = uq_createInput(InputOpts);

%% Scatter plot analysis---------------------------------------------------
if scatter_analysis == 1
X = uq_getSample(10000,'LHS');

YmFile = uq_evalModel(myModel_mFile,X);
end

%% Calculate Regression Rank correlation-------------------------------------------------
if rank_correlation ==1
  
SRCSensOpts.Type = 'Sensitivity';
SRCSensOpts.Method = 'SRC';
SRCSensOpts.SRC.SampleSize = 10000;
SRCAnalysis = uq_createAnalysis(SRCSensOpts);
    

uq_display(SRCAnalysis)

end

%% Calculate Spearmen Rank correlation-------------------------------------
if spearman_rank_correlation ==1
  
CorrSensOpts.Type = 'Sensitivity';
CorrSensOpts.Method = 'Correlation';
CorrSensOpts.Correlation.SampleSize = 10000;
CorrSensAnalysis = uq_createAnalysis(CorrSensOpts);
    

uq_display(CorrSensAnalysis)

end

%% Calculate Sobol indices-------------------------------------------------
if sobol ==1


SobolOpts.Type = 'Sensitivity';
SobolOpts.Method = 'Sobol';

SobolOpts.Sobol.Order = 1;

SobolOpts.Sobol.SampleSize = 50000;

mySobolAnalysisMC = uq_createAnalysis(SobolOpts);

mySobolResultsMC = mySobolAnalysisMC.Results;

toc
end

%% Calculatie Bonovo indices ----------------------------------------------
if borgonovo ==1
BorgonovoOpts.Type = 'Sensitivity';
BorgonovoOpts.Method = 'Borgonovo';
BorgonovoOpts.Borgonovo.SampleSize = 10000;

BorgonovoAnalysis = uq_createAnalysis(BorgonovoOpts);
end

%% Plot results

% Plot results UQ Style----------------------------------------------------
%{
myColors = uq_colorOrder(3);
uq_figure
uq_histogram(YmFile, 'FaceColor', myColors(1,:))
title('Costs of production')
xlabel('$\mathrm{Y}$')
ylabel('Frequency')
%}

% Set color sheme: 
color2=[0.1986, 0.7214,0.6310];
color1=[0.9856,0.7372, 0.2537];
color_area_neg =[0.9856,0.7372, 0.2537]; %[0.886, 0.250, 0.313];
color_area_pos = [0.1986 0.7214 0.6310];
area_trans = 0.4;
size_font = 14;



% Sobol indices------------------------------------------------------------
if sobol == 1
figure

%create tiled layout and set spacing style
graph_tiles = tiledlayout(2,1); % Requires R2019b or later
graph_tiles.TileSpacing = 'none'; %options are : loose', 'compact', 'tight' or 'none'

hold on
nexttile
data_first = mySobolResultsMC.FirstOrder;
labels = SENSI_TXT;
[sorted_data, new_indices] = sort(data_first); % sorts in *ascending* order
sorted_labels = labels(new_indices); 
b1 = barh(sorted_data,0.6);
b1.FaceColor = color_area_neg;
b1.FaceAlpha =0.5;
b1.EdgeColor = color1;
b1.LineWidth = 0.8;
set(gca,'yticklabel',sorted_labels)
%set(gca,'yTickLabelRotation',45)
title('First Order Sensitivities')
set(gca,'FontSize',12) 
xlim([0,0.3])

nexttile


data_total = mySobolResultsMC.Total;
labels = SENSI_TXT;
[sorted_data, new_indices] = sort(data_total); % sorts in *ascending* order
sorted_labels = labels(new_indices); 
b2 = barh(sorted_data,0.6);
b2.FaceColor = color_area_neg;
b2.FaceAlpha =0.5;
b2.EdgeColor = color1;
b2.LineWidth = 0.8;
set(gca,'yticklabel',sorted_labels)
%set(gca,'yTickLabelRotation',45)
title('Total Sensitivities')
set(gca,'FontSize',12) 
xlim([0,0.3])


hold off

%%
%both sobol indices in one plot
%insert background boxes
figure1 = figure;
axes1 = axes('Parent', figure1);
hold(axes1,'on');


%define colors: 
color_red = [ 1.0000    0.8314    0.8314];
color_yellow = [ 1.0000    0.9490    0.7412];
color_green = [   0.8902    0.945    0.8275];

%define limits for the boxes:
y_box_red = 17.5;
y_box_yellow = 11.5;
y_box_green = 0; 

height_box_red = 3; 
height_box_yellow = 6; 
height_box_green = 11.5; 

%red
red_box = rectangle('Parent',axes1,'Position',[-0.4 y_box_red 1 height_box_red],'FaceColor',color_red,'EdgeColor','none'); % Plots the rectangle
%yellow
yellow_box = rectangle('Parent',axes1,'Position',[-0.4 y_box_yellow 1 height_box_yellow],'FaceColor',color_yellow,'EdgeColor','none'); % Plots the rectangle
%green
green_box = rectangle('Parent',axes1,'Position',[-0.4 y_box_green 1 height_box_green],'FaceColor',color_green,'EdgeColor','none'); % Plots the rectangle
set(axes1 ,'Layer', 'Top')%bring to the front

ylim([0 20])
box on

% Sort data following the sorting of the total sobol indices:
[sorted_data_total, new_indices_total] = sort(data_total);
sorted_data_first = data_first(new_indices_total); %adapt the order of first Sobol indices to the ones used by total Sobol
sorted_data_combined = [ sorted_data_total sorted_data_first];
sorted_labels = labels(new_indices_total);

b3 = barh(sorted_data_combined,0.6);
set(b3, {'DisplayName'}, {'Total order','First order'}') % define legend entries
legend('Location','southeast')

%set plot style: 
b3(1).FaceColor = color_area_neg;
b3(1).FaceAlpha =0.5;
b3(1).EdgeColor = color1;
b3(1).LineWidth = 0.8;

b3(2).FaceColor = color_area_pos;
b3(2).FaceAlpha =0.5;
b3(2).EdgeColor = color2;
b3(2).LineWidth = 0.8;

title('Sobol indices')
set(gca,'FontSize',12) 
set(gca, 'YTick',1:length(SENSI_TXT))
set(gca,'YTickLabel',sorted_labels)
%set(gca, 'YTickLabelRotation',45)
xlim([0,0.35])
end

%% plot rank correlation results
if rank_correlation == 1
figure
hold on
b3 = bar(SRCAnalysis.Results.SRRCIndices);
b3.FaceColor = color_area_neg;
b3.FaceAlpha =0.5;
b3.EdgeColor = color1;
b3.LineWidth = 0.8;
set(gca, 'XTick',1:length(SENSI_TXT))
set(gca,'XTickLabel',labels)
set(gca, 'XTickLabelRotation',45)
hold off
end

%% plot Spearmen rank correlation results
if spearman_rank_correlation  == 1

%swap results order
labels = SENSI_TXT;
index_order = length(CorrSensAnalysis.Results.RankCorrIndices);
for i_order = 1: length(CorrSensAnalysis.Results.RankCorrIndices)
    result_new_order(i_order) = CorrSensAnalysis.Results.RankCorrIndices(index_order);
    label_new_order(i_order)  = labels(index_order);
    index_order = index_order-1;
end
b3 = barh(result_new_order);
b3.FaceColor = color_area_neg;
b3.FaceAlpha =0.5;
b3.EdgeColor = color1;
b3.LineWidth = 0.8;
set(gca, 'YTick',1:length(SENSI_TXT))
set(gca,'YTickLabel',label_new_order)
%set(gca, 'YTickLabelRotation',45)
title('Spearman Rank Correlation Indices')
box on
hold off


%% with sorted labels
%insert background boxes
figure1 = figure;
axes1 = axes('Parent', figure1);
hold(axes1,'on');


%define colors: 
color_red = [ 1.0000    0.8314    0.8314];
color_yellow = [ 1.0000    0.9490    0.7412];
color_green = [   0.8902    0.945    0.8275];

%define limits for the boxes:
y_box_red = 17.5;
y_box_yellow = 11.5;
y_box_green = 0; 

height_box_red = 3; 
height_box_yellow = 6; 
height_box_green = 11.5; 

%red
red_box = rectangle('Parent',axes1,'Position',[-0.4 y_box_red 1 height_box_red],'FaceColor',color_red,'EdgeColor','none'); % Plots the rectangle
%yellow
yellow_box = rectangle('Parent',axes1,'Position',[-0.4 y_box_yellow 1 height_box_yellow],'FaceColor',color_yellow,'EdgeColor','none'); % Plots the rectangle
%green
green_box = rectangle('Parent',axes1,'Position',[-0.4 y_box_green 1 height_box_green],'FaceColor',color_green,'EdgeColor','none'); % Plots the rectangle
set(axes1 ,'Layer', 'Top')%bring to the front

ylim([0 20])
box on
% insert line
bh = xline(0,'--');


%swap results order
labels = SENSI_TXT;
data = CorrSensAnalysis.Results.RankCorrIndices;

[~, new_indices] = sort(abs(data)); % sorts in *ascending* order
sorted_data = data(new_indices);
sorted_labels = labels(new_indices); 


b3 = barh(sorted_data,0.6);
b3.FaceColor = color_area_neg;
b3.FaceAlpha =0.5;
b3.EdgeColor = color1;
b3.LineWidth = 0.8;
set(gca, 'YTick',1:length(SENSI_TXT))
set(gca,'YTickLabel',sorted_labels)
%set(gca, 'YTickLabelRotation',45)
title('Spearman Rank Correlation Indices')
box on
hold off
end
%%
if scatter_analysis==1
    %%Input histogram

figure
clf;
graph_tiles_1 = tiledlayout(4,5); % Requires R2019b or later

if pdf_max_entropie == 1
    for i= 1:(length(SENSI_TXT))
        if MonteCarlo_Para(i,11) > 0
        X(:,i) = X(:,i).*MonteCarlo_Para(i,11);
        end
    end
    
end

for i= 1:(length(SENSI_TXT))
nexttile
histogram(X(:,i),'FaceAlpha',area_trans,'FaceColor',color_area_neg,'EdgeColor',color1);
hold on
%ylabel('Total cost of production in €/tonne')
title(SENSI_TXT(i))
set(gca,'FontSize',size_font-2) 
box off
ylim([0 1000])

end
hold off

xlabel(graph_tiles_1,'Value of Input variable', 'FontSize',size_font)
ylabel(graph_tiles_1,'Frequency', 'FontSize',size_font)


figure
clf;
graph_tiles = tiledlayout(4,5); % Requires R2019b or later

%define colors: 
color_red = [ 1.0000    0.8314    0.8314];
color_yellow = [ 1.0000    0.9490    0.7412];
color_green = [   0.8902    0.945    0.8275];

for i= 1:(length(SENSI_TXT))
nexttile
scatter(X(:,i),YmFile,0.3,color1);% plot scatter
l_1 = lsline; % add line
l_1.Color = color1;

%{
%add background color:
if MonteCarlo_Para(i,10) == 1
set(gca,'Color',color_red)
elseif MonteCarlo_Para(i,10) == 2
set(gca,'Color',color_yellow)
elseif MonteCarlo_Para(i,10) == 3
    set(gca,'Color',color_green)
end
%}


title(SENSI_TXT(i))
%ylabel('Total cost of production in €/tonne')
set(gca,'FontSize',10) 
end
xlabel(graph_tiles,'Value of Input variable', 'FontSize',size_font)
ylabel(graph_tiles,'Levelised cost of product in [€/t_{SCM}]','FontSize',size_font)
graph_tiles.TileSpacing = 'compact';


hold off
end

%% Plot Borgonovo indices-------------------------------------------------
if borgonovo ==1


hold on
labels = SENSI_TXT;
data = BorgonovoAnalysis.Results.Delta;

%sort data
[~, new_indices] = sort(abs(data)); % sorts in *ascending* order
sorted_data = data(new_indices);
sorted_labels = labels(new_indices);

%insert background boxes
figure1 = figure;
axes1 = axes('Parent', figure1);
hold(axes1,'on');


%define colors: 
color_red = [ 1.0000    0.8314    0.8314];
color_yellow = [ 1.0000    0.9490    0.7412];
color_green = [   0.8902    0.945    0.8275];

%define limits for the boxes:
y_box_red = 17.5;
y_box_yellow = 11.5;
y_box_green = 0; 

height_box_red = 3; 
height_box_yellow = 6; 
height_box_green = 11.5; 

%red
red_box = rectangle('Parent',axes1,'Position',[0 y_box_red 0.25 height_box_red],'FaceColor',color_red,'EdgeColor','none'); % Plots the rectangle
%yellow
yellow_box = rectangle('Parent',axes1,'Position',[0 y_box_yellow 0.25 height_box_yellow],'FaceColor',color_yellow,'EdgeColor','none'); % Plots the rectangle
%green
green_box = rectangle('Parent',axes1,'Position',[0 y_box_green 0.25 height_box_green],'FaceColor',color_green,'EdgeColor','none'); % Plots the rectangle
set(axes1 ,'Layer', 'Top')%bring to the front

ylim([0 20])
box on

%plot

b4 = barh(sorted_data,0.6);
b4.FaceColor = color_area_neg;
b4.FaceAlpha =0.5;
b4.EdgeColor = color1;
b4.LineWidth = 0.8;
set(gca, 'YTick',1:length(SENSI_TXT))
set(gca,'YTickLabel',sorted_labels)
%set(gca, 'YTickLabelRotation',45)
title('Borgonovo Delta')
hold off



end
%% 

sound(sin(2*pi*1000*(0:1/4000:20/1000)),4000)
%disp (strcat('Calculations done, number of total model runs:',num2str(mySobolAnalysisMC.Results.Cost)))
rmpath(genpath('C:\Users\TSR\Desktop\matlab_March_2020\updated Model\TEA_Model V3_0_01 - Uncertainty analysis paper'))