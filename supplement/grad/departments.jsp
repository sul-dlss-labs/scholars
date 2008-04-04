<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<jsp:include page="header.jsp">
    <jsp:param name="bodyID" value="departments"/>
</jsp:include>
        
        <div id="contentWrap">
            <div id="content" class="sevenUnit">
         
            <c:choose>
                <c:when test="${not empty param.uri}">
                    <c:import url="/entity">
                        <c:param name="portal" value="1" />
                        <c:param name="uri" value="${param.uri}" />
                        <c:param name="view" value="grad/templates/deptEntity.jsp" />
                    </c:import>
                </c:when>
            
                <c:otherwise>
                    <jsp:include page="part/alldepartments.jsp" />
                </c:otherwise>
            </c:choose>
                    
            </div><!-- content -->
        
        </div> <!-- contentWrap -->

<jsp:include page="footer.jsp" />