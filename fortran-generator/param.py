import re

class Var:
    def __init__(self, name: str, is_pointer: bool):
        self.name = name
        self.is_pointer = is_pointer
        
def get_all_variables(lines):
    variables = []
    pattern = r'\(.+\)'
    for line in lines:
        line = line[:-1] # \n

        sp = line.split("::")
        modifiers = sp[0]
        vars = re.sub(pattern, '', sp[1]).split(',')
        for var in vars:
            name = var.strip()
            is_pointer = 'pointer' in modifiers
            variables.append(Var(name, is_pointer))
    return variables

def main():
    with open("input") as f:
        lines = f.readlines()
        vars = get_all_variables(lines)
        for v in vars:
            eq = '=>' if v.is_pointer else '='
            print(f'lmd_skpp_loop5%{v.name} {eq} {v.name}')

if __name__ == '__main__':
    main()
