<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#-- Individual profile page template for foaf:Person individuals -->

<script>
$(document).ready(function() {
});
</script>

<!--[if IE 7]>
<link rel="stylesheet" href="${urls.base}/css/individual/ie7-standard-view.css" />
<![endif]-->
<#include "individual-setup.ftl">
<#import "individual-qrCodeGenerator.ftl" as qr>
<#import "lib-vivo-properties.ftl" as vp>
<#--Number of labels present-->
<#if !labelCount??>
    <#assign labelCount = 0 >
</#if>
<#assign nameForOtherGroup = "${i18n().other}">
<#--Number of available locales-->
<#if !localesCount??>
	<#assign localesCount = 1>
</#if>
<#--Number of distinct languages represented, with no language tag counting as a language, across labels-->
<#if !languageCount??>
	<#assign languageCount = 1>
</#if>	
<#assign emailProp = propertyGroups.pullProperty("http://purl.obolibrary.org/obo/ARG_2000028","http://www.w3.org/2006/vcard/ns#Email")!>
<#assign email = "" />
<#if emailProp?has_content && emailProp.statements?has_content>
	<#assign email = emailProp.statements?first/>
</#if>
<#assign isAuthor = p.hasVisualizationStatements(propertyGroups, "${core}relatedBy", "${core}Authorship") />
<#assign coAuthorVisUrl = individual.coAuthorVisUrl()>
<#assign obo_RO53 = "http://purl.obolibrary.org/obo/RO_0000053">
<#assign isInvestigator = ( p.hasVisualizationStatements(propertyGroups, "${obo_RO53}", "${core}InvestigatorRole") ||
                            p.hasVisualizationStatements(propertyGroups, "${obo_RO53}", "${core}PrincipalInvestigatorRole") || 
                            p.hasVisualizationStatements(propertyGroups, "${obo_RO53}", "${core}CoPrincipalInvestigatorRole") ) >
<#assign coInvestigatorVisUrl = individual.coInvestigatorVisUrl()>
<#assign visRequestingTemplate = "foaf-person-2column">
<#assign publicationsProp = propertyGroups.pullProperty("${core}relatedBy", "${core}Authorship")!>
<#if publicationsProp?has_content> 
    <#assign publications>
		<@p.objectProperty publicationsProp editable />
	</#assign>
</#if>
<#assign grantsPIProp = propertyGroups.pullProperty("http://purl.obolibrary.org/obo/RO_0000053", "${core}PrincipalInvestigatorRole")!>
<#if grantsPIProp?has_content> 
    <#assign grantsPI>
		<@p.objectProperty grantsPIProp editable />
	</#assign>
</#if>
<#assign grantsCOPIProp = propertyGroups.pullProperty("http://purl.obolibrary.org/obo/RO_0000053", "${core}CoPrincipalInvestigatorRole")!>
<#if grantsCOPIProp?has_content> 
    <#assign grantsCOPI>
		<@p.objectProperty grantsCOPIProp editable />
	</#assign>
</#if>
<#if subjectAreas?has_content>
  <#assign subjectAreaList>
	<article class="property" role="article">
		<h3 class="burnt-orange">Journal Subject Areas</h3>
		<ul id="journal-subject-area-list" class="property-list" role="list">
			<#list subjectAreas as subject>
				<li role="listitem">		
					<a href="${urls.base}/individual?uri=${subject.subjectArea!}">${subject.subjectAreaLabel!}</a>
				</li>
			</#list>
		</ul>
	</article>
  </#assign>
</#if>
<#assign webpageProp = propertyGroups.pullProperty("http://purl.obolibrary.org/obo/ARG_2000028","http://www.w3.org/2006/vcard/ns#URL")!>
<#if webpageProp?has_content && webpageProp.statements?has_content> 
    <#assign webpageStmt = webpageProp.statements?first />
	<#assign webpageLabel = webpageStmt.label! />
	<#assign webpageUrl = webpageStmt.url! />
