import flask
from flask import Flask, request, jsonify

app = Flask(__name__)
@app.route("/ihjin", methods=["GET","POST"])

def ihjin():
    data = {"success": False}

    # get the request parameters
    params = flask.request.args

    # if parameters are found, echo the msg parameter
    if ((params.get("myname") != None) and (params.get("message") != None)):
        #view & model work
        data["myname"] = params.get("myname")
        data["message"] = params.get("message")
        data["success"] = True

    return jsonify(data)
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int("80"), debug=True)