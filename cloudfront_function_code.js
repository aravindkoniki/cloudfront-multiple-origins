function handler(event) {
    var request = event.request;
    var headers = request.headers;
    var uri = request.uri;

    const hostHeader = headers.host && headers.host.value;

    // Config for domains where routing depends on both host and URI
    const complexOriginMap = {
        'portal.dev.cloudcraftlab.work': {
            '/masters': 'dev-masters-cloudcraftlab-work.s3.eu-central-1.amazonaws.com',
            'default': 'dev-portal-cloudcraftlab-work.s3.eu-central-1.amazonaws.com'
        }
    };

    // Simple host-only routing
    const simpleOriginMap = {
        'dev.cloudcraftlab.work': 'dev-cloudcraftlab-work.s3.eu-west-1.amazonaws.com',
        'test.cloudcraftlab.work': 'test-cloudcraftlab-work.s3.eu-west-1.amazonaws.com',
    };

    // Match complex mapping (host + URI)
    if (complexOriginMap[hostHeader]) {
        const routes = complexOriginMap[hostHeader];
        let matched = false;

        for (let path in routes) {
            if (path !== 'default' && uri.startsWith(path)) {
                request.headers['spa-custom-Header'] = { value: routes[path] };
                matched = true;
                console.log('Matched host ' + hostHeader + ' with URI ' + uri + ' → ' + routes[path]);
                break;
            }
        }

        // Fallback to default if no path match
        if (!matched && routes['default']) {
            request.headers['spa-custom-Header'] = { value: routes['default'] };
            console.log('No URI match for host ' + hostHeader + ', using default origin ' + routes['default']);
        }
    }
    // Match simple host-only routing
    else if (simpleOriginMap[hostHeader]) {
        const origin = simpleOriginMap[hostHeader];
        request.headers['spa-custom-Header'] = { value: origin };
        console.log('Matched host ' + hostHeader + ' to origin ' + origin);
    } else {
        console.log('No routing match for host: ' + hostHeader);
    }

    return request;
}