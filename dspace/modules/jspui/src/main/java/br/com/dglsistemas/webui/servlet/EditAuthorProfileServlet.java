/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package br.com.dglsistemas.webui.servlet;

import br.com.capes.eperson.Author;
import br.com.dglsistemas.webui.utils.AuthorUtils;
import org.apache.log4j.Logger;
import org.dspace.app.webui.servlet.DSpaceServlet;
import org.dspace.app.webui.util.JSPManager;
import org.dspace.authorize.AuthorizeException;
import org.dspace.core.Context;
import org.dspace.eperson.EPerson;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

/**
 * Servlet for handling editing user profiles
 *
 * @author Guilherme Lemeszenski
 * @version $Revision$
 */
public class EditAuthorProfileServlet extends DSpaceServlet {

    /**
     * Logger
     */
    private static Logger log = Logger.getLogger(EditAuthorProfileServlet.class);
    public static final int UNIQUE_CONSTRAINT_VIOLATION = 1;

    protected void doDSGet(Context context, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException {

        String operation = request.getParameter("operation");

        if (operation != null && operation.equals("edit")) {
            String id = request.getParameter("aid");
            String token = request.getParameter("t");

            Author author = Author.find(context, Integer.parseInt(id));
            
            String authorToken = author.getToken();

            if (author != null && authorToken != null && authorToken.equals(token)) {

                request.setAttribute("author", author);

            } else {
                JSPManager.showJSP(request, response, "/error/authorize.jsp");
                return;
            }
        }

        JSPManager.showJSP(request, response, "/register/author-form.jsp");

    }

    protected void doDSPost(Context context, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException {

        String operation = request.getParameter("operation");

        if (operation == null || operation.isEmpty()) {

            JSPManager.showJSP(request, response, "/register/author-form.jsp");

        } else if (operation != null) {

            if (operation.equals("create")) {

                if (checkRequiredFields(request)) {

                    String jsp = "/register/author-sucess.jsp";

                    try {

                        if (request.getParameter("author_id") == null || request.getParameter("author_id").isEmpty()) {
                            context.turnOffAuthorisationSystem();
                            EPerson eperson = EPerson.create(context);
                            this.setUserProfile(eperson, request);

                            Author author = Author.create(context);
                            this.setAuthorProperties(request, author, eperson);

                            context.complete();
                        } else {
                            int authorId = Integer.parseInt(request.getParameter("author_id"));
                            Author author = Author.find(context, authorId);

                            if (author != null && author.getToken().equals(request.getParameter("token"))) {
                                EPerson eperson = author.getEPerson();
                                this.setUserProfile(eperson, request);
                                this.setAuthorProperties(request, author, eperson);

                                context.complete();
                            } else {
                                log.warn("Author ID is invalid or Author and token does not match. [ID=" + authorId + "]");
                                request.setAttribute("errorMessage", "Operação não permitida!");
                                jsp = "/error/authorize.jsp";
                            }
                        }

                    } catch (SQLException e) {

                        String message = e.getMessage();



                        if(UNIQUE_CONSTRAINT_VIOLATION  == e.getErrorCode())

                        {
                            message = "Erro: CPF ou Endereço de e-mail já cadastrados";
                        }


                        if(message.contains("email")){

                                message = "Erro: Endereço de e-mail já cadastrado *";
                          }

                        if(message.contains("cpf")){

                                message = "Erro: CPF já cadastrado *";
                          }




                        request.setAttribute("errorMessage", message);

                        jsp = "/register/author-form.jsp";


                    } catch (Exception e) {

                        log.error(response, e);
                        request.setAttribute("javax.servlet.error.exception", e);
                        jsp = "/error/internal.jsp";
                    } finally {

                        context.restoreAuthSystemState();

                        // Clean up our context, if it still exists & it was never completed
                        if (context != null && context.isValid()) {
                            context.abort();
                        }

                        JSPManager.showJSP(request, response, jsp);
                    }

                } else {
                    request.setAttribute("errorMessage", "Um ou mais campos não foram preenchidos corretamente, por favor tente novamente");
                    JSPManager.showJSP(request, response, "/register/author-form.jsp");
                }

            } else if (operation.equals("edit")) {

                try {
                    context.turnOffAuthorisationSystem();
                    int id = Integer.parseInt(request.getParameter("author_id"));
                    Author author = Author.find(context, id);

                    this.setUserProfile(author.getEPerson(), request);

                    this.setAuthorProperties(request, author, author.getEPerson());

                    context.complete();
                    JSPManager.showJSP(request, response, "/register/author-sucess.jsp");

                } catch (Exception e) {
                    log.error(response, e);
                    request.setAttribute("javax.servlet.error.exception", e);
                    JSPManager.showJSP(request, response, "/error/internal.jsp");
                } finally {
                    // Clean up our context, if it still exists & it was never completed
                    if (context != null && context.isValid()) {
                        context.abort();
                    }
                }

            }

        }
    }

    /**
     *
     */
    public void setUserProfile(EPerson eperson,
            HttpServletRequest request) throws SQLException, AuthorizeException {
        // Get the parameters from the form
        String lastName = request.getParameter("last_name");
        String firstName = request.getParameter("first_name");
        String phone = request.getParameter("phone");
        String language = request.getParameter("language");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        // Update the eperson
        eperson.setEmail(email);
        eperson.setFirstName(firstName);
        eperson.setLastName(lastName);
        eperson.setMetadata("phone", phone);
        eperson.setLanguage(language);
        eperson.setPassword(password);

        eperson.setSelfRegistered(true);
        eperson.setCanLogIn(false);
        eperson.setRequireCertificate(false);

        eperson.update();
    }

    /**
     *
     */
    private boolean checkRequiredFields(HttpServletRequest request) {

        String password = (String) request.getParameter("password");
        String passwordConfirmation = (String) request.getParameter("password_confirmation");

        if (request.getParameter("last_name") != null && !request.getParameter("last_name").isEmpty()
                && request.getParameter("first_name") != null && !request.getParameter("first_name").isEmpty()
                //&& request.getParameter("phone") != null && !request.getParameter("phone").isEmpty()
                && AuthorUtils.validadeEmail(request.getParameter("email"))
                && AuthorUtils.validatecpf(request.getParameter("cpf"))
                && password != null && !password.isEmpty()
                && passwordConfirmation != null && !passwordConfirmation.isEmpty()
                && password.equals(passwordConfirmation)
                && request.getParameter("institution_name") != null && !request.getParameter("institution_name").isEmpty()
                && request.getParameter("institution_shortname") != null && !request.getParameter("institution_shortname").isEmpty()
                && request.getParameter("department") != null && !request.getParameter("department").isEmpty()
                && request.getParameter("job_function") != null && !request.getParameter("job_function").isEmpty()
                && request.getParameter("item_count") != null && !request.getParameter("item_count").isEmpty()) {
            return true;
        } else {
            return false;
        }
    }

    /**
     *
     */
    private void setAuthorProperties(HttpServletRequest request, Author author, EPerson eperson) throws SQLException, AuthorizeException {

        author.setEPersonId(eperson.getID());
        author.setInstitutionName(request.getParameter("institution_name"));
        author.setInstitutionShortName(request.getParameter("institution_shortname"));
        author.setCpf(request.getParameter("cpf"));
        author.setDepartment(request.getParameter("department"));
        author.setJobTitle(request.getParameter("job_function"));

        if (request.getParameter("celphone") != null && !request.getParameter("celphone").isEmpty()) {
            author.setCelphone(request.getParameter("celphone"));
        }

        if (request.getParameter("institution_site") != null && !request.getParameter("institution_site").isEmpty()) {
            author.setInstitutionSite(request.getParameter("institution_site"));
        }

        if (request.getParameter("institution_repository") != null && !request.getParameter("institution_repository").isEmpty()) {
            author.setInstitutionRepository(request.getParameter("institution_repository"));
        }

        if (request.getParameter("institution_ava") != null && !request.getParameter("institution_ava").isEmpty()) {
            author.setInstitutionAva(request.getParameter("institution_ava"));
        }

        author.setItemCount(Integer.parseInt(request.getParameter("item_count")));
        author.setActive(false);

        author.update();
    }
}
