<%@ page import="com.hp.hpl.jena.rdf.model.Model" %>
<%@ page import="com.thoughtworks.xstream.XStream" %>
<%@ page import="com.thoughtworks.xstream.io.xml.DomDriver" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.controller.VitroRequest" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.dao.WebappDaoFactory" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditConfiguration" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.Field" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.SparqlEvaluate" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.web.MiscWebUtils" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>
<%@ taglib prefix="v" uri="http://vitro.mannlib.cornell.edu/vitro/tags" %>
<%
    String subjectUri   = request.getParameter("subjectUri");
    request.setAttribute("subjectUriJson", MiscWebUtils.escape(subjectUri));

    String objectUri = request.getParameter("objectUri");
    if( objectUri != null){
        System.out.println("found a objectUri in personTeacherOfSemesterCourse.jsp:" + objectUri);
        request.setAttribute("objectUriJson", MiscWebUtils.escape(objectUri));
        request.setAttribute("existingUris", ",\"newCourse\": \""+MiscWebUtils.escape(objectUri)+"\"");
    }else{
        System.out.println("NO objectUri found in personTeacherOfSemesterCourse.jsp");
        request.setAttribute("existingUris","");  //since its a new insert, no existing uri
    }

    request.getSession(true);
%>
<v:jsonset var="semesterClass">http://vivo.library.cornell.edu/ns/0.1#AcademicSemester</v:jsonset>
<v:jsonset var="buildingClass">http://vivo.library.cornell.edu/ns/0.1#Building</v:jsonset>

<v:jsonset var="monikerExisting" >
      PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
      SELECT ?moniker
      WHERE {  ?newCourse vitro:moniker ?moniker }
</v:jsonset>
<v:jsonset var="monikerAssertion" >
      @prefix vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>.
      ?newCourse vitro:moniker ?moniker .
</v:jsonset>

<v:jsonset var="courseNameExisting" >
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      SELECT ?name
      WHERE {  ?newCourse rdfs:label ?name }
</v:jsonset>
<v:jsonset var="courseNameAssertion" >
    @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>.
    ?newCourse rdfs:label ?name .
</v:jsonset>

<v:jsonset var="courseDescExisting" >
      PREFIX vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>
      SELECT ?desc
      WHERE {  ?newCourse vitro:description ?desc }
</v:jsonset>
<v:jsonset var="courseDescAssertion" >
      @prefix vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>.
      ?newCourse vitro:description ?courseDescription .
</v:jsonset>

<v:jsonset var="courseHeldInExisting" >
      PREFIX vivo:  <http://vivo.library.cornell.edu/ns/0.1#>
      SELECT ?extBuilding
      WHERE {  ?newCourse vivo:eventHeldInFacility ?extBuilding }
</v:jsonset>
<v:jsonset var="courseHeldInAssertion" >
      @prefix vivo:  <http://vivo.library.cornell.edu/ns/0.1#>.
    ?newCourse vivo:eventHeldInFacility ?extBuilding .
</v:jsonset>

<v:jsonset var="courseSemesterExisting" >
      PREFIX vivo:  <http://vivo.library.cornell.edu/ns/0.1#>
      SELECT ?extSem
      WHERE {  ?newCourse vivo:SemesterCourseOccursInSemester  ?extSem }
</v:jsonset>
<v:jsonset var="courseSemesterAssertion" >
    @preifx vivo:  <http://vivo.library.cornell.edu/ns/0.1#>.
    ?newCourse vivo:SemesterCourseOccursInSemester  ?extSem .
</v:jsonset>

<v:jsonset var="n3ForEdit"  >
    @prefix rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#>.
    @prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>.
    @prefix vivo: <http://vivo.library.cornell.edu/ns/0.1#>.
    @prefix vitro: <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#>.

    ?person vivo:PersonTeacherOfSemesterCourse  ?newCourse.
    ?newCourse vivo:SemesterCourseHasTeacherPerson ?person.

    ?newCourse rdf:type vivo:CornellSemesterCourse.

    ?newCourse
          vitro:moniker     ?moniker;
          vitro:description ?courseDescription;
          rdfs:label        ?courseName.

    ?newCourse
          vivo:eventHeldInFacility            ?heldIn;
          vivo:SemesterCourseOccursInSemester ?semester.
