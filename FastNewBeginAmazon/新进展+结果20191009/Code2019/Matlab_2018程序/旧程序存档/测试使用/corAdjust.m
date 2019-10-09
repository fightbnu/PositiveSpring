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
all_path = 'E:\TEST\POSITIVE\Pair\correlation\metricALL.txt';
foutAll = fopen(all_path,'w');
    
for TOPIC = 0:4
    filelist = dir(['E:\TEST\POSITIVE\Pair\correlation\T',num2str(TOPIC),'\normal\*.txt']);
    
	%In: parameter1: average stress
	path_avg = ['E:\TEST\POSITIVE\Pair\correlation\','avgUSI',num2str(TOPIC),'.txt'];
    data_avg = importdata(path_avg);
	
	%In: parameter2: correlation - stress
	path_str = ['E:\TEST\POSITIVE\Pair\correlation\','corStress',num2str(TOPIC),'.txt'];
    data_cor_stress = importdata(path_str);
	
	%In: parameter3: correlation - stressor
	path_stressor = ['E:\TEST\POSITIVE\Pair\correlation\','corStressor',num2str(TOPIC),'.txt'];
    data_cor_stressor = importdata(path_stressor);
	
    %output ????
    m_path = ['E:\TEST\POSITIVE\Pair\correlation\adjust\','a_metricT',num2str(TOPIC),'124.txt'];
    foutMetric = fopen(m_path,'w');
    
    %对于124人的统计
    USER_ALL = 0;
    MAPE_A = 0;
    MSE_A = 0;
    RMSE_A = 0;
    MAD_A = 0;
    
    for pos = 1:length(filelist)
        disp(filelist(pos).name);
        %input
        path_predict = ['E:\TEST\POSITIVE\Pair\correlation\T',num2str(TOPIC),'\predict\',filelist(pos).name];
        path_normal = ['E:\TEST\POSITIVE\Pair\correlation\T',num2str(TOPIC),'\normal\',filelist(pos).name];	
        %output: 124tenn各自adjust结果
        cur_path = ['E:\TEST\POSITIVE\Pair\correlation\adjust\teen\','a_metricT',num2str(TOPIC),'_',num2str(pos),'.txt'];
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
        
        %adjust parameters
        M=[];
        P=zeros(11,11);
        %为什么11:因为a,b两个参数各自有10个值，因此有11*11种组合，此处用MAPE作为每次调参的综合结果
        %作用：画网格热度图

        for a=0.0:0.01:1          
            for b=0.0:0.1:1        
                for k=1:k1
                    y_s(k,1) = y_s(k,1) - avgHis*(a*corStress+b*corStressor); %预测值adjust %????这样到最后不会变成0吗
                    if(y_s(k,1)<0)
                        y_s(k,1)=0;
                    end                   
                end
                
                %output metrics for current teen （in current set）   
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
                
                %put into 1*6 matrix
                X=zeros(1,6);
                X(1,1)=MSE;
                X(1,2)=RMSE;
                X(1,3)=MAPE;
                X(1,4)=MAD;
                X(1,5)=a;
                X(1,6)=b;
                B=M;
                M=[B;X]; %最终M是100*6的matrix
                pos_i=floor(a*100+1);
                pos_j=floor(b*100+1);
                P(pos_i,pos_j)=MAPE; %目前后边就没有再用，是想画热点图来着
            end
        end
        
        if(~isempty(M))
            [x1,y1]=min(M(:,1));%x is value, y is line
            [x2,y2]=min(M(:,2));
            [x3,y3]=min(M(:,3));
            [x4,y4]=min(M(:,4));

            MAD_A = MAD_A + M(y1,1); %????应该是x1吧? ！！！ERROR? ！！！ERROR?
            RMSE_A = RMSE_A + M(y2,2);
            MSE_A = MSE_A + M(y3,3);
            MAPE_A = MAPE_A + M(y4,4);

            USER_ALL = USER_ALL + 1; %若当前teen进行了预测调参的话，用户+1
            %output best
            fprintf(foutMetric,'%s %.4f %.4f %.4f %.4f\r\n', filelist(pos).name, M(y1,1), M(y2,2), M(y3,3), M(y4,4)); %跟着错了吧????
            % m_path = ['E:\TEST\POSITIVE\Pair\correlation\adjust\','a_metricT',num2str(TOPIC),'124.txt'];
            
            %output all
            [s1,s2]=size(M);
            for c=1:1:s1
                for d=1:1:s2
                    fprintf(foutCurTeen,'%.4f ',M(c,d));
                    % cur_path = ['E:\TEST\POSITIVE\Pair\correlation\adjust\teen\','a_metricT',num2str(TOPIC),'_',num2str(pos),'.txt'];
                end
                fprintf(foutCurTeen,'\r\n');
            end            
        end     
        disp('file end-------------------------');
        fclose(foutCurTeen);
    end %current teen结束
    fclose(foutMetric); 
    
    if(USER_ALL>0) %所有参与预测调参的用户，<124可能
        fprintf(foutAll,'%d %.4f %.4f %.4f %.4f\r\n', TOPIC, MSE_A/USER_ALL, RMSE_A/USER_ALL,...
        MAPE_A/USER_ALL, MAD_A/USER_ALL);
    end  
end
fclose(foutAll);