</#if>
<#assign optIn = "pending" />
<#assign skippedDept = false />
<#assign collegeOptIn = "${orgOptIn?first.collegeOptIn!}" />
<#assign departmentOptIn = "${orgOptIn?first.departmentOptIn!}" />
<#assign optInProp = propertyGroups.pullProperty("http://scholars.cornell.edu/ontology/vivoc.owl#isOptIn")!>
<#if optInProp?has_content && optInProp.statements?has_content>
	<#assign optInStmt = optInProp.statements?first!/>
	<#assign optIn = optInStmt.value!"pending" />
<#elseif departmentOptIn?has_content>
	<#if departmentOptIn?contains("true")>
		<#assign optIn = "true" />
	<#elseif departmentOptIn?contains("false")>
		<#assign optIn = "false" />
	<#else>
		<#assign skippedDept = true />
	</#if>
</#if>
<#if skippedDept && collegeOptIn?has_content>
	<#if collegeOptIn?contains("true")>
		<#assign optIn = "true" />
	<#elseif collegeOptIn?contains("false")>
		<#assign optIn = "false" />
	</#if>
</#if>

<#-- for some reason pullProperty was only working when logged in, and even with the display level set to public. Weird! So using datagetter-->
<#if orcidID?has_content> 
	<#assign theOrcidId = orcidID?first.orcidId! />
</#if>

<#-- Image -->           
<#assign individualImage>
    <@p.image individual=individual 
              propertyGroups=propertyGroups 
              namespaces=namespaces 
              editable=editable 
              showPlaceholder="always" />
</#assign>
<#assign hasImage = true />
<#if ( individualImage?contains('<img class="individual-photo"') )>
    <#assign infoClass = 'withThumb'/>
</#if>
<#if ( individualImage?contains('placeholder') && !editable )>
    <#assign infoClass = ''/>
	<#assign hasImage = false />
</#if>

<#-- The row1 div contains the top portion of the profile page: name, photo, icon controls, positions -->
<div id="row1" class="row scholars-row">
<div itemscope itemtype="http://schema.org/Person" class="col-sm-12 col-md-12 col-lg-12 scholars-container" id="foafPersonMainColumn">
<section id="share-contact" role="region" <#if !hasImage >style="display:none"</#if>> 

    <div id="photo-wrapper" >${individualImage}</div>
    
    <#-- include "individual-visualizationFoafPerson.ftl" -->
</section> <!-- end share-contact -->
<section id="individual-info" class="scholars-person-info ${infoClass!}" role="region">
    <#include "individual-adminPanel.ftl">
    <header>
        <#if relatedSubject??>
            <h2>${relatedSubject.relatingPredicateDomainPublic} ${i18n().for} ${relatedSubject.name}</h2>
            <p><a href="${relatedSubject.url}" title="${i18n().return_to(relatedSubject.name)}">&larr; ${i18n().return_to(relatedSubject.name)}</a></p>
        <#else>  
            <h1 itemprop="name" class="vcard foaf-person fn"> 
                <#-- Label -->
                <@p.label individual editable labelCount localesCount/>
            </h1>
        </#if>    
		<div id="foaf-person-icons">
			<#include "individual-iconControls.ftl" />
		</div>
		<h2 id="page-heading-break">  </h2>
    	<#include "individual-positions.ftl">
    </header>
	</section>
</div> <!-- foafPersonMainColumn -->
</div> <!-- row1 -->


<#if isAuthor || isInvestigator>
<#-- The row2 div contains the visualization section and the publication and grants lists -->
<div id="row2" class="row scholars-row foaf-person-row2">

<#if optIn == "true" || optIn == "pending" >
<div id="visualization-column" class="col-sm-3 col-md-3 col-lg-3 scholars-container">
 	<#if isAuthor >
		<div id="word_cloud_icon_holder" style="display:none">
		    <a href="#" id="word_cloud_trigger" onclick="javascript:_paq.push(['trackEvent', 'Visualization', 'Person', 'Research-Keywords']);">
		    	<img id="vizIcon" width="152px" src="${urls.base}/themes/scholars/images/wordcloud-icon-hztl.png"/>
		    </a>
			<p>Research Keywords</p>
		</div>
 		<div>
 			<a href="${coAuthorVisUrl}" onclick="javascript:_paq.push(['trackEvent', 'Visualization', 'Person', 'Co-authors']);">
 				<img id="vizIcon" width="120px" src="${urls.base}/themes/scholars/images/co-authors.png"/>
 			</a>
 			<p>Co-authors</p>
 		</div>
 	</#if>
 	<#if isInvestigator >
 		<div>
 			<a href="${coInvestigatorVisUrl}" onclick="javascript:_paq.push(['trackEvent', 'Visualization', 'Person', 'Co-investigtors']);">
 				<img id="vizIcon" width="120px" src="${urls.base}/themes/scholars/images/co-investigators.png"/>
 			</a>
 			<p>Co-investigators</p>
 		</div>
 	</#if>
