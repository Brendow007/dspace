package org.dspace.rest.search;

import org.dspace.core.Context;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public interface Search {

    public ArrayList<org.dspace.rest.common.Item> search(Context context, HashMap<String,String>searchTerms, String expand, Integer limit, Integer offset, String sortfield, String sortorder);
    public long getTotalCount();

    public ArrayList<org.dspace.rest.common.Item> searchAll(Context context,String parent, String query, String expand, Integer limit, Integer offset, String sortfield, String sortorder, List<String[]> filters);

    public ArrayList<org.dspace.rest.common.Item> searchAll(Context context, String query, String expand, Integer limit, Integer offset, String sortfield, String sortorder);


}