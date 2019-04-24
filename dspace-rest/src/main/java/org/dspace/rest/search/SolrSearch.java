package org.dspace.rest.search;

import org.apache.log4j.Logger;
import org.dspace.authorize.AuthorizeManager;
import org.dspace.content.Collection;
import org.dspace.content.Community;
import org.dspace.content.DSpaceObject;
import org.dspace.core.Context;
import org.dspace.discovery.*;
import org.dspace.handle.HandleManager;
import org.dspace.rest.common.Item;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

public class SolrSearch implements Search {

    private static final Logger log = Logger.getLogger(SolrSearch.class);

    private DiscoverResult result;

    @Override
    public ArrayList<org.dspace.rest.common.Item> search(Context context, HashMap<String, String> searchTerms, String expand, Integer limit, Integer offset, String sortField, String sortOrder) {
        ArrayList<org.dspace.rest.common.Item> results = new ArrayList<org.dspace.rest.common.Item>();
        StringBuilder query_string = new StringBuilder();
        Iterator<String> keyset = searchTerms.keySet().iterator();
        while (keyset.hasNext()) {
            String key = keyset.next();
            query_string.append(key).append(":").append(searchTerms.get(key));
            if (keyset.hasNext()) {
                query_string.append(" AND ");
            }
        }
        log.debug("search query: " + query_string.toString());
        SolrServiceImpl solr = new SolrServiceImpl();
        DiscoverQuery query = new DiscoverQuery();
        query.setQuery(query_string.toString());
        query.setMaxResults(limit);
        query.setStart(offset);

        if (sortField != null && sortOrder != null) {
            query.setSortField(sortField, sortOrder.compareTo("asc") == 0 ? DiscoverQuery.SORT_ORDER.asc : DiscoverQuery.SORT_ORDER.desc);
        }
        try {
            result = solr.search(context, query);
            List<DSpaceObject> list = result.getDspaceObjects();
            for (DSpaceObject obj : list) {
                if (obj instanceof org.dspace.content.Item && AuthorizeManager.authorizeActionBoolean(context, obj, org.dspace.core.Constants.READ)) {
                    results.add(new org.dspace.rest.common.Item((org.dspace.content.Item) obj, expand, context));
                }
            }
        } catch (SearchServiceException e) {
            log.error(e.getMessage());
        } catch (SQLException e) {
            log.error(e.getMessage());
        }

        return results;
    }

    @Override
    public long getTotalCount() {
        if (result != null) {
            return result.getTotalSearchResults();
        }
        return 0;
    }

    @Override
    public ArrayList<Item> searchAll(Context context, String parent, String query,
                                     String expand, Integer limit, Integer offset, String sortField,
                                     String sortOrder, List<String[]> filters) {
        ArrayList<org.dspace.rest.common.Item>


                results = new ArrayList<org.dspace.rest.common.Item>();


        StringBuilder query_string = new StringBuilder();
        query_string.append("{!lucene q.op=AND}");
        query_string.append(query);
        log.debug("search query: " + query_string.toString());
        SolrServiceImpl solr = new SolrServiceImpl();
        DiscoverQuery dis_query = new DiscoverQuery();
        dis_query.setQuery(query_string.toString());


        dis_query.addFilterQueries("search.resourcetype:2");

        DSpaceObject scope = null;
        if (parent != null) {
            try {
                scope = HandleManager.resolveToObject(context, "capes/"+parent);

            } catch (Exception e) {
                log.error(e.getCause());
            }
        }

        // Filters parameters
        if (filters.size() > 0) {
            for (String[] filtersParam : filters) {
                try {
                    String addFilterToItems = SearchUtils.getSearchService().toFilterQuery(context, filtersParam[0], filtersParam[1], filtersParam[2]).getFilterQuery();
                    if (addFilterToItems != null) {
                        dis_query.addFilterQueries(addFilterToItems);
                    }
                } catch (Exception e) {
                    log.info("Errors:" + "::" + filtersParam[0] + "::" +
                            filtersParam[1] + "::" +
                            filtersParam[2], e.getCause());
                }
            }
        }

            if(scope != null) {
                if (scope instanceof Community)
                {
                    dis_query.addFilterQueries("location.comm:" + scope.getID());
                } else if (scope instanceof Collection)
                {
                    dis_query.addFilterQueries("location.coll:" + scope.getID());
                } else if (scope instanceof org.dspace.content.Item)
                {
                    dis_query.addFilterQueries("handle" + ":" + scope.getHandle());
                }
            }

        // Filter Query
        dis_query.setMaxResults(limit);
        dis_query.setStart(offset);
        if (sortField != null && sortOrder != null) {
            dis_query.setSortField(sortField, sortOrder.compareTo("asc") == 0 ? DiscoverQuery.SORT_ORDER.asc : DiscoverQuery.SORT_ORDER.desc);
        }
        try {
            result = solr.search(context, dis_query);
            List<DSpaceObject> list = result.getDspaceObjects();
            for (DSpaceObject obj : list) {
//                if (obj.getParentObject().getHandle().equals(""))
                if (obj instanceof org.dspace.content.Item && AuthorizeManager.authorizeActionBoolean(context, obj, org.dspace.core.Constants.READ)) {
                    results.add(new org.dspace.rest.common.Item((org.dspace.content.Item) obj, expand, context));
                }
            }
        } catch (SearchServiceException e) {
            log.error(e.getMessage());
        } catch (SQLException e) {
            log.error(e.getMessage());
        }

        return results;
    }

    //Search with filters
    public ArrayList<Item> searchAll(Context context, String query,
                                     String expand, Integer limit, Integer offset, String sortField,
                                     String sortOrder) {

        ArrayList<org.dspace.rest.common.Item> results = new ArrayList<org.dspace.rest.common.Item>();


        return results;

    }


//    public static DSpaceObject getSearchScope(Context context,
//                                              HttpServletRequest request) throws IllegalStateException,
//            SQLException
//    {
//        // Get the location parameter, if any
//        String location = request.getParameter("location");
//        if (location == null)
//        {
//            if (UIUtil.getCollectionLocation(request) != null)
//            {
//                return UIUtil.getCollectionLocation(request);
//            }
//            if (UIUtil.getCommunityLocation(request) != null)
//            {
//                return UIUtil.getCommunityLocation(request);
//            }
//            return null;
//        }
//        DSpaceObject scope = HandleManager.resolveToObject(context, location);
//        return scope;
//    }

}