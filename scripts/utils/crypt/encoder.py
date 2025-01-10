import string

def caesar(text, key, decrypt=False):
    alphas = [
        string.ascii_lowercase,
        string.ascii_uppercase
    ]
    result = ""
    for char in text:
        replaced = False
        for alpha in alphas:
            if char in alpha:
                index = alpha.find(char)
                if decrypt:
                    new = index - (key % len(alpha))
                    new = len(alpha) - new if new < 0 else new
                else:
                    new = (index + key) % len(alpha)
                result += alpha[new]
                replaced = True
        if not replaced:
            result += char
    return result

def rot13(text):
    return caesar(text, 13)