</v:jsonset>

<c:set var="editjson" scope="request">
  {
    "formUrl" : "${formUrl}",
    "editKey" : "${editKey}",

    "subjectUri"   : "${subjectUriJson}",
    "predicateUri" : "${predicateUriJson}",
    "objectUri"    : "${objectUriJson}",
    
    "n3required"    : [ "${n3ForEdit}" ],
    "n3optional"    : [ ],
    "newResources"  : { "newCourse" : "http://vivo.library.cornell.edu/ns/0.1#individual" },
    "urisInScope"   : {"person" : "${subjectUriJson}"
                        ${existingUris} },
    "literalsInScope": { },
    "urisOnForm"    : ["semester","heldIn"],
    "literalsOnForm":  [ "courseDescription", "courseName", "moniker" ],
    "objectVar"     : "newCourse",
    "sparqlForLiterals" : { },
    "sparqlForUris" : {  },
    "sparqlForExistingLiterals" : {
        "courseDescription" : "${courseDescExisting}",
        "courseName"        : "${courseNameExisting}",
        "moniker"        : "${monikerExisting}" },
    "sparqlForExistingUris" : {
        "heldIn" : "${courseHeldInExisting}",
        "semester" : "${courseSemesterExisting}"
    },
    "fields" : {
      "courseName" : {
         "newResource"      : "false",
         "validators"       : [ "nonempty" ],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [],
         "subjectUri"       : "${param.subjectUri}",
         "subjectClassUri"  : { },
         "predicateUri"     : "",
         "objectClassUri"   : "" ,
         "assertions"       : [ "${courseNameAssertion}" ]
      },
     "courseDescription" : {
         "newResource"      : "false",
         "validators"       : [ "nonempty" ],
         "optionsType"      : "UNDEFINED",
         "literalOptions"   : [],
         "subjectUri"       : "${param.subjectUri}",
         "subjectClassUri"  : { },
         "predicateUri"     : "",
         "objectClassUri"   : "" ,
         "assertions"       : [ "${courseDescAssertion}" ]
      },
      "moniker" : {
         "newResource"      : "false",
         "validators"       : [ ],
         "optionsType"      : "LITERALS",
         "literalOptions"   : ["1 credit course",
                               "2 credit course",
                               "3 credit course",
                               "4 credit course",
                               "5 credit course",
                               "6 credit course",
                               "1-3 credit course",
                               "1.5 credit course"],
         "subjectUri"       : "${param.subjectUri}",
         "subjectClassUri"  : { },
         "predicateUri"     : "${param.predicateUri}",
         "objectClassUri"   : { }  ,
         "assertions"       : [ "${monikerAssertion}" ]
      },
      "semester" : {
         "newResource"      : "false",
         "validators"       : [ ],
         "optionsType"      : "INDIVIDUALS_VIA_VCLASS",
         "literalOptions"   : [ ],
         "subjectUri"       : "${param.subjectUri}",
         "subjectClassUri"  : { },
         "predicateUri"     : "${param.predicateUri}",
         "objectClassUri"   : "${semesterClass}"   ,
         "assertions"       : [ "${courseSemesterAssertion}"]
      },
      "heldIn" : {
         "newResource"      : "false",
         "validators"       : [ ],
         "optionsType"      : "INDIVIDUALS_VIA_VCLASS",
         "literalOptions"   : ["leave blank"],
         "subjectUri"       : "${param.subjectUri}",
         "subjectClassUri"  : { },
         "predicateUri"     : "${param.predicateUri}",
         "objectClassUri"   : "${buildingClass}" ,
         "assertions"       : [ "${courseHeldInAssertion}" ]
      }
    }
  }
