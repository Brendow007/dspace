/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 * <p>
 * http://www.dspace.org/license/
 */
package br.com.dglsistemas.webui.servlet;

import br.com.capes.eperson.Author;
import br.com.capes.eperson.AuthorAccountManager;
import org.apache.log4j.Logger;
import org.dspace.app.webui.servlet.DSpaceServlet;
import org.dspace.app.webui.util.JSPManager;
import org.dspace.authorize.AuthorizeException;
import org.dspace.authorize.AuthorizeManager;
import org.dspace.content.Collection;
import org.dspace.content.Community;
import org.dspace.core.Context;
import org.dspace.core.LogManager;
import org.dspace.core.Utils;
import org.dspace.eperson.EPerson;
import org.dspace.eperson.Group;

import javax.mail.MessagingException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Servlet for handling editing user profiles
 *
 * @author Guilherme Lemeszenski
 *
 * @version $Revision$
 *
 * test
 */
public class ManageAuthorsServlet extends DSpaceServlet {

    // This will map community IDs to arrays of collections
    private Map<Integer, Collection[]> colMap;

    // This will map communityIDs to arrays of sub-communities
    private Map<Integer, Community[]> commMap;

    private static final String OPERATION_REMOVE = "remove";
    private static final String OPERATION_CHECK = "check";
    private static final String OPERATION_LIST = "list";
    private static final String OPERATION_REFUSE = "refuse";
    private static final String OPERATION_DETAIL = "detail";
    private static final String OPERATION_ACCEPT = "accept";
    private static final String OPERATION_ACTIVE = "active";
    private static final String LIST_ALL_COLLECTIONS = "listall";

    /**
     * Logger
     */
    private static Logger log = Logger.getLogger(ManageAuthorsServlet.class);

