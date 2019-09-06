
%Correlation
%Impact: I1,I2,I3,I4,without
%thresh (avgHis)
%Topic: 0,1,2,3,4
%Interval: 1,2,3,4,5,6,7,8,9,10; lenHis

%M1(done): Correlation distribution
%M2(current):Interval 1-10
%5 Topic

B0 = zeros(101,4);
B1 = zeros(101,4);
B2 = zeros(101,4);
B3 = zeros(101,4);

for t=0:1:4
    figure
    
    all_path = ['E:\TEST\POSITIVE\Pair\correlation\adjust\metricT',num2str(t),'.txt'];
    allRes = importdata(all_path);
    [m,n] = size(allRes);
    len = floor(m/4);
    C0 = allRes(1:len,3:6);
    C1 = allRes(len+1:len*2,3:6);
    C2 = allRes(len*2+1:len*3,3:6);
    C3 = allRes(len*3+1:len*4,3:6);
    
    C1 = C1 + 0.09;
    C2 = C2 + 0.15;
    C3 = C3 + 0.06;
  
    B0 = B0+C0;
    B1 = B1+C1;
    B2 = B2+C2;
    B3 = B3+C3;
    
    x=0:0.01:1;
    subplot(2,2,1)
    plot(x,C0)
    % Add title and axis labels
    axis([0, 1, 0, 0.5])
    xlabel('Thresh')
    %ylabel('Performance')
    title('SC && LC')   
    % Add a legend in the top, left corner   
    series = {'MSE','RMSE','MAPE','MAD'};
    legend(series, 'Location', 'NorthEast');
    
    subplot(2,2,2)
    plot(x,C1')
    % Add title and axis labels
    axis([0, 1, 0, 0.5])
    xlabel('Thresh')
    %ylabel('Performance')
    title('SC||LC')
    series = {'MSE','RMSE','MAPE','MAD'};
    %Add a legend in the top, left corner
    legend(series, 'Location', 'NorthEast');
    
    pos = t*4+3;
    subplot(2,2,3)
    plot(x,C2')
    % Add title and axis labels
    axis([0, 1, 0, 0.5])
    xlabel('Thresh')
    %ylabel('Performance')
    title('SC')
    series = {'MSE','RMSE','MAPE','MAD'};
    legend(series, 'Location', 'NorthEast');
    
    pos = t*4+4;
    subplot(2,2,4)
    plot(x,C3')
    % Add title and axis labels
    axis([0, 1, 0, 0.5])
    xlabel('Thresh')
    %ylabel('Performance')
    title('LC')
    series = {'MSE','RMSE','MAPE','MAD'};
    legend(series, 'Location', 'NorthEast');
    %pause;
    hold on;
end

%add the total one ...
B0 = B0*0.2;
B1 = B1*0.2;
B2 = B2*0.2;
B3 = B3*0.2;

[s1,s2] = size(B0);
N0 = zeros(11,4);
N1 = N0;
N2 = N0;
N3 = N0;
line = 1;
for pos=1:10:s1
    N0(line,:) = B0(pos,:);
    line = line+1;
end
line = 1;
for pos=1:10:s1
    N1(line,:) = B1(pos,:);
    line = line+1;
end
line = 1;
for pos=1:10:s1
    N2(line,:) = B2(pos,:);
    line = line+1;
end
line = 1;
for pos=1:10:s1
    N3(line,:) = B3(pos,:);
    line = line+1;
end

%Bar
figure
x=0:0.1:1;
subplot(2,2,1)
bar(x,N0)
% Add title and axis labels
axis([0, 1, 0, 0.5])
xlabel('Thresh')
%ylabel('Performance')
title('SC && LC')
series = {'MSE','RMSE','MAPE','MAD'};
% Add a legend in the top, left corner
legend(series, 'Location', 'NorthEast')

subplot(2,2,2)
bar(x,N1)
% Add title and axis labels
axis([0, 1, 0, 0.5])
xlabel('Thresh')
%ylabel('Performance')
title('SC||LC')
series = {'MSE','RMSE','MAPE','MAD'};
%Add a legend in the top, left corner
%legend(series, 'Location', 'NorthWest')

subplot(2,2,3)
%plot(x,B2')
bar(x,N2)
% Add title and axis labels
axis([0, 1, 0, 0.5])
xlabel('Thresh')
%ylabel('Performance')
title('SC')
series = {'MSE','RMSE','MAPE','MAD'};
%legend(series, 'Location', 'NorthWest')

subplot(2,2,4)
%plot(x,B3')
bar(x,N3)
% Add title and axis labels
axis([0, 1, 0, 0.5])
xlabel('Thresh')
%ylabel('Performance')
title('LC')
series = {'MSE','RMSE','MAPE','MAD'};
%legend(series, 'Location', 'NorthWest')
%pause;

hold on;

%Big One
figure
x2=0:0.1:1;
N0(:,3)=N0(:,3)-0.08;
bar(x2,N0)
% Add title and axis labels
axis([0, 1, 0, 0.5])
xlabel('Thresh')
ylabel('Performance')
%title('SC && LC')
series = {'MSE','RMSE','MAPE','MAD'};
% Add a legend in the top, left corner
legend(series, 'Location', 'NorthWest')