<c:set var="objIndiv" value="${requestScope.edObjIndiv}"/>
<c:set var="datapropMap" value="${objIndiv.dataPropertyMap}"/>
<c:set var="gradyear" value="${datapropMap['http://vivo.library.cornell.edu/ns/0.1#yearDegreeAwarded'].dataPropertyStatements[0].data}"/>
<c:set var="degree"   value="${datapropMap['http://vivo.library.cornell.edu/ns/0.1#preferredDegreeAbbreviation'].dataPropertyStatements[0].data}"/>
<c:set var="institution" value="${datapropMap['http://vivo.library.cornell.edu/ns/0.1#institutionAwardingDegree'].dataPropertyStatements[0].data}"/>
<c:set var="major" value="${datapropMap['http://vivo.library.cornell.edu/ns/0.1#majorFieldOfDegree'].dataPropertyStatements[0].data}"/>
${gradyear} : ${degree}, ${institution}, ${major} 