</div>
<div id="foafPersonSpacer" class="col-sm-1 col-md-1 col-lg-1"></div>
<div id="foafPersonTabs" class="col-sm-8 col-md-8 col-lg-8  scholars-container">
	<div id="scholars-tabs-container">
	  <#if optIn == "true" >
	  <ul id="scholars-tabs">
	    <#if isAuthor ><li><a href="#tabs-1" onclick="javascript:_paq.push(['trackEvent', 'Tab', 'Person', 'Publications']);">Publications</a></li></#if>
	    <#if isInvestigator ><li><a href="#tabs-2" onclick="javascript:_paq.push(['trackEvent', 'Tab', 'Person', 'Grants']);">Grants</a></li></#if>
	  </ul>
	  <#if isAuthor >
		  <div id="tabs-1" class="tab-content">
			<article class="property" role="article">
			<#if subjectAreaList?has_content>
				<a id="subject-area-link" href="#" class="jqModal" onclick="javascript:_paq.push(['trackEvent', 'Link', 'Person', 'Subject-Areas']);">Subject Areas</a>
			</#if>
		    <ul id="individual-publications" class="property-list" role="list" >
		    	${publications!}
			</ul>
			</article>	
		  </div>
	  </#if>
	  <#if isInvestigator >
		  <div id="tabs-2"  class="tab-content">
		    <article class="property" role="article">
		    <ul id="individual-grants-pi" class="property-list" role="list" >
				<li class="subclass" role="listitem">
				  <#if grantsPI?has_content >
					<h3>Principal Investigator</h3>
				    <ul class="subclass-property-list">
		    			${grantsPI!}
					</ul>
				  </#if>
				  <#if grantsCOPI?has_content >
					<h3>Co-principal Investigator</h3>
				    <ul class="subclass-property-list">
		    			${grantsCOPI!}
					</ul>
				  </#if>
				</li>
			</ul>
			</article>
		  </div>
	  </#if>
	<#else>
	  <ul id="scholars-tabs">
	  		<li><a href="#tabs-1">Profile Status</a></li>
	    	<#if isAuthor ><li class="pending-tab pending-tab-inactive">Publications</li></#if>
	    	<#if isInvestigator ><li class="pending-tab pending-tab-inactive">Grants</li></#if>
	  </ul>
	  	<div id="tabs-1" class="pending-tab-content ui-tabs ui-tabs-panel">
			<article class="property" role="article">
				<i class="fa fa-asterisk pending-asterisk" aria-hidden="true"></i>
				<p style="padding: 40px 40px 0 40px;">
				Release of the full publication view<#if isInvestigator>, as well as grant details,</#if> is pending author approval.</p>

				<p style="padding: 0 40px 20px 63px;">If this is your profile page, please contact the <a href="${urls.base!}/contact" style="color:#167093">Scholars<em style="color:#167093">@</em>Cornell team</a> to activate the display of your publications<#if isInvestigator> and grants</#if>.</p>
			</article>
	    </div>
	  
	</#if>
	</div>
	
