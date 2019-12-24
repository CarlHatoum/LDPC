function c_cor = HARD_DECODER_GROUPE3(c, H, MAX_ITER)
    
    [c_rows, c_cols] = size(c);
    [H_rows, H_cols] = size(H);
    
    % Check if c is of the form [N, 1] and if it contains only binary
    % values
    if c_cols == 1 && c_rows == 1
        disp("c must be of the form [N, 1]")
        return
    elseif sum(sum(c > 1)) ~= 0
        disp("c must only contain binary values")
        return
    else
        % amount_of_v_nodes is the number of 'v-nodes' in c
        if isvector(c) && (c_cols > 1)
            c = c';
            amount_of_v_nodes = c_cols; 
        else
            amount_of_v_nodes = c_rows;
        end
    end

    
    % Check if H is of the form [M, N] and if it contains only binary
    % values.
    % amount_of_c_nodes is the number of rows in H
    if H_rows >= H_cols
        disp("H must be of the form [M, N] where M < N")
        return
    elseif sum(sum(H > 1)) ~= 0
        disp("H must only contain binary values")
        return
    else
        amount_of_c_nodes = H_rows;
    end
        
    % Check MAX_ITER is a strictly positive integer
    if MAX_ITER <= 0 && floor(MAX_ITER) ~= MAX_ITER
        disp('MAX_ITER must be a "strictly positive integer"')
        return
    elseif MAX_ITER <= 0
        disp('MAX_ITER must be a "strictly positive" integer')
        return
    elseif floor(MAX_ITER) ~= MAX_ITER
        disp('MAX_ITER must be a strictly positive "integer"')
        return
    end
    
    % Iterate over the H matrix to create a new matrix 'messages' which 
    % will contain the "message" received from the 'v_nodes' of 'c'
    
    messages = -1 * ones(amount_of_c_nodes, amount_of_v_nodes);
    
    for row = 1:H_rows
        for col = 1:H_cols
            if H(row, col) == 1
                messages(row, col) = c(col);
            end
        end
    end
    
    % Calculate the responses from the received messages
    
    responses = -1 * ones(amount_of_c_nodes, amount_of_v_nodes);
    
    for row = 1:amount_of_c_nodes
        col = 1;
        % While we haven't reached the end of the row...
        while col <= amount_of_v_nodes
            % If the v_node sent a 'message' (cell isn't -1)...
            if messages(row, col) ~= -1
                parity_check_col = 1;
                parity_check = 0;
                % Iterate over the whole row...
                while parity_check_col <= amount_of_v_nodes
                    % Except if the value of the cell is -1 or if the
                    % current column is the same column that initiated this
                    % iteration...
                    if (parity_check_col ~= col) && (messages(row, parity_check_col) ~= -1)
                        % Add the values found to the variable
                        % 'parity_check'
                        parity_check = parity_check + messages(row, parity_check_col);
                    end
                    % Then go to the next column and continue searching
                    % until you reach the end of the row
                    parity_check_col = parity_check_col + 1;
                end
                % Check the parity result and send the correct bit back to
                % the 'v-node' to have the correct parity
                if mod(parity_check, 2) == 0
                    responses(row, col) = 0;
                else
                    responses(row, col) = 1;
                end
            end
            col = col + 1;
        end
    end
        
    % Create matrix for majority vote of size amount_of_v_nodes by 3
    majority_vote = zeros(amount_of_v_nodes, 3);
    
    % Place the c vector into the first column of the matrix
    majority_vote(:,1) = c;
    
    % Iterate over the columns...
    for col = 1:amount_of_v_nodes
        % Set the c-node index to the start of the columns and the
        % majority_vote_index to the second column to be filled in
        c_node_index = 1;
        majority_vote_index = 2;
        %Iterate over the c_nodes...
        while c_node_index < 5
            % If the current cell contains a response bit...
            if responses(c_node_index, col) ~= -1
                % Put the said response bit into the majority_vote array
                % and increment the majority_vote_index to fill the next
                % column on the following iteration.
                majority_vote(col, majority_vote_index) = responses(c_node_index, col);
                majority_vote_index = majority_vote_index + 1;
            end
            c_node_index = c_node_index + 1;
        end
    end
    
    % c_cor will contain the result of the majority vote
    c_cor = zeros(amount_of_v_nodes, 1);
    
    for row = 1:amount_of_v_nodes
        % Mode gets the most frequent element in an array, here the array
        % being each row
        c_cor(row, 1) = mode(majority_vote(row, :));
    end
end
