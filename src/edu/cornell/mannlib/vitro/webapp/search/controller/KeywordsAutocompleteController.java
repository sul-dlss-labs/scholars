/* $This file is distributed under the terms of the license in /doc/license.txt$ */

package edu.cornell.mannlib.vitro.webapp.search.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.json.JSONArray;
import org.json.JSONObject;

import edu.cornell.mannlib.vitro.webapp.application.ApplicationUtils;
import edu.cornell.mannlib.vitro.webapp.auth.permissions.SimplePermission;
import edu.cornell.mannlib.vitro.webapp.auth.requestedAction.AuthorizationRequest;
import edu.cornell.mannlib.vitro.webapp.beans.VClass;
import edu.cornell.mannlib.vitro.webapp.controller.VitroRequest;
import edu.cornell.mannlib.vitro.webapp.controller.ajax.VitroAjaxController;
import edu.cornell.mannlib.vitro.webapp.dao.VClassDao;
import edu.cornell.mannlib.vitro.webapp.modules.searchEngine.SearchEngine;
import edu.cornell.mannlib.vitro.webapp.modules.searchEngine.SearchFacetField;
import edu.cornell.mannlib.vitro.webapp.modules.searchEngine.SearchFacetField.Count;
import edu.cornell.mannlib.vitro.webapp.modules.searchEngine.SearchQuery;
import edu.cornell.mannlib.vitro.webapp.modules.searchEngine.SearchResponse;
import edu.cornell.mannlib.vitro.webapp.modules.searchEngine.SearchResultDocument;
import edu.cornell.mannlib.vitro.webapp.modules.searchEngine.SearchResultDocumentList;
import edu.cornell.mannlib.vitro.webapp.rdfservice.RDFService;
import edu.cornell.mannlib.vitro.webapp.rdfservice.impl.RDFServiceUtils;
import edu.cornell.mannlib.vitro.webapp.search.VitroSearchTermNames;

/**
 * AutocompleteController generates autocomplete content
 * via the search index.
 */

public class KeywordsAutocompleteController extends VitroAjaxController {

    private static final long serialVersionUID = 1L;
    private static final Log log = LogFactory.getLog(KeywordsAutocompleteController.class);
    
    //private static final String TEMPLATE_DEFAULT = "autocompleteResults.ftl";
    
    private static final String PARAM_QUERY = "term";
    private static final String PARAM_RDFTYPE = "type";
    private static final String PARAM_QUERY_TYPE = "querytype";
    private static final String PARAM_MULTIPLE_RDFTYPE = "multipleTypes";
    private static final String KEYWORD_FIELD = "keyword_ss";

	private boolean hasMultipleTypes = false;
	
    String NORESULT_MSG = "";    
    private static final int DEFAULT_MAX_HIT_COUNT = 500;

