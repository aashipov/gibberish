package org.dummy;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpServer;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.util.UUID;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * App.
 */
public class App {
    private static final int PORT = 8080;
    private static final ExecutorService HTTP_EXECUTOR_SERVICE =
            Executors.newWorkStealingPool(Math.max(Runtime.getRuntime().availableProcessors(), 2) * 8);
    private static final Logger LOGGER = Logger.getLogger(App.class.getSimpleName());

    public static void main(String[] args) throws IOException {
        HttpServer server = HttpServer.create(new InetSocketAddress(PORT), 0);
        server.createContext("/", new CommonHandler());
        server.setExecutor(HTTP_EXECUTOR_SERVICE);
        server.start();
    }

    /**
     * {@link HttpHandler}.
     */
    static class CommonHandler implements HttpHandler {
        private static final String POST = "POST";
        private static final String CONTENT_TYPE = "Content-Type";
        private static final Charset DEFAULT_CHARSET = StandardCharsets.UTF_8;
        private static final String DEFAULT_CHARSET_NAME = DEFAULT_CHARSET.name();
        private static final String TEXT_PLAIN = "text/plain; charset=" + DEFAULT_CHARSET_NAME;
        private static final int OK = 200;
        private static final int INTERNAL_SERVER_ERROR = 500;
        private static final String NO_REQUEST_METHOD = "No request method";
        private static final String WELCOME = "Welcome to gibberish service\nHTTP POST your stuff and enjoy gibberish";

        @Override
        public void handle(HttpExchange exchange) {
            String requestMethod = exchange.getRequestMethod();
            if (isBlank(requestMethod)) {
                textResponse(exchange, INTERNAL_SERVER_ERROR, NO_REQUEST_METHOD);
            } else {
                if (POST.equalsIgnoreCase(exchange.getRequestMethod())) {
                    try (InputStream inputStream = exchange.getRequestBody();
                         ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream()) {
                        inputStream.transferTo(byteArrayOutputStream);
                        String expr = byteArrayOutputStream.toString(DEFAULT_CHARSET);
                        String result = UUID.randomUUID().toString() + expr + UUID.randomUUID().toString() + "\n";
                        textResponse(exchange, OK, result);
                    } catch (Exception e) {
                        LOGGER.log(Level.SEVERE, "Can fabricate gibberish {0}", e.getMessage());
                        textResponse(exchange, INTERNAL_SERVER_ERROR, e.getMessage());
                    }
                } else {
                    textResponse(exchange, OK, WELCOME);
                }
            }
        }

        /**
         * Is {@link CharSequence} blank?.
         * @param cs {@link CharSequence}
         * @return is blank?
         */
        static boolean isBlank(final CharSequence cs) {
            if (null != cs) {
                final int strLen = cs.length();
                if (0 != strLen) {
                    for (int i = 0; i < strLen; i++) {
                        if (!Character.isWhitespace(cs.charAt(i))) {
                            return false;
                        }
                    }
                }
            }
            return true;
        }

        /**
         * Send text response.
         * @param exchange {@link HttpExchange}
         * @param rCode status code
         * @param msg message
         */
        static void textResponse(HttpExchange exchange, int rCode, String msg) {
            try (OutputStream os = exchange.getResponseBody()) {
                exchange.getResponseHeaders().add(CONTENT_TYPE, TEXT_PLAIN);
                exchange.sendResponseHeaders(rCode, msg.length());
                os.write(msg.getBytes(DEFAULT_CHARSET));
            } catch (IOException e) {
                LOGGER.log(Level.SEVERE, "Error sending plain text response {0}", e.getMessage());
            } finally {
                exchange.close();
            }
        }
    }
}
