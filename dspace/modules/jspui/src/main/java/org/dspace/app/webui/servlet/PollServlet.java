package org.dspace.app.webui.servlet;

import br.com.dglsistemas.webui.utils.AuthorUtils;
import org.apache.log4j.Logger;
import org.dspace.app.webui.util.JSPManager;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Poll;
import org.dspace.core.Context;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * Created by brendows on 07/10/2016.
 */
public class PollServlet extends DSpaceServlet {

    private static Logger log = Logger.getLogger(PollServlet.class);
    public static final int UNIQUE_CONSTRAINT_VIOLATION = 1;


    protected void doDSGet(Context context, HttpServletRequest request,
                           HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException {


        String operation = request.getParameter("operation");


             if (operation.equalsIgnoreCase("list")) {


            Poll p = Poll.create(context);

            int a = p.selectnote1(context);
            int b = p.selectnote2(context);
            int c = p.selectnote3(context);
            int d = p.selectnote4(context);
            int e = p.selectnote5(context);
            int total = a + b + c + d + e;

            request.setAttribute("a", a);
            request.setAttribute("b", b);
            request.setAttribute("c", c);
            request.setAttribute("d", d);
            request.setAttribute("e", e);
            request.setAttribute("total", total);


            JSPManager.showJSP(request, response, "register/poll-list.jsp");

        } else if (operation.equalsIgnoreCase("listall")) {

           Poll p = Poll.create(context);
           List<Poll> pollList = Poll.selectallnotes(context);

            request.setAttribute("pollList", pollList);
            JSPManager.showJSP(request, response, "register/poll-list.jsp");
        }

        show(context, request, response);


    }

    protected void doDSPost(Context context, HttpServletRequest request,
                            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException {

        String operation = request.getParameter("operation");

        if (operation == null || operation.isEmpty()) {

            JSPManager.showJSP(request, response, "/feedback");


        } else if (operation != null) {

            if (operation.equalsIgnoreCase("create")) {

                if (checkRequiredFields(request)) {

                    String jsp = "/register/poll-success.jsp";

                    try {

                        context.turnOffAuthorisationSystem();

                        Poll p = Poll.create(context);

                        this.setPollProperties(request, p);

                        context.complete();

                        JSPManager.showJSP(request, response, jsp);


                    } catch (SQLException e) {

                        String message = e.getMessage();


                        if (UNIQUE_CONSTRAINT_VIOLATION == e.getErrorCode())

                        {
                            message = "Já recebemos sua avaliação, Obrigado!";
                        } else

                        {
                            if (message.contains("email")) {

                                message = "Já recebemos sua avaliação, Obrigado!";
                            }

                        }


                        request.setAttribute("errorMessage", message);

                        jsp = "feedback";


                    } catch (Exception e) {

                        log.error(response, e);

                        request.setAttribute("javax.servlet.error.exception", e);

                        jsp = "/error/internal.jsp";

                    } finally {

                        if (context != null && context.isValid()) {

                            context.abort();
                        }

                        JSPManager.showJSP(request, response, jsp);

                    }
                }

            } else if (operation.isEmpty() || operation.matches("") || operation.equals(null)) {

                JSPManager.showJSP(request, response, "/feedback");

            }

        }

    }

    private void setPollProperties(HttpServletRequest request, Poll p) throws SQLException, AuthorizeException {


        if (request.getParameter("email") != null && !request.getParameter("email").isEmpty()) {

            String email = request.getParameter("email");

            p.setEmail(email);
        } else {


        }

        if (request.getParameter("note") != null && !request.getParameter("note").isEmpty()) {

            String note = request.getParameter("note");

            int i = Integer.parseInt(note);

            p.setNote(i);
        } else {


        }

        p.update();


    }


    private boolean checkRequiredFields(HttpServletRequest request) {


        if (request.getParameter("email") != null && !request.getParameter("email").isEmpty()
                && AuthorUtils.validadeEmail(request.getParameter("email"))
                && request.getParameter("note") != null && !request.getParameter("note").isEmpty()) {
            return true;
        } else {
            return false;
        }
    }


    private void show(Context c, HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException {


        JSPManager.showJSP(request, response, "/feedback");
        return;

    }

}
