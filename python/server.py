# https://pythonsansar.com/creating-simple-http-server-python/

import sys
import uuid
from http.server import HTTPServer, SimpleHTTPRequestHandler

HOST_NAME = '0.0.0.0'
PORT = 8080
WELCOME = bytes(
    'Welcome to gibberish service\nHTTP POST your stuff and enjoy gibberish', 'utf-8')


class PythonServer(SimpleHTTPRequestHandler):

    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(WELCOME)

    def do_POST(self):
        # https://gist.github.com/mdonkers/63e115cc0c79b4f6b8b3a6b797e485c7
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)
        expr = post_data.decode()
        result = str(uuid.uuid4()) + expr + str(uuid.uuid4()) + '\n'
        self.send_response(200)
        self.end_headers()
        self.wfile.write(bytes(result, 'utf-8'))


if __name__ == '__main__':
    server = HTTPServer((HOST_NAME, PORT), PythonServer)
    print(f'Server started http://{HOST_NAME}:{PORT}')
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        server.server_close()
        print('Server stopped successfully')
        sys.exit(0)
