const express = require('express');
const dns = require('dns');
const multer = require('multer')
const cors = require('cors');
const bodyParser = require('body-parser');

const { createProxyMiddleware } = require('http-proxy-middleware');
const { config } = require('process');

const app = express();
const port = 3000;

// Use the multer middleware to handle file uploads
// const storage = multer.memoryStorage(); // Use memory storage for simplicity

// Old code for direct csv file transfer
// const storage = multer.diskStorage({
//     destination: (req, file, cb) => {
//       // Specify the destination folder where the file will be saved
//       cb(null, 'uploads/');
//     },
//     filename: (req, file, cb) => {
//       // Specify the filename (you can also use a library like uuid to generate a unique filename)
//       cb(null, file.originalname);
//     }
//   });

// const upload = multer({ storage: storage });

var database = [] // Array for storing sent metrics

const weather_ids = [1, 2, 3, 4, 5, 6, 7, 8];
const times = [[0, 360], [720, 1080]];
const models = ["yolov2", "yolov2", "yolov2-tiny", "yolov2-tiny", "yolov3", "yolov3", "yolov3-tiny", "yolov3-tiny"]

// Simulation Condition selection parameter needed
// Iterate through times[0-1] and model[0-4] for 8 conditions


var counter = 0;

var config_arr = []

app.use(cors());
// Use middleware to parse JSON and URL-encoded data
app.use(bodyParser.json({limit: '50mb'}));
app.use(bodyParser.urlencoded({limit: '50mb', extended: true}));

// Not sure why this isn't working --> keep getting error saying I am missing a target option.

// const dynamicProxy = createProxyMiddleware((req) => {
    
//     const options = { target: req.query.address }
//     return options;
// });

var simultation_condition_iter = 0;

app.post('/iterate_simulation_conditions', (req, res) => {

    // generate new configs with new variables & update config_arr
    simultation_condition_iter++;
    config_arr = generate_config(weather_ids, times[simultation_condition_iter % times.length], models[simultation_condition_iter % models.length]);
    console.log("Iterated simulation conditions to: Time=" + times[simultation_condition_iter % times.length] + " and model = " +  models[simultation_condition_iter % models.length]);

    res.json("Stored simulation conditions iterated.");

});

function performDnsLookup(domain) {

    const options = {

        all: true

    }

    return new Promise((resolve, reject) => {
        dns.lookup(domain, options, (err, address) => {
            if (err) {
                console.log(err)
                return reject([]);
            }
            return resolve(address)
        })
    })

}

var podips

function generate_config(weathers, times, model) {

    config_arr = []

    for (let i = 0; i < weathers.length; i++) {
        for (let j = 0; j < times.length; j++) {
            //console.log("parsing: time:" + times[j] + " weather: " + weathers[i] + " model: " + model)
            config_arr.push({"time": times[j], "weather": weathers[i], "model": model});
        }
    }

    console.log("Generated config.");
    print_config(config_arr)
    return config_arr

}

function print_config(config_arr) {
    for(let i = 0; i < config_arr.length; i++) {
        console.log("time: " + config_arr[i]["time"] + " weather_id: " + config_arr[i]["weather"] + " model: " + config_arr[i]["model"])
    }
}

async function server_init(address) {

    podips = address;
    console.log("podips: " + podips);

    config_arr = await generate_config(weather_ids, times[0], models[0]);

    app.use('/stream', function(req, res, next) {

        // console.log("forwarding stream request to: http://" + podips[parseInt(req.url.split('/')[1])] + ":8000")
    
        // debug statements
        // if(true){

        //     console.log(req.url)
        //     console.log(podips[0].address)
        //     console.log(req.url.split('/'))
        // }

        var podnumber = req.url.split('/')[1];
        console.log("processing reques for pod number " + podnumber + "at ip " + podips[parseInt(req.url.split('/')[1])].address + "from url " + req.url)
        createProxyMiddleware({
            target: "http://" + podips[parseInt(req.url.split('/')[1])].address + ":8000",
            pathRewrite: function (path, req) { return path.replace('/stream/'+podnumber, '') },
            changeOrigin: true
        })(req, res, next);
    
    });

    app.listen(port, () => {
        console.log(`Server listening at http://localhost:${port}`);
    });

}

app.get('/variabilityconfig', (req, res) => {

    counter++;
    console.log("config request: " + counter);
    // res.json({ "config": config_arr[ counter % podips.length ]});
    res.json({ "config": config_arr[ counter % 16 ]});

});

app.get('/dns-lookup', (req, res) => {
    const domain = "sim-gateway";

    if (!domain) {
        return res.status(400).json({ error: 'Domain parameter is required' });
    }

    console.log('Looking up ', domain)
    performDnsLookup(domain)
        .then(result => {
            res.json(result);
            // pod_ips = result;
        })
        .catch(error => {
            console.error('Error performing DNS lookup:', error);
            res.status(500).json({ error: 'Internal Server Error' });
        });
});

app.get('/collectdata', (req, res) => {

    console.log("Sending data from server...");
    res.json(data=database);

});

// Define the /database endpoint to handle file uploads
app.post('/database', (req, res) => {

    var metric_data = req.body.data;

    if (!metric_data) {
        return res.status(400).send('No data found.');
    }

    console.log("Metric Data received: \n");
    // console.log(metric_data);
    database.push(metric_data);

    res.send('Metrics received.');

    // Old code for direct csv file transfer
    // const file = req.file;
    
    // console.log(file)
    // database.push(file)

    // if (!file) {
    //   return res.status(400).send('No file uploaded.');
    // }
  
    // // Process the file (e.g., save it to disk or perform other operations)
    // // For now, just send a success response
    // res.send('File uploaded successfully.');
  });

app.post('/resetdatabase', (req, res) => {
    
    console.log("Resetting Database")
    database = []
    res.json("Database Reset.")

})
  
app.post('/reset', (req, res) => {

    console.log("Resetting stored video streams...")

    // reset server side IPs
    var newPromise = performDnsLookup("sim-gateway")

    newPromise.then(
        function(address) {podips=address; console.log(podips); res.json({"reset": true})},
        function(error) {console.log(error); res.json({"reset": false});}
    )

});

const podipsPromise = performDnsLookup("sim-gateway")

podipsPromise.then(
    function(address) {server_init(address);},
    function(error) {console.log(error);server_init([]);}
);
