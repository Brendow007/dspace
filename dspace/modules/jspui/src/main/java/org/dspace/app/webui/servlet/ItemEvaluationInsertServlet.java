package org.dspace.app.webui.servlet;

import org.apache.log4j.Logger;
import org.dspace.app.webui.util.JSPManager;
import org.dspace.app.webui.util.UIUtil;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.dspace.core.LogManager;
import org.dspace.handle.HandleManager;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

/**
 * Created by Daniel on 31/07/2016.
 */
public class ItemEvaluationInsertServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response) throws ServletException, IOException
    {
      /*  int internalID = UIUtil.getIntParameter(request, "item_id");
        int grade =  UIUtil.getIntParameter(request, "grade_typed");
        */
        Context context = null;

        try {

            context = UIUtil.obtainContext(request);


            /* se for uma denuncia*/
            if(request.getParameter("vname")!=null){
                UIUtil.sendDenunciation(request);
                log.info(LogManager.getHeader(context,"Denunciation completed" ,UIUtil.getOriginalURL(request)+ " "+ UIUtil.getRequestLogInfo(request)));

                response.setContentType("text/plain");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("Denuncia enviada com sucesso!");
                return;
            }else {
                response.setContentType("text/plain");
                response.setCharacterEncoding("UTF-8");
//                response.getWriter().write("Por favor, o campo de denuncia é obrigatório!");
            }

            // set all incoming encoding to UTF-8
            request.setCharacterEncoding("UTF-8");

            int grade = Integer.parseInt(request.getParameter("grade"));


            int internalID = Integer.parseInt(request.getParameter("item_id"));


            String handle = request.getParameter("handle");
            boolean showError = false;

            // See if an item ID or Handle was passed in
            Item itemToEdit = null;

            if (internalID > 0) {

                itemToEdit = Item.find(context, internalID);


                showError = (itemToEdit == null);
            } else if ((handle != null) && !handle.equals("")) {
                // resolve handle
                DSpaceObject dso = null;
                dso = HandleManager.resolveToObject(context, handle.trim());

                // make sure it's an ITEM
                if ((dso != null) && (dso.getType() == Constants.ITEM)) {
                    itemToEdit = (Item) dso;
                    showError = false;
                } else {
                    showError = true;
                }
            }



            int iid = itemToEdit.getID();


            log.info("Grade: " + grade + " item id: " + iid);





            if (grade <= 0 || grade > 5){

                response.setContentType("text/plain");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("Nota inválida!");


            }else {itemToEdit.insertItemEvaluation(grade, iid, "teste");
                //JSPManager.showJSP(request, response, "/item-evaluation-inserted.jsp");
                response.setContentType("text/plain");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("Avaliação inserida com sucesso!");


            }


        }catch (SQLException se)
            {
                // For database errors, we log the exception and show a suitably
                // apologetic error
                log.warn(LogManager.getHeader(context, "database_error", se
                        .toString()), se);

                // Also email an alert
                UIUtil.sendAlert(request, se);

                JSPManager.showInternalError(request, response);
            }

        return;
    }

    private static final Logger log = Logger.getLogger(DSpaceObject.class);






}
