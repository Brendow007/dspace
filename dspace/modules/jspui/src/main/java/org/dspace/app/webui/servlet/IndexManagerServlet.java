package org.dspace.app.webui.servlet;

import org.apache.log4j.Logger;
import org.dspace.app.webui.util.JSPManager;
import org.dspace.authorize.AuthorizeException;
import org.dspace.authorize.AuthorizeManager;
import org.dspace.core.Context;
import org.dspace.discovery.IndexingService;
import org.dspace.utils.DSpace;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

public class IndexManagerServlet extends DSpaceServlet {

    private static Logger log = Logger.getLogger(IndexManagerServlet.class);

    protected void doDSPost(Context context, HttpServletRequest request,
                            HttpServletResponse response) throws ServletException, IOException,
            SQLException {

        String operation = request.getParameter("action");

        if (AuthorizeManager.isAdmin(context)) {

            returnIndexatorPage(context, request, response, "main");

            if (operation != null && !operation.isEmpty()) {

                if (operation.contains("Index")) {

                    DSpace dspace = new DSpace();

                    IndexingService indexer = dspace.getServiceManager().getServiceByName(IndexingService.class.getName(), IndexingService.class);


                    if (operation.equalsIgnoreCase("cleanIndex")) {

                        try {

                            indexer.cleanIndex(true);

                        } catch (Exception e) {

                            log.error(e.getMessage(), e);

                        }
                    } else if (operation.equalsIgnoreCase("createIndex")) {

                        try {

                            indexer.createIndex(context);

                        } catch (Exception e) {
                            log.error(e.getMessage(), e);

                        }
                    }else if (operation.equalsIgnoreCase("cleanCol")) {
                        String colHandle = request.getParameter("handle");
                        if (!colHandle.isEmpty()) {

                            try {
                                indexer.unIndexContent(context, colHandle);
                            } catch (Exception e) {
                                log.error(e.getMessage(), e);

                            }
                        }
                    } else {
                        request.setAttribute("message", operation);
                        returnIndexatorPage(context, request, response, "main");
                    }
                } else {

                    returnIndexatorPage(context, request, response, "main");

                }
            }
        } else {

            returnIndexatorPage(context, request, response, "admin");

        }

    }

    protected void doDSGet(Context context, HttpServletRequest request,
                           HttpServletResponse response) throws ServletException, IOException, AuthorizeException, SQLException {

        doDSPost(context, request, response);

    }


    public void returnIndexatorPage(Context c, HttpServletRequest request, HttpServletResponse response, String type) throws IOException, ServletException {

        if (type.equalsIgnoreCase("main")) {
            JSPManager.showJSP(request, response, "/dspace-admin/indexer.jsp");

        } else if (type.equalsIgnoreCase("admin")) {
            JSPManager.showAuthorizeError(request, response, null);
        } else {
            JSPManager.showInternalError(request, response);
        }


    }


}
