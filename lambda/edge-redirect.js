'use strict';

exports.handler = (event, context, callback) => {
    const request = event.Records[0].cf.request;
    
    console.log('initial request', request)

    console.log(JSON.stringify(request.headers))

    const customHeader = request.headers['spa-custom-Header'][0]

    console.log('spa-custom-Header', customHeader.value)

    let domainName = customHeader.value

    if(domainName){

        console.log("Within the if statement", domainName)

        request.origin.s3.domainName = domainName

        console.log("updated the request origin with s3 domain", domainName)

        request.headers['host'] = [{key: 'host', value: domainName}]
    }
    console.log('updated request', request)

    callback(null, request);
};