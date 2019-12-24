
function c_cor = SOFT_DECODER_GROUPE3(c, H, p, MAX_ITER)
    
    % Nous allons vérifier dans un premier temps si les paramètres en
    % entrée sont bons
    [c_rows, c_cols] = size(c);
    [H_rows, H_cols] = size(H);
    
    if c_cols == 1 && c_rows == 1
        disp("c must be of the form [N, 1]")
        return
    elseif sum(sum(c > 1)) ~= 0
        disp("c must only contain binary values")
        return
    else
       
        if isvector(c) && (c_cols > 1)
            c = c';
            amount_of_v_nodes = c_cols; 
        else
            amount_of_v_nodes = c_rows;
        end
    end

    % La matrice H ne doit contenir que des valeurs binaires
    if H_rows >= H_cols
        disp("H must be of the form [M, N] where M < N")
        return
    elseif sum(sum(H > 1)) ~= 0
        disp("H must only contain binary values")
        return
    else
        amount_of_c_nodes = H_rows;
    end
    
    % Verifer si les dimensions de la matrice H sont bonnes
    if amount_of_v_nodes ~= H_cols
        fprintf("H and c dimensions don't match, check your input for mistakes.\n")
        return
    end
        
    % Vérifier si le nombre d'iterations maximum et bon
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
    
    
    % Création de la matrice contenant les messages ( v-nodes --> c-nodes).
    % Nous remplisons la matrice par des "-1" de façon à, plus tard,
    % distinguer les noeuds connectés ou non.
    messages = -1 * ones(amount_of_c_nodes, amount_of_v_nodes);
    
    % Création du vecteur iter_c, contenant les différentes valeurs de c
    % qui vont être mises à jour au fil de l'algorithme
    iter_c=c;
    
    % On initialise la matrice messages par la valeur de p correspondant au
    % bon c-node. 
    for row = 1:H_rows
        for col = 1:H_cols
            if H(row, col) == 1
                messages(row, col) = p(col);
            end
        end
    end
    
    % Création de la matrice responses, qui stockera les valeurs des
    % réponses des c-nodes aux v-nodes. 
     responses = -1 * ones(amount_of_c_nodes, amount_of_v_nodes);
    
     % L'initialisation est terminée, nous allons à présent commencer la
     % partie itérative de l'algorithme.
    for iter = 1:MAX_ITER
                            
        % Les c-nodes vont calculer les reponses
        for row = 1:amount_of_c_nodes
            for col = 1:amount_of_v_nodes
                % Si il sont connectés, la valeur de la cellule est
                % différente de -1
                if messages(row, col) ~= -1
                    rij=zeros(1,2);
                    prod_temp = abs(prod(1-2*messages,2));
                    rij(1) = 0.5 + (0.5*(prod_temp(row)/(1-2*messages(row,col))));
                    rij(2) = 1-rij(1);
                    
                    % Nous allons envoyer que le rij(0), équivalent sous
                    % Matlab à rij(1) (les indices commencent à partir de
                    % 1). Il n'est pas nécessaire d'en envoyer plus car on
                    % peut déduire l'un à partir de l'autre
                    responses(row,col) = rij(1);
                    
                end
            end
        end

        % Nous allons à présent calculer les messages à partir des réponses
        % précedentes
        for col = 1:amount_of_v_nodes
            
            % Calculs du Qi et du Ki pour la colonne
            Qi = zeros(1,2);
            prod_col=zeros(1,2);
            Qi_provisoire=zeros(1,2);
            
            responses_col=responses(:,col);
            produit_mat=prod(abs(responses),1);
            produit_mat_opposees=prod(nonzeros(1-abs(responses_col)),1);
            
            prod_col(1) = produit_mat(col);
            prod_col(2) = produit_mat_opposees; 
            
            Qi_provisoire(1)= (1-p(col))*prod_col(1);
            Qi_provisoire(2)= p(col)*prod_col(2);
            
            Ki = 1/(Qi_provisoire(1)+Qi_provisoire(2));
            Qi(2) = Ki*Qi_provisoire(2);
            Qi(1) = Ki*Qi_provisoire(1);
           
            if(Qi(2) > Qi(1))
                iter_c(col) = 1;
            else 
                iter_c(col) = 0;
            end
           
            for row = 1:amount_of_c_nodes
                if(responses(row,col) ~= -1)
                   %chaque case nous allons calculer le message des v-nodes
                   %vers les c-nodes.

                    qij_provisoire=zeros(1,2);
                    qij=zeros(1,2);

                    qij_provisoire(1)=Qi_provisoire(1)/(responses(row,col));

                    qij_provisoire(2)=Qi_provisoire(2)/(1-responses(row,col));

                    Kij = 1/(qij_provisoire(1)+qij_provisoire(2));
                    qij(2) =  Kij * qij_provisoire(2);
                    qij(1) =  Kij * qij_provisoire(1); 

                    % Nous allons envoyer que le qij(0), équivalent sous
                    % Matlab à qij(1) (les indices commencent à partir de
                    % 1). Il n'est pas nécessaire d'en envoyer plus car on
                    % peut déduire l'un à partir de l'autre
                    messages(row, col)= qij(1);
                end
           end
        end
        
      
        
        % Nous allons vérifier si le vecteur iter_c, à savoir la valeur
        % dans cette itération des valeurs successives de la correction de
        % c, vérifie la condition de partié
        parity_check_vector = parity_check(iter_c, H, amount_of_c_nodes, amount_of_v_nodes);
        
        if sum(parity_check_vector) == 0
            fprintf("Parity check completed successfully after %i iterations.\n", iter);
            c_cor = iter_c;
            return
        end
    end
    
    fprintf("Reached maximum iterations.\n");
    c_cor = iter_c;
end

function parity_check_vector = parity_check(c, H, c_nodes, v_nodes)
    % Do the parity check for the given c
    parity_check_vector = zeros(c_nodes, 1);
    for row = 1:c_nodes
        parity = 0;
        for col = 1:v_nodes
            if H(row, col) ~= 0
                parity = parity + c(col);
            end
        end
        parity_check_vector(row) = mod(parity, 2);
    end
end
