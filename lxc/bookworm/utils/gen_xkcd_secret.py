import secrets

# On standard Linux systems, use a convenient dictionary file.
# Other platforms may need to provide their own word-list.
with open('/usr/share/dict/words') as f:
    words = [word.strip() for word in f]
    password = '_'.join(secrets.choice(words) for i in range(4))

if __name__ == '__main__':
    print(password)