</c:set>
<%
    EditConfiguration editConfig = EditConfiguration.getConfigFromSession(session,request);
    if( editConfig == null ){
        editConfig = new EditConfiguration((String)request.getAttribute("editjson"));
        EditConfiguration.putConfigInSession(editConfig, session);

        System.out.println("******************* JUST PUT EDITCONFIG IN SESSION ***********************");
        dump("editConfig",editConfig);
    }      else {
        System.out.println("WARNING: reusing editConfig from session, this should only happen whe we are doing a update or a re-edit after a submit");
    }
    if( objectUri != null ){
        System.out.println("found objectUri: " + objectUri);

        Model model =  (Model)application.getAttribute("jenaOntModel");
        prepareForEditOfExisting(editConfig, model, request, session);
        editConfig.getUrisInScope().put("newCourse",objectUri); //makes sure we reuse objUri, maybe this should be done by prepareForEditOfExisting?
         System.out.println("******************* SETUP For Update ***********************");
        dump("editConfig",editConfig);
    }

    /* get some data to make the form more useful */
    VitroRequest vreq = new VitroRequest(request);
    WebappDaoFactory wdf = vreq.getWebappDaoFactory();

    Individual subject = wdf.getIndividualDao().getIndividualByURI(subjectUri);
    if( subject == null ) throw new Error("could not find subject '" + subjectUri + "'");
    request.setAttribute("subjectName",subject.getName());

    String submitLabel=""; // don't put local variables into the request
    /* title is used by pre and post form fragments */
    if (objectUri != null) {
    	request.setAttribute("title", "Edit course for " + subject.getName());
        submitLabel = "Save changes";
    } else {
        request.setAttribute("title","Create a new course for " + subject.getName());
        submitLabel = "Create new course";
    }

    System.out.println("******************* About to do form html ***********************");
        dump("editConfig",editConfig)   ;
%>

<jsp:include page="${preForm}"/>
<h1>${title}</h1>
<form action="<c:url value="/edit/processRdfForm2.jsp"/>" >
    <v:input type="text" label="course title" id="courseName" size="60"/>
    <v:input type="checkbox" label="semester" id="semester"/>
    <v:input type="select" label="held in location" id="heldIn"/>
    <v:input type="radio" label="credit value" id="moniker"/>
    <v:input type="textarea" label="course description" id="courseDescription" rows="5"/>
    <v:input type="submit" id="submit" value="<%=submitLabel%>" cancel="${param.subjectUri}"/>
</form>

<jsp:include page="${postForm}"/>


 <%!/* copy of method in personAuthorOf.jsp, need to find better place fo these to live. */
/*
tasks of this method:
add objectUri to scope under specified var name
run sparqlForExisting URIs and Literals, add to scope
for each field:
    sub values in to the assertion strings and save as retractions,
    what else?
 */
  private void prepareForEditOfExisting( EditConfiguration editConfig, Model model, ServletRequest request, HttpSession session){
      //add objectUri to urisInScope
      editConfig.getUrisInScope().put(editConfig.getObjectVar(), request.getParameter("objectUri"));

      // run queries for existing values
      SparqlEvaluate sparqlEval = new SparqlEvaluate(model);
      Map<String,String> varsToUris =
              sparqlEval.sparqlEvaluateToUris(editConfig.getSparqlForExistingUris(),editConfig.getUrisInScope(),editConfig.getLiteralsInScope());
      editConfig.getUrisInScope().putAll( varsToUris );

      Map<String,String> varsToLiterals =
              sparqlEval.sparqlEvaluateToLiterals(editConfig.getSparqlForExistingLiterals(),editConfig.getUrisInScope(),editConfig.getLiteralsInScope());
      editConfig.getLiteralsInScope().putAll(varsToLiterals);

      //build retraction N3 for each Field
      for(String var : editConfig.getFields().keySet() ){
          Field field = editConfig.getField(var);
          List<String> retractions = null;
          retractions = EditConfiguration.subInLiterals(editConfig.getLiteralsInScope(),field.getAssertions());
          retractions = EditConfiguration.subInUris(editConfig.getUrisInScope(), retractions);
          field.setRetractions(retractions);
      }
}%>

<%!
    private void dump(String name, Object fff){
        XStream xstream = new XStream(new DomDriver());
        System.out.println( "*******************************************************************" );
        System.out.println( name );
        System.out.println(xstream.toXML( fff ));
    }
%>
