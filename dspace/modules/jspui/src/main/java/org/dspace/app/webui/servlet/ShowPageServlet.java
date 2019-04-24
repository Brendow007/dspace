package org.dspace.app.webui.servlet;

import org.apache.log4j.Logger;
import org.dspace.app.webui.util.JSPManager;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Faq;
import org.dspace.content.FaqGroup;
import org.dspace.core.Context;
import org.dspace.core.LogManager;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * Created by brendows on 28/07/2016.
 * <p>
 * Servlet to redirect pages
 */
public class ShowPageServlet extends DSpaceServlet {

    private static Logger log = Logger.getLogger(ShowPageServlet.class);

    protected void doDSGet(Context context, HttpServletRequest request,
                           HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException {

        String action = request.getParameter("action");

        if (action == null || action.isEmpty()) {

            show(request, response);

        } else if (action != null) {

            if (action.equalsIgnoreCase("partners")) {


                JSPManager.showJSP(request, response, "/static/pages/partners.jsp");
                return;
            }

            else if (action.equalsIgnoreCase("about")) {


                JSPManager.showJSP(request, response, "/static/pages/about.jsp");
                return;
            }
            else if (action.equalsIgnoreCase("search")) {


                JSPManager.showJSP(request, response, "/static/pages/search.jsp");
                return;
            }
            else if (action.equalsIgnoreCase("contact")) {


                JSPManager.showJSP(request, response, "/static/pages/contact.jsp");
                return;
            }
            else if (action.equalsIgnoreCase("faq")) {

                showFaq(context, request, response);


            }else if (action.equalsIgnoreCase("submission")) {


                JSPManager.showJSP(request, response, "/static/pages/submission.jsp");
                return;
            }

            if (action.equalsIgnoreCase("sitemap")) {


                JSPManager.showJSP(request, response, "/static/pages/sitemap.jsp");
                return;
            }

            if (action.equalsIgnoreCase("rss")) {


                JSPManager.showJSP(request, response, "/static/pages/rss.jsp");
                return;
            }

            show(request, response);
        }
    }


    private void show(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException {
        JSPManager.showJSP(request, response, "/home.jsp");
        return;
    }

    private void showFaq(Context context, HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException {

        log.info(LogManager.getHeader(context, "Faq_list_questions", ""));
        List<FaqGroup> faqGroups = FaqGroup.selectAllFaqGroup(context);
        List<Faq> faqlist = Faq.selectAllfaq(context);

        request.setAttribute("faqlist", faqlist);
        request.setAttribute("faqgroup", faqGroups);

        JSPManager.showJSP(request, response, "/static/pages/faq.jsp");

    }



    protected void doDSPost(Context context, HttpServletRequest request,
                            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException {

        doDSGet(context, request, response);

    }
}






