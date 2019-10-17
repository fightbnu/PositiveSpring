%Step1: read in files
    %1) stress series
        %E:\TEST\POSITIVE\Pair\correlation\T0\valueBig\
    %2) parameters
        %E:\TEST\POSITIVE\Pair\correlation\
        %avgUSI0.txt;corStress0.txt;corStressor0.txt
%Step2: predict
    %basic (done)
%Step3: metric
    %MSE, RMSE, MAPE, MAD
%Step4: adjust: corStress+corStressor; avgHis; 
    
%output
% all_path = 'E:\TEST\POSITIVE\Pair\correlation\metricALL_COR.txt';
% foutAll = fopen(all_path,'w');
        
for TOPIC = 0:4
        filelist = dir(['E:\TEST\POSITIVE\Pair\correlation\T',num2str(TOPIC),'\normal\*.txt']);
        
        %parameter1: average stress
        path_avg = ['E:\TEST\POSITIVE\Pair\correlation\','avgUSI',num2str(TOPIC),'.txt'];
        data_avg = importdata(path_avg);
        
        %parameter2: correlation - stress
        path_str = ['E:\TEST\POSITIVE\Pair\correlation\','corStress',num2str(TOPIC),'.txt'];
        data_cor_stress = importdata(path_str);
        
        %parameter3: correlation - stressor
        path_stressor = ['E:\TEST\POSITIVE\Pair\correlation\','corStressor',num2str(TOPIC),'.txt'];
        data_cor_stressor = importdata(path_stressor);

        m_path = ['E:\TEST\POSITIVE\Pair\correlation\adjust\','metricT',num2str(TOPIC),'.txt'];
        foutMetric = fopen(m_path,'w');
        
        lineNum = 101;%thresh 1)
        colNum = 4;
        I1 = zeros(lineNum,colNum);
        I2 = zeros(lineNum,colNum);
        I3 = zeros(lineNum,colNum);
        I4 = zeros(lineNum,colNum);
        USER_ALL = 0;
        
        for pos = 1:length(filelist)
            disp(filelist(pos).name);
            %input
            path_predict = ['E:\TEST\POSITIVE\Pair\correlation\T',num2str(TOPIC),'\predict\',filelist(pos).name];
            path_normal = ['E:\TEST\POSITIVE\Pair\correlation\T',num2str(TOPIC),'\normal\',filelist(pos).name];
            
            cur_path = ['E:\TEST\POSITIVE\Pair\correlation\adjust\teen\','adjustT',num2str(TOPIC),'_',num2str(pos),'.txt'];
            foutCurTeen = fopen(cur_path,'w');
            
            %avg, length, cor1, cor2
            lenHis = data_avg(pos,1);
            avgHis = data_avg(pos,2);
            corStressor = data_cor_stressor(pos,1);
            corStress = data_cor_stress(pos,1);
            
            disp('lenHis:');
            disp(lenHis);%
            disp('avgHis');
            disp(avgHis);%
            
            y = importdata(path_normal);
            y_s = importdata(path_predict);
            [k1,k2] = size(y_s);
            if(k1>0)
                USER_ALL = USER_ALL+1;
            end
            
            %adjust parameters
            label=zeros(4);
            if(corStressor>1.96 && corStress>1.96)
                label(1,1)=1;
            end
            if(corStressor>1.96 || corStress>1.96)
                label(1,2)=1;
            end
            if(corStressor>1.96)
                label(1,3)=1;
            end
            if(corStress>1.96)
                label(1,4)=1;
            end
            
            for I=1:1:4
                for thresh=0:0.01:1
                    if(label(1,I)==1)
                        for k=1:k1
                            y_s(k,1) = y_s(k,1) - avgHis*thresh;
                            if(y_s(k,1)<0)
                                y_s(k,1)=0;
                            end
                        end
                    end%label
                    
                    %output metrics for current teen
                    MSE = 0;
                    RMSE = 0;
                    MAPE = 0;
                    MAD = 0;
                    for i=1:1:k1
                        MSE = MSE+(y_s(i,1)-y(i,1))^2;
                        if(y(i,1)>y_s(i,1) && y(i,1)>0)
                            MAPE = MAPE + abs(y_s(i,1)-y(i,1))/y(i,1);
                        end
                        if(y_s(i,1)>=y(i,1)&& y_s(i,1)>0)
                            MAPE = MAPE + abs(y(i,1)-y_s(i,1))/y_s(i,1);
                        end
                        MAD = MAD + abs(y_s(i,1)-y(i,1));
                    end
                    if(k1>0)
                        MSE = MSE/k1;
                        RMSE = sqrt(MSE);
                        MAPE = MAPE*100/k1;
                        MAD = MAD/k1;
                    end
                    
                    if(I==1)
                        l_a = floor(thresh*100+1); %thresh 2)
                        I1(l_a,1) = I1(l_a,1)+MSE;
                        I1(l_a,2) = I1(l_a,2)+RMSE;
                        I1(l_a,3) = I1(l_a,3)+MAPE;
                        I1(l_a,4) = I1(l_a,4)+MAD;
                    end
                    if(I==2)
                        l_a = floor(thresh*100+1);
                        I2(l_a,1) = I2(l_a,1)+MSE;
                        I2(l_a,2) = I2(l_a,2)+RMSE;
                        I2(l_a,3) = I2(l_a,3)+MAPE;
                        I2(l_a,4) = I2(l_a,4)+MAD;
                    end
                    if(I==3)
                        l_a = floor(thresh*100+1);
                        I3(l_a,1) = I3(l_a,1)+MSE;
                        I3(l_a,2) = I3(l_a,2)+RMSE;
                        I3(l_a,3) = I3(l_a,3)+MAPE;
                        I3(l_a,4) = I3(l_a,4)+MAD;
                    end
                    if(I==4)
                        l_a = floor(thresh*100+1);
                        I4(l_a,1) = I4(l_a,1)+MSE;
                        I4(l_a,2) = I4(l_a,2)+RMSE;
                        I4(l_a,3) = I4(l_a,3)+MAPE;
                        I4(l_a,4) = I4(l_a,4)+MAD;
                    end
                    fprintf(foutCurTeen,'%s %.4f %d %.4f %.4f %.4f %.4f\r\n', filelist(pos).name, thresh, I, MSE, RMSE, MAPE, MAD);
                end%thresh
            end%I=1:1:4
            disp('file end-------------------------');
            fclose(foutCurTeen);
        end %for pos=1:124
        
        if(USER_ALL>0)
            [s3,s4] = size(I1);
            for b_l=1:1:s3
                fprintf(foutMetric,'%d %d %.4f %.4f %.4f %.4f\r\n', TOPIC, 1, I1(b_l,1)/USER_ALL, I1(b_l,2)/USER_ALL,...
                    I1(b_l,3)/USER_ALL, I1(b_l,4)/USER_ALL);
            end
            for b_l=1:1:s3
                fprintf(foutMetric,'%d %d %.4f %.4f %.4f %.4f\r\n', TOPIC, 2, I2(b_l,1)/USER_ALL, I2(b_l,2)/USER_ALL,...
                    I2(b_l,3)/USER_ALL, I2(b_l,4)/USER_ALL);
            end
            for b_l=1:1:s3
                fprintf(foutMetric,'%d %d %.4f %.4f %.4f %.4f\r\n', TOPIC, 3, I3(b_l,1)/USER_ALL, I3(b_l,2)/USER_ALL,...
                    I3(b_l,3)/USER_ALL, I3(b_l,4)/USER_ALL);
            end
            for b_l=1:1:s3
                fprintf(foutMetric,'%d %d %.4f %.4f %.4f %.4f\r\n', TOPIC, 4, I4(b_l,1)/USER_ALL, I4(b_l,2)/USER_ALL,...
                    I4(b_l,3)/USER_ALL, I4(b_l,4)/USER_ALL);
            end
        end
        fclose(foutMetric);
end  %....topic

%fclose(foutAll);