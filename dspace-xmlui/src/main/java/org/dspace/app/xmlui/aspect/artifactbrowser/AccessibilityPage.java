package org.dspace.app.xmlui.aspect.artifactbrowser;

import org.apache.log4j.Logger;
import org.dspace.app.xmlui.cocoon.AbstractDSpaceTransformer;
import org.dspace.app.xmlui.wing.WingException;
import org.dspace.app.xmlui.wing.element.Body;
import org.dspace.app.xmlui.wing.element.Division;
import org.dspace.app.xmlui.wing.element.PageMeta;
import org.xml.sax.SAXException;
import org.dspace.app.xmlui.wing.Message;

/**
 * Exibi informacoes sobre acessibilidade do site.
 *
 * @author Guilherme Lemeszenski
 */
public class AccessibilityPage extends AbstractDSpaceTransformer {

    public static final Message T_dspace_home
            = message("xmlui.general.dspace_home");
    public static final Message T_title
            = message("xmlui.ArtifactBrowser.AccessibilityPage.title");
    public static final Message T_trail
            = message("xmlui.ArtifactBrowser.AccessibilityPage.trail");
    public static final Message T_head
            = message("xmlui.ArtifactBrowser.AccessibilityPage.head");
    public static final Message T_para
            = message("xmlui.ArtifactBrowser.AccessibilityPage.para");

    private static Logger log = Logger.getLogger(AccessibilityPage.class);

    /**
     * Add a page title and trail links.
     */
    public void addPageMeta(PageMeta pageMeta) throws SAXException, WingException {
        pageMeta.addMetadata("title").addContent(T_title);
        pageMeta.addTrailLink(contextPath + "/", T_dspace_home);
        pageMeta.addTrail().addContent(T_trail);
    }

    /**
     * Add some basic contents
     */
    public void addBody(Body body) throws SAXException, WingException {
        Division division = body.addDivision("accessibility-page", "primary");
        division.setHead(T_head);
        division.addPara(T_para);
    }
}
