<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://djpowell.net/tmp/sparql-tag/0.1/" prefix="sparql" %>
<%@ taglib uri="http://mannlib.cornell.edu/vitro/ListSparqlTag/0.1/" prefix="listsparql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!-- Given a grouping/department/faculty URI, produce a list of graduate fields -->

<c:if test="${param.type == 'group'}">

    <sparql:sparql>
        <sparql:select model="${applicationScope.jenaOntModel}" var="rs" group="<${param.uri}>">
          PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
          PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
          PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
          PREFIX core: <http://vivoweb.org/ontology/core#>
          SELECT DISTINCT ?field ?fieldLabel ?groupLabel
          WHERE {
          SERVICE <http://vivoprod01.library.cornell.edu:2020/sparql> {
              ?group vivo:hasAssociated ?field .
#              ?field vivo:hasFieldMember ?person .
              OPTIONAL { ?field rdfs:label ?fieldLabel }
              OPTIONAL { ?group rdfs:label ?groupLabel }
            }
          } ORDER BY ?fieldLabel
          LIMIT 100
        </sparql:select>

            <c:forEach items="${rs.rows}" var="row">
                <c:set var="classForField" value="${fn:substringAfter(row.field,'/individual/')}"/>
                <li><a href="/fields/${classForField}">${row.fieldLabel.string}</a></li>
            </c:forEach>

    </sparql:sparql>

</c:if>

<c:if test="${param.type == 'department'}">

    <sparql:sparql>
        <listsparql:select model="${applicationScope.jenaOntModel}" var="rs" dept="<${param.uri}>">
          PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
          PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
          PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
          PREFIX core: <http://vivoweb.org/ontology/core#>
          SELECT DISTINCT ?fieldUri ?fieldLabel
          WHERE {
          SERVICE <http://vivoprod01.library.cornell.edu:2020/sparql> {
              ?dept vivo:hasEmployeeAcademicFacultyMember ?personUri .
              ?personUri vivo:memberOfGraduateField ?fieldUri .
              ?fieldUri rdf:type vivo:GraduateField ;
                rdfs:label ?fieldLabel ;
                vivo:associatedWith ?grouping .
              ?grouping rdf:type vivo:fieldCluster
            }
          } ORDER BY ?fieldLabel
          LIMIT 100
        </listsparql:select>

            <c:forEach items="${rs}" var="row">
                <li>
                    <c:set var="fieldID" value="${fn:substringAfter(row.fieldUri,'/individual/')}"/>
                    <a href="/fields/${fieldID}" title="go to this field">${row.fieldLabel.string}</a>
                </li>
            </c:forEach>
            
    </sparql:sparql>

</c:if>


<c:if test="${param.type == 'faculty'}">

    <sparql:sparql>
        <listsparql:select model="${applicationScope.jenaOntModel}" var="rs" facultyUri="<${param.uri}>">
          PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
          PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
          PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
          PREFIX core: <http://vivoweb.org/ontology/core#>
          SELECT DISTINCT ?fieldUri ?fieldLabel
          WHERE {
          SERVICE <http://vivoprod01.library.cornell.edu:2020/sparql> {
              ?facultyUri vivo:memberOfGraduateField ?fieldUri .
              ?fieldUri rdf:type vivo:GraduateField ;
                rdfs:label ?fieldLabel ;
                vivo:associatedWith ?grouping .
              ?grouping rdf:type vivo:fieldCluster .
            }
          } ORDER BY ?fieldLabel
          LIMIT 100
        </listsparql:select>

            <c:forEach items="${rs}" var="row">
                <li>
                    <c:set var="fieldID" value="${fn:substringAfter(row.fieldUri,'/individual/')}"/>
                    <a href="/fields/${fieldID}" title="go to this field">${row.fieldLabel.string}</a>
                </li>
            </c:forEach>
            
    </sparql:sparql>

</c:if>

<c:if test="${param.type == 'all'}">

    <sparql:sparql>
        <listsparql:select model="${applicationScope.jenaOntModel}" var="rs">
          PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
          PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
          PREFIX vivo: <http://vivo.library.cornell.edu/ns/0.1#>
          PREFIX core: <http://vivoweb.org/ontology/core#>
          SELECT DISTINCT ?field ?fieldLabel
          WHERE {
          SERVICE <http://vivoprod01.library.cornell.edu:2020/sparql> {
              ?group rdf:type vivo:fieldCluster .
              ?group vivo:hasAssociated ?field .
#              ?field vivo:hasFieldMember ?person .
              OPTIONAL { ?field rdfs:label ?fieldLabel }
              OPTIONAL { ?group rdfs:label ?groupLabel }
              }
          } ORDER BY ?fieldLabel
          LIMIT 100
        </listsparql:select>

            <c:set var="totalFields" value="${fn:length(rs)}" />
            
            <c:choose>
                <c:when test="${(totalFields mod 2) == 0}"><%--For lists that will have even column lengths--%>
                    <c:set var="colSize" value="${(totalFields div 2)}" />
                    <fmt:parseNumber var="colSize" value="${colSize}" type="number" integerOnly="true" />
                </c:when>
                <c:otherwise><%--For uneven columns--%>
                    <c:set var="colSize" value="${(totalFields div 2) + 1}" />
                    <fmt:parseNumber var="colSize" value="${colSize}" type="number" integerOnly="true" />
                </c:otherwise>
            </c:choose>
            
            <c:choose>
                <c:when test="${param.columns == 'yes'}">
                    <ul class="fields ungrouped">
                        <c:forEach items="${rs}" var="row" begin="0" end="${colSize - 1}">
                            <c:set var="classForField" value="${fn:substringAfter(row.field,'/individual/')}"/>
                            <li><a href="/fields/${classForField}">${row.fieldLabel.string}</a></li>
                        </c:forEach>
                    </ul>
                    <ul class="fields ungrouped">
                        <c:forEach items="${rs}" var="row" begin="${colSize}">
                            <c:set var="classForField" value="${fn:substringAfter(row.field,'/individual/')}"/>
                            <li><a href="/fields/${classForField}">${row.fieldLabel.string}</a></li>
                        </c:forEach>
                    </ul>
                </c:when>
                <c:otherwise>
                <ul class="fields">
                    <c:forEach items="${rs}" var="row">
                        <c:set var="fieldID" value="${fn:substringAfter(row.field,'/individual/')}"/>
                        <li id="${fieldID}"><a href="/fields/${fieldID}">${row.fieldLabel.string}</a></li>
                    </c:forEach>
                </ul>
                </c:otherwise>
            </c:choose>
     
    </sparql:sparql>

</c:if>