    public static final int MAX_QUERY_LENGTH = 200;
    
/*    @Override
    protected AuthorizationRequest requiredActions(VitroRequest vreq) {
    	return SimplePermission.PAGE_VIEWABLE_PUBLIC.ACTION;
    }
*/
    @Override
    protected void doRequest(VitroRequest vreq, HttpServletResponse response)
        throws IOException, ServletException {

        try {
            String qtxt = vreq.getParameter(PARAM_QUERY);
			String typeParam = vreq.getParameter(PARAM_RDFTYPE);
			String qType = vreq.getParameter(PARAM_QUERY_TYPE);

            SearchQuery query = getQuery(qtxt, qType, vreq);
            if (query == null ) {
                log.debug("query for '" + qtxt +"' is null.");
                doNoQuery(response);
                return;
            }
            log.debug("the query for '" + qtxt +"' = " + query.toString());

			SearchEngine search = ApplicationUtils.instance().getSearchEngine();
            SearchResponse queryResponse = search.query(query);

            if ( queryResponse == null) {
                log.error("Query response for a search was null");
                doNoSearchResults(response);
                return;
            }
			
            SearchResultDocumentList docs = queryResponse.getResults();
            if ( docs == null) {
                log.error("Docs for a search was null");
                doNoSearchResults(response);
                return;
            }

            long hitCount = docs.getNumFound();
            log.debug("Total number of hits = " + hitCount);
            if ( hitCount < 1 ) {
                doNoSearchResults(response);
                return;
            }  
			
			JSONArray jsonArray = new JSONArray();

			if ( qType.equals("subject") ) {
	    		List<FacetField> results = new ArrayList<FacetField>();
				List<SearchFacetField> ffs = queryResponse.getFacetFields();
				for(SearchFacetField ff : ffs) {
					List<Count> values = ff.getValues();
					for( Count value: values){
						String valueLow = value.getName().toLowerCase();
						if ( valueLow.contains(qtxt.toLowerCase()) ) {
							FacetField result = new FacetField(valueLow);
							results.add(result);
						}
					}
				}
	           Collections.sort(results);


	            for (FacetField result : results) {
	                //jsonArray.put(result.toMap());
	            	jsonArray.put(result.toJSONObject());
	            }
			}
			else {
				List<SearchResult> results = new ArrayList<SearchResult>();
	            for (SearchResultDocument doc : docs) {
	                try {                
	                    String uri = doc.getStringValue(VitroSearchTermNames.URI);
	                    String name = doc.getStringValue(VitroSearchTermNames.NAME_RAW);
	                    //There may be multiple most specific types, sending them all back
	                    String mst = doc.getStringValue(VitroSearchTermNames.MOST_SPECIFIC_TYPE_URIS);
	                    //Assuming these will get me string values
	                    Collection<Object> mstObjValues = doc.getFieldValues(VitroSearchTermNames.MOST_SPECIFIC_TYPE_URIS);
	                    String[] mstStringValues = mstObjValues.toArray(new String[mstObjValues.size()]);
	                    List<String> mstValues = Arrays.asList(mstStringValues);
	                    SearchResult result = new SearchResult(name, uri, mst, mstValues, hasMultipleTypes, vreq);
	                    results.add(result);
	                    log.debug("results = " + results.toString());
	                } catch(Exception e){
	                    log.error("problem getting usable individuals from search " +
	                            "hits" + e.getMessage());
	                }
	            }
				hasMultipleTypes = false;

	            Collections.sort(results);

	            for (SearchResult result : results) {
	                //jsonArray.put(result.toMap());
	            	jsonArray.put(result.toJSONObject());
	            }
			}
			
             response.getWriter().write(jsonArray.toString());

        } catch (Throwable e) {
            log.error(e, e);
            doSearchError(response);
        }
    }

    private SearchQuery getQuery(String queryStr, String queryType, VitroRequest vreq) {

        if ( queryStr == null) {
            log.error("There was no parameter '"+ PARAM_QUERY
                +"' in the request.");
            return null;
        } else if( queryStr.length() > MAX_QUERY_LENGTH ) {
            log.debug("The search was too long. The maximum " +
                    "query length is " + MAX_QUERY_LENGTH );
            return null;
        }

    	SearchQuery query = ApplicationUtils.instance().getSearchEngine().createQuery();
		query.setStart(0);
        
		if ( queryType.equals("subject") ) {
			String term = "\"facet.prefix=" + queryStr +"\"";
			query.setRows(1);
			query.addFacetFields(KEYWORD_FIELD).setFacetLimit(70000);
		}
		else {
			query.setRows(DEFAULT_MAX_HIT_COUNT);
			setNameQuery(query, queryStr, vreq);
			String typeParam = vreq.getParameter(PARAM_RDFTYPE);
	        String multipleTypesParam = vreq.getParameter(PARAM_MULTIPLE_RDFTYPE);

	        if (typeParam != null) {
	        	addFilterQuery(query, typeParam,  multipleTypesParam);
	        }

	        query.addFields(VitroSearchTermNames.NAME_RAW, VitroSearchTermNames.URI, VitroSearchTermNames.MOST_SPECIFIC_TYPE_URIS); // fields to retrieve
		}

        return query;
    }

