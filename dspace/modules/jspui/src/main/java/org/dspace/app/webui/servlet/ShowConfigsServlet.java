package org.dspace.app.webui.servlet;

import com.ibm.icu.text.SimpleDateFormat;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.dspace.app.webui.util.JSPManager;
import org.dspace.authorize.AuthorizeException;
import org.dspace.authorize.AuthorizeManager;
import org.dspace.core.ConfigurationManager;
import org.dspace.core.Context;

import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.*;
import java.nio.channels.FileChannel;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.sql.SQLException;
import java.util.Date;
import java.util.Enumeration;
import java.util.Properties;

public class ShowConfigsServlet extends DSpaceServlet {
    private static final String DSPACEDIR = (ConfigurationManager.getProperty("dspace.dir"));

    private  final String DIR = DSPACEDIR + "/config/dspace.cfg";

    private  final String LOG = DSPACEDIR + "/log/";
    private Date date = new Date();
    private String logsToday = new SimpleDateFormat("yyyy-MM-dd").format(date);
    private String filePath;




    private static Logger log = Logger.getLogger(ShowConfigsServlet.class);

    protected void doDSPost(Context context, HttpServletRequest request,
                            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException {

    }

    protected void doDSGet(Context context, HttpServletRequest request,
                           HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException {
                if (AuthorizeManager.isAdmin(context)) {
                    String action = request.getParameter("action");
                    if (StringUtils.isNotEmpty(action)){
                        if (action.equalsIgnoreCase("log-day")) {
                           String logToDownload = "dspace.log.".concat(logsToday);
                            filePath = LOG + logToDownload;
                            try
                            {
                            File file = new File(filePath);
                            response.addHeader("Content-Disposition", "attachment; filename=" + file.getName());
                            response.setContentLength((int) file.length());
                            FileInputStream fileInputStream = new FileInputStream(file);
                            ServletOutputStream responseOutputStream = response.getOutputStream();
                            int bytes;
                            while ((bytes = fileInputStream.read()) != -1) {
                                responseOutputStream.write(bytes);
                            }
                            }catch (Exception ex){
                                log.info(ex.getCause());
                            }
                        }else if(action.equalsIgnoreCase("cleanlog")){
                            String fileToClean = LOG + "dspace.log."+logsToday;
                            FileChannel.open(Paths.get(fileToClean), StandardOpenOption.WRITE).truncate(0).close();
//                            returnMainPage(request,response);
                        }else{
                            returnMainPage(request,response);
                        }
                    }else {
                        response.setContentType("text/html; charset=UTF-8");
                        response.setCharacterEncoding("UTF-8");
                        printThemAll(response);
                    }
                }
            }

    private static void returnMainPage(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException, SQLException {
        JSPManager.showJSP(request, response, "/");
    }

    private void printThemAll(HttpServletResponse response) throws IOException {
        File file = new File(DIR);
        Properties prop = new Properties();
        PrintWriter out = response.getWriter();
        InputStream input = new FileInputStream(DIR);
        try {
            String filename = file.getName();
            if (input.equals(null)) {
                out.println("Arquivo não encontrado:" + filename);
                return;
            }
            prop.load(input);
            Enumeration<?> e = prop.propertyNames();
            out.print("<ul class=\"listing\">");
            while (e.hasMoreElements()) {
                String key = (String) e.nextElement();
                String value = prop.getProperty(key);
                if (key.contains("webui.")) {
                    out.print("<br/>");
                    out.println("<li><strong><span class=\"keys\">" + key + "<span></strong> = ");
                    out.print("<span style=\"\" class=\"values\"><strong>"+value + "<strong></span></li>");
                }
            }
            out.print("</ul>");
            out.print("<style>");
            out.print(".keys{color: #3c693e;}");
            out.print(".listing{list-style: decimal-leading-zero;}");
            out.print("</style>");
        } catch (IOException ex) {
            ex.printStackTrace();
        } finally {
            if (input != null) {
                try {
                    input.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }
}