</div>
<#else> <#-- optin == false -->
	<div id="hztl-visualization-column" class="col-md-12 scholars-container">
	  <div class="row visualization-row">
		<div id="available-vis" class="col-sm-3 col-md-3 col-lg-3">
			<p>Available<br/>Visualizations</p>
		</div>
	 	<#if isAuthor && isInvestigator>
			<div id="word_cloud_icon_holder" class="col-md-3" style="display:none;padding-top: 0;">
			    <a href="#" id="word_cloud_trigger" onclick="javascript:_paq.push(['trackEvent', 'Visualization', 'Person', 'Research-Keywords']);">
			    	<img id="vizIcon" width="174px" src="${urls.base}/themes/scholars/images/wordcloud-icon-hztl.png"/>
			    </a>
				<p>Research Keywords</p>
			</div>
	 		<div id="co-author-vis" class="col-md-3" >
	 			<a href="${coAuthorVisUrl}" onclick="javascript:_paq.push(['trackEvent', 'Visualization', 'Person', 'Co-authors']);">
	 				<img id="vizIcon" width="120px" src="${urls.base}/themes/scholars/images/co-authors.png"/>
	 			</a>
	 			<p>Co-authors</p>
	 		</div>
	 		<div id="co-investigator-vis" class="col-md-3" >
	 			<a href="${coInvestigatorVisUrl}" onclick="javascript:_paq.push(['trackEvent', 'Visualization', 'Person', 'Co-investigtors']);">
	 				<img id="vizIcon" width="120px" src="${urls.base}/themes/scholars/images/co-investigators.png"/>
	 			</a>
	 			<p>Co-investigators</p>
	 		</div>
	 	<#elseif isAuthor >
			<div id="word_cloud_icon_holder" class="col-md-5" style="display:none;padding-top: 0;">
			    <a href="#" id="word_cloud_trigger" onclick="javascript:_paq.push(['trackEvent', 'Visualization', 'Person', 'Research-Keywords']);">
			    	<img id="vizIcon" width="174px" src="${urls.base}/themes/scholars/images/wordcloud-icon-hztl.png"/>
			    </a>
				<p>Research Keywords</p>
			</div>
	 		<div id="co-author-vis" class="col-md-4" >
	 			<a href="${coAuthorVisUrl}" onclick="javascript:_paq.push(['trackEvent', 'Visualization', 'Person', 'Co-authors']);">
	 				<img id="vizIcon" width="120px" src="${urls.base}/themes/scholars/images/co-authors.png"/>
	 			</a>
	 			<p>Co-authors</p>
	 		</div>
		<#elseif  isInvestigator >
	 		<div id="co-investigator-vis" class="col-sm-5 col-md-5 col-lg-5" >
	 			<a href="${coInvestigatorVisUrl}" onclick="javascript:_paq.push(['trackEvent', 'Visualization', 'Person', 'Co-investigtors']);">
	 				<img id="vizIcon" width="120px" src="${urls.base}/themes/scholars/images/co-investigators.png"/>
	 			</a>
	 			<p>Co-investigators</p>
	 		</div>
	 	</#if>
	  </div>
	</div>
</#if>
<#else> <#-- not an author or investigator -->
<div id="foaf-person-blank-row" class="row scholars-row"></div>
</#if>
</div> <!-- row2 div -->

<!-- =============== Word cloud visualization ======================= -->

