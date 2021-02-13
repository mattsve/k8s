#!/usr/bin/node
const https = require('https');

signIn = function (username, password) {
    return new Promise(function (resolve, reject) {
        var requestBody = `${encodeURI('user[login]')}=${encodeURI(username)}&${encodeURI('user[password]')}=${encodeURI(password)}`;        
        var options = {
            hostname: 'plex.tv',
            port: 443,
            path: '/users/sign_in.json',
            method: 'POST',
            headers: {
                'X-Plex-Version': '1.0.0',
                'X-Plex-Product': 'WHATEVER',
                'X-Plex-Client-Identifier': 'YOUR-PRODUCT-ID',
                'Content-Type': 'application/x-www-form-urlencoded',
                'Content-Length': Buffer.byteLength(requestBody)
            }
        };
        
        const request = https.request(options, function(response) {
            var responseBody = '';
            response.on('data', function(chunk) {
                responseBody += chunk;
            });
            response.on('end', function() {
                const parsedBody = JSON.parse(responseBody + '');
                response.statusCode > 299 ? reject(parsedBody) : resolve(parsedBody);
            });
        });

        request.write(requestBody);
        request.end();
        request.on('error', function(e) {
            reject(e);
        });
    });
}

getClaimToken = function (authToken) {
    return new Promise(function (resolve, reject) {
        var options = {
            hostname: 'plex.tv',
            port: 443,
            path: '/api/claim/token.json',
            method: 'GET',
            headers: {
                'X-Plex-Product': 'Plex SSO',
                'X-Plex-Client-Identifier': 'YOUR-PRODUCT-ID',
                'X-Plex-Token': authToken
            }
        };
        
        const request = https.request(options, function(response) {
            var responseBody = '';
            response.on('data', function(chunk) {
                responseBody += chunk;
            });
            response.on('end', function() {
                const parsedBody = JSON.parse(responseBody + '');
                response.statusCode > 299 ? reject(parsedBody) : resolve(parsedBody);
            });
        });

        request.end();
        request.on('error', function(e) {
            reject(e);
        });
    });
}

signIn(process.argv[2], process.argv[3]).then(function (userInformation) { 
    getClaimToken(userInformation.user.authToken).then(function (claimTokenInformation) { 
        console.log(claimTokenInformation.token);
    }) 
});
