xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace lina="http://lina.digital";

declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=no indent=yes";

declare variable $id := request:get-parameter('id', '1');
declare variable $doc := collection("/db/data")//tei:idno[@type="DLINA-ID"][. = $id]/base-uri();

doc( $doc )