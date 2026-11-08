from flask import Flask, request
from flask_restx import Resource, Api, reqparse
import random

app = Flask(__name__)
api = Api(app)


@api.route('/numberbot/double/<int:number>')
class double(Resource):
    def get(self, number):
        output = number *2
        return output


parser = reqparse.RequestParser()
parser.add_argument('low', type=int, help='Low number in range')
parser.add_argument('high', type=int, help='High number in range')


@api.route('/numberbot/random')
class randomNumber(Resource):
    @api.expect(parser)
    def get(self):
        args = parser.parse_args()
        return random.randint(args.low, args.high)


if __name__ == '__main__':
    app.run(debug=True)
