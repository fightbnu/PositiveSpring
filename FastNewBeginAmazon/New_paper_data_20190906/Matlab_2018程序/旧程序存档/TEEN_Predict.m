%Step1: read in files
    %1) stress series
        %E:\TEST\POSITIVE\Pair\correlation\T0\valueBig\
    %2) parameters
        %E:\TEST\POSITIVE\Pair\correlation\
        %avgUSI0.txt;corStress0.txt;corStressor0.txt
%Step2: predict
    %basic (done)
%Step3: metric
    %MSE, RMSE, MAPE
all_path = 'E:\TEST\POSITIVE\Pair\correlation\metricALL.txt';
foutAll = fopen(all_path,'w');

for T_NUM=1:1:10
        for TOPIC = 0:4
        filelist = dir(['E:\TEST\POSITIVE\Pair\correlation\T',num2str(TOPIC),'\valueBig\*.txt']);

        %parameter1: average stress
        path_avg = ['E:\TEST\POSITIVE\Pair\correlation\','avgUSI',num2str(TOPIC),'.txt'];
        data_avg = importdata(path_avg);

        %parameter2: correlation - stress
        path_str = ['E:\TEST\POSITIVE\Pair\correlation\','corStress',num2str(TOPIC),'.txt'];
        data_cor_str = importdata(path_str);

        %parameter3: correlation - stressor
        path_stressor = ['E:\TEST\POSITIVE\Pair\correlation\','corStressor',num2str(TOPIC),'.txt'];
        data_cor_stressor = importdata(path_stressor);

        m_path = ['E:\TEST\POSITIVE\Pair\correlation\','metricT',num2str(TOPIC),'124.txt'];
        foutMetric = fopen(m_path,'w');

        USER_ALL = 0;
        MAPE_A = 0;
        MSE_A = 0;
        RMSE_A = 0;
        MAD_A = 0;

        for pos = 1:length(filelist)
            disp(filelist(pos).name);
            %input
            path_s = ['E:\TEST\POSITIVE\Pair\correlation\T',num2str(TOPIC),'\valueBig\',filelist(pos).name];

            %output
            fnormalPath = ['E:\TEST\POSITIVE\Pair\correlation\T',num2str(TOPIC),'\normal\',filelist(pos).name];
            foutNormal = fopen(fnormalPath,'w');

            %output
            foutPath = ['E:\TEST\POSITIVE\Pair\correlation\T',num2str(TOPIC),'\predict\',filelist(pos).name];
            foutPredict = fopen(foutPath,'w'); 

            %avg, length
            lenHis = data_avg(pos,1);
            avgHis = data_avg(pos,2);
            disp('lenHis:');
            disp(lenHis);%
            disp('avgHis');
            disp(avgHis);%


            data_O = importdata(path_s);
            data_C = data_O';%column matrics
            %data_s = importdata(path_s); 
            %data_N = mapminmax(data_C,0,1);
            data_N = data_C;
            v_max = max(data_C);
            v_min = min(data_C);
            [v1,v2] = size(data_C);
            if(v_max>v_min)
                for k=1:1:v2
                    data_N(1,k) = (data_C(1,k)-v_min)/(v_max-v_min);
                end
            end

            data_s = data_N';
            [m1,n1] = size(data_s);
            trainNum = floor(m1*0.8);%change 1
            testNum = m1-trainNum;
            %if(testNum>10)
            %    testNum=10;
            %    trainNum = m1-testNum;
            %end
            disp('trainNum')
            disp(trainNum);
            disp('testNum');
            disp(testNum);

            if(trainNum>10)               
                USER_ALL = USER_ALL+1;
                %training data
                y = data_s(1:trainNum,1);%stress series
                [m,n] = size(y);
                %x-axis
                x = ones(m,1);
                for i=1:1:m
                    x(i,1)=i;
                end
                %fit and record ->estimate()
                N = 2;
                if(trainNum<=30)
                    N=1;
                end
                LOGL = zeros(N,N);
                PQ = zeros(N,N);
                %for t = 0:2
                    for p = 1:N
                        for q = 1:N
                            model_s = arima(p,0,q);
                            [fit,~,logL] = estimate(model_s,y,'print',false);
                            LOGL(p,q) = logL;
                            PQ(p,q) = p+q;
                         end
                    end
                %end

                %choose BIC ->aicbic()
                LOGL = reshape(LOGL,N*N,1);
                PQ = reshape(PQ,N*N,1);
                [~,bic] = aicbic(LOGL,PQ+1,100); 
                A = reshape(bic,N,N);

                %re-choose using smallest parameter from A       
                [m2,n2] = size(A);
                v_small = A(1,1);
                for i=1:m2
                    for j=1:n2
                        if(A(i,j)<v_small)
                            p=i;
                            q=j;
                            v_small = A(i,j);
                        end
                    end
                end

                model_new = arima(p,1,q);
                %[fit_new,~,logL] = estimate(model_new,y,'print',false); % fit is a model
                [fit_new,~,logL] = estimate(model_new,y); % fit is a model

                %PREDICT...length=testNum
                %setting1: according to lenHis
%                 if(testNum>lenHis)
%                     if(floor(lenHis)>0)
%                         testNum = floor(lenHis);
%                     end
%                 end
%                 if(testNum>7)
%                     testNum = 7;
%                 end
                    
               %setting2: according to T_NUM
               if(testNum>T_NUM)
                    testNum = T_NUM;
               end
                
                y_s = forecast(fit_new,testNum,'Y0',y); %41 means we cut down the 41 series..!!!

                %output predicted values
                for i=1:1:testNum
                    if(y_s(i,1)<0)
                        y_s(i,1)=0;
                    end
                    fprintf(foutPredict,'%.4f \r\n', y_s(i,1));
                    fprintf(foutNormal,'%.4f \r\n', data_s(trainNum+i,1));
                end

                fclose(foutPredict);     
                fclose(foutNormal);

                %output metrics for current teen
                [k1,k2] = size(y_s);
                MSE = 0;
                RMSE = 0;
                MAPE = 0;
                MAD = 0;
                %N_mape = 0;
                %mape..start
                for i=1:1:k1
                    MSE = MSE+(y_s(i,1)-data_s(i+trainNum,1))^2;

                  %  if(data_s(i+trainNum,1)>0 || y_s(i,1)>0)
                        if(data_s(i+trainNum,1)>y_s(i,1) && data_s(i+trainNum,1)>0)
                            MAPE = MAPE + abs(y_s(i,1)-data_s(i+trainNum,1))/data_s(i+trainNum,1);
                        %    N_mape = N_mape+1;
                        end
                        if(y_s(i,1)>=data_s(i+trainNum,1)&& y_s(i,1)>0)
                            MAPE = MAPE + abs(data_s(i+trainNum,1)-y_s(i,1))/y_s(i,1);
                       %     N_mape = N_mape+1;
                        end                 
                   % end

                    %mape..end
                    MAD = MAD + abs(y_s(i,1)-data_s(i+trainNum,1));
                end
                if(k1>0)
                    MSE = MSE/k1;
                    RMSE = sqrt(MSE);
                   % if(N_mape>0)
                   %     MAPE = MAPE*100/N_mape;
                    MAPE = MAPE*100/k1;
                   % end
                    MAD = MAD/k1;
                end

                MAD_A = MAD_A + MAD;
                RMSE_A = RMSE_A + RMSE;
                MSE_A = MSE_A + MSE;
                MAPE_A = MAPE_A + MAPE;

                USER_ALL = USER_ALL + 1;
                fprintf(foutMetric,'%s %.4f %.4f %.4f %.4f\r\n', filelist(pos).name, MSE, RMSE, MAPE, MAD);
                %pause;
            end
            disp('file end-------------------------');
        end
        fclose(foutMetric); 

        if(USER_ALL>0)
            fprintf(foutAll,'%d %d %.4f %.4f %.4f %.4f\r\n', TOPIC, T_NUM, MSE_A/USER_ALL, RMSE_A/USER_ALL,...
            MAPE_A/USER_ALL, MAD_A/USER_ALL);
        end  
    end
end

fclose(foutAll);