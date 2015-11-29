/**
 * Created by sagarbendale on 11/25/15.
 */

var serverLocations= window.location.hostname + ':'+window.location.port

var socket = io(serverLocations),

//var socket = io('52.25.169.164:51245'),
//var socket = io('sentinami.com:51245'),
    json, resizeId, callonce = true;
charts = {};
$(document).ready(function () {
    getServerData();
    new WOW().init();
    materialInit();
    $(this).scrollTop(0);

    $(window).resize(function () {
        clearTimeout(resizeId);
        resizeId = setTimeout(doneResizing, 500);
    });

    $('#system-tab').click(function () {
        $('.system-div').toggle('slow');
        $(this).toggleClass('disabled');
    });
    $('#cpu-tab').click(function () {
        $('.cpu-div').toggle('slow');
        $(this).toggleClass('disabled');
    });
    $('#network-tab').click(function () {
        $('.network-div').toggle('slow');
        $(this).toggleClass('disabled');
    });
    $('#memory-tab').click(function () {
        $('.memory-div').toggle('slow');
        $(this).toggleClass('disabled');
    });

    $('main').sortable({cursor: "move"});
    $('main > .row').sortable({cursor: "move", connectWith: $('.row')});
});
function materialInit() {
    $('.button-collapse').sideNav({
            menuWidth: 240, // Default is 240
            edge: 'left', // Choose the horizontal origin
            closeOnClick: false // Closes side-nav on <a> clicks, useful for Angular/Meteor
        }
    );
}
function doneResizing() {

}
function initialize(data) {
    addData(data);
    netStatChart(data);
    memoryChart(data);
    cpuHeavyChart(data);
    cpuChart(data);
    trafficBars(data);
    ioBars(data);
    cpuCombo(data);


    drawApps(data);
    cpuInfo(data);
    diskspace(data);

}
function getNetChartData(json) {
    var netstat = json.netstat,
        connections,
        address,
        data = [],
        total = 0;

    for (i = 0; i < netstat.length; i++) {
        connections = netstat[i].connections;
        total += connections;
    }

    for (i = 0; i < netstat.length; i++) {
        temp = [];
        address = netstat[i].address;
        connections = (netstat[i].connections / total) * 100;
        connections = parseFloat(connections.toFixed(2));
        temp.push(address);
        temp.push(connections);
        data.push(temp);
    }
    return data;
}
function getTrafficBarsData(json) {
    var bandwidth = json.bandwidth,
        interface = [],
        trx = [];
    tx = [],
        rx = [];
    for (i = 0; i < bandwidth.length; i++) {
        temp = bandwidth[i].interface;
        interface.push(temp.substr(0, temp.length - 1));
        tx.push(bandwidth[i].tx);
        rx.push(bandwidth[i].rx);
    }
    trx.push(tx);
    trx.push(rx);
    trx.push(interface);
    return trx;
}
function getCpuComboData(json) {
    var cpu = json.cpu_heavy_processes,
        xyname = [],
        x = [],
        y = [],
        name = [];
    for (i = 0; i < cpu.length; i++) {
        x.push(cpu[i].x);
        y.push(cpu[i].y);
        name.push(cpu[i].name);
    }
    xyname.push(x);
    xyname.push(y);
    xyname.push(name);
    return xyname;

}
function getIoBarsData(json) {
    var io_stats = json.io_stats,
        drw = [],
        device = [],
        reads = [],
        writes = [];
    for (i = 0; i < io_stats.length; i++) {
        device.push(io_stats[i].device);
        reads.push(parseInt(io_stats[i].reads));
        writes.push(parseInt(io_stats[i].writes));
    }
    drw.push(device);
    drw.push(reads);
    drw.push(writes);
    console.log(drw[0]);
    return drw;

}

