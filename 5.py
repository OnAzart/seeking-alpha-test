# [2,3,5,1] the results should be [15,10,6,30]

input_list = [2,3,5,1]
output_list = [(3,5,1), (2,5,1), (2,3,1), (2,3,5)]

before = {}
after = {}

total = 1
for i, el in enumerate(input_list):
    before[i] = total
    total *= el

total = 1
for i, el in reversed(list(enumerate(input_list))):
    after[i] = total
    total *= el

print(before, after)
output_list = [before[i]*after[i] for i in range(len(input_list))]

print(output_list)
