function [modelParameters] = positionEstimatorTraining(training_data)
    a = size(training_data,1)
    b = size(training_data,2)
    X=zeros(a*b,98);
    y=zeros(a*b,1);
 
    for i = 1:a
        for n = 1:b
            spikes = training_data(i,n).spikes;
            f_rate=sum(spikes, 2)/size(spikes,2);
            X((i-1) * b + n,:)=f_rate;
            y((i-1) * b + n,:)=n;
        end
    end
    k=a*b/8;
    modelParameters.X=X;
    modelParameters.k=k;
    modelParameters.training_data=training_data;
    modelParameters.a=a;
    modelParameters.b=b;
    modelParameters.ID=-1;
    
end