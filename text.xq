xquery version "3.1";
declare namespace tei="http://www.tei-c.org/ns/1.0";
import module namespace text="http://dlina.github.io/text" at "modules/text.xqm";
import module namespace config="http://dlina.github.io/config" at "modules/config.xqm";

switch ( request:get-parameter("text", "speaker") )
    case "full" return
        let $tei := collection($config:data-root)//tei:idno[. = request:get-parameter("id", "false")]/ancestor::tei:TEI//tei:text
        let $filename := replace(tokenize($tei/base-uri(), "/")[last()], '-lina.xml', '-fulltext.txt')
        let $text := text:fulltext( $tei )
        return
            (serialize(response:stream($text, '')))
            
    case "speaker" return
        let $tei := collection($config:data-root)//tei:idno[. = request:get-parameter("id", "51")]/ancestor::tei:TEI
        let $filename := replace(tokenize($tei/base-uri(), "/")[last()], '-lina.xml', '-NAME.txt')
        let $texts as map() := text:speech($tei)
        let $zip :=
            ( 
                let $entries as item()+ := 
                    ( 
                        for $key in map:keys($texts)
                        let $name := replace($filename, 'NAME', $key)
                        let $text := $texts($key)
                        return
                            <entry name="{replace(replace(replace($name, '%C3%BC', 'ü'), '%C3%B6', 'ö'), '%C3%A4', 'ä')}" type="text" method="store">{$text}</entry>
                    )
                    return
(:                        $entries:)
                        compression:zip($entries, false())
            )
        return 
               response:stream-binary($zip, 'application/zip', $filename  || '.zip')
    default return ()