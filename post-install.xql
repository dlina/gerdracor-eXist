xquery version "3.0";

import module namespace unzip="http://joewiz.org/ns/xquery/unzip" at "modules/unzip.xqm";


declare namespace repo="http://exist-db.org/xquery/repo";

(: The following external variables are set by the repo:deploy function :)

(: the target collection into which the app is deployed :)
declare variable $target external;

(: uncomment next line for rewriting the corpus or testing purposes
 : let $target := "/db/apps/newLina":)

let $url := "https://github.com/dlina/gerdracor/archive/master.zip"
let $gitRepo := httpclient:get($url, false(), ())
let $zip := xs:base64Binary( $gitRepo//httpclient:body[@mimetype="application/zip"][@type="binary"][@encoding="Base64Encoded"]/string(.) )
let $storeBinary := xmldb:store-as-binary($target, tokenize($url, '/')[last()], $zip)
return
    unzip:unzip($storeBinary)