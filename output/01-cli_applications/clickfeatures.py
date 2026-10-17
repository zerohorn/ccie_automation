import click

@click.command()
@click.option("--name", help="Your name", required=True)
@click.option("--devp", "--p", is_flag=True, help="Add if you are DevNet Professional")
@click.option("--deve/--no-deve", default=False, help="Add if you are DevNet Expert")
@click.option("--api", type=click.Choice(["netconf", "restconf"]), default="netconf", show_default=True)
def demo(name, devp, deve, api):
    print(f"name: {name}")
    print(f"devp: {devp}")
    print(f"deve: {deve}")
    print(f"api: {api}")

if __name__ == "__main__":
    demo()