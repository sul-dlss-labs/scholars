<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Template for displaying paged search results -->
<div class="row scholars-row">
<div id="biscuit-container" class="col-sm-12 scholars-container">

<h2 class="searchResultsHeader">
<#escape x as x?html>
    ${i18n().search_results_for} '${querytext}'
    <#if classGroupName?has_content>${i18n().limited_to_type} '${classGroupName}'</#if>
    <#if typeName?has_content>${i18n().limited_to_type} '${typeName}'</#if>
</#escape>
<script type="text/javascript">
	var url = window.location.toString();	
	if (url.indexOf("?") == -1){
		var queryText = 'querytext=${querytext}';
	} else {
		var urlArray = url.split("?");
		var queryText = urlArray[1];
	}
	
	var urlsBase = '${urls.base}';
</script>

	<img id="downloadIcon" src="images/download-icon.png" alt="Download Results" title="Download Results" />
</h2>

<span id="searchHelp"><a href="${urls.base}/searchHelp" title="${i18n().search_help}">${i18n().not_expected_results}</a></span>
<div class="contentsBrowseGroup">

    <#-- Refinement links -->
    <#if classGroupLinks?has_content>
        <div class="searchTOC">
            <h4>${i18n().display_only}</h4>           
            <ul>           
            <#list classGroupLinks as link>
                <li><a href="${link.url}" title="${i18n().class_group_link}">${link.text}</a><span>(${link.count})</span></li>
            </#list>
            </ul>           
        </div>
    </#if>

    <#if classLinks?has_content>
        <div class="searchTOC">
            <#if classGroupName?has_content>
                <h4>${i18n().limit} ${classGroupName} to</h4>
            <#else>
                <h4>${i18n().limit_to}</h4>
            </#if>
            <ul>           
            <#list classLinks as link>
                <li><a href="${link.url}" title="${i18n().class_link}">${link.text}</a><span>(${link.count})</span></li>
            </#list>
            </ul>
        </div>
    </#if>

    <#-- Search results -->
    <ul class="searchhits">
        <#list individuals as individual>
            <li>                        
            	<@shortView uri=individual.uri viewContext="search" />
            </li>
        </#list>
    </ul>
    

    <#-- Paging controls -->
    <#if (pagingLinks?size > 0)>
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
				  '<link rel="stylesheet" href="${urls.base}/css/jquery_plugins/jquery.qtip.min.css" />',
  				  '<link rel="stylesheet" href="${urls.base}/css/search.css" />')}

${headScripts.add('<script src="//code.jquery.com/ui/1.10.3/jquery-ui.js"></script>',
				  '<script type="text/javascript" src="${urls.base}/js/jquery_plugins/qtip/jquery.qtip-3.0.3.min.js"></script>',
                  '<script type="text/javascript" src="${urls.base}/js/tiny_mce/tiny_mce.js"></script>'
                  )}

${scripts.add('<script type="text/javascript" src="${urls.base}/js/searchDownload.js"></script>')}
