package org.dspace.app.webui.servlet;

import com.google.gson.Gson;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.dspace.app.webui.util.JSPManager;
import org.dspace.authorize.AuthorizeException;
import org.dspace.authorize.AuthorizeManager;
import org.dspace.core.Context;
import org.dspace.harvest.MetadataValuesProfile;
import org.dspace.harvest.ProfileHarvestedCollection;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.*;

public class ProfileCollectionManagerServlet extends DSpaceServlet {
    private Gson gson = new Gson();

//    JSONObject json = new JSONObject();
private static Logger log = Logger.getLogger(FaqGroupManagerServlet.class);

    protected void doDSGet(Context context, HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException, AuthorizeException {


        HashMap<String, Boolean> arraytest = new HashMap<>();
        HashMap<String, String> testarra = new HashMap<>();
        testarra.put("name", "texto");
//        testarra.put("text","text" );
        testarra.put("value", "texto");
        testarra.put("text", "texto");
//        arraytest.put("success",true);

        List<Map<String, String>> superLista = new ArrayList<>();

        superLista.add(testarra);
        List<Object> fack = new ArrayList<>();
//        fack.add(arraytest);
        fack.add(superLista);

        RetornoDTO obj = new RetornoDTO();
        obj.success = true;
        obj.results = superLista;
        String json = null;

        String action = request.getParameter("action");

        PrintWriter out = response.getWriter();
        if (StringUtils.isNotEmpty(action)) {
            if (AuthorizeManager.isAdmin(context)) {
                if (action.equalsIgnoreCase("test")) {
                    json = gson.toJson(obj);
                    out.print(json);
                    response.setContentType("application/json");
                    response.setCharacterEncoding("UTF-8");
                    out.flush();


                } else if (action.equalsIgnoreCase("jsonValuesUpdate")) {
                    saveArrayValues(context, request, response);
                }
            }
        } else {
            doDSPost(context, request, response);
        }
    }

    class RetornoDTO {
        public boolean success = true;
        public List<Map<String, String>> results;
    }

    protected void doDSPost(Context context, HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException, SQLException, AuthorizeException {
        String action = request.getParameter("action");
        String id = request.getParameter("identify");
        if (AuthorizeManager.isAdmin(context)) {
            if (StringUtils.isNotEmpty(action)) {
                switch (action) {
                    case "editProf":
                        if (StringUtils.isNotEmpty(id)) {
                            returnProfile(context, request, response, id);
                        }
                        break;
                    case "editValues":
                        returnArrayValues(context, request, response, id);
                        break;
                    case "createTranscription":
                        createTranscription(context, request, response);
                        break;
                    case "deleteTranscription":
                        deleteTranscription(context, request, response);
                        break;
                    case "jsonValuesUpdate":
                        saveArrayValues(context, request, response);
                        break;
                    default:
                        returnProfiles(context, request, response);
                }
            } else {
                returnProfiles(context, request, response);
            }
        }
    }

    private void returnProfile(Context context, HttpServletRequest request, HttpServletResponse response, String id) throws ServletException, IOException, SQLException {
        ProfileHarvestedCollection profile = ProfileHarvestedCollection.find(context, id);
        List<MetadataValuesProfile> listValuesProfile = null;
        if (StringUtils.isNotEmpty(profile.getHandle())) {
            listValuesProfile = MetadataValuesProfile.findAllMetadataValuesByProfile(context, profile.getHandle());
        }
        request.setAttribute("profile", profile);
        request.setAttribute("valuesProfile", listValuesProfile);
        JSPManager.showJSP(request, response, "/dspace-admin/profile-detail.jsp");
    }


    private void returnArrayValues(Context context, HttpServletRequest request, HttpServletResponse response, String id)
            throws ServletException, IOException, SQLException {
        MetadataValuesProfile mtval = MetadataValuesProfile.find(context, Integer.parseInt(request.getParameter("idValue")));
        List<String> splitdValues = Arrays.asList(mtval.getArrayValues().replaceAll("\\(|\\)", "").split("\\|"));
        request.setAttribute("idValue", request.getParameter("idValue"));
        request.setAttribute("typeValue", mtval.getTypeValues());
        request.setAttribute("metadata", mtval.getMetadataValues());
        request.setAttribute("values", splitdValues);
        JSPManager.showJSP(request, response, "/dspace-admin/values.jsp");
    }

    private void saveArrayValues(Context context, HttpServletRequest request, HttpServletResponse response) throws SQLException, AuthorizeException, IOException {
        String arrayJson = request.getParameter("nameJson");
        String id = request.getParameter("idValues");
        String transcription = request.getParameter("transcription");

        if (StringUtils.isNotEmpty(id)) {
            if (StringUtils.isNotEmpty(arrayJson) && StringUtils.isNotEmpty(transcription)) {
                MetadataValuesProfile mtval = MetadataValuesProfile.find(context, Integer.parseInt(id));
                mtval.setArrayValues(formatJson(arrayJson));
                mtval.setType(transcription);
                mtval.update();
                context.commit();
                responseStatus(response, "OK");
            } else {
                responseStatus(response, "PRECONDITIONFAIL");
            }
        } else {
            responseStatus(response, "ERROR");
        }
    }

    private String formatJson(String json) {
        return Arrays.toString(gson.toJson(json)
                .replaceAll("\\[|\\]|\\\\|\"|\"", "")
                .split(","))
                .replaceAll("\\[", "(")
                .replaceAll("\\]", ")")
                .replaceAll(",", "|")
                .replaceAll(" ", "");
    }

    private void returnProfiles(Context context, HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException, SQLException {
        List<ProfileHarvestedCollection> profiles = ProfileHarvestedCollection.findAllProfiles(context);
        request.setAttribute("profiles", profiles);
        JSPManager.showJSP(request, response, "/dspace-admin/profiles.jsp");
    }

    private void createTranscription(Context context, HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException, SQLException, AuthorizeException {
        String id = request.getParameter("identify");
        if (StringUtils.isNotEmpty(id)) {
            MetadataValuesProfile newTranscription = MetadataValuesProfile.create(context);
            newTranscription.setProfile(id);
            newTranscription.setType("transcricao");
            newTranscription.setMetadataValues("default");
            newTranscription.setArrayValues("(filtro1|filtro2|filtro3)");
            newTranscription.update();
            returnProfile(context, request, response, id);
            context.commit();
        }
        returnProfiles(context, request, response);
    }

    private void deleteTranscription(Context context, HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException, SQLException, AuthorizeException {
        String id = request.getParameter("id");
        String identify = request.getParameter("identify");
        if (StringUtils.isNotEmpty(id) && StringUtils.isNotEmpty(identify)) {
            MetadataValuesProfile newTranscription = MetadataValuesProfile.find(context,Integer.parseInt(id));
            newTranscription.delete();
            returnProfile(context, request, response, identify);
            context.commit();
        }
        returnProfiles(context, request, response);
    }

    private void responseStatus(HttpServletResponse response, String state) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        if (state.equalsIgnoreCase("OK")) {
            out.print("202");
        } else if (state.equalsIgnoreCase("ERROR")) {
            out.print("500");
        } else if (state.equalsIgnoreCase("PARTIAL")) {
            out.print("206");
        } else if (state.equalsIgnoreCase("PRECONDITIONFAIL")) {
            out.print("412");
        }
        out.flush();
    }
}

