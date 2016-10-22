# cr-web-session
An example microservice in Crystal for storing and querying live web sessions.

The purpose of this project is mostly to learn Crystal.

## Installation
```sh
crystal deps
crystal build src/cr-web-session.cr
sudo mv cr-web-session /usr/local/bin
```

## Usage
```js
$ cat test.json 
{
  "key": "f8",
  "entry": {
    "hello": "world"
  }
}

$ http POST localhost:3000/save < test.json
HTTP/1.1 200 OK
Connection: keep-alive
Content-Length: 12
Content-Type: application/json
X-Powered-By: Kemal

{
    "error": ""
}

$ http POST localhost:3000/query key=f8    
HTTP/1.1 200 OK
Connection: keep-alive
Content-Length: 48
Content-Type: application/json
X-Powered-By: Kemal

{
    "entry": {
        "hello": "world"
    },
    "error": "",
    "ttl": 580
}

$ http POST localhost:3000/query key=f8a
HTTP/1.1 200 OK
Connection: keep-alive
Content-Length: 20
Content-Type: application/json
X-Powered-By: Kemal

{
    "error": "no entry"
}
```

## Development
Make sure Redis is installed and running on the default host and port.
```sh
crystal deps
crystal run src/cr-web-session.cr
```

## Contributing

1. Fork it ( https://github.com/lbn/cr-web-session/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [lbn](https://github.com/lbn) Lee Archer - creator, maintainer
