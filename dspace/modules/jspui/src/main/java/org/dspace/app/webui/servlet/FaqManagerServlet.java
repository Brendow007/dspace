package org.dspace.app.webui.servlet;

import org.apache.log4j.Logger;
import org.dspace.app.webui.util.JSPManager;
import org.dspace.authorize.AuthorizeException;
import org.dspace.authorize.AuthorizeManager;
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
 * /**
 * Created by brendows on 17/08/2017.
 */
public class FaqManagerServlet extends DSpaceServlet {

    private static Logger log = Logger.getLogger(FaqManagerServlet.class);

    protected void doDSPost(Context context, HttpServletRequest request,
                            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException {

        String operation = request.getParameter("operation");

        if (AuthorizeManager.isAdmin(context)) {

            if (operation.equalsIgnoreCase("edit")) {

                context.turnOffAuthorisationSystem();

                Faq f = Faq.find(context, Integer.parseInt(request.getParameter("id")));

                editFaq(request, f);

                context.commit();

                show(context, request, response);

            } else {

                doDSGet(context, request, response);

            }


        }
    }

    protected void doDSGet(Context context, HttpServletRequest request,
                           HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException {

        if (AuthorizeManager.isAdmin(context)) {

            String operation = request.getParameter("operation");

            if (operation == null || operation.isEmpty()) {

                show(context, request, response);

            } else if (operation != null) {

                try {

                    if (!operation.equalsIgnoreCase("list")) {

                        if (operation.equalsIgnoreCase("create")) {

                            Faq f = Faq.create(context);

                            if (f != null) {

                                int i = f.countMaxQuestions(context);
                                int j = i + 1;

                                f.setQuestionID(j);
                                f.setGroupID(5);

                                f.setQuestion("Question " + j);
                                f.setAnswer("Answer " + j);
                                f.update();

                            }

                            show(context, request, response);

                        } else if (operation.equalsIgnoreCase("detail")) {

                            int faqid = Integer.parseInt(request.getParameter("id"));

                            Faq faq = Faq.find(context, faqid);

                            log.info(LogManager.getHeader(context, "list_faq_detail", "id: " + faqid));

                            int i = faq.countMaxQuestions(context);
                            int ii = faq.countMaxLimit(context,faq.getGroupID());

                            request.setAttribute("maxlimit", ii);
                            request.setAttribute("faqlimit", i);

                            detailFaq(request, response, faq, context);

                        } else if (operation.equalsIgnoreCase("remove")) {

                            if (request.getParameter("id") != null || !request.getParameter("id").isEmpty()) {

                                int faqid = Integer.parseInt(request.getParameter("id"));

                                Faq faq = Faq.find(context, faqid);

                                faq.delete();

                                show(context, request, response);

                            } else {

                                show(context, request, response);

                            }

                        }
                            context.commit();
                    } else {

                        show(context, request, response);

                    }
                    context.complete();

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
        }else {
            JSPManager.showJSP(request,response, "/error/authorize.jsp");

        }
    }

    private void editFaq(HttpServletRequest request, Faq f) throws SQLException, AuthorizeException, IOException {

        log.info(LogManager.escapeLogField("edit_faq"));

        int questionID = Integer.parseInt(request.getParameter("question_id"));
        int groupID = Integer.parseInt(request.getParameter("group_id"));

        String question = request.getParameter("question");
        String answer = request.getParameter("answer");

        f.setGroupID(groupID);
        f.setQuestionID(questionID);

        f.setQuestion(question);
        f.setAnswer(answer);

        f.update();
    }


    private void detailFaq(HttpServletRequest request, HttpServletResponse response, Faq f, Context c) throws ServletException, IOException,
            SQLException, AuthorizeException {


        injectGroupList(c, request);
        request.setAttribute("faq", f);
        JSPManager.showJSP(request, response, "register/faq-edit.jsp");

    }

    private void show(Context context, HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException {

        log.info(LogManager.getHeader(context, "List_Faq", ""));
        injectGroupList(context, request);

        List<Faq> faqlist = Faq.selectAllfaq(context);

        request.setAttribute("faqlist", faqlist);
        JSPManager.showJSP(request, response, "register/faq-list.jsp");


    }

    private void injectGroupList(Context context, HttpServletRequest request) throws ServletException, SQLException, AuthorizeException {

        List<FaqGroup> faqGroup = FaqGroup.selectAllFaqGroup(context);
        request.setAttribute("faqgroup", faqGroup);

    }

}
