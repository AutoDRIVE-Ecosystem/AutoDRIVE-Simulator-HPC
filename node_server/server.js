const express = require('express');
const dns = require('dns');

const cors = require('cors');

const { createProxyMiddleware } = require('http-proxy-middleware')

const app = express();
const port = 3000;



app.use(cors());


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
                return reject(err);
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

function server_init(address) {

    var podips = address;
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

const podipsPromise = performDnsLookup("sim-gateway")

podipsPromise.then(
    function(address) {server_init(address);},
    function(error) {console.log(error);}
);
