function plot_multivar(sigma,accept,xStep,x_keep,M_frac,x0,numIt,p,...
                       paramsVaried,axisLabels,maxNumBins,L_type,path,f_max,t_max)

% get useful info
numParams = length(paramsVaried);
numPanelSide = numParams + 1;

% make gridded plots of all independent parameters
for i = 1:numParams
    for j = i:numParams
        
        if i ~= j
            
            % get number of bins
            numBins = length(unique(x_keep(paramsVaried(i),:)));
            if numBins > maxNumBins
                numBins = maxNumBins;
            end
            
            % get point with max density for current variable pair
            if paramsVaried(j) == 4
                xFit = getFitLog(x_keep,[paramsVaried(j) paramsVaried(i)],numBins,x0,'x');
            else
                xFit = getFit(x_keep,[paramsVaried(j) paramsVaried(i)],numBins,x0);
            end
            % make dscatter density plot of results
            figInd = sub2ind([numPanelSide,numPanelSide],j,i);
            subplot(numPanelSide,numPanelSide,figInd);           
   
            dscatter(x_keep(paramsVaried(j),:)',x_keep(paramsVaried(i),:)','BINS',[numBins,numBins]);
            if paramsVaried(j) == 4
                dscatter(x_keep(paramsVaried(j),:)',x_keep(paramsVaried(i),:)','BINS',[numBins,numBins],'LOGX',true);
                xticks([1e-2 1e-1 1e0 1e1 1e2]);
                xticklabels({'10^{-2}','10^{-1}','10^{0}','10^{1}','10^{2}'})
            end

            ax = gca;
            ax.YAxisLocation = "right";
            ax.XAxisLocation = "top";
            xline(xFit(paramsVaried(j)),"r--");
            yline(xFit(paramsVaried(i)),"r--");
            xlim([min(x_keep(paramsVaried(j),:)),max(x_keep(paramsVaried(j),:))]);
            ylim([min(x_keep(paramsVaried(i),:)),max(x_keep(paramsVaried(i),:))]);
            box on;
            if figInd > length(paramsVaried)
                xticklabels(gca,{})
            else
                xlabel(axisLabels(j),'Color',[0 0.4470 0.7410])
            end
            yticklabels(gca,{})
        end
        
    end

    % make histogram
    histInd = sub2ind([numPanelSide,numPanelSide],i,i);
    subplot(numPanelSide,numPanelSide,histInd);
   
    if paramsVaried(i) == 4
        [~,edges] = histcounts(log10(x_keep(paramsVaried(i),:)),numBins);
        histogram(x_keep(paramsVaried(i),:),10.^edges,'FaceColor',[0 0.4470 0.7410],...
                 'EdgeColor',[0 0.4470 0.7410],'FaceAlpha',1);
        set(gca,'xscale','log');
        xticks([1e-2 1e-1 1e0 1e1 1e2]);
        xticklabels({'10^{-2}','10^{-1}','10^{0}','10^{1}','10^{2}'})
    else
        histogram(x_keep(paramsVaried(i),:),numBins,'FaceColor',[0 0.4470 0.7410],...
                 'EdgeColor',[0 0.4470 0.7410],'FaceAlpha',1);
    end

    xlim([min(x_keep(paramsVaried(i),:)),max(x_keep(paramsVaried(i),:))]);
    xlabel(axisLabels(i),'Color',[0 0.4470 0.7410])
end

% make column of M_frac plots
for i = 1:numParams
    
    % get number of bins
    numBins = length(unique(x_keep(paramsVaried(i),:)));
    if numBins > maxNumBins
        numBins = maxNumBins;
    end
    
    % get point with max density for current variable pair
    if paramsVaried(i) == 4
        xFit = getFitLog([x_keep;M_frac],[7 paramsVaried(i)],numBins,[x0 0],'both');
    else
        xFit = getFitLog([x_keep;M_frac],[7 paramsVaried(i)],numBins,[x0 0],'x');
    end
    figInd = sub2ind([numPanelSide,numPanelSide],numPanelSide,i);
    subplot(numPanelSide,numPanelSide,figInd);           
    
    dscatter(M_frac',x_keep(paramsVaried(i),:)','BINS',[numBins,numBins],'LOGX',true);
    
    xticks([1e-2 1e-1 1e0 1e1 1e2]);
    xticklabels({'10^{-2}','10^{-1}','10^{0}','10^{1}','10^{2}'})
    if paramsVaried(i) == 4
        dscatter(M_frac',x_keep(paramsVaried(i),:)','BINS',[numBins,numBins],'LOGX',true,'LOGY',true);
        yticks([1e-2 1e-1 1e0 1e1 1e2]);
        yticklabels({'10^{-2}','10^{-1}','10^{0}','10^{1}','10^{2}'})
    end
    
    ax = gca;
    ax.YAxisLocation = "right";
    ax.XAxisLocation = "top";            
    xline(xFit(7),"r--");
    yline(xFit(paramsVaried(i)),"r--");
    
    xlim([min(M_frac),max(M_frac)]);
    ylim([min(x_keep(paramsVaried(i),:)),max(x_keep(paramsVaried(i),:))]);
    box on;
    ylabel(axisLabels(i),'Color',[0 0.4470 0.7410])                
    if i == 1
        xlabel("M_{obs}/M_0",'Color',[0.8500 0.3250 0.0980])
    else
        xticklabels(gca,{})
    end
    
end

% make histogram of M_frac
subplot(numPanelSide,numPanelSide,numPanelSide*numPanelSide);
[~,edges] = histcounts(log10(M_frac),numBins);
histogram(M_frac,10.^edges,'FaceColor',[0.8500 0.3250 0.0980],...
         'EdgeColor',[0.8500 0.3250 0.0980],'FaceAlpha',1);
set(gca,'xscale','log');
xticks([1e-2 1e-1 1e0 1e1 1e2]);
xticklabels({'10^{-2}','10^{-1}','10^{0}','10^{1}','10^{2}'})
xlim([min(M_frac),max(M_frac)]);
xlabel("M_{obs}/M_0",'Color',[0.8500 0.3250 0.0980])

% report parameters and settings for MCMC
subplot(numPanelSide,numPanelSide,numPanelSide*numPanelSide-(numPanelSide-1))
yticklabels(gca,{})
xticklabels(gca,{})
set(gca, 'visible', 'off')
text(0,1,string("MCMC parameters" + newline + "----------------------------" + newline + ...                            
                       "h_i step: " + xStep(1) + " m    h_w step: " + xStep(2) + " m" + newline + ...
                       "X_{stat} step: " + xStep(3) + " m    t_0 step: log10(" + round(10^xStep(4)) + ") s" + newline + ...
                       "Number of iterations: " + numIt + newline + "Sigma: " + sigma + newline + ...
                       "Liklihood function: " + L_type + newline + "Accepted " + ...
                       round(100*sum(accept)/length(accept)) + "% of proposals" + newline + newline + ...
                       "Model parameters" + newline + "----------------------------" + newline + ... 
                       "Sampling Frequency: " + 2*f_max + " Hz" + newline + "Duration: " + t_max + " s"))                   
            
% set figure size and title
set(gcf,'Position',[10 10 1200 1000])
sgtitle("Result of MCMC inversion after " + numIt + " iterations" + newline)

saveas(gcf,path + "run" + p + "_multivar_dscatter.png")
close(gcf)

end