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
 * Exibe informacoes sobre RSS do site.
 * https://wiki.duraspace.org/display/DSPACE/Manakin+theme+tutorial#Manakinthemetutorial-Addingstaticpages
 *
 * @author Guilherme Lemeszenski
 */
public class RssPage extends AbstractDSpaceTransformer {

    public static final Message T_dspace_home
            = message("xmlui.general.dspace_home");
    public static final Message T_title
            = message("xmlui.ArtifactBrowser.RssPage.title");
    public static final Message T_trail
            = message("xmlui.ArtifactBrowser.RssPage.trail");
    public static final Message T_head
            = message("xmlui.ArtifactBrowser.RssPage.head");
    public static final Message T_para
            = message("xmlui.ArtifactBrowser.RssPage.para");

    private static Logger log = Logger.getLogger(RssPage.class);

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
        Division division = body.addDivision("rss-page", "primary");
        division.setHead(T_head);
        division.addPara(T_para);
    }
}
