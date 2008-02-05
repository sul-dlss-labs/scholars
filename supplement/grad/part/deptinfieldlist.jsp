<jsp:root xmlns:jsp="http://java.sun.com/JSP/Page"
          xmlns:c="http://java.sun.com/jsp/jstl/core"
          xmlns:sparql="http://djpowell.net/tmp/sparql-tag/0.1/"
          version="2.0" >
<!-- given a graduate field , produce a list of departments in the field with links -->
  <jsp:directive.page contentType="text/xml; charset=UTF-8" />
  <jsp:directive.page session="false" />

    <sparql:sparql>
    <sparql:select model="${applicationScope.jenaOntModel}" var="rs"
            field="&lt;${param.uri}&gt;">
      <![CDATA[

              PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
              PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
              SELECT DISTINCT ?deptUri ?deptLabel
              WHERE
              {
              ?person
              <http://vivo.library.cornell.edu/ns/0.1#AcademicEmployeeOtherParticipantAsFieldMemberInAcademicInitiative>
              ?field .

              ?person
              <http://vivo.library.cornell.edu/ns/0.1#CornellFacultyMemberInOrganizedEndeavor>
              ?deptUri .

              ?deptUri
               rdf:type
               <http://vivo.library.cornell.edu/ns/0.1#AcademicDepartment> .

              OPTIONAL { ?deptUri rdfs:label ?deptLabel }
              }
              ORDER BY ?deptLabel
              LIMIT 2000

          ]]>
    </sparql:select>


        <ul>
            <c:forEach  items="${rs.rows}" var="dept">
                <li>
                    <c:url var="href" value="/entity"><c:param name="uri" value="${dept.deptUri}"/></c:url>
                    <a href="${href}">${dept.deptLabel.string}</a>
                </li>
            </c:forEach>
        </ul>

    </sparql:sparql>

</jsp:root>