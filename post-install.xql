xquery version "3.0";

import module namespace load="http://dlina.github.io/gerdracor-load" at "modules/loadCorpus.xqm";
declare namespace repo="http://exist-db.org/xquery/repo";

(: The following external variables are set by the repo:deploy function :)

(: the target collection into which the app is deployed :)
declare variable $target external;

load:gerdracor($target)