    private void addFilterQuery(SearchQuery query, String typeParam, String multipleTypesParam) {
    	if(multipleTypesParam == null || multipleTypesParam.equals("null") || multipleTypesParam.isEmpty()) {
    		//Single type parameter, process as usual
            query.addFilterQuery(VitroSearchTermNames.RDFTYPE + ":\"" + typeParam + "\"");
    	} else {
    		//Types should be comma separated
    		String[] typeParams = typeParam.split(",");
    		int len = typeParams.length;
    		int i;
    		List<String> filterQueries = new ArrayList<String>();

    		for(i = 0; i < len; i++) {
    			filterQueries.add(VitroSearchTermNames.RDFTYPE + ":\"" + typeParams[i] + "\" ");
    		}
    		String filterQuery = StringUtils.join(filterQueries, " OR ");
    		query.addFilterQuery(filterQuery);
    	}
	}

	private void setNameQuery(SearchQuery query, String queryStr, HttpServletRequest request) {

        if (StringUtils.isBlank(queryStr)) {
            log.error("No query string");
        }
        String tokenizeParam = request.getParameter("tokenize");
        boolean tokenize = "true".equals(tokenizeParam);

        // Note: Stemming is only relevant if we are tokenizing: an untokenized name
        // query will not be stemmed. So we don't look at the stem parameter until we get to
        // setTokenizedNameQuery().
        if (tokenize) {
            setTokenizedNameQuery(query, queryStr, request);
        } else {
            setUntokenizedNameQuery(query, queryStr);
        }
    }

    private void setTokenizedNameQuery(SearchQuery query, String queryStr, HttpServletRequest request) {
 
        /* We currently have no use case for a tokenized, unstemmed autocomplete search field, so the option
         * has been disabled. If needed in the future, will need to add a new field and field type which
         * is like AC_NAME_STEMMED but doesn't include the stemmer.
        String stemParam = (String) request.getParameter("stem");
        boolean stem = "true".equals(stemParam);
        if (stem) {
            String acTermName = VitroSearchTermNames.AC_NAME_STEMMED;
            String nonAcTermName = VitroSearchTermNames.NAME_STEMMED;
        } else {
            String acTermName = VitroSearchTermNames.AC_NAME_UNSTEMMED;
            String nonAcTermName = VitroSearchTermNames.NAME_UNSTEMMED;
        }
        */

        String acTermName = VitroSearchTermNames.AC_NAME_STEMMED;
        String nonAcTermName = VitroSearchTermNames.NAME_STEMMED;
        String acQueryStr;

        if (queryStr.endsWith(" ")) {
            acQueryStr = makeTermQuery(nonAcTermName, queryStr, true);
        } else {
            int indexOfLastWord = queryStr.lastIndexOf(" ") + 1;
            List<String> terms = new ArrayList<String>(2);

            String allButLastWord = queryStr.substring(0, indexOfLastWord);
            if (StringUtils.isNotBlank(allButLastWord)) {
                terms.add(makeTermQuery(nonAcTermName, allButLastWord, true));
            }

            String lastWord = queryStr.substring(indexOfLastWord);
            if (StringUtils.isNotBlank(lastWord)) {
                terms.add(makeTermQuery(acTermName, lastWord, false));
            }

            acQueryStr = StringUtils.join(terms, " AND ");
        }
        
        log.debug("Tokenized name query string = " + acQueryStr);
        query.setQuery(acQueryStr);

    }

    private void setUntokenizedNameQuery(SearchQuery query, String queryStr) {
        queryStr = queryStr.trim();
        queryStr = makeTermQuery(VitroSearchTermNames.AC_NAME_UNTOKENIZED, queryStr, true);
        log.debug("UNtokenized name query string = " + queryStr);
        query.setQuery(queryStr);
    }

    private String makeTermQuery(String term, String queryStr, boolean mayContainWhitespace) {
        if (mayContainWhitespace) {
            queryStr = "\"" + escapeWhitespaceInQueryString(queryStr) + "\"";
        }
        return term + ":" + queryStr;
    }

    private String escapeWhitespaceInQueryString(String queryStr) {
        // The search engine wants whitespace to be escaped with a backslash
        return queryStr.replaceAll("\\s+", "\\\\ ");
    }
       
