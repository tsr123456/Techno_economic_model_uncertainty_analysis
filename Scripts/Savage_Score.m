function [S_Score] = Savage_Score(N,rank)

% N is the number of inputs and should be scalar
% rank is the rank and can be a vector

number_of_ranks = length(rank); % determine number of ranks to be computed.
S_Score = zeros(1,number_of_ranks);

for i = 1:number_of_ranks

rank_i = rank(i); % select rank for this iteration
s_score = 0; 

for ii = rank_i:N
    
    y = 1/rank_i;
    
    s_score = s_score + y; % add up score
    
    rank_i = rank_i +1; %increase rank by one
end
S_Score(i) = s_score; % copy final result into output array

end

S_Score = reshape (S_Score, number_of_ranks, 1); 

end

