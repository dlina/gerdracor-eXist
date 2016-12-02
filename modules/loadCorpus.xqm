xquery version "3.1";
module namespace load="http://dlina.github.io/gerdracor-load";
import module namespace unzip="http://joewiz.org/ns/xquery/unzip" at "unzip.xqm";
import module namespace config="http://dlina.github.io/config" at "config.xqm";

declare function load:gerdracor($target as xs:string) {
let $url := "https://github.com/dlina/gerdracor/archive/master.zip"
let $gitRepo := httpclient:get($url, false(), ())
let $zip := xs:base64Binary( $gitRepo//httpclient:body[@mimetype="application/zip"][@type="binary"][@encoding="Base64Encoded"]/string(.) )
let $storeBinary := xmldb:store-as-binary($target, tokenize($url, '/')[last()], $zip)
let $doTheWork := unzip:unzip($storeBinary)
return
    true()
};