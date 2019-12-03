// BMI <-> node communication
// |
// ! -- BMI ZMQ Model Runner
// | timestep
// | data -> json -> zmq.publish
// | -- Node.js publisher
// | zmq.subscribe(runner) -> socket.io -> data update
// | zmq.push(runner) <- socket.io <- data update
// | -- Browser
// | socket.io -> message -> draw
// | socket.io <- message <- interaction

var zmq = require('zmq');
// Setup the websocket server.
var io = require('socket.io').listen(8001, { log: false });

subsock = zmq.socket('sub');
pushsock = zmq.socket('push');

// Setup 2 sockets, one to subscribe
// (getting data from the model, one to push data back in the model)....
subsock.connect('tcp://0.0.0.0:5556');
pushsock.bindSync('tcp://0.0.0.0:5557');

// Subscribe to all get messages
subsock.subscribe('s1');
subsock.subscribe('lines');
subsock.subscribe('grid');

io.sockets.on('connection', function (iosocket) {
    iosocket.emit('info', {'connection': 'ok'});
    subsock.on('message', function(msg){
        // New message from the model
        // split up in 2 parts on first space
        splitted = msg.toString().split(' ',2);
        tag = splitted[0]; // this should be get....
        data = splitted[1]; // this should be json
        // Pass on the data to the webbrowser.
        iosocket.volatile.emit(tag, data);
    });

    iosocket.on('set', function (data) {
        // New data from the webbrowser
        // Pass it on to the model runner
        pushsock.send('set ' + JSON.stringify(data));
    });
    iosocket.on('grid', function (data) {
        // New data from the webbrowser
        // Pass it on to the model runner
        pushsock.send('grid ' + JSON.stringify(data));
    });
});