${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/scholars-vis/keywordcloud/kwcloud.css" />')}

<div id="word_cloud_vis" class="vis_modal" style="display:none; ">
  <div class="vis_toolbar">
    <span class="heading">Research Keywords</span>
    <span class="glyphicon glyphicon-info-sign pull-right" data-original-title="" title=""></span>
    <a data-view-selector="vis" href="#" class="vis-view-toggle pull-right" style="display: none">Show visualization</a>
    <a data-view-selector="table" href="#" class="vis-view-toggle pull-right">Show table format</a>
  </div>
  
  <div id="info_icon_text">
    <p>
      This visualization displays the research keywords associated with the author, 
      and is an aggregation of keywords found in all of the author's articles. 
      There are different sources of these keywords: those expressed by the author in the articles, 
      those assigned by the publishers to the article, and those that are algorithmically inferred 
      from the text of the article's abstract. The size of the keyword indicates the frequency 
      with which the keyword appears in the author's publications, indicating which subject 
      the author published on most (or least) frequently. 
    </p>
    <p>
       To interact with the visualization, click on any the keyword to see the list of the 
       articles associated with the keyword. You can then click on the article title in this 
       list to navigate to the full view of the article's metadata and a link to the full 
       text when its available.
    </p>
    <hr> 
    <p>
      Note: This information is based solely on publications that have been loaded into the system.
    </p> 
  </div>
  
  <div id="time-indicator">
    <img id="time-indicator-img" src="${urls.images}/indicator1.gif"/>
  </div>

  <div data-view-id="vis" style="height: 90%; ">
    <div class="vis-exports-container" >
      <a href="javascript:return false;" data-export-id="json" class="vis-view-toggle pull-right">Export as JSON</a>
      <a href="javascript:return false;" data-export-id="svg" style="margin-right: 7px;" class="vis-view-toggle pull-right">Export as SVG</a>
	</div>
    <font size="2">
      <span><i>Click on a keyword to view the list of related publications.</i></span>
    </font>
    <div style="margin-top: 10px">
      <font size="2">
        <label class="radio-inline radio-inline-override"><input id="all" type="radio" name="kwRadio" class="radio" checked>Featured Keywords</label>
        <label class="radio-inline"><input id="keyword"  type="radio" name="kwRadio" class="radio" >Article Keywords</label>
        <label class="radio-inline"><input id="mesh"     type="radio" name="kwRadio" class="radio" >External Vocab. Terms</label>
        <label class="radio-inline"><input id="inferred" type="radio" name="kwRadio" class="radio" >Mined Keywords</label>
      </font>
    </div>
  </div>

  <div data-view-id="table" class="vis-table-container">
    <div class="vis-exports-container">
      <a href="javascript:return false;" data-export-id="json"  class="vis-view-toggle pull-right">Export as JSON</a>
      <a href="javascript:return false;" data-export-id="csv" style="margin-right: 10px;" class="vis-view-toggle pull-right">Export as CSV</a>
    </div>
    <table class="scholars-vis-table">
      <thead>
        <tr>
          <th data-sort="string-ins">Keyword</th>
          <th data-sort="string-ins">Keyword type(s)</th>
          <th data-sort="string-ins">Publication</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>Template cell</td>
          <td>Template cell</td>
          <td>Template cell</td>
        </tr>
      </tbody>
    </table>
  </div>
</div>

<!-- ================================================================ -->

<div class="jqmWindow" id="subject-area-dialog">
	<div>
		<a id="subject-area-dialog-close" href="#" class="jqmClose"><i class="fa fa-times" aria-hidden="true"></i>
		</a>
		${subjectAreaList!}
	</div>
</div>

<#if !editable>
<script>
    var title = $('div#titleContainer').width();
    var name = $('h1.vcard').width();
    var total = parseInt(title,10) + parseInt(name,10);
    if ( name < 280 && total > 600 ) {
        var diff = total - 600;
        $('div#titleContainer').width(title - diff);
    }
    else if ( name > 279 && name + title > 600 ) {
        $('div#titleContainer').width('620');
    }
</script>
</#if>
<script>
    var imagesPath = '${urls.images}';
</script>
<#assign rdfUrl = individual.rdfUrl>

<#if rdfUrl??>
    <script>
        var individualRdfUrl = '${rdfUrl}';
    </script>
</#if>
<script type="text/javascript">
var individualUri = '${individual.uri!}';
var individualPhoto = '${individual.thumbNail!}';
var exportQrCodeUrl = '${urls.base}/qrcode?uri=${individual.uri!}';
var baseUrl = '${urls.base}';
var profileTypeData = {
    processingUrl: '${urls.base}/edit/primitiveRdfEdit',
    individualUri: '${individual.uri!}',
    defaultProfileType: '${profileType!}'
};
var i18nStrings = {
    errorProcessingTypeChange: '${i18n().error_processing_type_change}',
    displayLess: '${i18n().display_less}',
    displayMoreEllipsis: '${i18n().display_more_ellipsis}',
    showMoreContent: '${i18n().show_more_content}',
    verboseTurnOff: '${i18n().verbose_turn_off}',
    standardviewTooltipOne: '${i18n().standardview_tooltip_one}',
    standardviewTooltipTwo: '${i18n().standardview_tooltip_two}',
    researchAreaTooltipOne: '${i18n().research_area_tooltip_one}',
    researchAreaTooltipTwo: '${i18n().research_area_tooltip_two}'
};
var i18nStringsUriRdf = {
    shareProfileUri: '${i18n().share_profile_uri}',
    viewRDFProfile: '${i18n().view_profile_in_rdf}',
    closeString: '${i18n().close}'
};
</script>
<script>
$(function() {
  $( "#scholars-tabs-container" ).tabs();
});
$().ready(function() {
  $('#subject-area-dialog').jqm();
});
</script>
<script>
$().ready(function() {
  var wc = new ScholarsVis.PersonWordCloud({
    target : '#word_cloud_vis',
    modal : true,
    person : "${individual.uri?url}",
    animation : true
  });
  wc.examineData(function(data) {
    if (data.length > 0) {
      $('#word_cloud_icon_holder').show();
      $('#word_cloud_trigger').click(wc.show);
    }
	else {
	  if ( $("#co-investigator-vis").length ) {
		$("#co-author-vis").addClass("col-md-5");
	  	$("#co-investigator-vis").addClass("col-md-4");
		$("#co-author-vis").removeClass("col-md-3");
	  	$("#co-investigator-vis").removeClass("col-md-3");
	  }
	  else {
 	  	$("#co-author-vis").addClass("col-md-8");
		$("#available-vis").addClass("col-md-4");
		$("#hztl-visualization-column").addClass("col-md-7");
	  	$("#co-author-vis").removeClass("col-md-4");
		$("#available-vis").removeClass("col-md-3");
		$("#hztl-visualization-column").removeClass("col-md-12");
	  }
	}
  });
});
</script>

${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/individual/individual.css" />',
		         '<link rel="stylesheet" href="${urls.base}/css/individual/individual-vivo.css" />',
				  '<link rel="stylesheet" href="${urls.base}/css/jquery_plugins/jquery.qtip.min.css" />',
                  '<link rel="stylesheet" href="${urls.base}/css/individual/individual-2column-view.css" />')}

