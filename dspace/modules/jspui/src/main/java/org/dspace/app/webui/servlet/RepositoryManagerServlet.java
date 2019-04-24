package org.dspace.app.webui.servlet;

import com.google.gson.Gson;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import org.apache.log4j.Logger;
import org.dspace.app.webui.util.JSPManager;
import org.dspace.authorize.AuthorizeException;
import org.dspace.authorize.AuthorizeManager;
import org.dspace.content.Collection;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.dspace.content.ItemIterator;
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.dspace.core.LogManager;
import org.dspace.eperson.EPerson;
import org.dspace.handle.HandleManager;
import org.dspace.harvest.HarvestedCollection;
import org.dspace.harvest.OAIHarvester;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

public class RepositoryManagerServlet extends DSpaceServlet {

    private static Logger log = Logger.getLogger(FaqManagerServlet.class);
    String mssg;


    public void doJSONRequest(Context context, HttpServletRequest req, HttpServletResponse resp)
            throws AuthorizeException, IOException {
    }

    protected void doDSPost(Context context, HttpServletRequest request,
                            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException {

        String action;
        String idcol;

        int idcolCast = 0;
        if (AuthorizeManager.isAdmin(context)) {
            action = request.getParameter("action");
            idcol = request.getParameter("col_id");

            if (idcol == null || idcol.isEmpty()) {
                returnMainPage(context, request, response, null);
            } else {
                idcolCast = Integer.parseInt(idcol);
            }

            if (action == null || action.isEmpty()) {
                returnMainPage(context, request, response, null);
            } else if (checkCollisHarvested(context, idcolCast)) {
                if (action.equalsIgnoreCase("harvestCol")) {
                    runHarvest(idcol, context.getCurrentUser().getEmail(), context);
                    returnMainPage(context, request, response, null);

                } else if (action.equalsIgnoreCase("purgeCol")) {
                    purgeCollection(idcol, context.getCurrentUser().getEmail(), context);
                    returnMainPage(context, request, response, null);

                } else if (action.equalsIgnoreCase("editCol")) {
                    Collection collection = resolveCollection(idcol, context);
                    returnSingleCol(context, request, response, collection.getID());

                } else if (action.equalsIgnoreCase("pingCol")) {
                    try {
                        Collection collection = resolveCollection(idcol, context);
                        HarvestedCollection hc = HarvestedCollection.find(context, collection.getID());
                        if (hc != null) {
                            if (hc.getOaiSource() != null && hc.getOaiSetId() != null) {
                                GetPingResponder(hc.getOaiSource(), hc.getOaiSetId(), hc.getHarvestMetadataConfig());
                                returnMainPage(context, request, response, GetPingResponder(hc.getOaiSource(), hc.getOaiSetId(), hc.getHarvestMetadataConfig()));
                            } else {
                                returnMainPage(context, request, response, "");
                            }
                        }
                        returnMainPage(context, request, response, "");

                    } catch (SQLException e) {
                        System.out.println(e.getErrorCode());
                    }
                } else {
                    returnMainPage(context, request, response, null);
                }
            }
        }
    }

    protected void doDSGet(Context context, HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException, AuthorizeException {
        String action = request.getParameter("action");
        Gson gson = new Gson();
        JsonElement tree = gson.toJsonTree("testestestes");
        JsonObject jo = new JsonObject();
        jo.add("result", tree);
        response.getWriter().write(jo.toString());
        returnMainPage(context, request, response, null);
//        doDSPost(context, request, response);

    }


    private void runHarvest(String collectionID, String email, Context context) {
        System.out.println("Running: a harvest cycle on " + collectionID);

        System.out.print("Initializing the harvester... ");
        OAIHarvester harvester = null;
        try {
            Collection collection = resolveCollection(collectionID, context);
            HarvestedCollection hc = HarvestedCollection.find(context, collection.getID());
            harvester = new OAIHarvester(context, collection, hc);
            System.out.println("success. ");
        } catch (OAIHarvester.HarvestingException hex) {
            System.out.print("failed. ");
            System.out.println(hex.getMessage());
            throw new IllegalStateException("Unable to harvest", hex);
        } catch (SQLException se) {
            System.out.print("failed. ");
            System.out.println(se.getMessage());
            throw new IllegalStateException("Unable to access database", se);
        }

        try {
            // Harvest will not work for an anonymous user
            EPerson eperson = EPerson.findByEmail(context, email);
            System.out.println("Harvest started... ");
            context.setCurrentUser(eperson);
            harvester.runHarvest();
//            context.complete();
        } catch (SQLException e) {
            throw new IllegalStateException("Failed to run harvester", e);
        } catch (AuthorizeException e) {
            throw new IllegalStateException("Failed to run harvester", e);
        } catch (IOException e) {
            throw new IllegalStateException("Failed to run harvester", e);
        }

        System.out.println("Harvest complete. ");
    }

    private Collection resolveCollection(String collectionID, Context context) {

        DSpaceObject dso;
        Collection targetCollection = null;

        try {
            // is the ID a handle?
            if (collectionID != null) {
                if (collectionID.indexOf('/') != -1) {
                    // string has a / so it must be a handle - try and resolve it
                    dso = HandleManager.resolveToObject(context, collectionID);

                    // resolved, now make sure it's a collection
                    if (dso == null || dso.getType() != Constants.COLLECTION) {
                        targetCollection = null;
                    } else {
                        targetCollection = (Collection) dso;
                    }
                }
                // not a handle, try and treat it as an integer collection
                // database ID
                else {
                    System.out.println("Looking up by id: " + collectionID + ", parsed as '" + Integer.parseInt(collectionID) + "', " + "in context: " + context);
                    targetCollection = Collection.find(context, Integer.parseInt(collectionID));
                }
            }
            // was the collection valid?
            if (targetCollection == null) {
                System.out.println("Cannot resolve " + collectionID + " to collection");
                System.exit(1);
            }
        } catch (SQLException se) {
            se.printStackTrace();
        }

        return targetCollection;
    }

    private void purgeCollection(String collectionID, String email, Context context) {

        System.out.println("Purging collection of all items and resetting last_harvested and harvest_message: " + collectionID);
        Collection collection = resolveCollection(collectionID, context);

        try {

            HarvestedCollection hc = HarvestedCollection.find(context, Integer.parseInt(collectionID));


            ItemIterator it = collection.getAllItems();
            //IndexBrowse ib = new IndexBrowse(context);
            while (it.hasNext()) {
                Item item = it.next();
                //System.out.println("Deleting: " + item.getHandle());
                //ib.itemRemoved(item);
                collection.removeItem(item);
                System.out.println("Deleting: " + item.getHandle());

            }
            hc.setHarvestResult(null, "");
            hc.update();
            collection.update();
            context.commit();
        } catch (Exception e) {
            log.info(e.getLocalizedMessage() + ": " + e.getCause());
        }


     /*   try {
            EPerson eperson = EPerson.findByEmail(context, email);
            context.setCurrentUser(eperson);
            context.turnOffAuthorisationSystem();

            ItemIterator it = collection.getAllItems();
            IndexBrowse ib = new IndexBrowse(context);
            int i = 0;
            while (it.hasNext()) {
                i++;
                Item item = it.next();
                System.out.println("Deleting: " + item.getHandle());
                ib.itemRemoved(item);
                collection.removeItem(item);
                // commit every 50 items
                if (i % 50 == 0) {
                    context.commit();
                    i = 0;
                }
            }

            HarvestedCollection hc = HarvestedCollection.find(context, collection.getID());
            if (hc != null) {
                hc.setHarvestResult(null, "");
                hc.setHarvestStatus(HarvestedCollection.STATUS_READY);
                hc.setHarvestStartTime(null);
                hc.update();
            }
            context.restoreAuthSystemState();
            context.commit();
        } catch (Exception e) {
            System.out.println("Changes could not be committed");
            e.printStackTrace();
            System.exit(1);
        } finally {
            context.restoreAuthSystemState();
        }*/
    }


    private boolean checkCollisHarvested(Context context, int idCol) throws SQLException {
        HarvestedCollection col = HarvestedCollection.find(context, idCol);
        if ((col != null && col.getHarvestType() > 0 && col.getOaiSource() != null && col.getOaiSetId() != null && col.getHarvestStatus() != HarvestedCollection.STATUS_UNKNOWN_ERROR)) {
            return true;
        } else
            return false;
    }

    private String GetPingResponder(String server, String set, String metadataFormat) {
        List<String> errors;
        String configs = server + " " + set + " " + metadataFormat;
        String msg = configs;
        errors = OAIHarvester.verifyOAIharvester(server, set, (null != metadataFormat) ? metadataFormat : "dc", false);
        if (errors.isEmpty()) {
            msg = "OK - " + configs;
            return msg;
        } else {
            for (String error : errors) {
                msg = error + " To: " + configs;
            }
            return msg;
        }
    }

    private static void returnMainPage(Context context, HttpServletRequest request, HttpServletResponse response, String msg) throws IOException, ServletException, SQLException {
        List<HarvestedCollection> harvestedCollections = HarvestedCollection.findAllObject(context);
        log.info(LogManager.getHeader(context, "OAI Servlet", "GET: main"));
        request.setAttribute("harvestedCollections", harvestedCollections);
        request.setAttribute("msg", msg);
        JSPManager.showJSP(request, response, "/dspace-admin/repository-list.jsp");
    }

    private static void returnSingleCol(Context context, HttpServletRequest request, HttpServletResponse response, int id) throws IOException, ServletException, SQLException {
        HarvestedCollection hc = HarvestedCollection.find(context, id);
        request.setAttribute("harvestedCol", hc);
        JSPManager.showJSP(request, response, "/dspace-admin/hcCollection-detail.jsp");

    }

/*    public static void addThread(int collecionID) throws SQLException, IOException, AuthorizeException {
        log.debug("****** Entered the addThread method. Active threads: " + harvestThreads.toString());
        Context subContext = new Context();
        subContext.setCurrentUser(harvestAdmin);

        HarvestedCollection hc = HarvestedCollection.find(subContext, collecionID);
        hc.setHarvestStatus(HarvestedCollection.STATUS_QUEUED);
        hc.update();
        subContext.commit();

        OAIHarvester.HarvestThread ht = new OAIHarvester.HarvestThread(subContext, hc);
        harvestThreads.push(ht);

        log.debug("****** Queued up a thread. Active threads: " + harvestThreads.toString());
        log.info("Thread queued up: " + ht.toString());
    }*/

}

