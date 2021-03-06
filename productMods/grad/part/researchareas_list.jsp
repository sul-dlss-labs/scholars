<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://mannlib.cornell.edu/vitro/ListSparqlTag/0.1/" prefix="listsparql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<%-- Given a faculty or field URI, get associated research areas --%>
<%-- or given a field URI, get top 4 ranked research areas --%>



<c:if test="${param.type == 'all'}">

    <sparql:sparql>
        <listsparql:select model="${applicationScope.jenaOntModel}" var="rs">
          PREFIX fn:  <http://www.w3.org/2005/xpath-functions#>
          PREFIX rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
          PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
          PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
          PREFIX core: <http://vivoweb.org/ontology/core#>
          SELECT DISTINCT ?areaUri ?areaLabel 
          WHERE {
            SERVICE <http://vivoprod01.library.cornell.edu:2020/sparql> {
                  ?group rdf:type vivo:fieldCluster .
                  ?group vivo:hasAssociated ?field .
                  ?field vivo:hasFieldMember ?personUri .
                  ?personUri core:hasResearchArea ?areaUri .
                  ?areaUri rdfs:label ?areaLabelRaw .
            }
                LET (?areaLabel := str(?areaLabelRaw))
          } ORDER BY fn:lower-case(?areaLabel)
          LIMIT 1000
        </listsparql:select>
        
            <c:set var="total" value="${fn:length(rs)}"/>
        
            <c:forEach items="${rs}" var="row">
                <c:set var="areaID" value="${fn:substringAfter(row.areaUri,'/individual/')}"/>
                
                <li><a href="/researchareas/${areaID}">${row.areaLabel.string}</a></li>
            </c:forEach>
            
            <li>Total: ${total}</li>
    </sparql:sparql>

</c:if>

<c:if test="${param.type == 'all-menu'}">

    <sparql:sparql>
        <listsparql:select model="${applicationScope.jenaOntModel}" var="rs">
          PREFIX fn:  <http://www.w3.org/2005/xpath-functions#>
          PREFIX rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
          PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
          PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
          PREFIX core: <http://vivoweb.org/ontology/core#>
          SELECT DISTINCT ?areaUri ?areaLabel
          WHERE {
            SERVICE <http://vivoprod01.library.cornell.edu:2020/sparql> {
                    ?group rdf:type vivo:fieldCluster .
                    ?group vivo:hasAssociated ?field .
                    ?field vivo:hasFieldMember ?personUri .
                    ?personUri core:hasResearchArea ?areaUri .
                    ?areaUri rdfs:label ?areaLabelRaw .
            }
                  LET (?areaLabel := str(?areaLabelRaw))
          } ORDER BY fn:lower-case(?areaLabel)
          LIMIT 1000
        </listsparql:select>
        
            <c:forEach items="${rs}" var="row">
                <c:set var="areaID" value="${fn:substringAfter(row.areaUri,'/individual/')}"/>
                <option value="${areaID}">${row.areaLabel.string}</option>
            </c:forEach>
            
    </sparql:sparql>

</c:if>

<c:if test="${param.type == 'faculty'}">

    <sparql:sparql>
        <listsparql:select model="${applicationScope.jenaOntModel}" var="rs" facultyUri="<${param.uri}>">
          PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
          PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
          PREFIX core: <http://vivoweb.org/ontology/core#>
          SELECT DISTINCT ?areaUri ?areaLabel
          WHERE {
            SERVICE <http://vivoprod01.library.cornell.edu:2020/sparql> {
              ?facultyUri core:hasResearchArea ?areaUri .
              ?areaUri rdfs:label ?areaLabel .
            }
          } ORDER BY ?areaLabel
          LIMIT 200
        </listsparql:select>

            <c:forEach items="${rs}" var="row">
                <li>${row.areaLabel.string}</li>
            </c:forEach>
        
    </sparql:sparql>

</c:if>

<c:if test="${param.type == 'field'}">

    <sparql:sparql>
        <listsparql:select model="${applicationScope.jenaOntModel}" var="rs" fieldUri="<${param.uri}>">
          PREFIX fn:  <http://www.w3.org/2005/xpath-functions#>
          PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
          PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
          PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
          PREFIX core: <http://vivoweb.org/ontology/core#>
          SELECT DISTINCT ?areaUri ?areaLabel
          WHERE {
            SERVICE <http://vivoprod01.library.cornell.edu:2020/sparql> {
                ?fieldUri vivo:hasFieldMember ?facultyUri .
                ?facultyUri core:hasResearchArea ?areaUri .
                ?areaUri rdfs:label ?areaLabelRaw .
                OPTIONAL { ?facultyUri vitro:moniker ?moniker }
            }
              LET (?areaLabel := str(?areaLabelRaw))
              FILTER (!regex(?moniker, "emeritus", "i"))
          } ORDER BY fn:lower-case(?areaLabel)
          LIMIT 200
        </listsparql:select>

            <c:forEach items="${rs}" var="row">
                <c:set var="areaID" value="${fn:substringAfter(row.areaUri,'/individual/')}"/>
                <li id="${areaID}"><a href="/researchareas/${areaID}">${row.areaLabel.string}</a></li>
            </c:forEach>
        
    </sparql:sparql>

