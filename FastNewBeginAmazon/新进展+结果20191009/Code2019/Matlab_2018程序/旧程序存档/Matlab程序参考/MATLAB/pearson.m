%%for pearson
load examgrades

dim=['1','2','3','4','5'];

for DIM=1:1:5
   
    %INPUT-FILE
    foutPath=['E:\TEST\Predict\DayStaFilter\Correlation\correlation_',dim(DIM),'.txt'];
    disp(foutPath);
    fout=fopen(foutPath,'w');
    foutPath_stressor=['E:\TEST\Predict\DayStaFilter\Correlation\correlationStressor_',dim(DIM),'.txt'];
    fout_stressor=fopen(foutPath_stressor,'w');

    %stress
    datalist_random=dir(['E:\TEST\Predict\DayStaFilter\E',dim(DIM),'\randomSlide\*.txt']);  %random-slide
    datalist_stress=dir(['E:\TEST\Predict\DayStaFilter\E',dim(DIM),'\slide\*.txt']);      %stressor-slide
    %stressor
    datalist_random_stressor=dir(['E:\TEST\Predict\DayStaFilter\E',dim(DIM),'\randomSlide_stressor\*.txt']);  %random-slide
    datalist_stressor=dir(['E:\TEST\Predict\DayStaFilter\E',dim(DIM),'\slide_stressor\*.txt']);      %stressor-slide
    %name
    datalist_name=dir(['E:\TEST\Predict\DayStaFilter\E',dim(DIM),'\name\*.txt']);  %random-slide
    
    for pos=1:length(datalist_stress)
        corRes=0;
        corRes_stressor=0;
    
        %stress
        finRandomPath=['E:\TEST\Predict\DayStaFilter\E',dim(DIM),'\randomSlide\',datalist_random(pos).name];
        finStressPath=['E:\TEST\Predict\DayStaFilter\E',dim(DIM),'\slide\',datalist_stress(pos).name];
        %stressor
        finRandomPath_stressor=['E:\TEST\Predict\DayStaFilter\E',dim(DIM),'\randomSlide_stressor\',datalist_random_stressor(pos).name];
        finStressPath_stressor=['E:\TEST\Predict\DayStaFilter\E',dim(DIM),'\slide_stressor\',datalist_stressor(pos).name];
        %name
        finNamePath=['E:\TEST\Predict\DayStaFilter\E',dim(DIM),'\name\',datalist_name(pos).name];
        
        x = importdata(finRandomPath);
        y = importdata(finStressPath);   
        x_stressor=importdata(finRandomPath_stressor);
        y_stressor=importdata(finStressPath_stressor);
        name = importdata(finNamePath);

        %1)Input: random slide
        [m_r,n_r] = size(x);
        id_r = ones(m_r,1);
        for i=1:1:m_r
            id_r(i,1)=i;
        end
        X=[id_r,x];
        X_Stressor=[id_r,x_stressor];

        %1)Input: slide
        [m,n] = size(y);
        id = ones(m,1);
        for i=1:1:m
            id(i,1)=i;
        end
        Y=[id,y];
        Y_Stressor=[id,y_stressor];

        %1)Combine-input: slide+random slide
        [m_name,n_name]=size(name);
        if(~(m_r==2*m && (m_r+m)==m_name))
            disp('FILE NOT EQUAL');
            pause;
        end  
        z=[y;x];%按行合并
        z_stressor=[y_stressor;x_stressor];
        id_z = ones(m_r+m,1);
        for i=1:1:m_r+m
            id_z(i,1)=i;
        end
        Z=[id_z,z];
        Z_Stressor=[id_z,z_stressor];

%         %2)TEST-KNN-method (2 methods)
%         [N,D]=knnsearch(z,z,'k',3,'distance','minkowski','p',5);%!!!!!!!!!!!
%         [ncb,dcb]=knnsearch(z,y,'k',3,'distance','chebychev');
% 
%         [N_stressor,D_stressor]=knnsearch(z_stressor,z_stressor,'k',3,'distance','minkowski','p',5);%!!!!!!!!!!!
%         [ncb_2,dcb_2]=knnsearch(z_stressor,y_stressor,'k',3,'distance','chebychev');
        
        %pearson
        %[s1,s2]=size(y);
        %[ss1,ss2]=size(z);
        M1=y';
        M2=z';
        M3=y_stressor';
        M4=z_stressor';     
        
        [a1,a2]=size(M1);
        [b1,b2]=size(M3);
        
        if(a1==0 || b1==0)
            display('null');
             fprintf(fout,'0 %s\r\n',datalist_stress(pos).name);
             fprintf(fout_stressor,'0 %s\r\n',datalist_stress(pos).name);
            continue;
        end
        
        res1 = corr(M1,M2);
        R1 = res1(~isnan(res1));
        [s1,s2]=size(R1);
        r1=0;
        for i=1:1:s1
            for j=1:1:s2
                r1=r1+R1(i,j);
            end
        end
        
        if(s1>0 && s2>0)
            r1=r1/(s1*s2);
        end
        
        res2 = corr(M3,M4);
        R2 = res2(~isnan(res2));
        [ss1,ss2]=size(R2);
        r2=0;
        for i=1:1:ss1
            for j=1:1:ss2
                r2=r2+R2(i,j);              
            end
        end
        if (ss1>0 && ss2>0)
            r2=r2/(ss1*ss2);    
        end
        fprintf(fout,'%.4f %s\r\n',r1,datalist_stress(pos).name);
        fprintf(fout_stressor,'%.4f %s\r\n',r2,datalist_stress(pos).name);
        disp(datalist_stress(pos).name);    
    end
    
    fclose(fout);
    fclose(fout_stressor);
end

