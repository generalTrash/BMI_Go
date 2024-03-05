function y_pred = knn_model(average_firing_rate, test_f_rate, k,direction_size)
    train_num = size(average_firing_rate, 1);
    test_num = size(test_f_rate, 1);
    % distances between the test and training dataset
    dist = zeros(test_num, train_num);
    for i = test_num
        for j = 1:train_num
            dist(i,j) = norm(test_f_rate(i,:) - average_firing_rate(j,:));
        end
    end
    
    % nearest k neighbors
    [~, idx] = sort(dist, 'ascend');
    idx = idx(:, 1:k);
    % Make predictions
    y_pred = zeros(test_num, 1);
    for i = 1:test_num
        knn_labels = (mod(idx(i,:)-1,direction_size)+1)';
        y_pred(i) = mode(knn_labels);
    end
end