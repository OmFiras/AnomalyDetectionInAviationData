function [  ] = frobeniusSimilaritySyn( pathToTheDir, numFeatures, numClusters )

listOfFiles = dir(pathToTheDir);
listOfFiles([listOfFiles.isdir])= []; % Remove directories

fileList = {listOfFiles.name};

%% Compute the eigVectMatrix for each flight (each *.mat file)
eigVectCorrMatrix = [];
eigValuesCorrMatrix = [];

corrMatrix = [];

allDataMatrix = [];
tobeRemovedCols = [];

% go over all files and find all where variance is zero
for index = 1 : size(fileList,2)
    totalPath = sprintf('%s%s', pathToTheDir, fileList{1, index});
    dataMatrix = csvread(totalPath);
    for idx = 1 : size(dataMatrix, 2)
        if var(dataMatrix(:, idx)) == 0
            tobeRemovedCols = [tobeRemovedCols idx];
        end
    end
end

% eliminate duplicates
tobeRemovedCols = unique(tobeRemovedCols);

for index = 1 : size(fileList, 2)
    totalPath = sprintf('%s%s', pathToTheDir, fileList{1, index});
    dataMatrix = csvread(totalPath);
    dataMatrix(:, tobeRemovedCols) = [];
    
    allDataMatrix{index} = dataMatrix;
    %     for i = 1 : size(dataMatrix, 2)
    %         for j = 1 : size(dataMatrix, 2)
    %             Data1 = dataMatrix(:, i);
    %             Data2 = dataMatrix(:, j);
    %             temp =  corr(Data1, Data2, 'type', 'Kendall');
    %             if( temp <= 1 && temp >= -1)
    %                 correlation(i, j) = abs(temp);
    %             else
    %                 correlation(i, j) = 0;
    %             end
    %         end
    %     end
    correlation = corr(dataMatrix, 'type', 'kendall');
    
    corrMatrix{index} = correlation;
    
    if numFeatures == 0
        [~, eV] = eigs(correlation, size(dataMatrix, 2));
        sumEV = 0;
        cutOff = trace(eV) * 0.9; % capture 90% of the data
        for i = 1 : length(eV)
            sumEV = sumEV + eV(i, i);
            if sumEV >= cutOff
                numFeatures = i;
                break;
            end
        end
    end
    
    [eVMatrix, eV] = eigs(correlation, numFeatures);
    
    eigValuesCorrMatrix = [eigValuesCorrMatrix; eV(sub2ind(size(eV),1 : size(eV,1), 1 : size(eV,2)))];
    % plot(1:size(eV), eV,'r+');
    
    eigVectCorrMatrix{index} = eVMatrix;
end

%% Similarity of PCA
spcaSim = zeros(size(eigVectCorrMatrix, 2));

for i = 1 : size(eigVectCorrMatrix, 2)
    A = eigVectCorrMatrix{i};
    for j = 1 : size(eigVectCorrMatrix, 2)
        B = eigVectCorrMatrix{j};
        spcaSim(i, j) = trace(A * B' * B * A');
        spcaSim(j, i) = spcaSim(i, j);
    end
end

disp('Similarity matrix using SPCA:');
disp(spcaSim);

%% Frobenius norm

frobeniusSim = zeros(size(corrMatrix, 2));

for i = 1 : size(corrMatrix, 2)
    a = corrMatrix{i};
    for j = 1 : size(corrMatrix, 2)
        b = corrMatrix{j};
        x = a - b;
        frobeniusSim(i, j) = sum(sqrt(sum(x.^2)));
    end
end

disp('Similarity matrix using Frobenius norm:');
disp(frobeniusSim);

%% Squared Frobenius norm

sqFCorr = zeros(size(eigVectCorrMatrix, 2));

for i = 1 : size(eigVectCorrMatrix, 2)
    corrA = eigVectCorrMatrix{i};
    for j = (i + 1) : size(eigVectCorrMatrix, 2)
        corrB = eigVectCorrMatrix{j};
        normSq1 = sqrt(sum(corrA.^2)) .* sqrt(sum(corrB.^2));
        sqFCorr(i, j) =  2* (numFeatures - sum(dot(corrA, corrB) ./ normSq1));
        sqFCorr(j, i) = sqFCorr(i, j);
    end
