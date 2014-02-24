function [data] = subSamplesItBasedOnRate(oldData, rate)

data = zeros(size(oldData, 1)/rate, 1);

for j = 1 : size(data)
    data(j, 1) = oldData(j * rate, 1);
end

end
