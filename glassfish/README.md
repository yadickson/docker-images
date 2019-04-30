Build glassfish image
=====================

```
$ docker build --force-rm --rm -t yadickson/glassfish:5.0.1 .
```

```
$ docker build --force-rm --rm -t yadickson/glassfish:5.0 --build-arg GF_VERSION=5.0 .
```

```
$ docker run --name glassfish -it yadickson/glassfish bash
```
