%Correlation
%Impact: I1,I2,I3,I4,without
%thresh (avgHis)
%Topic: 0,1,2,3,4
%Interval: 1,2,3,4,5,6,7,8,9,10; lenHis

%M1(done): Correlation distribution
%M2(current):Interval 1-10 
%5 Topic

all_path = 'D:\TEST\POSITIVE\Pair\correlation\metricALL.txt';
allRes = importdata(all_path);

[m,n] = size(allRes);

if(m==50 && n==6)
	C0 = allRes(1:10,3:6);
	C1 = allRes(11:20,3:6);
	C2 = allRes(21:30,3:6);
	C3 = allRes(31:40,3:6);
	C4 = allRes(41:50,3:6);
end

CA = zeros(10,4);
[a,b] = size(CA);
for i=1:1:a
    for j=1:1:b
        CA(i,j) = (C0(i,j) + C1(i,j) + C2(i,j) + C3(i,j) + C4(i,j))/5;
    end
end

x=1:1:10;

figure
subplot(2,3,1)
plot(x,C0','s-')
% Add title and axis labels
axis([1, 10, 0, 0.5]) 
xlabel('Forecast length (day)')
ylabel('Performance')
title('School life')
series = {'MSE','RMSE','MAPE','MAD'};
% Add a legend in the top, left corner
legend(series, 'Location', 'NorthWest')

subplot(2,3,2)
plot(x,C1','s-')
% Add title and axis labels
axis([1, 10, 0, 0.5])
xlabel('Forecast length (day)')
ylabel('Performance')
title('Romantic')
series = {'MSE','RMSE','MAPE','MAD'};
% Add a legend in the top, left corner
legend(series, 'Location', 'NorthWest')

subplot(2,3,3)
plot(x,C2','s-')
% Add title and axis labels
axis([1, 10, 0, 0.5])
xlabel('Forecast length (day)')
ylabel('Performance')
title('Peer relationship')
series = {'MSE','RMSE','MAPE','MAD'};
% Add a legend in the top, left corner
legend(series, 'Location', 'NorthWest')

subplot(2,3,4)
plot(x,C3','s-')
% Add title and axis labels
axis([1, 10, 0, 0.5])
xlabel('Forecast length (day)')
ylabel('Performance')
title('Family life')
series = {'MSE','RMSE','MAPE','MAD'};
% Add a legend in the top, left corner
legend(series, 'Location', 'NorthWest')

subplot(2,3,5)
plot(x,C4','s-')
% Add title and axis labels
axis([1, 10, 0, 0.5])
xlabel('Forecast length (day)')
ylabel('Performance')
title('Healthy')
series = {'MSE','RMSE','MAPE','MAD'};
% Add a legend in the top, left corner
legend(series, 'Location', 'NorthWest')

subplot(2,3,6)
plot(x,CA','s-')
% Add title and axis labels
axis([1, 10, 0, 0.5])
xlabel('Forecast length (day)')
ylabel('Performance')
title('All types of events')
series = {'MSE','RMSE','MAPE','MAD'};
% Add a legend in the top, left corner
legend(series, 'Location', 'NorthWest')
