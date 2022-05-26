map = [
    ["g","g","g","g","g","g","g","g","g","g","g","g","g","g","g","g","g"],
    ["g","g","r","g","g","g","g","g","g","g","g","g","g","g","g","g","g"],
    ["g","g","r","g","g","g","g","g","g","g","g","g","g","g","g","g","g"],
    ["g","g","r","g","g","g","g","g","g","g","g","g","g","g","g","g","g"],
    ["g","g","r","g","g","g","g","g","g","g","g","g","g","g","g","g","g"],
    ["g","g","b","r","g","g","g","g","g","g","g","g","g","g","g","g","g"],
    ["g","g","g","r","r","g","g","g","g","g","g","g","g","g","g","g","g"],
    ["g","g","g","g","r","r","g","g","g","g","g","g","g","g","g","g","g"],
    ["g","g","g","g","g","r","r","g","g","g","g","g","g","g","g","g","g"],
]

def to_atom(arg):
    if arg == "g":
        return ":grey"
    elif arg == "r":
        return ":red"
    elif arg == "b":
        return ":blue"
    else:
        return ":green"

for r in map:
    print("[" + ''.join([to_atom(i) + "," for i in r]) +"]")


