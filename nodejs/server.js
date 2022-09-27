const http = require('http');
const { randomUUID } = require('crypto');

const welcome = 'Welcome to gibberish service\nHTTP POST your stuff and enjoy gibberish';
const canNotEvaluate = 'Can not evaluate';

http.createServer((request, response) => {
    if (request.method === 'POST') {
        let gibberish = '';
        let result = canNotEvaluate;
        request
            .on('data', (chunk) => {
                gibberish += chunk;
            })
            .on('end', () => {
                try {
                    result = ''  + randomUUID() + gibberish + randomUUID() + '\n';
                } catch (exc) {
                    result += '' + gibberish + ': ' + exc.message;
                } finally {
                    response.end(result);
                }
            })
            .on('error', (err) => {
                response.end(err);
            });
    } else {
        response.end(welcome);
    }
}).listen(8080);
