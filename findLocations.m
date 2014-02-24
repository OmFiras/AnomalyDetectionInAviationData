function [startingLocation, endingLocation] = findLocations(input)

D=input.RALT.data;
% start = 1;
endi = size(input.RALT.data);
endi = int64(endi(1,1));
Increasinglimit = int16(7000*endi/80000);
Increasinglimit = int16(Increasinglimit(1,1));
% DecreasingLimit = 100;
runningSum = zeros(endi,1);
startingLocation = 0;
endingLocation = 0;

for i=2:endi
    
    if( D(i,1) > 100)
        runningSum(i,1) = runningSum(i-1,1) + 1;
    else
        runningSum(i,1) = 0;
    end
    
    if(runningSum(i,1)==Increasinglimit)
        startingLocation = int16(i)-Increasinglimit+int16(1);
        endingLocation = int16(i);
        break;
    end
end

if(startingLocation <= 0)
    startingLocation=2;
end
 
% runningSum = zeros(endi,1);
% for j=int64(startingLocation):endi
%     
%     if( D(j,1) > 100)
%         runningSum(j,1) = 0;
%     else
%         runningSum(j,1) = runningSum(j-1,1) + 1;
%     end
%     
%     if(runningSum(j,1)==DecreasingLimit)
%         
%         endingLocation= j-DecreasingLimit;
%         break;
%     end
%     
%     
% end

Scale = input.RALT.Rate/input.LATP.Rate;
startingLocation = int16(startingLocation/Scale);
endingLocation = int16(endingLocation/Scale);
end