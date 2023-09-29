function w = gamfittruncated(data,limits)

    data = abs(data);
    limits = abs(limits);
    for i=1:size(data,1)
       if limits(i,1) > limits(i,2) 
            limits(i,[1 2]) = limits(i,[2 1]); 
       end
    end
           
    f = @(w)gamliketruncated(w,data,limits);
    
    a0b0 = gamfit(data);
    a0 = a0b0(1);
    b0 = a0b0(2);

    w0 = [a0 b0];
    
    if ~isnan(gamliketruncated(w0,data,limits))
        options = optimset('Display', 'off','TolFun',0.000000000000001,'TolX',0.000000000000001,'MaxIter',1000000,'MaxFunEvals',100000);
        %fprintf('Optimizing...\n');
        [w LL flag output] = fminunc(f,w0,options);
    else
        w = w0;
    end

    fprintf('.');
  
end