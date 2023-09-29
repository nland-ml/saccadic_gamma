function LL = gamliketruncated(w,data,limits)

   a = w(1);
   b = w(2);

   data = representAmplitude(data);
   limits(:,1) = representAmplitude(limits(:,1));
   limits(:,2) = representAmplitude(limits(:,2));
   
  
   LL0s = mygamlike(a,b,data);

   normalizers = gamcdf(limits(:,2),a,b) - gamcdf(limits(:,1),a,b);
   if sum(normalizers==0)>0
       %if differences between CDFs are so small that they are numerically
       %zero, the computation does not give useful results - better return
       %NaN
       LL = NaN;   
   else
       LLs = LL0s+log(normalizers);
       LL = sum(LLs);
   end
 
end