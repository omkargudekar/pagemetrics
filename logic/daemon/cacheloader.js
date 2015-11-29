fs = require('fs');

var cacheDriver = require('../communication/cachedriver');

module.exports = {

    runDaemon: function () {


        setInterval(function () {

            fs.readFile('././scripts/performance.log', 'utf8', function (err,data) {
                if (err) {
                    return console.log(err);
                }
                //console.log(data);
                cacheDriver.updateCache(data);
            });

        }, 3000)




    }
};