function updateData(json) {

    addData(json);
    var data;
    //Netchart Update
    data = getNetChartData(json);
    charts['netStatChart'].series[0].setData(data);

    console.log(json.cpu_free);
    charts['cpuChart'].series[0].setData([parseFloat(json.cpu_free)]);


    var chart = charts['memoryChart'],
        point = chart.series[0].points[0],
        newVal = Math.round(json.memory.used);
    point.update(newVal);

    charts['cpuHeavyChart'].series[0].setData(json.ram_heavy_processes, false);
    charts['cpuHeavyChart'].series[1].setData(json.cpu_heavy_processes);

    data = getTrafficBarsData(json);
    charts['trafficBars'].series[0].setData(data[0]);
    charts['trafficBars'].series[1].setData(data[1]);
    charts['trafficBars'].xAxis[0].setCategories(data[2]);

    data = getCpuComboData(json);
    charts['cpuCombo'].series[0].setData(data[0]);
    charts['cpuCombo'].series[1].setData(data[1]);
    charts['cpuCombo'].xAxis[0].setCategories(data[2]);

    data = getIoBarsData(json);
    charts['ioBars'].xAxis[0].setCategories(data[0]);
    charts['ioBars'].series[0].setData(data[1]);
    charts['ioBars'].series[1].setData(data[2]);


    //cpuInfo(json);
    //diskspace(json);


}
function netStatChart(json) {
    var data = getNetChartData(json);
    var netStatChart = new Highcharts.Chart({
        chart: {
            renderTo: 'netstat',
            type: 'pie',
            options3d: {
                enabled: true,
                alpha: 45,
                beta: 0
            }
        },
        title: {
            text: ''
        },
        tooltip: {
            pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
        },
        plotOptions: {
            pie: {
                allowPointSelect: true,
                cursor: 'pointer',
                depth: 35,
                dataLabels: {
                    enabled: true,
                    format: '{point.name}'
                }
            }
        },
        series: [{
            type: 'pie',
            name: 'Network Statistics',
            data: data
        }]
    });
    charts['netStatChart'] = netStatChart;


}
function cpuChart(json) {


    var cpuChart = new Highcharts.Chart({
        chart: {
            renderTo: 'cpu',


            type: 'gauge',
            plotBackgroundColor: null,
            plotBackgroundImage: null,
            plotBorderWidth: 0,
            plotShadow: false
        },

        title: {
            text: ''
        },

        pane: {
            startAngle: -150,
            endAngle: 150,
            background: [{
                backgroundColor: {
                    linearGradient: {x1: 0, y1: 0, x2: 0, y2: 1},
                    stops: [
                        [0, '#FFF'],
                        [1, '#333']
                    ]
                },
                borderWidth: 0,
                outerRadius: '109%'
            }, {
                backgroundColor: {
                    linearGradient: {x1: 0, y1: 0, x2: 0, y2: 1},
                    stops: [
                        [0, '#333'],
                        [1, '#FFF']
                    ]
                },
                borderWidth: 1,
                outerRadius: '107%'
            }, {
                // default background
            }, {
                backgroundColor: '#DDD',
                borderWidth: 0,
                outerRadius: '105%',
                innerRadius: '103%'
            }]
        },

        // the value axis
        yAxis: {
            min: 0,
            max: 100,

            minorTickInterval: 'auto',
            minorTickWidth: 1,
            minorTickLength: 10,
            minorTickPosition: 'inside',
            minorTickColor: '#666',

            tickPixelInterval: 30,
            tickWidth: 2,
            tickPosition: 'inside',
            tickLength: 10,
            tickColor: '#666',
            labels: {
                step: 2,
                rotation: 'auto'
            },
            title: {
                text: '%'
            },
            plotBands: [{
                from: 0,
                to: 33,
                color: '#55BF3B' // green
            }, {
                from: 33,
                to: 66,
                color: '#DDDF0D' // yellow
            }, {
                from: 66,
                to: 100,
                color: '#DF5353' // red
            }]
        },

        series: [{
            name: 'Percentage Usage',
            data: [parseFloat(json.cpu_free)],
            tooltip: {
                valueSuffix: ' %'
            }
        }]

    });

    charts['cpuChart'] = cpuChart;
}
function memoryChart(json) {
    var memory = json.memory,
        total = Math.round(memory.total),
        free = Math.round(memory.free),
        used = total - free,
        gaugeid = '#memory';
    //if ($(window).width() < 992) {
    //    gaugeid = '.memory'
    //}
    var gaugeOptions = {

        chart: {
            type: 'solidgauge'
        },

        title: null,

        pane: {
            center: ['50%', '85%'],
            size: '140%',
            startAngle: -90,
            endAngle: 90,
            background: {
                backgroundColor: (Highcharts.theme && Highcharts.theme.background2) || '#EEE',
                innerRadius: '60%',
                outerRadius: '100%',
                shape: 'arc'
            }
        },

        tooltip: {
            enabled: false
        },

        // the value axis
        yAxis: {
            stops: [
                [0.1, '#55BF3B'], // green
                [0.5, '#DDDF0D'], // yellow
                [0.9, '#DF5353'] // red
            ],
            lineWidth: 0,
            minorTickInterval: null,
            tickPixelInterval: 400,
            tickWidth: 0,
            title: {
                y: -70
            },
            labels: {
                y: 16
            }
        },

        plotOptions: {
            solidgauge: {
                dataLabels: {
                    y: 5,
                    borderWidth: 0,
                    useHTML: true
                }
            }
        }
    };

    // The speed gauge
    $(gaugeid).highcharts(Highcharts.merge(gaugeOptions, {
        yAxis: {
            min: 0,
            max: total,
            tickInterval: total / 5,
            title: {
                text: ''
            }
        },

        credits: {
            enabled: false
        },

        series: [{
            name: 'Memory',
            data: [used],
            dataLabels: {
                format: '<div style="text-align:center"><span style="font-size:25px;color:' +
                ((Highcharts.theme && Highcharts.theme.contrastTextColor) || 'black') + '">{y}</span><br/>' +
                '<span style="font-size:12px;color:silver">mb</span></div>'
            },
            tooltip: {
                valueSuffix: ' mb'
            }
        }]

    }));

    var memoryChart = $(gaugeid).highcharts();
    charts['memoryChart'] = memoryChart;


}
function cpuHeavyChart(json) {
    var processes = json.cpu_heavy_processes;
    var ram_processes = json.ram_heavy_processes;

    var cpuHeavyChart = new Highcharts.Chart({
        chart: {
            renderTo: 'cpuHeavy',
            type: 'bubble',
            plotBorderWidth: 1,
            zoomType: 'xy'
        },
        plotOptions: {
            series: {
                dataLabels: {
                    enabled: true
                }
            },
        },

        legend: {
            enabled: true
        },


        title: {
            text: 'CPU And Ram Heavy Processes'
        },

        xAxis: {
            gridLineWidth: 1,
            title: {
                text: 'Virtual Memory'
            },
            labels: {
                format: '{value} K'
            }
        },

        yAxis: {
            startOnTick: false,
            endOnTick: false,
            title: {
                text: 'Actual Memory'
            },
            labels: {
                format: '{value} , K'
            },
            maxPadding: 0.2

        },

        tooltip: {
            useHTML: true,
            headerFormat: '<table>',
            pointFormat: '<tr><th colspan="2"><h3>{point.name}</h3></th></tr>' +
            '<tr><th>User:</th><td>{point.user}</td></tr>' +
            '<tr><th>Virtual Memory:</th><td>{point.x}K</td></tr>' +
            '<tr><th>Actual Memory:</th><td>{point.y}K</td></tr>' +
            '<tr><th>CPU %:</th><td>{point.z}%</td></tr>',
            footerFormat: '</table>',
            followPointer: true
        },

        series: [
            {
                name: "RAM Processes",
                data: ram_processes
            },
            {
                name: "CPU Processes",
                data: processes

            }
        ]

    });
    charts['cpuHeavyChart'] = cpuHeavyChart;
}

