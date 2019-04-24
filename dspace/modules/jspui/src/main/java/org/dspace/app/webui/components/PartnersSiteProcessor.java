package org.dspace.app.webui.components;

import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Partners;
import org.dspace.core.Context;
import org.dspace.plugin.PluginException;
import org.dspace.plugin.SiteHomeProcessor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;

public class PartnersSiteProcessor implements SiteHomeProcessor
{

    /**
     * blank constructor - does nothing.
     *
     */
    public PartnersSiteProcessor()
    {

    }

    @Override
    public void process(Context context, HttpServletRequest request,
                        HttpServletResponse response) throws PluginException,
            AuthorizeException
    {
        // Get all active partners
        List<Partners> p;
        HashMap<Integer, List<Partners>> partners = new LinkedHashMap<>();
        try
        {
            p = Partners.selectAllActivepartners(context);
            for(Partners partner:p) {
                if(!partners.containsKey(partner.getGroup())){
                    partners.put(partner.getGroup(), new ArrayList<Partners>());
                }
                partners.get(partner.getGroup()).add(partner);
            }
        }
        catch (SQLException e)
        {
            throw new PluginException(e.getMessage(), e);
        }
        //request.setAttribute("partnersList", p);
        request.setAttribute("partnersList", partners);
    }

}
