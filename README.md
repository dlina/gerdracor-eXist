# gerdracor-eXist
Application for the eXist database for managing the [GerDraCor - German Drama Corpus](https://github.com/dlina/gerdracor)

## build
calling `ant` in the root directory of this repo will prepare a XAR package in the build directory.

## installation
* install and start a recent version of [eXist-db](http://exist-db.org/exist/apps/homepage/index.html)
 * tested with 3.0RC2-develop (https://github.com/eXist-db/exist/tree/605c4e3f4c2232e42467f6658f8b5e61516c7159)
* direct a browser to [localhost:8080](http://localhost:8080)
* use the `Package Manager` to install the XAR package

* alternatively you can place the builded XAR package in the directory `autodelopy` before starting the database

* visit the [GerDraCor home page](http://localhost:8080/exist/apps/gerdracor/index.html)
## usage
This tool generates a [table of content](http://localhost:8080/exist/apps/gerdracor/index.thml) of the git repo.

