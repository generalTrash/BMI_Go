
function y_pred = knn_model(train, test, k,b)
    train_num = size(train, 1);
    test_num = size(test, 1);
    % distances between the test and training dataset
    dist = zeros(test_num, train_num);
    for i = test_num
        for j = 1:train_num
            dist(i,j) = norm(test(i,:) - train(j,:));
        end
    end
    
    % nearest k neighbors
    [~, idx] = sort(dist, 'ascend');
    idx = idx(:, 1:k);
    % Make predictions
    y_pred = zeros(test_num, 1);
    for i = 1:test_num
        knn_labels = (mod(idx(i,:)-1,b)+1)';
        y_pred(i) = mode(knn_labels);
    end
end