    private void doNoQuery(HttpServletResponse response) throws IOException  {
        // For now, we are not sending an error message back to the client because
        // with the default autocomplete configuration it chokes.
        doNoSearchResults(response);
    }

    private void doSearchError(HttpServletResponse response) throws IOException {
        // For now, we are not sending an error message back to the client because 
        // with the default autocomplete configuration it chokes.
        doNoSearchResults(response);
    }

    private void doNoSearchResults(HttpServletResponse response) throws IOException {
        response.getWriter().write("[]");
    }

	private RDFService getRdfService(HttpServletRequest req) {
		return RDFServiceUtils.getRDFService(new VitroRequest(req));
	}

    public class FacetField implements Comparable<Object> {
        private String name;

        FacetField(String name) {
			this.name = name;				
        }
		
        public String getName() {
            return name;
        }

        public String getJsonName() {
            return JSONObject.quote(name);
        }

                
        //Simply passing in the array in the map converts it to a string and not to an array
        //which is what we want so need to convert to an object instad
        JSONObject toJSONObject() {
        	JSONObject jsonObj = new JSONObject();
        	try {
        	 jsonObj.put("name", name);
        	} catch(Exception ex) {
        		log.error("Error occurred in converting values to JSON object", ex);
        	}
        	return jsonObj;
        }

        public int compareTo(Object o) throws ClassCastException {
            if ( !(o instanceof FacetField) ) {
                throw new ClassCastException("Error in FacetField.compareTo(): expected FacetFieldt object.");
            }
            FacetField sr = (FacetField) o;
            return name.compareToIgnoreCase(sr.getName());
        }
    }
    public class SearchResult implements Comparable<Object> {
        private String label;
        private String uri;
        private String msType;
        private List<String> allMsTypes;
		private boolean hasMultipleTypes;

        SearchResult(String label, String uri, String msType, List<String> allMsTypes, boolean hasMultipleTypes, VitroRequest vreq) {
			if ( hasMultipleTypes ) {
	            this.label = label + " (" + getMsTypeLocalName(msType, vreq) + ")";
			}
			else {
	            this.label = label;				
			}
            this.uri = uri;
            this.msType = msType;
            this.allMsTypes = allMsTypes;
        }
		
        public String getLabel() {
            return label;
        }

        public String getJsonLabel() {
            return JSONObject.quote(label);
        }

        public String getUri() {
            return uri;
        }

        public String getJsonUri() {
            return JSONObject.quote(uri);
        }
        
        public String getMsType() {
            return msType;
        }
        
        public List<String> getAllMsTypes() {
        	return allMsTypes;
        }

		public String getMsTypeLocalName(String theUri, VitroRequest vreq) {
			VClassDao vcDao = vreq.getUnfilteredAssertionsWebappDaoFactory().getVClassDao();
			VClass vClass = vcDao.getVClassByURI(theUri);
			String theType = ((vClass.getName() == null) ? "" : vClass.getName());
			return theType;
		}

        public String getJsonMsType() {
            return JSONObject.quote(msType);
        }
        
        
        //Simply passing in the array in the map converts it to a string and not to an array
        //which is what we want so need to convert to an object instad
        JSONObject toJSONObject() {
        	JSONObject jsonObj = new JSONObject();
        	try {
        	 jsonObj.put("label", label);
             jsonObj.put("uri", uri);
             //Leaving this in for now, in case there is code out there that depends on this single string version
             //But this should really be changed so that the entire array is all that should be returned
             jsonObj.put("msType", msType);
             //map.put("allMsTypes", allMsTypes);
             JSONArray allMsTypesArray = new JSONArray(allMsTypes);
             jsonObj.put("allMsTypes", allMsTypesArray);
        	} catch(Exception ex) {
        		log.error("Error occurred in converting values to JSON object", ex);
        	}
        	return jsonObj;
        }

        public int compareTo(Object o) throws ClassCastException {
            if ( !(o instanceof SearchResult) ) {
                throw new ClassCastException("Error in SearchResult.compareTo(): expected SearchResult object.");
            }
            SearchResult sr = (SearchResult) o;
            return label.compareToIgnoreCase(sr.getLabel());
        }
    }

}
