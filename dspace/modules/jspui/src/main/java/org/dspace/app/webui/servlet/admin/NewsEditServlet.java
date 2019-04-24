/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 * <p>
 * http://www.dspace.org/license/
 */
package org.dspace.app.webui.servlet.admin;

import org.apache.commons.lang3.StringUtils;
import org.dspace.app.webui.servlet.DSpaceServlet;
import org.dspace.app.webui.util.JSPManager;
import org.dspace.app.webui.util.UIUtil;
import org.dspace.authorize.AuthorizeException;
import org.dspace.core.Context;
import org.dspace.core.NewsManager;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

/**
 * Servlet for editing the front page news
 *
 * @author gcarpent
 */
public class NewsEditServlet extends DSpaceServlet {
    protected void doDSGet(Context c, HttpServletRequest request,
                           HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException {
        //always go first to news-main.jsp
        JSPManager.showJSP(request, response, "/dspace-admin/news-main.jsp");
    }

    protected void doDSPost(Context c, HttpServletRequest request,
                            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException {
        //Get submit button
        String button = UIUtil.getSubmitButton(request, "submit");

        String news = "";
        String imageExtraction = "";
        //String image = "";
        //Index element
        //int startIdx;
        //int endIdx;
        //Are we editing the top news or the sidebar news?
        String position = request.getParameter("position");

        if (button.equals("submit_edit")) {
            //get the existing text from the file
            news = NewsManager.readNewsFile(position);

//            if (StringUtils.isBlank(news)) {
//                news = "";
//            } else {
//                StringBuilder strImage = new StringBuilder(news);
//                StringBuilder strText = new StringBuilder(news);
//                if (strImage.toString().contains("<img")) {
//                    //Extract image from html
//                    startIdx = strImage.indexOf("<img");
//                    endIdx = strImage.indexOf(">");
//                    ++endIdx;
//                    imageExtraction = strImage.substring(startIdx, endIdx);
//
//                    //Remove image from text
//                    strText = strImage.replace(startIdx,endIdx,"");
//                    news = strText.toString();
//                } else {
//                    imageExtraction = "";
//                }
//            }


            //pass the position back to the JSP
            //pass the existing news back to the JSP
            //pass the existing image back to the JSP

            request.setAttribute("position", position);
            request.setAttribute("news", news);
            request.setAttribute("image", imageExtraction);

            //show news edit page
            JSPManager.showJSP(request, response, "/dspace-admin/news-edit.jsp");


        } else if (button.equals("submit_save")) {
            //get text string from form
            news = (String) request.getParameter("news");
//            image = (String) request.getParameter("image");
//            news += image;
            if (StringUtils.isBlank(news)) {
                news = news.replaceAll(" ", "");
            }
            //write the string out to file
            NewsManager.writeNewsFile(position, news);

            JSPManager.showJSP(request, response, "/dspace-admin/news-main.jsp");
        } else if (button.equals("submit_upload_image")) {
            //the user hit cancel, so return to the main news edit page
            JSPManager.showJSP(request, response, "/");
        } else {
            //the user hit cancel, so return to the main news edit page
            JSPManager.showJSP(request, response, "/dspace-admin/news-main.jsp");
        }

        c.complete();
    }
}