function trafficBars(json) {
    var trx = getTrafficBarsData(json);
    var trafficBars = new Highcharts.Chart({
        chart: {
            renderTo: 'traffic',


            type: 'column'
        },
        title: {
            text: 'Total traffic'
        },
        xAxis: {
            categories: trx[2],
            crosshair: true
        },
        yAxis: {
            min: 0,
            max: Math.max(Math.max.apply(null, tx), Math.max.apply(null, rx)),
            title: {
                text: 'Traffic (bytes)'
            }
        },
        tooltip: {
            headerFormat: '<span style="font-size:10px">{point.key}</span><table>',
            pointFormat: '<tr><td style="color:{series.color};padding:0">{series.name}: </td>' +
            '<td style="padding:0"><b>{point.y} bytes</b></td></tr>',
            footerFormat: '</table>',
            shared: true,
            useHTML: true
        },
        plotOptions: {
            column: {
                pointPadding: 0.2,
                borderWidth: 0
            }
        },
        series: [{
            name: 'Transmitted Traffic',
            data: trx[0]

        }, {
            name: 'Received Traffic',
            data: trx[1]

        }]
    });
    charts['trafficBars'] = trafficBars;
}

function cpuCombo(json) {
    var xyname = getCpuComboData(json);
    var cpuCombo = new Highcharts.Chart({
        chart: {
            renderTo: 'cpupro',


            type: 'area'
        },
        title: {
            text: 'CPU Heavy Processes'
        },
        xAxis: {
            categories: xyname[2],
            allowDecimals: false,
            labels: {
                formatter: function () {
                    return this.value; // clean, unformatted number for year
                }
            }
        },
        yAxis: {
            title: {
                text: 'size in kilobytes'
            },
            labels: {
                formatter: function () {
                    return this.value + 'kb';
                }
            }
        },
        tooltip: {
            pointFormat: '{series.name} : <b>{point.y}</b>'
        },
        plotOptions: {
            area: {
                marker: {
                    enabled: false,
                    symbol: 'circle',
                    radius: 2,
                    states: {
                        hover: {
                            enabled: true
                        }
                    }
                }
            }
        },
        series: [{
            name: 'rss',
            data: xyname[0]
        }, {
            name: 'vsz',
            data: xyname[1]
        }]
    });
    charts['cpuCombo'] = cpuCombo;
}