</c:if>

<c:if test="${param.type == 'field-ranked'}">

    <sparql:sparql>
        <listsparql:select model="${applicationScope.jenaOntModel}" var="rs" fieldUri="<${param.uri}>">
          PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
          PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
          PREFIX core: <http://vivoweb.org/ontology/core#>
          SELECT ?areaLabel ?areaUri ?facultyLabel ?facultyUri
          WHERE {
            SERVICE <http://vivoprod01.library.cornell.edu:2020/sparql> {
                ?fieldUri vivo:hasFieldMember ?facultyUri .
                ?facultyUri core:hasResearchArea ?areaUri .
                ?areaUri rdfs:label ?areaLabel .
                OPTIONAL { ?facultyUri rdfs:label ?facultyLabel }
            }
          } ORDER BY ?areaLabel ?facultyLabel
          LIMIT 2000
        </listsparql:select>

        <%-- Here is a pretty wacky way to rank research areas using JSTL --%>
        
        <%-- We want the top 4, so we'll do 4 iterations --%>
        <%-- first iteration will get the top-ranked area, second iteration will get the second highest-ranked, etc --%>
        <c:forEach begin="1" end="4" varStatus="item">
        
            <c:set var="thisArea" value=""/>
            <c:set var="largestCount" value=""/>
        
                <%-- First, go through the whole result set --%>
                <c:forEach var="row" items="${rs}"> 
                    <c:set var="counter" value="0"/>
                    
                    <%-- The result set contains multiple rows with the same research area -- one for each faculty member with that area
                        so the first condition below will skip rows with areas that have already been checked
                        and the next conditions will skip rows with areas already determined to be top ranking --%>
                        
                    <c:if test="${(row.areaUri != thisArea) && (row.areaUri != topArea1) && (row.areaUri != topArea2) && (row.areaUri != topArea3) && (row.areaUri != topArea4)}">
                        <c:set var="thisArea" value="${row.areaUri}"/>
                        <c:set var="thisAreaLabel" value="${row.areaLabel.string}"/>
                        
                            <%-- Now for each unique research area, we're iterating through the whole result set again --%>
                            <c:forEach var="area" items="${rs}">
                                <c:if test="${area.areaUri == thisArea}">
                                    <%-- We're counting how many times the research area appears in the whole result set --%>
                                    <c:set var="counter" value="${counter+1}"/>
                                </c:if>
                            </c:forEach>

                            <%-- when the count is higher than previous totals, set the corresponding variables--%>
                            <c:if test="${counter > largestCount}">
                                <c:set var="largestCount" value="${counter}"/>
                                <c:choose>
                                
                                    <%-- item.index is the position in the initial 4-step loop --%>
                                    <c:when test="${item.index == 1}">
                                        <c:set var="topArea1" value="${thisArea}"/>
                                        <c:set var="topArea1label" value="${thisAreaLabel}"/>
                                        <c:set var="topArea1count" value="${counter}"/>
                                    </c:when>
                                    <c:when test="${item.index == 2}">
                                        <c:set var="topArea2" value="${thisArea}"/>
                                        <c:set var="topArea2label" value="${thisAreaLabel}"/>
                                        <c:set var="topArea2count" value="${counter}"/>
                                    </c:when>
                                    <c:when test="${item.index == 3}">
                                        <c:set var="topArea3" value="${thisArea}"/>
                                        <c:set var="topArea3label" value="${thisAreaLabel}"/>
                                        <c:set var="topArea3count" value="${counter}"/>
                                    </c:when>
                                    <c:when test="${item.index == 4}">
                                        <c:set var="topArea4" value="${thisArea}"/>
                                        <c:set var="topArea4label" value="${thisAreaLabel}"/>
                                        <c:set var="topArea4count" value="${counter}"/>
                                    </c:when>
                                    <c:otherwise></c:otherwise>
                                    
                                </c:choose>
                            </c:if>
                    </c:if>
                </c:forEach>
            
        </c:forEach>
        
        <%-- research areas with only the minimum number of people will not be displayed --%>
        <c:set var="min" value="1"/>
        
        <c:if test="${topArea1count > min}">${topArea1label}</c:if>
        <c:if test="${topArea2count > min}">; ${topArea2label}</c:if>
        <c:if test="${topArea3count > min}">; ${topArea3label}</c:if>
        <c:if test="${topArea4count > min}">; ${topArea4label}</c:if>
        
        <%-- <c:if test="${topArea1count > min}"><li>${topArea1label}(${topArea1count})</li></c:if>
        <c:if test="${topArea2count > min}"><li>${topArea2label}(${topArea2count})</li></c:if>
        <c:if test="${topArea3count > min}"><li>${topArea3label}(${topArea3count})</li></c:if>
        <c:if test="${topArea4count > min}"><li>${topArea4label}(${topArea4count})</li></c:if> --%>
        
    </sparql:sparql>

</c:if>


