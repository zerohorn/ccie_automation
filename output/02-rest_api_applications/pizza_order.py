from flask import Flask
from flask_restx import Resource, Api, reqparse

app = Flask(__name__)
api = Api(app)

sales_history = []

parser = reqparse.RequestParser()
parser.add_argument('variant', choices=('margherita', 'pepperoni', 'hawaii'), help='What type of pizza you want to order')
parser.add_argument('quantity', type=int, help='How many of this type of pizza you want to order')


@api.route('/pizzeria/sale')
class pizza_sale(Resource):
    @api.expect(parser)
    def get(self):
        args = parser.parse_args() 
        sales_history.append({"variant": args['variant'], "quantity": args['quantity']})
        return None, 201



@api.route('/pizzeria/salessummary')
class pizza_summary(Resource):
    def get(self):
        summary = {"margherita":0 , "pepperoni": 0, "hawaii": 0}
        for sale in sales_history: 
            summary[sale["variant"]] += sale["quantity"]
        return summary


if __name__ == '__main__':
    app.run(debug=True)