import click
import requests

@click.group()
def demo():
    pass

@demo.command()
@click.argument("student")
@click.option("--count", type=int)
def devnet(student, count):
    for i in range(0,count):
        print("Hello " + student)

@demo.command()
def example():
    pass

@demo.command()
@click.option("--category", type=click.Choice(['dev','music','sport']))
@click.option("--shout", is_flag=True)
@click.option("--funny/--not-funny")
def joke(category, shout, funny):
    if category: 
        response = requests.get(f"https://api.chucknorris.io/jokes/random?category={category}")
    else: 
        response = requests.get("https://api.chucknorris.io/jokes/random")
    joke_data = response.json()
    joke = (joke_data['value'])

    if shout:
        joke = joke.upper() +"!!"
    print(joke)

    if funny:
        print(":-)")
    else:
        print(":-(")


@demo.command()
@click.option("--level", "-l", type=click.Choice(["Associate", "Professional", "Expert"]), required =True)
@click.pass_context
def cert(ctx, level):
    # ctx.obj = {}
    ctx.ensure_object(dict)
    ctx.obj['cert_level'] = level
    print_output_from_context()
    print_output_from_object()

@click.pass_context
def print_output_from_context(ctx):
    ctx.ensure_object(dict)
    print(f"Cisco Certified Devnet {ctx.obj['cert_level']}")

@click.pass_obj
def print_output_from_object(obj):
    print(f"Cisco Certified Devnet {obj['cert_level']}")




if __name__ == "__main__":
    demo()