Build glassfish image
=====================

Build

```
$ docker build --force-rm --rm -t yadickson/glassfish:5.0.1 .
```
or
```
$ docker build --force-rm --rm -t yadickson/glassfish:5.0 --build-arg GF_VERSION=5.0 .
```

Run

```
$ docker run --name glassfish -it yadickson/glassfish:5.0.1 bash
```
or
```
$ docker run --name glassfish -it yadickson/glassfish:5.0 bash
```

