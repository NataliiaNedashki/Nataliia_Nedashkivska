import random

# Генерація випадкових оцінок
def generation_mark(x: int = 60, y: int = 100) -> int:
    return random.randint(x,y) if y > x else 1

# Генерація стану "Здав\Не здав"
def generate_result() -> str:
    result = random.choice(["Failed", "Passed"])
    return result

# Заповнення словника значеннями
register = {}
for i in range(1, 7):
    student_name = f"Student {i}"
    mark = generation_mark()
    exam_result = generate_result()
    register[student_name] = mark, exam_result


print(register)

# Перевірка на послідовність Професора

# Перевіряємо чи всі здали екзамен
all_passed = True
for student, (points, result) in register.items():
    if result != "Passed":
        all_passed = False
    break

# Перевіряємо чи всі не здали екзамен
all_failed = True
for student, (points, result) in register.items():
    if result != "Failed":
        all_failed = False
    break


if all_passed and all_failed:
    print("Професор Губл був послідовним")
else:
    min_passed = 100
    max_failed = 60
    for student, (points, result) in register.items():
        if points > max_failed and result == 'Failed':
            max_failed = points
        elif points < min_passed and result == 'Passed':
            min_passed = points


    if min_passed <= max_failed:
        print("Професор Губл був не послідовним")
    else:
        print("Професор Губл був послідовним")
        print(f"Поріг для складання іспиту: {max_failed + 1, 100}")