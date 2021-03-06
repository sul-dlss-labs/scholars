<%@ page import="java.util.*"%>
<%@ page import="java.net.URLEncoder"%>
<%@ page import="edu.cornell.mannlib.vitro.webapp.beans.*" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %><%/* this odd thing points to something in web.xml */ %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page errorPage="/error.jsp"%>
<%
/***********************************************
 Display Search Results

 request.attributes:
 a Map object with the name "collatedResultsLists"
 collatedGroupNames
 request.parameters:
 None yet.

 Consider sticking < % = MiscWebUtils.getReqInfo(request) % > in the html output
 for debugging info.

 **********************************************/
 if (request.getAttribute("collatedResultsLists") == null) {
     String e = "searchBaisc.jsp expects that request attribute " +
             "'collatedResultsLists' be set to a Map of Lists of results to display.";
     throw new JspException(e);
 }
 if (request.getAttribute("collatedGroupNames") == null) {
     String e = "searchBaisc.jsp expects that request attribute "
             + "'collatedGroupNames' be set to a list of keys in collatedResultsLists.";
     throw new JspException(e);
 }

 int switchdivs = 0; // for making IDs for the plus-icon expansion divs
 
 edu.cornell.mannlib.vitro.webapp.beans.Portal portal = (Portal) request.getAttribute("portalBean");
 int portalId = portal.getPortalId();

 Map results = (Map) request.getAttribute("collatedResultsLists");

 out.println("<div id='content'><h2>Search Results</h2> <div class='contentsBrowseGroup'>");

 //do classgroup toc
 Iterator it = results.keySet().iterator();
 out.println("<div class='searchTOC'>Jump to results of type: ");
 while (it.hasNext()) {
     Object key = it.next();
     out.println(" <a href='#" + key.toString().replaceAll("\\W","") + "'>" + key + "</a> ");
 }
 out.println(" </div>");

 //get each ClassGroup
 it = results.keySet().iterator();
 while (it.hasNext()) {
     Object key = it.next();
     out.println("<h3 id='" + key.toString().replaceAll("\\W","") + "'>" + key + "</h3>");
     VClassGroup grp = (VClassGroup) results.get(key);

     //get each VClassList
     Iterator it2 = grp.iterator();
	 int countVclass = 0;
     while (it2.hasNext()) {
         VClassList vcl = (VClassList) it2.next();

         int resultSetSize = vcl.getEntities().size();
         int displayLimit = vcl.getDisplayLimit();
         if (resultSetSize - displayLimit == 1)
             ++displayLimit;
         boolean hiddenDivStarted = false;

         if (countVclass == 0)
         	out.println("<h4 class=\"first\">" + vcl.getName() + " (" + resultSetSize + ")</h4>");
         else
         	out.println("<h4>" + vcl.getName() + " (" + resultSetSize + ")</h4>");
         out.println("<ul>");

         ++countVclass;

         List ents = vcl.getEntities();
         if (ents == null || ents.size() == 0)
             out.println("<li>none</li>");
         else {
			//get each entity
			Iterator it3 = ents.iterator();
			int count = 0;
			while (it3.hasNext()) {
				Individual ent = (Individual) it3.next();
				++count;
				String escapedURIStr = "";
				try {
					escapedURIStr = URLEncoder.encode(ent.getURI(),"UTF-8");
				} catch (Exception e) {
					/*unsupported encoding?*/
				}
				out.println("<li>");
				out.println("<a href='"
                    		 + response.encodeURL(request.getContextPath()+"/entity?uri=" + escapedURIStr + "&amp;home=" + portalId)
                    		 + "'>" + ent.getName().replaceAll("&","&amp;") + "</a>");
                if (ent.getMoniker() != null && ent.getMoniker().length() > 0) {
                    out.println(" | " + ent.getMoniker().replaceAll("&","&amp;"));
				}
	            
            if (1==1) { // BJL temporarily re-enabling for a demo 
                // For now, custom search views just add additional information to the name and moniker
	            String searchViewPrefix = "/templates/search/";
                String customSearchView = null;
                for (VClass type : ent.getVClasses(true)) { // first get directly asserted class(es)
                    if (type!=null) {
                        customSearchView = type.getCustomSearchView();
                        if (customSearchView!=null && customSearchView.length()>0 ) {
                            // NOTE we are NOT putting "individualURL" in the request scope
                            // An included custom search view jsp can optionally implement a test for "individualURL"
                            // as a way to optionally render additional text as a link
                            // SEE entityList.jsp and searchViewWithTimekey.jsp as an example
                            request.setAttribute("individual",ent); %>
                            | <jsp:include page="<%=searchViewPrefix+type.getCustomSearchView()%>"/>
<%							request.removeAttribute("individual");
							// TODO: figure out which of the directly asserted classes should have precedence; for now, just take the 1st
							break; // have to break because otherwise customSearchView may get reset to null and trigger more evaluation
						}
                    }
                }
                if (customSearchView == null ) { // try inferred classes, too
                    for (VClass type : ent.getVClasses()) {
                        if (type!=null) {
                            customSearchView = type.getCustomSearchView();
                            if (customSearchView!=null && customSearchView.length()>0 ) {
                                // SEE NOTE just above
                            	request.setAttribute("individual",ent); %>
                                <jsp:include page="<%=searchViewPrefix+type.getCustomSearchView()%>"/>
<%								request.removeAttribute("individual");
								//TODO: figure out which of the inferred classes should have precedence; for now, just take the 1st
								break;
							}
                        }
                    }
                }
            } // end BJL disabling
                if (portal.getPortalId() == 6) { //show anchors in impact portal for submitter's name
                    if (ent.getAnchor() != null && ent.getAnchor().length() > 0) {
                        out.println(" | <span class='externalLink'>" + ent.getAnchor() + "</span>");
                    }
                }
/*     			if (portal.getAppName().equalsIgnoreCase("VIVO") || portal.getAppName().equalsIgnoreCase("Research")) {
                    //Medha's desired display
                    if (ent.getUrl() != null && ent.getUrl().length() > 0) {
                        out.println(" | <a class='externalLink' href='"
                        			+ response.encodeURL(ent.getUrl().replaceAll("&","&amp;")) + "'>"
                                 	+ ent.getAnchor().replaceAll("&","&amp;") + "</a>");
                     } else if (ent.getAnchor() != null && ent.getAnchor().length() > 0) {
                         out.println(" | <span class='externalLink'>" + ent.getAnchor().replaceAll("&","&amp;") + "</span>");
                     }
                     List linksList = ent.getLinksList();
                     if (linksList != null) {
                        Iterator lit = linksList.iterator();
                        while (lit.hasNext()) {
                            Link l = (Link) lit.next();
                             if (l.getUrl() != null && l.getUrl().length() > 0) {
                                out.println(" | <a class='externalLink' href='"
                                         	+ response.encodeURL(l.getUrl().replaceAll("&","&amp;")) + "'>"
                                         	+ l.getAnchor().replaceAll("&","&amp;") + "</a>");
                             } else {
                                out.println(" | <span class='externalLink'>" + l.getAnchor().replaceAll("&","&amp;") + "</span>");
                               }
                         }
                     }
				} else { //show the Google-like excerpt */                
                	if (ent.getDescription() != null && ent.getDescription().length() > 0) {
                        out.println("<div>" + ent.getDescription() + "</div>");
                 	}
             /*	} */
				out.println("</li>");
                int remaining = resultSetSize - count;
                if (count == displayLimit && remaining > 0) {
                	hiddenDivStarted = true; switchdivs++; %>
                  	</ul>
                  	<div style="color: black; cursor: pointer;" onclick="javascript:switchGroupDisplay('extra_ib<%=switchdivs%>','extraSw_ib<%=switchdivs%>','<%= response.encodeURL(portal.getThemeDir())%>site_icons')"
                         title="click to toggle additional entities on or off" class="navlinkblock" onmouseover="onMouseOverHeading(this)"
                         onmouseout="onMouseOutHeading(this)">                                   
                        <span class="resultsMoreSpan"><img src='<%= response.encodeURL( portal.getThemeDir() )+"site_icons/plus.gif"%>' id="extraSw_ib<%=switchdivs%>" alt="more results"/>
<%							out.println("<strong>"+remaining+" more</strong>"); %>
                        </span>
                  	</div>
<%					out.println("<div id='extra_ib"+switchdivs+"' style='display:none'>");
                  	out.println("  <ul>");
                }
                if ((count == resultSetSize) && (hiddenDivStarted)) {
                 	out.println("</ul></div> <!--  extra_ib"+switchdivs+"-->"); 
                }
			} // END while it3.hasNext()
            if (!hiddenDivStarted) {
                out.println("</ul>");
            }                                     
        } // END else have entities
    } // END while it2.hasNext()
} // END while it.hasNext()
%>
</div><!--contentsBrowseGroup-->
</div><!--content-->