    /**
     *
     */
    protected void doDSPost(Context context, HttpServletRequest request,
                            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException {
        doDSGet(context, request, response);
    }

    /**
     *
     */
    protected void doDSGet(Context context, HttpServletRequest request,
                           HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException {

        if (AuthorizeManager.isAdmin(context)) {

            String operation = request.getParameter("operation");

            try {
                if (!operation.equalsIgnoreCase(OPERATION_LIST)) {

                    if (operation.equalsIgnoreCase(OPERATION_CHECK)) {

                        int authorId = Integer.parseInt(request.getParameter("id"));
                        Author author = Author.find(context, authorId);

                        log.info(LogManager.getHeader(context, "list_check", ""));

                        request.setAttribute("author", author);
                        loadCommunities(request, context);
                        JSPManager.showJSP(request, response, "/register/author-form.jsp");
                        return;

                    }
                    if (operation.equalsIgnoreCase(OPERATION_DETAIL)) {

                        int authorId = Integer.parseInt(request.getParameter("id"));
                        Author author = Author.find(context, authorId);

                        log.info(LogManager.getHeader(context, "list_check_detail", ""));

                        request.setAttribute("author", author);
                        JSPManager.showJSP(request, response, "/register/author-detail.jsp");

                    } else if (operation.equalsIgnoreCase(OPERATION_REFUSE)) {

                        refuseAuthor(context, request);

                    } else if (operation.equalsIgnoreCase(LIST_ALL_COLLECTIONS)) {

                        returnAll(context, request, response);

                    } else if (operation.equalsIgnoreCase(OPERATION_ACCEPT)) {

                        acceptAuthor(context, request);

                    } else if (operation.equalsIgnoreCase(OPERATION_ACTIVE)) {

                        List<Author> authorList = Author.findAllActive(context);

                        request.setAttribute("authorList", authorList);
                        JSPManager.showJSP(request, response, "/register/author-list-active.jsp");
                        return;

                    } else if (operation.equalsIgnoreCase(OPERATION_REMOVE)) {

                        int authorId = Integer.parseInt(request.getParameter("id"));
                        Author author = Author.find(context, authorId);

                        author.delete();

                    }

                    context.commit();

                }

                log.info(LogManager.getHeader(context, "list_authors", ""));

                List<Author> authorList = Author.findAllInactive(context);

                request.setAttribute("authorList", authorList);

                request.setAttribute("communityList", Community.findAll(context));

                JSPManager.showJSP(request, response, "/register/author-list.jsp");

            } catch (Exception e) {
                context.abort();
                log.error(e.getMessage(), e);
                request.setAttribute("javax.servlet.error.exception", e);
                JSPManager.showJSP(request, response, "/error/internal.jsp");
            }

        } else {
            JSPManager.showJSP(request, response, "/error/authorize.jsp");
            return;
        }

    }

    /**
     *
     */
    private void loadCommunities(HttpServletRequest request, Context context) throws SQLException {

        colMap = new HashMap<Integer, Collection[]>();
        commMap = new HashMap<Integer, Community[]>();

        log.info(LogManager.getHeader(context, "view_community_list", ""));

        Community[] communities = Community.findAllTop(context);

        for (int com = 0; com < communities.length; com++) {
            build(communities[com]);
        }

        // can they admin communities?
        if (AuthorizeManager.isAdmin(context)) {
            // set a variable to create an edit button
            request.setAttribute("admin_button", Boolean.TRUE);
        }

        request.setAttribute("communities", communities);
        request.setAttribute("collections.map", colMap);
        request.setAttribute("subcommunities.map", commMap);
    }

    /*
     * Get all subcommunities and collections from a community
     */
    private void build(Community c) throws SQLException {

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

    /**
     *
     */
    private void refuseAuthor(Context context, HttpServletRequest request) throws SQLException, AuthorizeException, IOException, MessagingException {

        int authorId = Integer.parseInt(request.getParameter("author_id"));
        String cause = request.getParameter("cause");

        Author author = Author.find(context, authorId);

        String token = Utils.generateKey();
        author.setRefusalCause(cause);
        author.setToken(token);
        author.update();

        AuthorAccountManager.sendRefusedAccountEmail(context, author.getEPerson().getEmail(), cause, author.getID(), token);
    }

    /**
     *
     */
    private void acceptAuthor(Context context, HttpServletRequest request) throws SQLException, AuthorizeException, IOException, MessagingException {

        int authorId = Integer.parseInt(request.getParameter("author_id"));
        String[] collectionIds = request.getParameterValues("collection_id");

        Author author = Author.find(context, authorId);
        EPerson eperson = author.getEPerson();

        if (collectionIds != null && collectionIds.length > 0) {
            for (String collectionIdString : collectionIds) {
                Collection collection = Collection.find(context, Integer.parseInt(collectionIdString));
                if (collection != null) {
                    Group submittersGroup = collection.getSubmitters();

                    if (submittersGroup == null) {
                        submittersGroup = collection.createSubmitters();
                    }

                    submittersGroup.addMember(eperson);
                    submittersGroup.update();
                }
            }
        }

        author.setActive(true);
        author.setRefusalCause(null);
        author.setToken(null);
        author.update();

        eperson.setCanLogIn(true);
        eperson.update();
        AuthorAccountManager.sendAcceptedAccountEmail(context, author.getEPerson().getEmail());
    }

    private void returnAll(Context context, HttpServletRequest request, HttpServletResponse response) throws ServletException, SQLException, AuthorizeException, IOException, MessagingException {

//        DSIndexer ds = new DSIndexer();
//        String [] args = {};
//        ds.main(args);

//        EPerson ep = EPerson.find(context, 905);
//        Group test = Group.find(context, 124);
//
//        String nomeProjeto = test.getName();
//
//        String nomeProjetoREGEX = nomeProjeto.replaceAll("[a-zA-Z0-9]+_","");
//
////        if (test.getMemberGroups() == null) {
//
//            if (ep.getLastName().equals(nomeProjetoREGEX)) {
//
//                test.addMember(ep);
//                test.update();
////            }
//
//        }


//      Lista de objetos
//         EPerson[] epersonList = EPerson.findAll(context, EMAIL);
         Group[] groupCollection = Group.findAll(context, 1);


  /*      for (Group gp : groupCollection) {

            String nomeProjeto = gp.getName();
            String nomeProjetoREGEX = nomeProjeto.replaceAll("[a-zA-Z0-9]+_","");

            for (EPerson epp:epersonList) {
                if (gp.getMembers() == null) {

                    if (epp.getLastName().equals(nomeProjetoREGEX))
                        gp.addMember(epp);
                        gp.update();
                 }
            }
        }*/
        Collection[] collectionList = Collection.findAll(context);
        Collection collection_undefined = Collection.find(context,5043);
        Collection educapes_collection = Collection.find(context,4881);



//CreateGroups
//     for (Collection ccc:collectionList) {
//
//
//            String name = ccc.getName();
//            String nameRegex = name.replaceAll("\\D+","");
//
//
//         Group newGroup = ccc.populateCollectionWithadmin(nameRegex);
//         ccc.update();
//
//
//        }


//        request.setAttribute("test", nameRegex);

//        request.setAttribute("eperson", eperson);
//        request.setAttribute("cc", cc);
        request.setAttribute("collectionList", collectionList);
        request.setAttribute("collection_undefined", collection_undefined);
        request.setAttribute("educapes_collection", educapes_collection);
        JSPManager.showJSP(request, response, "/register/collection-list.jsp");
//        JSPManager.showJSP(request, response, "/static/pages/contact.jsp");

    }

}
