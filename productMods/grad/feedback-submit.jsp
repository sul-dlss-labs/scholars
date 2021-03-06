<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/mailer-1.1" prefix="mt" %>
<%@ page import="org.joda.time.DateTime"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.text.DateFormat"%>
<%@ page import="java.text.SimpleDateFormat"%>

<jsp:include page="header.jsp">
    <jsp:param name="bodyID" value="feedback"/>
    <jsp:param name="titleText" value="Feedback | Cornell University"/>
</jsp:include>

<%  DateTime now = new DateTime();
    request.setAttribute("now", "\"" + now.toDateTime().toString() + "\"" );

    DateFormat dateformat = new SimpleDateFormat("yyyy-MM-dd-HH:mm:ss");
    java.util.Date date = new java.util.Date();
    String d = dateformat.format(date); %>

<div id="contentWrap">
	<div id="content">

<%-- get the captcha status from the session --%>
<c:set var="captchaStatus">
    <% String status = session.getAttribute("status").toString(); %>
    <%=status%>
</c:set>

<%-- if all is well, grab the keys from the session --%>
<c:if test="${captchaStatus=='ok'}">
    <% String captchaKey = session.getAttribute("captcha").toString(); 
       String requestedValue = request.getParameter("captcha"); %>
    <c:set var="captchaKey" value="<%=captchaKey%>"/> <%-- key set by captcha.jsp --%>
    <c:set var="requestKey" value="<%=requestedValue%>"/> <%-- key set by the user sending feedback --%>
</c:if>

        <%-- proceed with mailing feedback if: the keys match OR there's a problem loading captcha.jsp --%>
        <c:if test="${(captchaKey==requestKey) || (captchaStatus=='error')}">
            
            <%-- wipe out the session's key so that page reloads won't re-submit the form --%>
            <% session.setAttribute("captcha","xxxxxx"); %>
        
            <h2>Got it!</h2>
            <p>Thanks for taking the time to send us feedback.</p>

            <%-- build the email body here before sending --%>
            <fmt:parseDate var="now" value="<%=d%>" pattern="yyyy-MM-dd-HH:mm:ss" />
            <fmt:formatDate var="dateTime" value="${now}" type="both" pattern="EEEE, MMMM d @ hh:mm a"  />
            
            <c:if test="${!empty param.name}">
                <c:set var="fbName">${param.name}</c:set>
            </c:if>
            <c:if test="${empty param.name}">
                <c:set var="fbName">not provided</c:set>
            </c:if>

            
            <c:if test="${!empty param.email}">
                <c:set var="fbEmail">${param.email}</c:set>
            </c:if>
            <c:if test="${empty param.email}">
                <c:set var="fbEmail">not provided</c:set>
            </c:if>
            
            
            <c:if test="${!empty param.message}">
                <c:set var="fbMessage">${param.message}</c:set>
            </c:if>
            
            <c:choose>
                <c:when test="${param.type == 'content'}">
                    <c:set var="fbRegarding" value="content"/>
                </c:when>
                <c:when test="${param.type == 'technical'}">
                    <c:set var="fbRegarding" value="technical issues"/>
                </c:when>
                <c:when test="${param.type == 'other'}">
                    <c:set var="fbRegarding" value="other"/>
                </c:when>
            </c:choose>
            
<c:set var="emailBody">
Received: ${dateTime}
From: ${fbName}
Email: ${fbEmail}

Message:
${fbMessage}
</c:set>
            <mt:mail>
                <c:choose>
                    <c:when test="${param.type == 'content'}">
                        <mt:subject>Graduate Programs in the Life Sciences - Feedback Received (content-related)</mt:subject>
                    </c:when>
                    <c:when test="${param.type == 'technical'}">
                        <mt:subject>Graduate Programs in the Life Sciences - Feedback Received (technical issues)</mt:subject>
                    </c:when>
                    <c:when test="${param.type == 'other'}">
                        <mt:subject>Graduate Programs in the Life Sciences - Feedback Received (other)</mt:subject>
                    </c:when>
                </c:choose>
                
                <mt:setrecipient type="to">vivo-contact-l@cornell.edu</mt:setrecipient>
                <mt:setrecipient type="cc">mw542@cornell.edu</mt:setrecipient>
                
                <mt:from>site-feedback@gradeducation.lifesciences.cornell.edu</mt:from>

                <mt:message>${emailBody}</mt:message>
                
                <mt:send>
                    <p>The following errors occured<br/><br/>
                    <mt:error id="err">
                        <jsp:getProperty name="err" property="error"/><br/>
                    </mt:error>
                    <br/>Please back up a page, fix the error and resubmit.</p>
                </mt:send>

            </mt:mail>
        
            </c:if>
        
            <%-- wrong key entered but the captcha is loading properly --%>
            <c:if test="${(captchaKey != requestKey) && (captchaStatus=='ok')}">
               <h2>Sorry, there was a problem...</h2>
               <p>Either the code you entered was incorrect or you tried to submit the form more than once. Hit your back button to try again.</p>
            </c:if>
            
            <%-- mail the following recipient and notify them of a problem with the captcha --%>
            <c:if test="${captchaStatus=='error'}">
                <mt:mail>
                    <mt:setrecipient type="to">mw542@cornell.edu</mt:setrecipient>
                    <mt:setrecipient type="cc">nick.cappadona@cornell.edu</mt:setrecipient>
                    <mt:subject>Grad Site Notice: captcha on feedback form is broken</mt:subject>
                    <mt:from>site-feedback@gradeducation.lifesciences.cornell.edu</mt:from>
                    <mt:message>
                    *** This is an automated message ***
                    Tomcat could not load the captcha JSP when a user submitted the feedback form
                    </mt:message>
                    <mt:send>
                        <p>The following errors occured<br/><br/>
                        <mt:error id="err">
                            <jsp:getProperty name="err" property="error"/><br/>
                        </mt:error>
                        </p>
                    </mt:send>
                </mt:mail>
            </c:if>

        
	</div> <!-- content -->
</div> <!-- contentWrap -->

<hr/>
<jsp:include page="footer.jsp" />
