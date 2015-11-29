var socketio = require('socket.io');

var cacheDriver = require('./cachedriver');

module.exports = {

    runSocketServer: function (http) {
        var io = socketio.listen(http);

        io.sockets.on('connection', function (socket) {


            console.log("Client connected: " + socket.id);

            socket.on('disconnect', function () {
                console.log("Client disconnected: "+ socket.id);

            });

            socket.on('getPerformanceDetails', function (request) {

                setInterval(function () {

                    cacheDriver.getCachedData(function(data){
                        socket.emit('performanceDetails',data )

                    })

                }, 1000)

            });

        });
    }
};
