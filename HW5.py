from collections import defaultdict

# Читаємо дані з файлу
with open('orders.txt', 'r') as txtfile:
    data = txtfile.read()

# Розділяємо на рядки та продукти
orders = [line.split('@@@') for line in data.split('\n\n')]

# Список усіх продуктів
all_products = list(set(product for order in orders for product in order))

# Словник з кількістю кожного продукту
product_count = defaultdict(int)
for order in orders:
    for product in order:
        product_count[product] += 1

# Словник підрахунку кожної пари продуктів
pair_count = defaultdict(int)
for order in orders:
    for i in range(len(order)):
        for j in range(i + 1, len(order)):
            pair = (order[i], order[j])
            pair_count[pair] += 1
            pair_symmetric = (order[j], order[i])
            pair_count[pair_symmetric] += 1

# Словник підрахунку пар містить підтримку кожної пари елементів
pair_support = defaultdict(int)
for pair, count in pair_count.items():
    pair_support[pair] = count


# Використовуйте два словники, щоб розрахувати впевненість для кожної пари елементів.
min_confidence = 5
min_support = 2

for pair, count in pair_count.items():
    product1, product2 = pair
    support_product1 = product_count[product1]
    confidence = (count / support_product1) * 100
    support = support_product1

    if confidence >= min_confidence and support >= min_support:
        print(f'{product1} => {product2} (Впевненість: {confidence:.2f}%, Підтримка: {support})')

