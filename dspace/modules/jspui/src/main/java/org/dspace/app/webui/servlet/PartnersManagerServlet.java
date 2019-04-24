package org.dspace.app.webui.servlet;

import br.com.dglsistemas.webui.utils.FileUploadPartnersRequest;
import org.apache.commons.fileupload.FileUploadBase;
import org.apache.log4j.Logger;
import org.dspace.app.webui.util.FileUploadRequest;
import org.dspace.app.webui.util.JSPManager;
import org.dspace.authorize.AuthorizeException;
import org.dspace.authorize.AuthorizeManager;
import org.dspace.content.Partners;
import org.dspace.core.ConfigurationManager;
import org.dspace.core.Context;
import org.dspace.core.LogManager;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;


public class PartnersManagerServlet extends DSpaceServlet {

    private static final String DSPACEDIR = (ConfigurationManager.getProperty("dspace.dir"));
    private static final String DIR = "/webapps/jspui/image/img/parceiros/";
    private static final String PATHDIR = DSPACEDIR + DIR;


    private static Logger log = Logger.getLogger(PartnersManagerServlet.class);

    protected void doDSPost(Context context, HttpServletRequest request,
                            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException {


        String operation = request.getParameter("operation");

        if (AuthorizeManager.isAdmin(context)) {

            String contentType = request.getContentType();

            if ((contentType != null) && (contentType.indexOf("multipart/form-data") != -1)) {
                try {

                    FileUploadPartnersRequest wrapper = new FileUploadPartnersRequest(request);

                    String uploadOp = wrapper.getParameter("operation");
                    String idString = wrapper.getParameter("partner_id");
                    if (wrapper.getFile("file").getName() == null || wrapper.getFile("file").getName().isEmpty()) {

                        returnMainPage(context, request, response);

                    } else if (idString != null && uploadOp != null && wrapper.getFile("file").getName() != null) {
                        int id = Integer.parseInt(idString);
                        Partners p = Partners.find(context, id);

                        /**
                         * delete old file from DIR
                         */
                        deleteFilePartner(p);


                        /**
                         * update path name on partner
                         */
                        File f = wrapper.getFile("file");
                        p.setPath(f.getName());
                        p.update();

                    } else {

                        uploadFile(context, wrapper);
                    }


                    context.commit();

                } catch (Exception e) {

                    log.info(e.getMessage(), e);

                }

            } else if (operation != null && !operation.isEmpty()) {

                if (request.getParameter("partner_id") == null || request.getParameter("partner_id").isEmpty()) {

                    returnMainPage(context, request, response);


                } else if (request.getParameter("partner_id") != null || !request.getParameter("partner_id").isEmpty()) {

                    if (operation.equalsIgnoreCase("delete")) {

                        int id = Integer.parseInt(request.getParameter("partner_id"));
                        Partners partner = Partners.find(context, id);
                        deleteFilePartner(partner);
                        partner.delete();

                    } else if (operation.equalsIgnoreCase("updated")) {

                        int id = Integer.parseInt(request.getParameter("partner_id"));
                        Partners partner = Partners.find(context, id);
                        updatePartners(partner, request);
                    }

                } else {
                    returnMainPage(context, request, response);
                }

                //commit just exist valid op
                context.commit();

            }

        } else {
            returnMainPage(context, request, response);
        }

        returnMainPage(context, request, response);

    }

    protected void doDSGet(Context context, HttpServletRequest request,
                           HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException {

        String operation = request.getParameter("operation");

        if (operation == null || operation.isEmpty()) {

            doDSPost(context, request, response);

        } else if (operation.equalsIgnoreCase("edit")) {

            int id = Integer.parseInt(request.getParameter("partner_id"));
            Partners p = Partners.find(context, id);
            int LimitPartnersByGroup = p.countMaxOrderByGroup(context, p.getGroup());
            int GroupLimit = p.countMaxLimit(context);

            request.setAttribute("partner", p);
            request.setAttribute("limitGroup", GroupLimit);
            request.setAttribute("limitOrder", LimitPartnersByGroup);

            JSPManager.showJSP(request, response, "register/partners-detail.jsp");

        } else if (operation.equalsIgnoreCase("edit_logo")) {

            int id = Integer.parseInt(request.getParameter("partner_id"));

            Partners p = Partners.find(context, id);


            request.setAttribute("partner", p);

            JSPManager.showJSP(request, response, "register/partners-upload-logo.jsp");

        } else {

            doDSPost(context, request, response);
        }
    }


    public void returnMainPage(Context c, HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException, SQLException {

        log.info(LogManager.getHeader(c, "list_partners", ""));

        int groupLimit = Partners.countMaxLimit(c);


        List<Partners> partnersList = Partners.selectAllpartners(c);


        request.setAttribute("groupLimit", groupLimit);
        request.setAttribute("partnersList", partnersList);

        JSPManager.showJSP(request, response, "register/partners-list.jsp");

    }

    private void uploadFile(Context context, FileUploadPartnersRequest wrapper) throws IOException, SQLException, AuthorizeException, NullPointerException {

        try {
            Partners p = Partners.Create(context);

            createPartners(p, wrapper, context);

        } catch (Exception e) {
            log.info("Exception::" + e.getMessage());
        }


    }

    private void deleteFilePartner(Partners partner) {


        File deleteFile = new File(PATHDIR + partner.getPath());

        if (deleteFile.exists()) {

            if (deleteFile.getName().equals(partner.getPath())) {

                deleteFile.delete();

            }
        }

    }


    private void createPartners(Partners p, FileUploadPartnersRequest request, Context c) throws IOException, SQLException, AuthorizeException {

        File file = request.getFile("file");
        String path = "";

        if (request.getParameter("url") != null && !request.getParameter("url").isEmpty()
                || request.getParameter("name") != null && !request.getParameter("name").isEmpty()
                || request.getParameter("status") != null && !request.getParameter("status").isEmpty()
//                || request.getParameter("order") != null && !request.getParameter("order").isEmpty()
                || request.getParameter("group") != null && !request.getParameter("group").isEmpty()) {


            String url = request.getParameter("url");
            String name = request.getParameter("name");
            Boolean status = Boolean.valueOf(request.getParameter("status"));
//            int order = Integer.parseInt(request.getParameter("order"));
            int group = Integer.parseInt(request.getParameter("group"));

            if (file.getName() == null || file.getName().isEmpty()) {
                p.setPath("sem_arquivo");
                p.setStatus(false);
            } else {
                path = file.getName();
                p.setPath(path);
                p.setStatus(status);
            }

            int i = 1;
            i += p.countMaxOrderByGroup(c, group);


            p.setName(name);
            p.setUrl(url);
            p.setGroup(group);
            p.setOrderPartner(i);

        } else {

            p.setPath(request.getTmpPathFile());
            p.setName("nome-parceiro");
            p.setUrl("url-parceiro");
            p.setGroup(0);
            p.setOrderPartner(0);
            p.setStatus(false);

        }


        p.update();

        log.info(LogManager.escapeLogField("create_partner::" + p.getID() + "->" + p.getName() + "->" + file.getName()));


    }

    private void updatePartners(Partners p, HttpServletRequest request) throws SQLException, AuthorizeException {

        if (request.getParameter("url") != null && !request.getParameter("url").isEmpty()
                || request.getParameter("name") != null && !request.getParameter("name").isEmpty()
                || request.getParameter("status") != null && !request.getParameter("status").isEmpty()
                || request.getParameter("order") != null && !request.getParameter("order").isEmpty()
                || request.getParameter("group") != null && !request.getParameter("group").isEmpty()) {


            int group = Integer.parseInt(request.getParameter("group"));
            int order = Integer.parseInt(request.getParameter("order"));
            Boolean status = Boolean.valueOf(request.getParameter("status"));
            String name = request.getParameter("name");
            String url = request.getParameter("url");


            p.setGroup(group);
            p.setOrderPartner(order);
            p.setStatus(status);
            p.setName(name);
            p.setUrl(url);

        } else {

            p.setStatus(false);

        }

        p.update();

        log.info("update_partner::" + p.getID() + " " + p.getName());

    }


    private void validatePartner(HttpServletRequest request) throws IOException {

        try {

            FileUploadRequest wrapper = new FileUploadRequest(request);
            File temp = wrapper.getFile("file");


        } catch (FileUploadBase.FileSizeLimitExceededException e) {

            log.info(e.getMessage(), e);

        }


    }

}
