import click

@click.command()
@click.pass_context # standard dict
def function1(ctx):
    ctx.ensure_object(dict)
    function2()
    function3()

@click.pass_context
def function2(ctx): #  set context_object dict's key hello item to the value world
    ctx.obj['hello'] = "world"

@click.pass_obj
def function3(obj): #  use the pass_object decorator, and print out the value assigned in function 2. Do not pass the context to this function.
    print(obj['hello'])

if __name__ == "__main__":
    function1()