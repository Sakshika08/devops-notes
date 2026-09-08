# Strings

## Concatenation

```python
str1 = "Hello"
str2 = "World"
print(str1 + " " + str2)
```

## Length 
``` print(len("Python is awesome"))```

### Case Conversion
```
text = "Python"
print(text.upper())
print(text.lower())
```
 
### Replace
```
text = "Python is awesome"
print(text.replace("awesome", "great"))
```

##$ Split
```
text = "Python is awesome"
print(text.split())
```

### Substring Check
```
if "is" in text:
    print("Found")
```
2
print("Found")

### Addition with User Input in Python
```
a = int(input("Enter first number: "))
b = int(input("Enter second number: "))

sum = a + b

print("Sum =", sum)
```

### Write Python to read a file
```
with open("app.log", "r") as f:
    data = f.read()

print(data)
```

### Count ERROR lines in a log
```
count = 0

with open("app.log") as f:
    for line in f:
        if "ERROR" in line:
            count += 1

print(count)
```

### How do you consume a REST API in Python?
```
import requests

response = requests.get("https://api.example.com/users")

print(response.status_code)
```
