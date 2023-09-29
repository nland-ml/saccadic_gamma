
% Creates Figure 3 (left) in paper
function run_experiment

    addpath('models/modelSimple')
    addpath('baseline/')
    addpath('baseline/shiftmean')

    load('dataset.mat','xFull');

    numRuns = 5;              % number of repetitions with different train/test splits (paper = 20)
    minNumTest = 2;
    maxNumTest = 72;            
    stepSize = 10;            % resolution of "number of test sentences"-axis in results (paper =5)

    rng(1);

    tic
    data = getFixationData();


    accuracy = -ones(numRuns,ceil(maxNumTest/stepSize),4);
    startSeed = 1;
    endSeed = numRuns;
    testSizes = minNumTest:stepSize:maxNumTest
    for seed=startSeed:endSeed
        [trainId testId trainSentences testSentences] = splitData(data,seed,72,0);

        minSampleSize = 20;
        %minSampleSize = mdlSimpleTuning(data,trainId,3);   % tuning, disabled to save time (paper = on)

        for testSize=1:length(testSizes)
            fprintf('\nRunning train/test split (seed %i)\n\n');
            [trainId testId trainSentences testSentences] = splitData(data,seed,72,testSizes(testSize));
            [acc] = mdlSimple(data, trainId, testId, minSampleSize);
            [accBaselineWeighted, mapping] = readerIdAccuracy(trainSentences, testSentences, xFull,1);
            [accBaseline, mapping] = readerIdAccuracy(trainSentences, testSentences, xFull,0);
            accuracy(seed,testSize,1:4) = acc;
            accuracy(seed,testSize,5) = accBaselineWeighted;
            accuracy(seed,testSize,6) = accBaseline;
            fprintf('\nSeed = %i: accuracy = %f (Baseline = %f)\n\n',seed,accuracy(seed,testSize,1),accuracy(seed,testSize,5));
        end
    end

    toc

    save('resultsTestSizes','accuracy','testSizes');

    plotCurves;
end
