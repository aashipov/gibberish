## Gibberish generator

Stateless HTTP server that expects HTTP POST with body, responds <UUID1>body<UUID2>

Main goal - load test

## How to use

```shell
curl -X POST -H "Content-Type: text/plain" --data "abc" http://localhost:8080
```

## License

Perl The "Artistic License"
