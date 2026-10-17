import click

@click.command()
@click.option("--a", type=int, required=True)
@click.option("--b", type=int, required=True)
def multiply(a, b):
    product = a * b
    print(f"{a} * {b} = {product}")
    
if __name__ == "__main__":
    multiply()