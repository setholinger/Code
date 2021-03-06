function plot_bivar_loc(x_keep,x0,numIt,p,paramsVaried,axisLabels,paramLabels,maxNumBins,path)

% find best-fit parameters using 2D histogram
numBins = length(unique(x_keep(paramsVaried(1),:)));
if numBins > maxNumBins
    numBins = maxNumBins;
end

% get best fit parameters- use log if t0
if paramsVaried(1) == 4
    xFit = getFitLog(x_keep,paramsVaried,numBins,x0,'x');
elseif paramsVaried(2) == 4
    xFit = getFitLog(x_keep,paramsVaried,numBins,x0,'y');
else
    xFit = getFit(x_keep,paramsVaried,numBins,x0);
end

% set subplot and position (tight layout) for first parameter
ax1 = subplot(3,3,8:9);
pos = get(ax1,'Position');
pos(1) = .35;
pos(2) = .1;
set(ax1,'Position',pos)

% make histogram- use log if t0
histogram(x_keep(paramsVaried(1),:),numBins);

% set axes limits based on range of values- supress scientific notation
xlim([min(x_keep(paramsVaried(1),:)),max(x_keep(paramsVaried(1),:))]);
xlabel(axisLabels(paramsVaried(1)))
ax1.XRuler.Exponent = 0;
ax1.YRuler.Exponent = 0;

% plot red dashed line at best fit point
xline(xFit(paramsVaried(1)),"r--");

% set subplot and position (tight layout) for second parameter
ax2 = subplot(3,3,[1 4]);
pos = get(ax2,'Position');
pos(1) = 0.1;
pos(2) = 0.35;
set(ax2,'Position',pos)

% make histogram- use log if t0
histogram(x_keep(paramsVaried(2),:),numBins);

% set axes limits based on range of values- supress scientific notation
set(ax2,'view',[-90 90])
xlim([min(x_keep(paramsVaried(2),:)),max(x_keep(paramsVaried(2),:))]);
xlabel(axisLabels(paramsVaried(2)))
ax2.XRuler.Exponent = 0;
ax2.YRuler.Exponent = 0;

% plot red dashed line at best fit point
xline(xFit(paramsVaried(2)),"r--");

% set position of scatter plot
ax3 = subplot(3,3,[2,3,5,6]);
pos = get(ax3,'Position');
pos(1) = 0.35;
pos(2) = 0.35;
set(ax3,'Position',pos)

% make dscatter plot- log if t0
dscatter(x_keep(paramsVaried(1),:)',x_keep(paramsVaried(2),:)','BINS',[numBins,numBins]);

% set axes limits
xlim([min(x_keep(paramsVaried(1),:)),max(x_keep(paramsVaried(1),:))]);
ylim([min(x_keep(paramsVaried(2),:)),max(x_keep(paramsVaried(2),:))]);

% add title
title("Result of MCMC inversion after " + numIt + " iterations")
hold on
set(gcf,'Position',[10 10 1000 800])

% plot crosshairs at best fit point
xline(xFit(paramsVaried(1)),"r--");
yline(xFit(paramsVaried(2)),"r--");

% remove labels
xticklabels(ax3,{})
yticklabels(ax3,{})

% save plots
saveas(gcf,path + "run" + p + "_" + paramLabels(paramsVaried(1)) + ...
       "-" + paramLabels(paramsVaried(2)) + "_dscatter.png")
close(gcf)

end