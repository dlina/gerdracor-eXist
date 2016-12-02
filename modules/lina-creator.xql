xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace lina="http://lina.digital";



declare function local:attrib($nodes) {
for $node in $nodes
return
    typeswitch ( $node )
    case element( * ) return
        element {node-name($node)} {
            for $attribute in $node/@*[not(./local-name() = ("n", "id"))]
            return
                if(starts-with($attribute, 'zeno'))
                then ()
                else 
                if(string($attribute = "work:no")) then ()
                else $attribute,
            local:transform($node/node())
        }
    default return
        ()
};

declare function local:transform($nodes) {
for $node in $nodes
return
    typeswitch ( $node )
    (: elements to be removed :)
    case element (tei:lb) return ()
    case element (tei:pb) return ()
    case element (tei:milestone) return ()
    (: elements to be transformed :)
    case element( tei:div ) return
        (element {node-name($node)} {
            $node/@*[not(. = "work:no")][not(./local-name() = ("n", "id"))][not(starts-with(., "tg"))],
            local:transform($node/node())
        })
    (: identity template :)
    case element (*) return
        local:attrib($node)
    case text() return $node
    default return
        local:transform($node/node())
};

declare function local:addWho($nodes) {
for $node in $nodes
return
    typeswitch ( $node )
    case element( tei:sp ) return
        (element sp {
            if($node//tei:speaker) then
                attribute who {
                    let $first := '#' || replace(replace($node/tei:speaker/lower-case(.), '\.|,|;|:|-', ''), '\s+', '_')
                    let $second := if(contains($first, "_und_")) then replace($first, '_und_', ' #') else $first
                    return
                        $second
                }
                else (),
            local:addWho($node/node())
        })
    case text() return 
        text {replace($node, '\s+', ' ')}
    default return
        element {node-name($node)} {
            $node/@*,
            local:addWho($node/node())
        }
};

let $process :=
map:new(
    for $lina at $pos in (collection('/db/data/lina')//lina:play
(:    [@id="333"]:)
    )
(:    [position() lt 21]:)
    let $filename := tokenize($lina/base-uri(), '/')[last()]
    let $textgrid-uri := "textgrid:" || ($lina//lina:source)[1]/substring-before(substring-after(., 'textgrid:'), '.')
    let $url := xs:anyURI("http://textgridrep.org/" || $textgrid-uri)
    let $doc := httpclient:get($url, false(), ())//httpclient:body//tei:TEI
    let $newLina :=
    <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <teiHeader>
          <fileDesc>
             <titleStmt>
                {($doc//tei:title)[1]}
                {($doc//tei:author)[1]}
             </titleStmt>
             <publicationStmt>
                    <publisher xml:id="dlina">DLINA</publisher>
                    <idno type="URL">https://dlina.github.io</idno>
                    <idno type="DLINA-ID">{$lina/string(@id)}</idno>
                    <availability>
                        <licence>
                            <ab>CC-BY-4.0</ab>
                            <ref target="https://creativecommons.org/licenses/by/4.0/legalcode">Lizenzvertrag</ref>
                        </licence>
                    </availability>
             </publicationStmt>
             <sourceDesc>
                 <bibl type="digitalSource">
                     <name>TextGrid Repository</name>
                     <idno type="URL">http://www.textgridrep.org/textgrid:{substring-before(substring-after(($lina//lina:source/text())[1], 'textgrid:'), '.0')}.0</idno>
                     <availability>
                         <licence>
                             <ab>CC-BY-3.0</ab>
                             <ref target="http://creativecommons.org/licenses/by/3.0/de/legalcode">Lizenzvertrag</ref>
                         </licence>
                     </availability>
                     <bibl type="originalSource">
                            {$doc//tei:sourceDesc/tei:biblFull/tei:titleStmt/tei:title}
                            <date type="print">{$lina//*:date[@type="print"]/@when, $lina//*:date[@type="print"]/text()}</date>
                            <date type="premiere">{$lina//*:date[@type="premiere"]/@when, $lina//*:date[@type="premiere"]/text()}</date>
                            <date type="written">{$lina//*:date[@type="written"]/@when, $lina//*:date[@type="written"]/text()}</date>
                     </bibl>
                 </bibl>
             </sourceDesc>
          </fileDesc>
            <profileDesc>
                <particDesc>
                    <listPerson>
                        {
                            for $person in $lina//lina:personae/lina:character
                            return
                                element person {
                                    ($person//@xml:id)[1],
                                    for $persName at $pos in $person/lina:alias
                                    return
                                        element persName {
                                            if($pos gt 1) then $persName/@xml:id else (),
                                            $persName/lina:name/text()
                                        }
                                }
                        }
                    </listPerson>
                </particDesc>
                <textClass>
                    <keywords>
                        <term type="genreTitle">{$lina//lina:genretitle/text()}</term>
                    </keywords>
                </textClass>
            </profileDesc>
            <revisionDesc>
                <listChange>
                    <change who="#dlina" when="{current-dateTime()}">file conversion from source</change>
                </listChange>
            </revisionDesc>
       </teiHeader>
            {local:transform($doc//tei:text)}
    </TEI>
(:    let $spXPath :=:)
(:        for $sp in $doc//tei:sp:)
(:        return:)
(:            string-join( ($sp/ancestor-or-self::tei:*/local-name()),  "/"):)
(:    let $distinctPathes := distinct-values( $spXPath ):)
    let $newLina := local:addWho($newLina)
    return
        map:entry($filename, $newLina))
let $login := xmldb:login("/", 'admin', '')
return
    map:keys($process) ! xmldb:store( "/db/data/lina-tei", ., $process(.) )