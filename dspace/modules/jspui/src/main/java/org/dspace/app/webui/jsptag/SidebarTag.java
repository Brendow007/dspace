/**
 * The contents of this file are subject to the license and copyright detailed
 * in the LICENSE and NOTICE files at the root of the source tree and available
 * online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.webui.jsptag;

import org.dspace.app.webui.util.UIUtil;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.tagext.BodyTagSupport;
import javax.servlet.jsp.tagext.TagSupport;
import java.util.Locale;

/**
 * Tag for including a "sidebar" - a column on the right-hand side of the page.
 * Must be used within a dspace:layout tag.
 *
 * @author Peter Breton
 * @author Guilherme
 */
public class SidebarTag extends BodyTagSupport {

    public SidebarTag() {
        super();
    }

    public int doAfterBody() throws JspException {

        HttpServletRequest request = (HttpServletRequest) pageContext.getRequest();
        Locale sessionLocale = UIUtil.getSessionLocale(request);
        LayoutTag tag = (LayoutTag) TagSupport.findAncestorWithClass(this, LayoutTag.class);

        if (tag == null) {
            throw new JspException(
                    "Sidebar tag must be in an enclosing Layout tag");
        }

        String staticPagesDir = request.getContextPath() + "/static/pages";

        StringBuilder builder = new StringBuilder();

//        builder.append("<aside>");
//        builder.append("<span class=\"logoEducapes\">Logo Educapes</span>");
//        builder.append("<span class=\"logoCapes\">Logo Capes</span>");
//        builder.append("<nav>");
//        builder.append("<h2>" + LocaleSupport.getLocalizedMessage(pageContext, "jsp.sidebar.mainmenu.title") + "</h2>");
//        builder.append("<ul>");
//        builder.append("<li><a href=\"" + staticPagesDir + "/about.jsp\">" + LocaleSupport.getLocalizedMessage(pageContext, "jsp.sidebar.mainmenu.whatis") + "</a></li>");
//        builder.append("<li><a href=\"" + staticPagesDir + "/search.jsp\">" + LocaleSupport.getLocalizedMessage(pageContext, "jsp.sidebar.mainmenu.search") + "</a></li>");
//        builder.append("<li><a href=\"" + staticPagesDir + "/partners.jsp\">" + LocaleSupport.getLocalizedMessage(pageContext, "jsp.sidebar.mainmenu.partners") + "</a></li>");
//        builder.append("<li><a href=\"" + request.getContextPath() + "/feedback\">" + LocaleSupport.getLocalizedMessage(pageContext, "jsp.sidebar.mainmenu.contact") + "</a></li>");
//        builder.append("</ul>");
//        builder.append("</nav>");
        builder.append(getBodyContent().getString());
//        builder.append("<nav>");
//        builder.append("<h2>" + LocaleSupport.getLocalizedMessage(pageContext, "jsp.sidebar.submitmenu.title") + "</h2>");
//        builder.append("<ul>");
//        builder.append("<li><a href=\"" + staticPagesDir + "/submission.jsp\">" + LocaleSupport.getLocalizedMessage(pageContext, "jsp.sidebar.submitmenu.submit") + "</a></li>");
//        builder.append("</ul>");
//        builder.append("</nav>");
//        builder.append("</aside>");

        tag.setSidebar(builder.toString());

        return SKIP_BODY;
    }
}
