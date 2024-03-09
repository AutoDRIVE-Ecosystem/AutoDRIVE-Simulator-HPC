const express = require('express');
const dns = require('dns');
const multer = require('multer')
const cors = require('cors');
const bodyParser = require('body-parser');

const { createProxyMiddleware } = require('http-proxy-middleware')

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

app.use(cors());
// Use middleware to parse JSON and URL-encoded data
app.use(bodyParser.json({limit: '50mb'}));
app.use(bodyParser.urlencoded({limit: '50mb', extended: true}));

// Not sure why this isn't working --> keep getting error saying I am missing a target option.

// const dynamicProxy = createProxyMiddleware((req) => {
    
//     const options = { target: req.query.address }
//     return options;
// });

function performDnsLookup(domain) {

    const options = {

        all: true

    }

    // dns.lookup(domain, options, (err, value) => {
    //     if (err) {
    //         console.log(err)
    //     } else {
    //         console.log(value);
    //     }
    
    // return value.address;

    // });

    return new Promise((resolve, reject) => {
        dns.lookup(domain, options, (err, address) => {
            if (err) {
                console.log(err)
                return reject([]);
            }
            return resolve(address)
        })
    })

    // return new Promise((resolve, reject) => {
    //     dns.lookup(domain, options, (err, value) => {
    //         if (err) {
    //             reject(err);
    //         } else {
    //             console.log(value);
    //             resolve({ domain, value });
    //         }
    //     });
    // });
}

var podips

function server_init(address) {

    podips = address;
    console.log("podips: " + podips);
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

let counter = 0;

// Array to hold demo parameters
const weather_params = [
    { "time": 0, "cloud": 0, "fog": 0, "rain": 0, "snow": 0}, // Case 0, Midnight clear
    { "time": 360, "cloud": 0, "fog": 0, "rain": 0, "snow": 0}, // Case 1, Dawn clear
    { "time": 720, "cloud": 0, "fog": 0, "rain": 0, "snow": 0}, // Case 2, Mid Day clear
    { "time": 1080, "cloud": 0, "fog": 0, "rain": 0, "snow": 0}, // Case 3, Dusk clear
    { "time": 0, "cloud": 1, "fog": 0, "rain": 0, "snow": 0}, // Case 4, Midnight cloudy
    { "time": 360, "cloud": 1, "fog": 0, "rain": 0, "snow": 0}, // Case 5, Mid Day cloudy
    { "time": 720, "cloud": 0, "fog": 1, "rain": 0, "snow": 0}, // Case 6, Dawn foggy
    { "time": 1080, "cloud": 0, "fog": 1, "rain": 0, "snow": 0}, // Case 7, Dusk foggy
    { "time": 0, "cloud": 0, "fog": 0, "rain": 1, "snow": 0}, // Case 8, Midnight heavy rain
    { "time": 360, "cloud": 0, "fog": 0, "rain": 0.5, "snow": 0}, // Case 9, Dawn mild rain
    { "time": 720, "cloud": 0, "fog": 0, "rain": 1, "snow": 0}, // Case 10, Mid day heavy rain
    { "time": 1080, "cloud": 0, "fog": 0, "rain": 0.5, "snow": 0}, // Case 11, Dusk milkd rain
    { "time": 0, "cloud": 0, "fog": 0, "rain": 0, "snow": 1}, // Case 12, Midnight heavy snow
    { "time": 360, "cloud": 0, "fog": 0, "rain": 0, "snow": 0.5}, // Case 13, Dawn mild snow
    { "time": 720, "cloud": 0, "fog": 0, "rain": 0, "snow": 1}, // Case 14, Mid Day heavy snow
    { "time": 1080, "cloud": 0, "fog": 0, "rain": 0, "snow": 0.5}, // Case 15, Dusk mild snow
]

app.get('/weather', (req, res) => {
    counter++;
    console.log("weather request: " + counter)
    res.json({ "weather_config": weather_params[counter % weather_params.length] });
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
    function(error) {console.log(error);}
);
