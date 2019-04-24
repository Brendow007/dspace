package org.dspace.app.webui.servlet;

import org.apache.log4j.Logger;
import org.dspace.app.webui.util.JSPManager;
import org.dspace.authorize.AuthorizeException;
import org.dspace.authorize.AuthorizeManager;
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
 * Created by brendows on 15/09/2017.
 */
public class FaqGroupManagerServlet extends DSpaceServlet {

    private static Logger log = Logger.getLogger(FaqGroupManagerServlet.class);

    protected void doDSPost(Context context, HttpServletRequest request,
                            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException {

        String operation = request.getParameter("operation");

        if (AuthorizeManager.isAdmin(context)) {

            if (operation.equalsIgnoreCase("create")) {

                FaqGroup faqgroup = FaqGroup.create(context);

                createGroup(request, response, faqgroup,context);

                context.commit();

                showGroups(context, request, response);

            } else if (operation.equalsIgnoreCase("edit")) {

                context.turnOffAuthorisationSystem();

                FaqGroup f = FaqGroup.find(context, Integer.parseInt(request.getParameter("id")));

                editFaq(request, f);

                context.commit();

                showGroups(context, request, response);
                
            }
        } else {

            doDSGet(context, request, response);

        }


    }

    
    protected void doDSGet(Context context, HttpServletRequest request,
                           HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException {

        if (AuthorizeManager.isAdmin(context)) {

            String operation = request.getParameter("operation");

            if (operation == null || operation.isEmpty()) {

                showGroups(context, request, response);

            } else if (operation != null) {

                try {

                    if (!operation.equalsIgnoreCase("list")) {

                        if (operation.equalsIgnoreCase("detail")) {

                            int groupid = Integer.parseInt(request.getParameter("id"));

                            FaqGroup f = FaqGroup.find(context, groupid);

                            log.info(LogManager.getHeader(context, "list_faq_detail", "id: " + groupid));

                            int i = f.countMaxLimit(context);
                            request.setAttribute("grouplimit", i);

                            detailGroupFaq(request, response, f, context);


                            log.info(LogManager.getHeader(context, "list_faq_detail", "id:  " + groupid));


                        } else if (operation.equalsIgnoreCase("remove")) {

                            int groupid = Integer.parseInt(request.getParameter("id"));

                            FaqGroup f = FaqGroup.find(context, groupid);

                            f.delete();

                            context.commit();

                            log.info(LogManager.getHeader(context, "list_faq_detail", "id:  " + groupid));

                            showGroups(context, request, response);


                        }
                    } else {
                        showGroups(context, request, response);
                    }


                } catch (Exception e) {
                    context.abort();
                    log.error(e.getMessage(), e);
                    request.setAttribute("javax.servlet.error.exception", e);
                    JSPManager.showInternalError(request, response);
                }
            }
        } else {
            JSPManager.showJSP(request, response, "error/authorize.jsp");
        }
    }

    private void createGroup(HttpServletRequest request, HttpServletResponse response, FaqGroup f,Context c) throws SQLException, AuthorizeException, IOException {
        log.info(LogManager.escapeLogField("create_group_faq"));

        int limit = f.countMaxLimit(c);

        f.setGroupOrder(limit);
        f.setGroupName("Group Name" + " " + limit);
        f.update();

    }

    private void showGroups(Context context, HttpServletRequest request, HttpServletResponse response) throws SQLException, AuthorizeException,
            IOException, ServletException {

        log.info(LogManager.getHeader(context, "List_group_faq", ""));
        List<FaqGroup> groupList = FaqGroup.selectAllFaqGroup(context);


        request.setAttribute("grouplist", groupList);
        JSPManager.showJSP(request, response, "register/faq-group-list.jsp");

    }

    private void detailGroupFaq(HttpServletRequest request, HttpServletResponse response, FaqGroup f, Context c) throws ServletException, IOException,
            SQLException, AuthorizeException {

        log.info(LogManager.escapeLogField("edit_faq-group"));



        request.setAttribute("faqgroup", f);

        JSPManager.showJSP(request, response, "register/faq-group-edit.jsp");

    }

    private void editFaq(HttpServletRequest request, FaqGroup f) throws SQLException, AuthorizeException, IOException {

        int order = Integer.parseInt(request.getParameter("order"));
        String name = request.getParameter("name");

        log.info(LogManager.escapeLogField("edit_faq-group"));

        f.setGroupOrder(order);
        f.setGroupName(name);

        f.update();
    }


}