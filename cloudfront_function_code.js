import cf from 'cloudfront';
function handler(event) {
    var request = event.request;
    var headers = request.headers;
    // Check if host header exists
    if (headers.host) {
        console.log("Inside headers.host " + headers.host.value);

        const hostHeader = headers.host.value;

        if (hostHeader === 'dev.cloudcraftlab.work') {
            request.headers['spa-custom-Header'] = { value: 'dev-cloudcraftlab-work.s3.eu-west-1.amazonaws.com' };
            console.log("Inside dev.cloudcraftlab.work");

        } else if (hostHeader === 'test.cloudcraftlab.work') {
            request.headers['spa-custom-Header'] = { value: 'test-cloudcraftlab-work.s3.eu-west-1.amazonaws.com' };
            console.log("Inside test.cloudcraftlab.work");
        }
    }
    console.log("Request updated :", JSON.stringify(request))
    return request;
}