import string
import secrets

length=8
#special_chars="!#$$%&*()-_=+[]{}<>:?"
special_chars="!#%*+,-/:=?_"
# Symbols supported by RDS
alphabet = string.ascii_letters + string.digits + special_chars

# Making sure the password has atleast 1 uppercase, 1 lowercase, 1 special character and 2
password = [
    secrets.choice(string.ascii_uppercase),
    secrets.choice(string.ascii_lowercase),
    secrets.choice(string.digits),
    secrets.choice(special_chars),
    secrets.choice(string.digits)
]

for _ in range(length - len(password)):
    password.append(secrets.choice(alphabet))

secrets.SystemRandom().shuffle(password)

print("".join(password))