filelist = dir('E:\TEST\POSITIVE\Depart\forMat\*.txt');
    path_up = 'E:\TEST\POSITIVE\Depart\forMat\a1.txt';
    path_str = 'E:\TEST\POSITIVE\Depart\forMat\a1_s.txt';
    
    data_up = importdata(path_up);
    data_str = importdata(path_str);
         
    y_up = data_up(:,1);
    y_str = data_str(:,1);
                             
   
    
    [m,n] = size(y_up);    
    x_up = ones(m,1);
    
    for i=1:1:m
        x_up(i,1)=i;
    end
    
    for i=1:1:m
        y_up(i,1)=y_up(i,1)*(-1);
    end
    
    y_up2 = smooth(y_up,15, 'lowess');%
    y_str2 = smooth(y_str,15,'lowess');
    
    
    plot(x_up,y_str,x_up,y_up2,x_up,y_str2);
    legend('origin','smooth_up','smooth_str');