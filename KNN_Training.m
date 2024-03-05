function [modelParameters] = positionEstimatorTraining(training_data)
    train_size = size(training_data,1);
    direction_size = size(training_data,2);
    average_f_rate=zeros(train_size*direction_size,98);
 
    for i = 1:train_size
        for n = 1:direction_size
            spikes = training_data(i,n).spikes;
            f_rate=sum(spikes, 2)/size(spikes,2);
            average_f_rate((i-1) * direction_size + n,:)=f_rate;
        end
    end
    k=train_size*direction_size/8;
    modelParameters.average_firing_rate=average_f_rate;
    modelParameters.k=k;
    modelParameters.training_data=training_data;
    modelParameters.train_size=train_size;
    modelParameters.direction_size=direction_size;
end