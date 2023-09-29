

load('resultsTestSizes');

results = accuracy;

colors = {'r','g','g','k','b','c'};


meanStandard = mean(results,1);
stdStandard = std(results,[],1)/sqrt(size(results,1));  % Standard Error

lineWidth = 1.8;
close all;
figure;
hold on;


for i=[1 3 4 5 6]
    errorbar(testSizes,squeeze(meanStandard(:,:,i)),squeeze(stdStandard(:,:,i)),colors{i},'LineWidth',lineWidth);
end

majority = 0.05*ones(size(meanStandard(:,:,1)));
plot(testSizes,majority,'m','LineWidth',lineWidth);

axis([0 75 0 1]);

legend('full model','saccade type + amplitude','saccade type only','Holland & K. (weighted)','Holland & K. (unweighted)','random guessing',[240 65 100 100]);
ylabel('identification accuracy','fontsize',22);
xlabel('number of test sentences m','fontsize',22);

title('Accuracy Over Test Sentences m (n=72)','FontSize',24');  

set(gca,'FontSize',18)
set(gca, 'box', 'off');


print  -dpdf testSizes.pdf

