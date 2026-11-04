from flask import Flask
from flask_restx import Resource, Api, reqparse

app = Flask("devnet")
api = Api(app)

@api.route("/devnet")
class DevNet(Resource):
    def get(self):
        return "Expert"

@api.route("/multiply/<int:a>/<int:b>")
class Multiply(Resource):
    def get(self,a,b):
        return a * b

calculator_parser = reqparse.RequestParser()
calculator_parser.add_argument("function", choices=('add','subtract','divide'))
calculator_parser.add_argument("a", type=int)
calculator_parser.add_argument("b", type=int)

@api.route("/calculator")
class Calculator(Resource):
    @api.expect(calculator_parser)
    def get(self):
        args = calculator_parser.parse_args()
        if args.function == "add":
            result = args.a + args.b

        elif args['function'] == "subtract":
            result = args['a'] - args['b']
        elif args['function'] == "divide":
            result = args['a'] / args['b']
        return result


library_data = {
    "1111111" : "Overcome your DevNet fears",
    "2222222" : "How to humblbrag about your certs"
}
remove_book_parser = reqparse.RequestParser()
remove_book_parser.add_argument("isbn")

add_book_parser = remove_book_parser.copy()
add_book_parser.add_argument("title")



@api.route("/book")
class Book(Resource):
    def get(self):
        return library_data
    
    @api.expect(add_book_parser)
    def post(self):
        args = add_book_parser.parse_args()
        library_data[args.isbn] = args.title
        return "Successfully added " + args.title , 201

    @api.expect(remove_book_parser)
    def delete(self):
        args = remove_book_parser.parse_args()
        library_data.pop(args.isbn)
        return "", 204

if __name__ == "__main__":
    app.run(debug=True, port = 4999)