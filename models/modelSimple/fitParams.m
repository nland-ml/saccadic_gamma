function [sacParams durParams ampParams] = fitParams(Xtmp,minSampleSize,durDefaultParams,ampDefaultParams)
sacPrior  = 1; % laplace prior for saccade type

saccade   = Xtmp(:,1);

sacTypes  = [1:4]'; 
sacParams = histc(saccade,sacTypes)+sacPrior;
sacParams = sacParams./sum(sacParams);

warning('off','optim:fminunc:SwitchingMethod');

numParamsGamma = 2;
durParams = zeros(length(sacTypes)+1,numParamsGamma);
ampParams = zeros(length(sacTypes)+3,numParamsGamma);

for i=sacTypes'
    durationData     = representDuration(Xtmp(saccade==i,2));
    amplitudeData    = Xtmp(saccade==i,3);
    
       
    limits = Xtmp(saccade==i,i*2+2:i*2+3);  
    if (nargin == 4 && (size(durationData,1)<minSampleSize || i==3 && min(sum(amplitudeData>0),sum(amplitudeData<=0)) < minSampleSize))
            
            if (i==3)
                ampParams(i,:) = ampDefaultParams(i,:);
                ampParams(i+1,:) = ampDefaultParams(i+1,:);
                ampParams(i+2,:) = ampDefaultParams(i+2,:);
                durParams(i,:) = durDefaultParams(i,:);
            elseif(i==4)
                ampParams(i+2,:) = ampDefaultParams(i+2,:);
                durParams(i,:) = durDefaultParams(i,:);
                %also store initial fixation 
                ampParams(7,:) = ampDefaultParams(7,:);
                durParams(5,:) = durDefaultParams(5,:);
            else
                ampParams(i,:) = ampDefaultParams(i,:);
                durParams(i,:) = durDefaultParams(i,:);
            end
    else

        if i==3
           limits1 = limits(amplitudeData>0,:);
           limits1(:,1) = 0;
           ampParams(i,:) = gamfittruncated(amplitudeData(amplitudeData>0),limits1);
           limits2 = limits(amplitudeData<=0,:);
           limits2(:,2) = abs(limits2(:,1));
           limits2(:,1) = 0;
           ampParams(i+1,:) = gamfittruncated(-amplitudeData(amplitudeData<=0)+0.1,limits2);
           ampParams(i+2,1) = (sum(amplitudeData>0)+1)/(length(amplitudeData)+2);
           ampParams(i+2,2) = 1 - ampParams(i+2,1);
           durParams(i,:) = gamfit(durationData);
        elseif i==4
            ampParams(i+2,:) = gamfittruncated(amplitudeData,limits);
            durParams(i,:) = gamfit(durationData);
            %also store initial fixation parameters
            initialDurations = Xtmp(saccade==0,2);
            if length(unique(initialDurations))<2
                durParams(5,:) = durDefaultParams(5,:);    
            else
                durParams(5,:) = gamfit(initialDurations);     
            end
            initialPositions = Xtmp(saccade==0,12);
            if length(unique(initialPositions))<2
                ampParams(7,:) = ampDefaultParams(7,:);    
            else
                ampParams(7,:) = gamfit(initialPositions+0.1);
            end
        else 
            ampParams(i,:) = gamfittruncated(amplitudeData,limits);
            durParams(i,:) = gamfit(durationData);
        end
    end
   
end