${headScripts.add('<script type="text/javascript" src="${urls.base}/js/tiny_mce/tiny_mce.js"></script>',
                  '<script type="text/javascript" src="${urls.base}/js/jquery_plugins/qtip/jquery.qtip-3.0.3.min.js"></script>',
                  '<script type="text/javascript" src="${urls.base}/js/json2.js"></script>',
                  '<script type="text/javascript" src="${urls.base}/js/jquery_plugins/jquery.truncator.js"></script>')}

${scripts.add('<script type="text/javascript" src="${urls.base}/themes/scholars/js/individualUriRdf.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/individual/individualUtils.js?vers=1.5.1"></script>',
			  '<script type="text/javascript" src="${urls.base}/js/individual/moreLessController.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/individual/individualProfilePageType.js"></script>',
              '<script type="text/javascript" src="${urls.base}/js/imageUpload/imageUploadUtils.js"></script>')}

${stylesheets.add('<link rel="stylesheet" href="${urls.base}/css/scholars-vis/jqModal.css" />')}

${scripts.add('<script type="text/javascript" src="${urls.base}/js/d3.min.js"></script>',
	              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/jqModal.js"></script>',
	              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/scholars-vis.js"></script>',
                  '<script type="text/javascript" src="${urls.base}/js/scholars-vis/FileSaver.js"></script>',
	              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/stupidtable.min.js"></script>',
	              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/rdflib.js"></script>',
	              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/d3/d3-tip.js"></script>',
				  '<script type="text/javascript" src="https://d1bxh8uas1mnw7.cloudfront.net/assets/embed.js"></script>',
	              '<script type="text/javascript" src="${urls.base}/js/scholars-vis/d3/d3.layout.cloud.js"></script>',
                  '<script type="text/javascript" src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>',
				  '<script type="text/javascript" src="${urls.base}/js/scholars-vis/wordcloud/word-cloud.js"></script>')}

${stylesheets.add('<link rel="stylesheet" type="text/css" href="https://fonts.googleapis.com/css?family=Raleway" />',
	'<link rel="stylesheet" type="text/css" href="https://fonts.googleapis.com/css?family=Muli" />')}

<div id="ldjson">
</div>
<script>
  var ldjson = document.createElement('script');
  ldjson.type = 'application/ld+json';
  ldjson.text = JSON.stringify({
    "@context": "http://schema.org",
    "@type": "Person",
	  "name": "${individual.name?replace("\"","")!}",
	  "affiliation": "Cornell University",
	  "image": "${individual.thumbNail!}",
	  "url": "${individual.uri}",
	  "jobTitle": posT,
	  "worksFor": posD + ", " + posU
  });
  $('#ldjson').append(ldjson);
</script>
