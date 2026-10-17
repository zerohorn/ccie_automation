import click
import requests

@click.group()
def vehicles():
    pass


@vehicles.command()
@click.argument("brand")
def searchbrands(brand):
    response = requests.get("https://vpic.nhtsa.dot.gov/api/vehicles/getallmakes?format=json")
    brand_list = response.json()
    for i in brand_list['Results']:
        if brand.upper() in i['Make_Name']:
            print(i['Make_Name'])

@vehicles.command()
@click.argument("makename")
@click.option("--year", type=int)
def listmodels(makename, year):
    if year:
        response = requests.get(f"https://vpic.nhtsa.dot.gov/api/vehicles/GetModelsForMakeYear/make/{makename}/modelyear/{year}?format=json")
    else:
        response = requests.get(f"https://vpic.nhtsa.dot.gov/api/vehicles/GetModelsForMake/{makename}?format=json")
    models = response.json()
    print(models['Results'])
    for i in models['Results']:
        print(i['Model_Name'])

if __name__ == "__main__":
    vehicles()