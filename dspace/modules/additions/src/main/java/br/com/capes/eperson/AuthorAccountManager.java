/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package br.com.capes.eperson;

import org.apache.log4j.Logger;
import org.dspace.core.ConfigurationManager;
import org.dspace.core.Context;
import org.dspace.core.Email;
import org.dspace.core.I18nUtil;

import javax.mail.MessagingException;
import java.io.IOException;
import java.util.Locale;

/**
 *
 * @author Guilherme
 */
public class AuthorAccountManager {

    /**
     * log4j log
     */
    private static Logger log = Logger.getLogger(AuthorAccountManager.class);

    /**
     * Protected Constructor
     */
    protected AuthorAccountManager() {
    }

    /**
     *
     */
    public static void sendRefusedAccountEmail(Context context, String email, String cause, int authorId, String token) throws IOException, MessagingException {

        String base = ConfigurationManager.getProperty("dspace.url");

        StringBuilder urlBUilder = new StringBuilder();
        urlBUilder.append(base);
        urlBUilder.append("/register/edit-author?aid=");
        urlBUilder.append(authorId);
        urlBUilder.append("&t=");
        urlBUilder.append(token);
        urlBUilder.append("&operation=edit");

        Locale locale = context.getCurrentLocale();
        Email bean = Email.getEmail(I18nUtil.getEmailFilename(locale, "author_refused"));
        bean.addRecipient(email);
        bean.addArgument(cause);
        bean.addArgument(urlBUilder.toString());
        bean.send();

        // Breadcrumbs
        if (log.isInfoEnabled()) {
            log.info("Sent author_refused information to " + email);
        }

    }
    
    /**
     *
     */
    public static void sendAcceptedAccountEmail(Context context, String email) throws IOException, MessagingException {

        String base = ConfigurationManager.getProperty("dspace.url");

        String specialLink = new StringBuffer().append(base).toString();
        Locale locale = context.getCurrentLocale();
        Email bean = Email.getEmail(I18nUtil.getEmailFilename(locale, "author_accepted"));
        bean.addRecipient(email);
        bean.addArgument(specialLink);
        bean.send();

        // Breadcrumbs
        if (log.isInfoEnabled()) {
            log.info("Sent author_accepted information to " + email);
        }

    }

}
