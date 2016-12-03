xquery version "3.1";

(:~
 : preperation of plain text files from GerDraCor
 : 
 : @see https://github.com/dlina/gerdracor
 : @version 1.0
 : @author Dario Kampkaspar
 : @author Mathias Göbel
 : 
 :)
module namespace text="http://dlina.github.io/text";
import module namespace config="http://dlina.github.io/config" at "config.xqm";
declare namespace tei="http://www.tei-c.org/ns/1.0";

(:~
 : get the full text as plain text file
 : 
 : @param $tei as a single tei:text element
 : @return xs:string
 :)
declare function text:fulltext($tei as element(tei:text)) {
let $l := $tei//tei:sp/tei:p | $tei//tei:sp//tei:l
let $m := $l/node()[not(self::tei:hi)]
let $fullText := string-join($m, ' ')
return replace($fullText, '\s\s*', ' ')
};

(:~ 
 : full text in chunks
 : 
 : @param $tei as a single tei:text element
 : @param $chunkSize as xs:integer
 : @return xs:string()+
 : 
 : :)
declare function text:chunks($tei as element(tei:text), $chunkSize as xs:integer) {
    let $l := $tei//tei:sp/tei:p | $tei//tei:sp//tei:l
    let $m := $l/node()[not(self::tei:hi)]
    let $fullText := replace(string-join($m, ' '), '\s\s*', ' ')
    let $tok := tokenize($fullText, ' ')
    
    let $max := count($tok) idiv $chunkSize
    for $n in 0 to $max
        let $start := $n * $chunkSize
        let $text := string-join(subsequence($tok, $start, $start+$chunkSize), ' ')
    return $text
};

(:~
 : text per character
 : 
 : @param a single tei:text element
 : @return plain text per speaker as xs:string()+
 :)
declare function text:speech($tei as element(tei:text)) as xs:string+ {
for $tei in (collection($sourceCol))
    for $per in $tei//tei:particDesc/tei:listPerson/tei:person
        let $name := ($per//@xml:id)[1]
        let $match := string-join($per//@xml:id, '|')
        let $utt :=$tei//tei:sp[matches(@who, $match)]
        let $l := $utt/tei:p | $utt//tei:l
        let $m := $l/node()[not(self::tei:hi)]
        let $text := string-join($m, ' ')
        return replace($text, '\s\s*', ' ')
};