end

disp('Similarity matrix using Squared Frobenius norm - Kendall Correlation:');
disp(sqFCorr);

%% Weighted Eros norm

weightedErosCorr = zeros(size(eigVectCorrMatrix, 2));
wEVCorr = sum(eigValuesCorrMatrix) / sum(sum(eigValuesCorrMatrix));

for i = 1 : size(eigVectCorrMatrix, 2)
    corrA = eigVectCorrMatrix{i};
    for j = (i + 1) : size(eigVectCorrMatrix, 2)
        corrB = eigVectCorrMatrix{j};
        normSq1 = sqrt(sum(corrA.^2)) .* sqrt(sum(corrB.^2));
        weightedErosCorr(i, j) = sum(wEVCorr .* abs(dot(corrA, corrB) ./ normSq1));
        weightedErosCorr(j, i) = weightedErosCorr(i, j);
    end
end

disp('Similarity matrix using Weighted Eros - Kendall Correlation:');
disp(weightedErosCorr);

%% Geometric mean Weighted Eros norm

gWeightedErosCorr = zeros(size(eigVectCorrMatrix, 2));

for i = 1 : size(eigVectCorrMatrix, 2)
    corrA = eigVectCorrMatrix{i};
    eva1 = eigValuesCorrMatrix(i, :);
    for j = (i + 1) : size(eigVectCorrMatrix, 2)
        corrB = eigVectCorrMatrix{j};
        evb1 = eigValuesCorrMatrix(j, :);
        normSq1 = sqrt(sum(corrA.^2)) .* sqrt(sum(corrB.^2));
        geoMean1 = sqrt(eva1 .* evb1);
        geoMean1 = geoMean1 / sum(geoMean1);
        gWeightedErosCorr(i, j) =  sum(geoMean1 .* abs(dot(corrA, corrB) ./ normSq1));
        gWeightedErosCorr(j, i) = gWeightedErosCorr(i, j);
    end
end

disp('Similarity matrix using GWeighted Eros - Kendall Correlation:');
disp(gWeightedErosCorr);

%% Bregman divergence
bDMatrix = zeros(size(corrMatrix, 2));

for i = 1 : size(corrMatrix, 2)
    M1 = corrMatrix{i} + ((0.001) * eye(size(corrMatrix{i})));
    for j = (i + 1) : size(corrMatrix, 2)
        M2 = corrMatrix{j} + ((0.001) * eye(size(corrMatrix{i})));
        bDMatrix(i, j) = trace( M1*logm(M1) - M1*logm(M2) - M1 + M2 );
        bDMatrix(j, i) = bDMatrix(i, j);
    end
end


%% Form the SimMatrix

SimMatrix{1} = bDMatrix;
SimMatrix{2} = gWeightedErosCorr;
SimMatrix{3} = weightedErosCorr;
SimMatrix{4} = sqFCorr;
SimMatrix{5} = frobeniusSim;
SimMatrix{6} = spcaSim;

%% Spectral clustering using similarity matrices
for index = 1 : size(SimMatrix, 2)
    W = SimMatrix{1, index};
    % S = diag(sum(W, 2));
    % L = eye(length(W)) - (S^(-1/2) * W * S^(-1/2));
    % [eVectors, ~] = eigs(L);
    % eVectors = eVectors(:, (end - numClusters + 1) : end);
    % clusters{index} = kmeans(eVectors, numClusters);
    clusters{index} = linkage(W);
end

delete('results.txt');

for index = 1 : size(clusters, 2)
    Z = clusters{index};
    c = cluster(Z, 'maxclust', numClusters);
    figure
    [H, T, PERM] = dendrogram(Z, 0);
    dlmwrite('results.txt', PERM, '-append', 'delimiter', ' ');
    dlmwrite('results.txt', c', '-append', 'delimiter', ' ');
    xlabel('Flight #');
    ylabel('Distance between the clusters');
    % disp(clusters{index});
end

end
