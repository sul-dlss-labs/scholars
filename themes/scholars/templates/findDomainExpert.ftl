<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Template for displaying paged search results -->
<div class="row scholars-row">
<div id="biscuit-container" class="col-sm-12 scholars-container">

<h2 class="searchResultsHeader">
<#escape x as x?html>
    ${i18n().search_results_for} '${querytext!""}'
    <#if classGroupName?has_content>${i18n().limited_to_type} '${classGroupName}'</#if>
    <#if typeName?has_content>${i18n().limited_to_type} '${typeName}'</#if>
</#escape>
<script type="text/javascript">
	var url = window.location.toString();	
	if (url.indexOf("?") == -1){
		var queryText = 'querytext=${querytext!""}';
	} else {
		var urlArray = url.split("?");
		var queryText = urlArray[1];
	}
	
	var urlsBase = '${urls.base}';
</script>

</h2>

<div class="contentsBrowseGroup row fff-bkg" style="margin-bottom:20px">
  <div class="col-md-12">
    <fieldset>
        <legend>${i18n().search_form}</legend>

		<form id="results-search-form" action="${urls.base}/domainExpert" name="search" role="search" accept-charset="UTF-8" method="POST"> 
			<input id="de-search-vclass" type="hidden" name="vclassId" value="http://xmlns.com/foaf/0.1/Person" />
			<input id="de-search-input" type="text" name="querytext" value="${querytext!}" style="width:300px" />
			<input id="results-search-submit" type="submit" action="${urls.base}/domainExpert?origin=homepage" value="Go" />
			<div class="results-search-radio-container">
				<#assign qType = querytype!"subject" />
				<input type="radio" name="querytype" value="subject" <#if qType == "subject">checked</#if>> by subject or keyword
	   			<input id="by-name-radio" type="radio" name="querytype" value="name" <#if qType == "name">checked</#if>> by name
	  		</div>
		</form>
		<#-- we need these values for the ajax call that happens on scrolling and faceting. can't use the values in the form -->
		<#-- because, though unlikely, users could clear the query text or change the query type, change their mind and      -->
		<#-- continue scrolling or clicking facets. Deal with it, Hudson.                                                    -->
		<input id="hidden-querytext" type="hidden" name="q-text" value="${querytext}" />
		<input id="hidden-querytype" type="hidden" name="q-type" value="${querytype}" />
    </fieldset>
  </div>
</div>
<div class="contentsBrowseGroup row fff-bkg">
  <div id="facet-container" class="col-md-3">

    <#if classLinks?has_content>
        <div class="panel panel-default selection-list" >
                <div class="panel-heading" style="line-height:18px;font-size:16px">Position</div>
            <#list classLinks as link>
                <div class="panel-body" style="padding:10px;line-height:16px;font-size:14px">
					<#-- if link.text != "Person" -->
						<#assign vclassid = link.url[link.url?index_of("vclassId=")+9..] />
						<input type="checkbox" class="type-checkbox" data-vclassid="${vclassid?url}" /> ${link.text}<span> (${link.count})</span>
					<#-- if -->
				</div>
            </#list>
        </div>
<a href="/scholars/domainExpert?ajax=1&querytext=Potassium&amp;querytype=subject&amp;vclassId=http%3A%2F%2Fvivoweb.org%2Fontology%2Fcore%23FacultyMember" title="class link">Faculty Member</a>
    </#if>
  </div>
  <div id="results-container" class="col-md-8">
    <#-- Search results -->
	<#if individuals?? >
    <ul class="searchhits">
			<#list individuals as indy>
				${indy!}
			</#list>
			<#assign adjPage = (currentPage + 1) />
			<#assign adjStartIndex =  (adjPage * hitsPerPage) />
			<#if ( hitCount > adjStartIndex ) >
				<li id="scroll-control" data-start-index="${adjStartIndex}" data-current-page="${adjPage}">yowzah</li>
			</#if>
			<script>
				console.log("INITIAL START INDEX = " + "${adjStartIndex}");
				console.log("INITIAL PAGE ADJ = " + "${adjPage}");
			</script>
    </ul>
	</#if>
  </div>  
</div>
    <#-- Paging controls -->
    <#if pagingLinks?? && (pagingLinks?size > 0)>
        <div class="searchpages">
            Pages: 
            <#if prevPage??><a class="prev" href="${prevPage}" title="${i18n().previous}">${i18n().previous}</a></#if>
            <#list pagingLinks as link>
                <#if link.url??>
                    <a href="${link.url}" title="${i18n().page_link}">${link.text}</a>
                <#else>
                    <span>${link.text}</span> <#-- no link if current page -->
                </#if>
            </#list>
            <#if nextPage??><a class="next" href="${nextPage}" title="${i18n().next_capitalized}">${i18n().next_capitalized}</a></#if>
        </div>
    </#if>
    <br />

</div> <!-- end contentsBrowseGroup -->
  </div> <!--! end of #container -->
</div> <!-- end of row -->

${stylesheets.add('<link rel="stylesheet" href="//code.jquery.com/ui/1.10.3/themes/smoothness/jquery-ui.css" />',
  				  '<link rel="stylesheet" href="${urls.base}/css/search.css" />')}

${scripts.add('<script type="text/javascript" src="${urls.base}/js/searchDownload.js"></script>')}
<script>
var baseUrl = "${urls.base}";
var concepts = [
<#if conceptsDG?has_content>
    <#list conceptsDG as resultRow>"${resultRow["label"]}"<#if (resultRow_has_next)>,</#if></#list>       
<#else>
	Nopers
</#if>
];
</script>
${scripts.add('<script type="text/javascript" src="${urls.base}/js/findDomainExpert.js"></script>',
			  '<script type="text/javascript" src="${urls.base}/js/jquery_plugins/jquery.scrollTo-min.js"></script>')}
<#-- @dumpAll/ -->
