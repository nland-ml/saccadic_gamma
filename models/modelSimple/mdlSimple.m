function [accuracy ] = mdlSimple(data, trainId, testId, minSampleSize)
    Xtrain = data.X(trainId,:);
    ytrain = data.y(trainId,:);
    Xtest = data.X(testId,:);
    ytest = data.y(testId,:);
        
    numClasses = max(unique(ytrain));
    numSacType = 4;   
    numParamsGamma = 2;
    
    % estimate majority fit (for fall back)
    [globSac, globDur, globAmp] = fitParams(Xtrain,minSampleSize);
    params.saccade       = -ones(numSacType,numClasses);
    params.duration      = -ones(numSacType+1,numParamsGamma,numClasses);
    params.amplitude  = -ones(numSacType+3,numParamsGamma,numClasses);
    for y = unique(ytrain)'        
            [params.saccade(:,y), params.duration(:,:,y), params.amplitude(:,:,y)] = ...
                fitParams(Xtrain(ytrain==y,:), minSampleSize, globDur, globAmp);            
    end
   
    % evaluate on test data
    correct = -ones(numClasses,4);
    for y=unique(ytrain)'
        prediction = classify(params, Xtest(ytest==y,:));
        correct(y,:)=(prediction==y);
    end
    accuracy = mean(correct(unique(ytrain),:));
end