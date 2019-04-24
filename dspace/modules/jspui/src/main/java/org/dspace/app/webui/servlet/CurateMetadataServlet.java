package org.dspace.app.webui.servlet;

import org.apache.log4j.Logger;
import org.dspace.app.webui.util.JSPManager;
import org.dspace.authorize.AuthorizeException;
import org.dspace.authorize.AuthorizeManager;
import org.dspace.content.Item;
import org.dspace.content.ItemIterator;
import org.dspace.core.Context;
import org.dspace.core.LogManager;
import org.dspace.eperson.EPerson;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

/**
 * Created by brendows on 08/11/2017.
 */
public class CurateMetadataServlet extends DSpaceServlet {

    private static Logger log = Logger.getLogger(CurateMetadataServlet.class);

    @Override
    protected void doDSGet(Context context, HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException, SQLException, AuthorizeException {
        String operation = request.getParameter("operation");

        if (AuthorizeManager.isAdmin(context)) {

            if (operation.equalsIgnoreCase("edit")) {

                context.turnOffAuthorisationSystem();

//                Faq f = Faq.find(context, Integer.parseInt(request.getParameter("id")));

//                editFaq(request, f);

                context.commit();

                ShowPage(context, request, response);

            } else {

                doDSGet(context, request, response);

            }


        }
    }


    @Override
    protected void doDSPost(Context context, HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException, SQLException, AuthorizeException {

        String action = "";


    }


    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        super.doGet(request, response);
    }

    public void ShowPage(Context c, HttpServletRequest rq, HttpServletResponse rp) throws ServletException, IOException, AuthorizeException, SQLException {
        Item[] items;
        //List returning to page of metadatas with bad-values

        log.info(LogManager.getHeader(c, "Returning BadMetadataValues-list", ""));

        int i = 1;

        EPerson[] ep = EPerson.findAll(c, i);

        ItemIterator iter = Item.findAll(c);


        JSPManager.showJSP(rq, rp, "/register/BadMetadataList.jsp");

    }

}
