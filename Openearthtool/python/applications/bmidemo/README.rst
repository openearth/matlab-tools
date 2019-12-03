bmidemo README

# Start the demo like this:
pserve ./production.ini
python ./bin/bmizmqrunner.py
node ./bin/worker.js

Then open the website at localhost:6543

This is an example of how to setup a websocket server that connects to a running model.
This allows asynchronous communication (pushing data) and should provide a better experience.
The communcation can also go to the websocket server (for sending changes to the model).

The communication with models is done through zmq.

Messages have this format in zmq:

(get|set) [JSON]

Thus a get or set tag, followed by a space and then followed by a utf8 json message.

The JSON part is passed along with a (get|set) tag to the socket.io connection.

Techniques used:

- json -> data format that happens to be valid javascript. This is the serialization format used.
- socket.io -> wrapper around websockets that handles tag, message based communication between server and webbrowser.
- node.js -> javascript based webserver that handles asynchronous connections pretty well.
- zmq -> also called 0mq, inter process communication protocol, used for communicating between model and webserver.
- websocket -> sort of a socket but than with connections to the browser. Connections stay open so you can push data to the browser.

Alternatives:
- If serialization turns out to be a bottleneck it makes sense to put the data in an arraybuffer format (just bytes)  as that is faster to serialize to.
- There are more websocket servers
- Instead of zmq we could use delftonline.

Running:
The worker.js can be run by using node:

node worker.js

This connects to a running model on port 5556 for subscribing to model updates.
The connection with the same model for sending data is run on port 5557.
The webserver port is 8001 by default. Best run through a reverse proxy when connected to the internet.
Ports 5556 and 5557 should not be exposed to the internet.

The bmizmqrunner in the openearthtools python package can be combined with this model.
