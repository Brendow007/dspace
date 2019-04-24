/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.dspace.content.crosswalk;

import org.apache.log4j.Logger;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.jdom.Element;
import org.jdom.Namespace;

import java.io.IOException;
import java.sql.SQLException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 *
 * @author Guilherme Lemeszenski
 * @version $Revision: 1 $
 */
public class OBAAIngestionCrosswalk implements IngestionCrosswalk{
    
    /** log4j category */
    private static Logger log = Logger.getLogger(OBAAIngestionCrosswalk.class);
    
    private static final String OBAA_NAMESPACE = "http://ltsc.ieee.org/xsd/LOM";
    
    @Override
    public void ingest(Context context, DSpaceObject dso, List<Element> elements) throws CrosswalkException, IOException, SQLException, AuthorizeException {
        
        Element wrapper = new Element("wrap", elements.get(0).getNamespace());
        wrapper.addContent(elements);

        ingest(context,dso,wrapper);
    }

    @Override
    public void ingest(Context context, DSpaceObject dso, Element root) throws CrosswalkException, IOException, SQLException, AuthorizeException {
        
        log.info("Harvesting OBAA record");
        
        if (dso.getType() != Constants.ITEM)
        {
            throw new CrosswalkObjectNotSupported("OBAAIngestionCrosswalk can only crosswalk an Item.");
        }
        
        Item item = (Item)dso;
        if (root == null)
        {
            System.err.println("The element received by ingest was null");
            return;
        }
        
        List<Element> children = (List<Element>) root.getChildren();
        
        DateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
        item.addMetadata("dc", "date", "issued", null, formatter.format(new Date()));

        for(Element element : children)
        {
            if(element.getName().equalsIgnoreCase("general"))
            {
                Element titleElement = element.getChild("title", Namespace.getNamespace(OBAA_NAMESPACE));
                if(titleElement != null && !titleElement.getTextTrim().isEmpty())
                {
                    item.addMetadata("dc", "title", null, null, titleElement.getTextTrim());
                }

                List<Element> generalChildrenTitle = (List<Element>) element.getChildren("title", Namespace.getNamespace(OBAA_NAMESPACE));
                if(generalChildrenTitle != null && generalChildrenTitle.size() > 0)
                {
                    for(Element chieldElement : generalChildrenTitle)
                    {
                        if(!chieldElement.getTextTrim().equals(titleElement.getTextTrim()))
                        {
                            item.addMetadata("dc", "title", "alternative", null, chieldElement.getTextTrim());
                        }
                    }
                }

                List<Element> generalChildrenKeyword = (List<Element>) element.getChildren("keyword", Namespace.getNamespace(OBAA_NAMESPACE));
                if(generalChildrenKeyword != null && generalChildrenKeyword.size() > 0)
                {
                    for(Element chieldElement : generalChildrenKeyword)
                    {
                        item.addMetadata("dc", "subject", null, null, chieldElement.getTextTrim());
                    }
                }

                Element descriptionElement = element.getChild("description", Namespace.getNamespace(OBAA_NAMESPACE));
                if(descriptionElement != null && !descriptionElement.getTextTrim().isEmpty())
                {
                    item.addMetadata("dc", "description", "abstract", null, descriptionElement.getTextTrim());
                }
            }
            else if(element.getName().equalsIgnoreCase("lifeCycle"))
            {
                List<Element> generalChildrenContribute = (List<Element>) element.getChildren("contribute", Namespace.getNamespace(OBAA_NAMESPACE));
                if(generalChildrenContribute != null && generalChildrenContribute.size() > 0)
                {
                    for(Element chieldElement : generalChildrenContribute)
                    {
                        if(chieldElement.getChild("role", Namespace.getNamespace(OBAA_NAMESPACE)).getTextTrim().equalsIgnoreCase("author"))
                        {
                            item.addMetadata("dc", "contributor", "author", null, chieldElement.getChild("entity", Namespace.getNamespace(OBAA_NAMESPACE)).getTextTrim());
                        }

                    }
                }
            }
            else if(element.getName().equalsIgnoreCase("technical"))
            {
                List<Element> generalChildrenLocation = (List<Element>) element.getChildren("location", Namespace.getNamespace(OBAA_NAMESPACE));
                if(generalChildrenLocation != null && generalChildrenLocation.size() > 0)
                {
                    for(Element chieldElement : generalChildrenLocation)
                    {
                        Pattern p = Pattern.compile("^(http|https){1}(.)+");
                        Matcher m = p.matcher(chieldElement.getTextTrim());
                        if(m.matches())
                        {
                            item.addMetadata("dc", "identifier", null, null, chieldElement.getTextTrim());
                        }
                    }
                }
            }

        }

    }

    @Override
    public void ingest(Context context, DSpaceObject dso, Element root, int colId) throws CrosswalkException, IOException, SQLException, AuthorizeException {

    }

}