/**
 * Created by omkargudekar on 11/26/15.
 */

var redis = require("redis");
var redisClient = redis.createClient();

redisClient.on('connect', function () {
    console.log('redis connected');
});

module.exports = {


    getCachedData: function (callback) {


        try {
            redisClient.get('performance', function (error, reply) {


                console.log(reply)

                callback(reply)


            });

        }
        catch (e) {

            console.log('exception caught', e)
        }


    },

    updateCache: function (data) {


        try {
            redisClient.set('performance', data, function (err, reply) {
                console.log(reply);
            });
        }
        catch (e) {
            console.log('exception caught', e)
        }

    }
};