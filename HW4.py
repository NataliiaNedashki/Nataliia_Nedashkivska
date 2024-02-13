import time

# Простий метод
def is_prime_simple(n):
    for i in range(2, int(n ** 0.5) + 1):
        if n % i == 0:
            return False
    return True

# Решето Ератосфена
def sieve_eratosthenes(x):
    sieve = [True] * (x + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(x ** 0.5) + 1):
        if sieve[i]:
            for j in range(i * i, x + 1, i):
                sieve[j] = False
    return [i for i, is_prime in enumerate(sieve) if is_prime]

# Перевірка коректності вводу
while True:
    try:
        input_str = input("Введіть ціле число: ")
        if input_str.strip():  # Перевірити, що рядок не порожній
            n = int(input_str)
            if n < 2:
                raise ValueError("Введіть позитивне ціле число.")
            break  # Вийти з циклу, якщо введене число є коректним
    except ValueError as e:
        print(f"Помилка: {e}")

# Заміряємо час виконання простим методом
start_time = time.time()
simple_primes = [i for i in range(2, n) if is_prime_simple(i)]
simple_time = time.time() - start_time

# Заміряємо час виконання методом Решета Ератосфена
start_time_2 = time.time()
eratosthenes_primes = sieve_eratosthenes(n)
eratosthenes_time = time.time() - start_time_2

# Порівнюємо час виконання функцій
print(f"Кількість простих чисел до {n} (простий метод): {len(simple_primes)}")
print(f"Час виконання (простий метод): {simple_time:.4f} секунд")

print(f"Кількість простих чисел до {n} (ефективний метод): {len(eratosthenes_primes)}")
print(f"Час виконання (ефективний метод): {eratosthenes_time:.4f} секунд")

