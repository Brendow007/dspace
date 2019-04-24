<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Formats JSP
  -
  - Note that this is a "stand-alone" JSP that is invoked directly, and not
  - via a Servlet.  
  - This page involves no user interaction, but needs to be a JSP so that it
  - can retrieve the bitstream formats from the database.
  -
   --%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt"
    prefix="fmt" %>


<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="java.sql.SQLException" %>

<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>

<%@ page import="org.apache.log4j.Logger" %>

<%@ page import="org.dspace.app.webui.util.JSPManager" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.content.BitstreamFormat" %>
<%@ page import="org.dspace.core.Context" %>
<%@ page import="org.dspace.core.LogManager" %>

<%
    Context context = null;
    BitstreamFormat[] formats = null;
    
    try
    {
        // Obtain a context so that the location bar can display log in status
        context = UIUtil.obtainContext(request);
      
       // Get the Bitstream formats
        formats = BitstreamFormat.findAll(context);
    }
    catch (SQLException se)
    {
        // Database error occurred.
        Logger log = Logger.getLogger("org.dspace.jsp");
        log.warn(LogManager.getHeader(context,
            "database_error",
            se.toString()), se);

        // Also email an alert
        UIUtil.sendAlert(request, se);

        JSPManager.showInternalError(request, response);
    }
    finally {
        context.abort();
    }
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<title>
	<fmt:message key="jsp.help.formats.title"/></title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<link rel="stylesheet" href="../styles.css" type="text/css"/>
</head>
<body class="help">

<%-- <h2 align="center"><a name="top">DSpace Supported Formats</a></h2> --%>
<h2 align="center"><a name="top"><fmt:message key="jsp.help.break-file.title"/></a></h2>
<p align="right"><a href="<%= LocaleSupport.getLocalizedMessage(pageContext, "help.index")%>"><fmt:message key="jsp.help.formats.return"/></a></p>

<%-- <h5><a href="#policy">Format Support Policy</a></h5> --%>
<h5><a href="#policy"><fmt:message key="jsp.help.break.file.zip"/></a></h5>
<%-- <h5><a href="#formats">Format Support Levels</a></h5> --%>
<h5><a href="#formats"><fmt:message key="jsp.help.break.file.unzip"/></a></h5>
<p>&nbsp;</p>
<table>
    <tr>
    <%-- <td class="leftAlign"><a name="policy"></a><strong>FORMAT SUPPORT POLICY</strong></td> --%>
    <td class="leftAlign"><a name="policy"></a><strong><fmt:message key="jsp.help.break.file.zip"/></strong></td>
    <%-- <td class="rightAlign"><a href="#top" align="right">top</a></td> --%>
    <td class="rightAlign"><a href="#top"><fmt:message key="jsp.help.formats.top"/></a></td>
    </tr>
</table>
<%-- <p><i>(Your Format Support Policy Here)</i></p> --%>
<p><i><fmt:message key="jsp.help.break.file.zip.message"/></i></p> 
<p>&nbsp;</p>
<table>
    <tr>
    <%-- <td class="leftAlign"><a name="policy"></a><strong>FORMAT SUPPORT POLICY</strong></td> --%>
    <td class="leftAlign"><a name="policy"></a><strong><fmt:message key="jsp.help.break.file.unzip"/></strong></td>
    <%-- <td class="rightAlign"><a href="#top" align="right">top</a></td> --%>
    <td class="rightAlign"><a href="#top"><fmt:message key="jsp.help.formats.top"/></a></td>
    </tr>
</table>
<%-- <p><i>(Your Format Support Policy Here)</i></p> --%>
<p><i><fmt:message key="jsp.help.break.file.unzip.message"/></i></p> 
<p>&nbsp;</p>
</body>
</html>
