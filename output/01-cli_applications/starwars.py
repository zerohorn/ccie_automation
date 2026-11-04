import requests
import click

# base_url = "http://starwars.devnetexperttraining.com/graphql"
base_url = "http://10.0.0.241:4000/graphql"

@click.group()
def cli():
    pass

@click.command()
def listplanets():
    query = """
query allPlanets {
  allPlanets {
    planets {
      name
      id
    }
  }
}
"""
    response = requests.post(base_url, json={'query': query})
    planets = response.json()
    for planet in planets['data']['allPlanets']['planets']:
        output = planet['name'] + ", " + planet['id']
        print(output.replace('==', ''))


@click.command()
@click.argument('planet_id')
def planetdetails(planet_id):
    query = f"""
query planetdetails {{
  planet(id: "{planet_id}") {{
    name
    terrains
    filmConnection {{
      films {{
        title
        director
      }}
    }}
  }}
}}
"""
    response = requests.post(base_url, json={'query': query})
    result = response.json()
    terrain_list = ', '.join(result['data']['planet']['terrains'])
    print(f"{result['data']['planet']['name']} is a planet with the following terrain(s): {terrain_list}")
    for film in result['data']['planet']['filmConnection']['films']:
        print(f"{film['title']}, directed by {film['title']}")

cli.add_command(listplanets)
cli.add_command(planetdetails)

if __name__ == "__main__":
    cli()