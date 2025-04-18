# what number is missing out of 10

array = [5, 3, 7, 8, 2, 4, 9, 6, 0]
input_row = array or input('Enter array: ')

etalon = {k: 0 for k in list(range(10))}
print(etalon)

[etalon.pop(i, None) for i in input_row]
print(list(etalon.keys())[0])
