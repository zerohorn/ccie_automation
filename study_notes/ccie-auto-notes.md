# ccie-automation.com Notes

## Python Click
curl 
curl --help | more
    --header (-H) can pass multiple times
    --data (-d) can only be passed once

Click has built in error handling, input validation, etc and is recommended for exam
- Passes between CLI Shell and Python
- Automatically makes --help available
- commands match name of functions

python3 demo.py Matt --count 3

Click uses python decorators (@)
takes agruments and options

@click.command()
@click.argument("student")
@click.option("--count", type=int)
def devnet(student, count):
    for i in range(0,count):
        print("Example" + student)

if __name__ == "__main":
    devnet()

Click Groups

python3 demo.py Matt devnet --count 3

@click.group()
def demo():
    pass

@demo.command()
... same as above


