var socketio = require('socket.io');

module.exports = {

    runSocketServer: function (http) {
        var io = socketio.listen(http);

        io.sockets.on('connection', function (socket) {


            console.log("Client connected: " + socket.id);

            socket.on('disconnect', function () {
                console.log("Client disconnected:");

            });

            socket.on('getPerformanceDetails', function (request) {
                //webPageTest(request, function (data) {
                //    socket.emit('performanceDetails', data)
                //});
                console.log(request)
                socket.emit('performanceDetails', 'hello')


            });

        });
    }
};
