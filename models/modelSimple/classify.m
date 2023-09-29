function [pred likelihood] = classify(params, X)

ySpace = find(params.saccade(1,:)>-1);

sac = X(:,1);

dur = representDuration(X(:,2));
amp = X(:,3);

    
likelihood = -inf(size(params.saccade,2),4);
for ybar=ySpace
   
    sacPositive = sac(sac>0);
    LLSaccade = sum(log(params.saccade(sacPositive,ybar)));
    
    LLFixations = 0;
    LLAccelerations = 0;
    for i=1:4
        limits = X(sac==i,i*2+2:i*2+3); 
        
        if (i==3)
            amp3 = amp(sac==i);
            limits1 = limits(amp3>0,:);
            limits1(:,1) = 0;
            if (size(limits1,1)>0)
                LLAccelerations = LLAccelerations - gamliketruncated(params.amplitude(i,:,ybar)',amp3(amp3>0),limits1);    
                LLAccelerations = LLAccelerations + log(params.amplitude(i+2,1,ybar))*sum(amp3>0);
            end
            
            limits2 = limits(amp3<=0,:);
            limits2(:,2) = abs(limits2(:,1));
            limits2(:,1) = 0;
            if (size(limits2,1)>0)
                LLAccelerations = LLAccelerations - gamliketruncated(params.amplitude(i+1,:,ybar)',-amp3(amp3<=0)+0.1,limits2);    
                LLAccelerations = LLAccelerations + log(params.amplitude(i+2,2,ybar))*sum(amp3<=0);
            end
         
            
        elseif (i==4)
            data = amp(sac==i);
            data = abs(data);
            limits = abs(limits);
            for j=1:size(data,1)
                if limits(j,1) > limits(j,2) 
                    limits(j,[1 2]) = limits(j,[2 1]); 
                end
            end
            LLAccelerations = LLAccelerations - gamliketruncated(params.amplitude(i+2,:,ybar)',data,limits);
        else
            data = amp(sac==i);
            LLAccelerations = LLAccelerations - gamliketruncated(params.amplitude(i,:,ybar)',data,limits);
        end
        LLFixations = LLFixations - gamlike(params.duration(i,:,ybar)',dur(sac==i));
        
    end
      
    %initial fixation
    initialPositions = X(X(:,1)==0,12);
    initialPositionLL = gamlike(params.amplitude(7,:,ybar),initialPositions+0.1);
    LLAccelerations = LLAccelerations - initialPositionLL;
    initialDurations = X(X(:,1)==0,2);
    initialDurationLL = gamlike(params.duration(5,:,ybar),initialDurations);
    LLFixations = LLFixations - initialDurationLL;
   
    
    likelihood(ybar,:) = [...
            (LLSaccade+LLAccelerations+LLFixations)/length(sac)...
            (LLSaccade+LLFixations)/length(sac)...
            (LLSaccade+LLAccelerations)/length(sac)...
            LLSaccade/length(sac)...        
        ];
end


    
[tmp,pred]=max(likelihood);


    

        
