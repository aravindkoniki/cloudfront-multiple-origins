'use strict';

exports.handler = (event, context, callback) => {
    const request = event.Records[0].cf.request;
    
    console.log('initial request', request)

    console.log(JSON.stringify(request.headers))

    const bucket = request.headers['bucket'][0]

    console.log('bucket', bucket.value)

    let domainName = bucket.value

    if(domainName){

        console.log("Within the if statement", domainName)
        
        request.origin.s3.domainName = domainName

        request.headers['host'] = [{key: 'host', value: domainName}]
    }
    console.log('updated request', request)
    // Return the modified request
    callback(null, request);
};