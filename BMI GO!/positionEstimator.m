% estimate function
function [x, y] = positionEstimator(test_data, modelParameters)

  % **********************************************************
  %
  % You can also use the following function header to keep your state
  % from the last iteration
  %
  % function [x, y, newModelParameters] = positionEstimator(test_data, modelParameters)
  %                 ^^^^^^^^^^^^^^^^^^
  % Please note that this is optional. You can still use the old function
  % declaration without returning new model parameters. 
  %
  % *********************************************************

  % - test_data:
  %     test_data(m).trialID
  %         unique trial ID
  %     test_data(m).startHandPos
  %         2x1 vector giving the [x y] position of the hand at the start
  %         of the trial
  %     test_data(m).decodedHandPos
  %         [2xN] vector giving the hand position estimated by your
  %         algorithm during the previous iterations. In this case, N is 
  %         the number of times your function has been called previously on
  %         the same data sequence.
  %     test_data(m).spikes(i,t) (m = trial id, i = neuron id, t = time)
  %     in this case, t goes from 1 to the current time in steps of 20
  %     Example:
  %         Iteration 1 (t = 320):
  %             test_data.trialID = 1;
  %             test_data.startHandPos = [0; 0]
  %             test_data.decodedHandPos = []
  %             test_data.spikes = 98x320 matrix of spiking activity
  %         Iteration 2 (t = 340):
  %             test_data.trialID = 1;
  %             test_data.startHandPos = [0; 0]
  %             test_data.decodedHandPos = [2.3; 1.5]
  %             test_data.spikes = 98x340 matrix of spiking activity
  
  
  
  % ... compute position at the given timestep.
  
  % Return Value:
  
  % - [x, y]:
  %     current position of the hand
 

    % read the parameters
  average_firing_rate=modelParameters.average_firing_rate;
  k=modelParameters.k;
  training_data=modelParameters.training_data;
  train_size=modelParameters.train_size;
  direction_size=modelParameters.direction_size;
  
  % set the memmory
  test_spikes=test_data.spikes;
  time_length=length(test_spikes(1,:));
  x_sum=0;
  y_sum=0;
  
  % test data firing rate
  test_f_rate=sum(test_spikes,2)/time_length;

  % predict the direction
  predict_direction=knn(average_firing_rate, (test_f_rate)', k,direction_size);
      
 
 for i = 1:train_size
    if (size(training_data(i,predict_direction).handPos,2)>=time_length)
        % average movement in training data
        x_sum = x_sum+training_data(i,predict_direction).handPos(1,time_length)-training_data(i,predict_direction).handPos(1,300);
        y_sum = y_sum+training_data(i,predict_direction).handPos(2,time_length)-training_data(i,predict_direction).handPos(2,300);
    else
        % average movement (action completed) in training data
        x_sum = x_sum+training_data(i,predict_direction).handPos(1,end-100)-training_data(i,predict_direction).handPos(1,300);
        y_sum = y_sum+training_data(i,predict_direction).handPos(2,end-100)-training_data(i,predict_direction).handPos(2,300);
    end
 end

 x=test_data.startHandPos(1)+x_sum/size(training_data,1);
 y=test_data.startHandPos(2)+y_sum/size(training_data,1);
   
end

% knn classification
function pred = knn(average_firing_rate, test_f_rate, k,direction_size)
    train_num = size(average_firing_rate, 1);
    test_num = size(test_f_rate, 1); 

    %locate memory
    dist = zeros(test_num, train_num);
    pred = zeros(test_num, 1);
    
    % difference between test and training dataset
    for i = test_num
        for j = 1:train_num
            dist(i,j) = norm(test_f_rate(i,:) - average_firing_rate(j,:));
        end
    end
    
    % k classification
    [~, idx] = sort(dist, 'ascend');
    idx = idx(:, 1:k);
    
    for i = 1:test_num
        knn_labels = (mod(idx(i,:)-1,direction_size)+1)';
        pred(i) = mode(knn_labels);
    end
end