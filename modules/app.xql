xquery version "3.1";
module namespace app="http://dlina.github.io/templates";
import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://dlina.github.io/config" at "config.xqm";
import module namespace load="http://dlina.github.io/gerdracor-load" at "loadCorpus.xqm";
import module namespace text="http://dlina.github.io/text" at "text.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare default element namespace "http://www.w3.org/1999/xhtml";

declare function app:receiver($node as node(), $model as map(*)) {
    let $parameters := request:get-parameter-names()
return
    for $parameter in $parameters
    return
        switch ($parameter)
        case "reload" return
            if(request:get-parameter($parameter, "false") = "true")
            then load:gerdracor( $config:app-root )
            else ()
        case "text" return
            if(request:get-parameter($parameter, "false") = "full")
            then
                let $tei := collection($config:data-root)//tei:idno[. = request:get-parameter("id", "false")]/ancestor::tei:TEI//tei:text
                return
                    text:fulltext( $tei )
            else ()
        default return ()
};

declare function app:menuitem($node as node(), $model as map(*)) {
if( sm:get-user-groups( xmldb:get-current-user() ) = "dba" )
then <xhtml:li><xhtml:a href="?reload=true" title="reload from git">&#8634;</xhtml:a></xhtml:li>
else ()
};

declare function app:table($node as node(), $model as map(*)) as map(*) {
    let $items :=
        for $i in collection($config:data-root)//tei:TEI
        return $i
    return
        map { "data" := $items }
};

declare function app:tableHead($node as node(), $model as map(*)) {
        <thead>
          <tr>
            <th>Author</th>
            <th>Title</th>
            <th>print</th>
            <th>premiere</th>
            <th>written</th>
            <th>genreTitle</th>
            <th>view</th>
            <th>plain</th>
            <th>source</th>
            {if( sm:get-user-groups( xmldb:get-current-user() ) = "dba" ) then <th>edit</th> else ()}
          </tr>
        </thead>
};

declare function app:tableRow($node as node(), $model as map(*)) {
     <tbody>
        {for $i in $model("data")
        let $date := 
            if( $i//tei:date[@type='print']/@when 
                and
                $i//tei:date[@type='premiere']/@when)
            then 
                min(number($i//tei:date[@type='print']/@when), 
                number($i//tei:date[@type='premiere']/@when))
            else if(number($i//tei:date[@type='premiere']/@when))
                then $i//tei:date[@type='premiere']/@when 
            else number($i//tei:date[@type='print']/@when),
        $date := if(exists($i//tei:date[@type='written']/@when)
                    and $date - 10 gt number($i//tei:date[@type='written']/@when))
                then number($i//tei:date[@type='written']/@when)
                else $date,
        $date := if(string($date) = ('', 'NaN')) then '1800' else string($date)
        order by xs:integer($date)
        return
            <tr>
                <td>{$i//tei:author/text()}</td>
                <td>{($i//tei:title)[1]/text()}</td>
                <td>{$i//tei:date[@type="print"]/string(@when)}{if($date = $i//tei:date[@type="print"]/string(@when)) then "*" else ()}</td>
                <td>{$i//tei:date[@type="premiere"]/string(@when)}{if($date = $i//tei:date[@type="premiere"]/string(@when)) then "*" else ()}</td>
                <td>{$i//tei:date[@type="written"]/string(@when)}{if($date = $i//tei:date[@type="written"]/string(@when)) then "*" else ()}</td>
                <td>{$i//tei:textClass/tei:keywords/tei:term[@type="genreTitle"]/text()}</td>
                <td><a href="view.html?id={$i//tei:idno[@type="DLINA-ID"]/string(.)}">view</a></td>
                <th><a href="?text=full&amp;id={$i//tei:idno[@type="DLINA-ID"]/string(.)}">txt</a></th>
                <th><a href="modules/xml-indent.xql?id={$i//tei:idno[@type="DLINA-ID"]/string(.)}" target="_blank">source</a></th>
                {if( sm:get-user-groups( xmldb:get-current-user() ) = "dba" ) then <th>edit</th> else ()}
            </tr>}
    </tbody>
};
declare function local:render($nodes) {
for $node in $nodes
return
    typeswitch ( $node )
    case text() return $node
    default return
        element {"tei-" || $node/local-name()} {
            for $attrib in $node/@*
            return
                attribute {"tei-" || $attrib/local-name()} {
                    string($attrib)
                },
            local:render($node/node())
        }
};

declare function app:view($node as node(), $model as map(*), $id) {
let $tei := collection($config:data-root)//tei:idno[. = $id]/ancestor::tei:TEI
return
    local:render($tei)
};