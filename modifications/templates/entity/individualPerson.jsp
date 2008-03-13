<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.Individual" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.VClass" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditConfiguration" %>
<%@ page import="edu.cornell.mannlib.vitro.webapp.edit.n3editing.EditSubmission" %>
<%@ page import="java.util.List" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ page errorPage="/error.jsp"%>
<%  /***********************************************
         Display a single Entity in the most basic fashion.
         
         request.attributes:
         an Entity object with the name "entity" 
         
         request.parameters:
         None yet.
         
          Consider sticking < % = MiscWebUtils.getReqInfo(request) % > in the html output
          for debugging info.
                 
         bdc34 2006-01-22 created        
        **********************************************/                           
        Individual entity = (Individual)request.getAttribute("entity");
        if (entity == null){
            String e="entityBasic.jsp expects that request attribute 'entity' be set to the Entity object to display.";
            throw new JspException(e);
        }
 %>
<c:set var='imageDir' value='images' />
<%
    //here we build up the url for the larger image.
    String imageUrl = null;
    if (entity.getImageFile() != null && 
        entity.getImageFile().indexOf("http:")==0) {
        imageUrl =  entity.getImageFile();
    } else {
        imageUrl = response.encodeURL( "images/" + entity.getImageFile() );                     
    }

    //anytime we are at an entity page we shouldn't have an editing config or submission
    session.removeAttribute("editjson");
    EditConfiguration.clearAllConfigsInSession(session);
    EditSubmission.clearAllEditSubmissionsInSession(session);
%>
<c:set var='entity' value='${requestScope.entity}'/><%/* just moving this into page scope for easy use */ %>
<c:set var='entityPropsListJsp' value='/entityPropList'/>
<c:set var='portal' value='${currentPortalId}'/>
<c:set var='portalBean' value='${currentPortal}'/>
<c:set var="themeDir"><c:out value="${portalBean.themeDir}" default="themes/vivo/"/></c:set>

    <jsp:include page="/${themeDir}jsp/dashboard.jsp" flush="true" />

    <div id="content" class="person">
        <jsp:include page="entityAdmin.jsp"/>
        
        <div class='contents entity'>
                <h2>${entity.name}</h2> 
                <c:choose>
                    <c:when test="${!empty entity.moniker}">
                        <em class="moniker">${entity.moniker}</em>
                    </c:when>
                    <c:otherwise>
                        <em class="moniker">${vclassName}</em>
                    </c:otherwise>
                </c:choose>
                
                <ul id="profileCats">
                    <li><a id="currentCat" href="#" title="Cornell Affiliations">Affiliations</a></li>
                    <li><a class="miles" href="#" title="Research, Practice &amp; Professional Activites">Research</a></li>
                    <li><a href="#" title="Instruction &amp; Advising">Teaching</a></li>
                    <li><a href="#" title="Outreach &amp; Service">Service</a></li>
                    <li><a href="#" title="Biography &amp; Background">Background</a></li>
                    <li><a href="#" title="Publications &amp; Other Works">Publications</a></li>
                    <li><a href="#" title="International Expertise &amp; Activites">International</a></li>
                </ul>

                <% /* CALS Impact portal wants data properties first */ %>
                <c:choose>
                    <c:when test="${portalBean.appName eq 'CALS Impact'}">
                        <jsp:include page="/${entityDatapropsListJsp}"/> <% /*here we import the datatype properties for th
                        e entity */ %>
                        <c:import url="${entityPropsListJsp}" />  <% /* here we import the properties for the entity */ %>
                    </c:when>
                    <c:otherwise>
                        <c:import url="${entityPropsListJsp}" />  <% /* here we import the properties for the entity */ %>  
                        <jsp:include page="/${entityDatapropsListJsp}"/> <% /*here we import the datatype properties for the entity */ %>
                    </c:otherwise>
                </c:choose>

                <div class='description'>
                  ${entity.blurb}
                </div>
                <div class='description'>
                  ${entity.description}
                </div>
                <c:if test="${(!empty entity.citation) && (empty entity.imageThumb)}">
                <div class="citation">
                    ${entity.citation}
                </div>
                </c:if>
                <c:if test="${!empty entity.keywordString}">
                <div class="citation">
                    Keywords: ${entity.keywordString}
                </div>
                </c:if>
                ${requestScope.servletButtons} 
        </div>
    </div> <!-- content -->
    <div class="clear"></div>