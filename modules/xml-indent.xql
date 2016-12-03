xquery version "3.1";
import module namespace config="http://dlina.github.io/config" at "config.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace lina="http://lina.digital";

declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=no indent=yes";

declare variable $id := request:get-parameter('id', '1');
declare variable $doc := (collection($config:data-root)//tei:idno[@type="DLINA-ID"][. = $id])[1]/base-uri();

doc( $doc )