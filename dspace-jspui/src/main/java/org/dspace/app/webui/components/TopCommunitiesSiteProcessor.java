/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 * <p>
 * http://www.dspace.org/license/
 */
package org.dspace.app.webui.components;

import org.dspace.content.Collection;
import org.dspace.content.Community;
import org.dspace.core.Context;
import org.dspace.plugin.PluginException;
import org.dspace.plugin.SiteHomeProcessor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

/**
 * This class add top communities object to the request attributes to use in
 * the site home page implementing the SiteHomeProcessor.
 *
 * @author Andrea Bollini
 */
public class TopCommunitiesSiteProcessor implements SiteHomeProcessor {
    // This will map community IDs to arrays of collections
    private Map<Integer, Collection[]> colMap;

    // This will map communityIDs to arrays of sub-communities
    private Map<Integer, Community[]> commMap;

    /**
     * blank constructor - does nothing.
     */
    public TopCommunitiesSiteProcessor() {

    }

    private void build(Community c) throws SQLException {

        if (c.getName().equals("Cursos Nacionais")) {

            Integer comID = Integer.valueOf(c.getID());

            // Find collections in community
            Collection[] colls = c.getCollections();
            colMap.put(comID, colls);

            // Find subcommunties in community
            Community[] comms = c.getSubcommunities();

            // Get all subcommunities for each communities if they have some
            if (comms.length > 0) {
                commMap.put(comID, comms);

                for (int sub = 0; sub < comms.length; sub++) {

                    build(comms[sub]);
                }
            }
        }

    }


    protected void returnAllCommunity(Context context, HttpServletRequest request,
                                      HttpServletResponse response) throws
            SQLException {
        {
            colMap = new HashMap<Integer, Collection[]>();
            commMap = new HashMap<Integer, Community[]>();


            Community[] communities = Community.findAllTop(context);

            for (int com = 0; com < communities.length; com++) {

                if (communities[com].getName().equals("Cursos Nacionais")) {
                    build(communities[com]);
                }
            }


            request.setAttribute("communities", communities);
            request.setAttribute("collections.map", colMap);
            request.setAttribute("subcommunities.map", commMap);
        }
    }


    @Override
    public void process(Context context, HttpServletRequest request,
                        HttpServletResponse response) throws PluginException {
//        Community[] communities;

        try {

//            communities = Community.findAllTop(context);
            returnAllCommunity(context, request, response);

        } catch (SQLException e) {
            throw new PluginException(e.getMessage(), e);
        }
//        request.setAttribute("communities", communities);
    }

}