function ioBars(json) {
    var drw = getIoBarsData(json);
    var ioBars = new Highcharts.Chart({
        chart: {
            renderTo: 'io',
            type: 'column'
        },
        title: {
            text: ''
        },
        xAxis: {
            categories: drw[0]
        },
        yAxis: [{
            min: 0,
            title: {
                text: 'IO Operations (k)'
            }
        }, {
            title: {
                text: 'Profit (millions)'
            },
            opposite: true
        }],
        legend: {
            shadow: false
        },
        tooltip: {
            shared: true
        },
        plotOptions: {
            column: {
                grouping: false,
                shadow: false,
                borderWidth: 0
            }
        },
        series: [{
            name: 'reads',
            color: 'rgba(165,170,217,1)',
            data: drw[1],
            pointPadding: 0.3,
            pointPlacement: -0.2
        }, {
            name: 'writes',
            color: 'rgba(126,86,134,.9)',
            data: drw[2],
            pointPadding: 0.4,
            pointPlacement: -0.2
        }]
    });
    charts['ioBars'] = ioBars;
}

function addData(json) {

    var general_info = json.general_info;
    $("#os").html(general_info.OS);
    $("#host").html(general_info.Hostname);
    $("#uptime").html(Math.round(general_info.Uptime / 86400) + ' Days');
    $("#servertime").html(general_info.server_time);
    $("#ipaddress").html(json.ip_address.interface + ': ' + json.ip_address.ip);
}


function cpuInfo(json) {
    var cpuObject = json.cpu_info;

    var data = new google.visualization.DataTable(),
        data1 = [];

    for (key in cpuObject) {
        data1.push([key, cpuObject[key]])
    }

    data.addColumn('string', 'Name');
    data.addColumn('string', 'Details');

    data.addRows(data1);

    var table = new google.visualization.Table(document.getElementById('cpuinfo'));

    table.draw(data, {showRowNumber: false, width: '100%', height: '100%'});
}
function diskspace(json) {
    var data = new google.visualization.DataTable();
    var diskspace = json.diskspace,
        data1 = [];
    //console.log(diskspace);
    for (i = 0; i < diskspace.length; i++) {
        var temp = [];
        var file_system = diskspace[i].file_system,
            size = diskspace[i].size,
            used = diskspace[i].used,
            available = diskspace[i].avail,
            percentage = diskspace[i].used_per;
        temp.push(file_system);
        temp.push(size);
        temp.push(used);
        temp.push(available);
        temp.push(percentage);
        data1.push(temp);
    }
    data.addColumn('string', 'File System');
    data.addColumn('string', 'Size');
    data.addColumn('string', 'Used');
    data.addColumn('string', 'Available');
    data.addColumn('string', 'Used %');
    data.addRows(data1);

    var table = new google.visualization.Table(document.getElementById('diskspace'));

    table.draw(data, {showRowNumber: false, width: '100%', height: '100%'});
}
function drawApps(json) {
    var data = new google.visualization.DataTable();
    var common_apps = json.common_apps,
        binary,
        location,
        installed,
        data1 = [];

    for (i = 0; i < common_apps.length; i++) {
        var temp = [];
        binary = common_apps[i].binary;
        location = common_apps[i].location;
        arr = location.split(" ");
        installed = common_apps[i].installed;
        temp.push(binary);
        temp.push(location);
        temp.push(installed);
        data1.push(temp);
    }
    data.addColumn('string', 'Name');
    data.addColumn('string', 'Location');
    data.addColumn('boolean', 'Installed');
    data.addRows(data1);

    var table = new google.visualization.Table(document.getElementById('commonapps'));

    table.draw(data, {showRowNumber: false, width: '100%', height: '100%'});
}

function getServerData() {
    socket.emit('getPerformanceDetails', '');
    socket.on('performanceDetails', function (data) {
        //console.log(data);
        data = JSON.parse(data);
        if (callonce) {
            console.log('initialize');
            callonce = false
            initialize(data);
        }
        else
            updateData(data)
    });
}