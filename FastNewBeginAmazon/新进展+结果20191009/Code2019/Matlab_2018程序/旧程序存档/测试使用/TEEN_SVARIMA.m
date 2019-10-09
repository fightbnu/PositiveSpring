%Step1: read in files
    %1) stress series
        %E:\TEST\POSITIVE\Pair\correlation\T0\valueBig\
    %2) parameters
        %E:\TEST\POSITIVE\Pair\correlation\
        %avgUSI0.txt;corStress0.txt;corStressor0.txt
%Step2: predict
%Step3: metric

filelist = dir('E:\TEST\POSITIVE\Pair\correlation\T0\valueBig\*.txt');
path_avg = ['E:\TEST\POSITIVE\Pair\correlation\','avgUSI0.txt'];
data_avg = importdata(path_avg);

for pos = 1:length(filelist)
    %input
    path_s = ['E:\TEST\POSITIVE\Pair\correlation\T0\valueBig\',filelist(pos).name];

    %output
    foutPath = ['E:\TEST\POSITIVE\Pair\correlation\T0\predict\',filelist(pos).name];
    foutPredict = fopen(foutPath,'w'); 
    
    %avg, length
    lenHis = data_avg(pos,1);
    avgHis = data_avg(pos,2);
    disp('lenHis:');
    disp(lenHis);%
    disp('avgHis');
    disp(avgHis);%
    
    data_s = importdata(path_s);  
    [m1,n1] = size(data_s);
    trainNum = floor(m1*0.7);
    testNum = m1-trainNum;
    disp('trainNum')
    disp(trainNum);
    disp('testNum');
    disp(testNum);
       
    if(trainNum>10)     
        %the gap
        lenPre = lenHis;
        if(floor(trainNum*0.4)<lenPre && floor(trainNum*0.4)>0)
            lenPre = floor(trainNum*0.4);
        end
        disp('lenPredict');
        disp(lenPre);
        
        %training data
        y = data_s(1:trainNum,1);%stress series
        [m,n] = size(y);
        %x-axis
        x = ones(m,1);
        for i=1:1:m
            x(i,1)=i;
        end

        %predict!!!!      
        model_s = arima('MALags', 1, 'D', 1, 'SMALags', lenPre,...
            'Seasonality',lenPre, 'Constant', 0);
        fit_s = estimate(model_s,y);
        
        y_s = forecast(fit_s,testNum,'Y0',y); %41 means we cut down the 41 series..!!!
        l1 = plot(trainNum+1:m1,data_s(trainNum+1:m1),'k','LineWidth',3); %T is size; dat is the whole data;
        hold on %or l1 and l2 will be covered
        l2 = plot(trainNum+1:m1,y_s,'-r','LineWidth',2);
        hold off
        %!!!!
                     
        for i=1:1:testNum
            fprintf(foutPredict,'%.4f \r\n', y_s(i,1));
        end

        fclose(foutPredict);
        disp(filelist(pos).name);
        %plot(x_up,y_up,x_up,y_up2);
        %legend('origin','smooth_up');
    end
end