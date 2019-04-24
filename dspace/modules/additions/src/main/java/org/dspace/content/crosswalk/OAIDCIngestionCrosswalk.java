/**
 * The contents of this file are subject to the license and copyright detailed
 * in the LICENSE and NOTICE files at the root of the source tree and available
 * online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.content.crosswalk;

import com.ibm.icu.text.SimpleDateFormat;
import org.apache.commons.lang.StringUtils;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.dspace.harvest.HarvestedCollection;
import org.dspace.harvest.MetadataValuesProfile;
import org.dspace.harvest.ProfileHarvestedCollection;
import org.jdom.Element;
import org.jdom.Namespace;

import java.io.IOException;
import java.sql.SQLException;
import java.text.ParseException;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * DIM ingestion crosswalk
 * <p>
 * Processes Dublic Core metadata encased in an oai_dc:dc wrapper
 *
 * @author Brendow Adriel
 * @version $Revision: 1 $
 */
public class OAIDCIngestionCrosswalk implements IngestionCrosswalk {

    private static final Namespace DC_NS = Namespace.getNamespace("http://www.dspace.org/xmlns/dspace/dim");
    private static final Namespace OAI_DC_NS = Namespace.getNamespace("http://www.openarchives.org/OAI/2.0/oai_dc/");

    private final Set<String> iso6392Set = new HashSet();

    public OAIDCIngestionCrosswalk() {
        super();
        this.loadLocaleMap();
    }

    public void ingest(Context context, DSpaceObject dso, List<Element> metadata) throws CrosswalkException, IOException, SQLException, AuthorizeException {
        Element wrapper = new Element("wrap", metadata.get(0).getNamespace());
        wrapper.addContent(metadata);

        ingest(context, dso, wrapper);
    }

    @Override
    public void ingest(Context context, DSpaceObject dso, Element root) throws CrosswalkException, IOException, SQLException, AuthorizeException {
//        null
    }


    public void ingest(Context context, DSpaceObject dso, Element root, int idCol) throws CrosswalkException, IOException, SQLException, AuthorizeException {

        Pattern p = Pattern.compile("^(http|https){1}(.)+");
        Matcher m;

        HarvestedCollection coll = HarvestedCollection.find(context,idCol);
        ProfileHarvestedCollection prof = ProfileHarvestedCollection.find(context,coll.getProfileIdentify());
        List<MetadataValuesProfile> listValuesProfile = MetadataValuesProfile.findAllMetadataValuesByProfile(context,prof.getStandard());


//         for (MetadataValuesProfile valuesOfProfile:listValuesProfile){
//             valuesOfProfile.getArrayValues();
//         }






        if (dso.getType() != Constants.ITEM) {
            throw new CrosswalkObjectNotSupported("DIMIngestionCrosswalk can only crosswalk an Item.");
        }
        Item item = (Item) dso;

        if (root == null) {
            System.err.println("The element received by ingest was null");
            return;
        }

        List<Element> metadata = root.getChildren();

        for (Element element : metadata) {

            // get language - prefer xml:lang, accept lang.


//            resolverType(element,item);


            String lang = element.getAttributeValue("lang", Namespace.XML_NAMESPACE);

            if (lang == null) {
                lang = element.getAttributeValue("lang");
            }

                if (element.getName().equalsIgnoreCase("type")) {

                //filter ↓
                    //Profile (get)-> MetadataValues of this profile )
                    //MetadataProfileValues.()

                String textValue = resolverType(element,item);
                //String textValue = element.getText();
                //if schema metadata equals → collection metadata equals → value eq metadata equivalence
                //Find collection → profile → profile-equivalence
                    if(StringUtils.isNotEmpty(textValue)) {
                        item.addMetadata("dc", element.getName(), null, lang, textValue);
                    }

                } else if (element.getName().equalsIgnoreCase("language")) {
                String newValue = null;
                if ((element.getText().length() == 5 && element.getText().contains("_")) || element.getText().length() == 2) {
                    Locale locale;
                    if (element.getText().length() == 2) {
                        locale = new Locale(element.getText());
                    } else {
                        String[] arrayIdioma = element.getText().split("_");
                        locale = new Locale(arrayIdioma[0], arrayIdioma[1]);
                    }
                    try {
                        newValue = locale.getISO3Language();
                    } catch (Exception e) {
                    }
                } else if (element.getText().length() == 3) {
                    if (iso6392Set.contains(element.getText())) {
                        newValue = element.getText();
                    }
                }

                if (newValue != null) {
                    String textValue = resolverLang(newValue);
                    item.addMetadata("dc", element.getName(), null, lang, textValue);
                }

            } else if (element.getName().equalsIgnoreCase("identifier")) {

                String textValue = element.getTextTrim();
                m = p.matcher(textValue);
                if(m.matches()){
                    item.addMetadata("dc", "identifier", null, null, textValue);
                }

            }else if(element.getName().equalsIgnoreCase("date")){
                    if (validValuesDate(element.getText())) {
                        item.addMetadata("dc", "date", "issued", lang, element.getText());
                    }
                }else {
                if (StringUtils.isNotEmpty(element.getText())){
                     item.addMetadata("dc", element.getName(), null, lang, element.getText());
                }
            }

        }

    }



    public void loadLocaleMap() {
        Locale[] locales = Locale.getAvailableLocales();

        for (Locale locale : locales) {
            iso6392Set.add(locale.getISO3Language());
        }
    }

    private static final String tab00c0 =
            "AAAAAAACEEEEIIII" +
            "DNOOOOO\u00d7\u00d8UUUUYI\u00df" +
            "aaaaaaaceeeeiiii" +
            "\u00f0nooooo\u00f7\u00f8uuuuy\u00fey" +
            "AaAaAaCcCcCcCcDd" +
            "DdEeEeEeEeEeGgGg" +
            "GgGgHhHhIiIiIiIi" +
            "IiJjJjKkkLlLlLlL" +
            "lLlNnNnNnnNnOoOo" +
            "OoOoRrRrRrSsSsSs" +
            "SsTtTtTtUuUuUuUu" +
            "UuUuWwYyYZzZzZzF";

    public static String removeDiacritic(String source) {
        char[] vysl = new char[source.length()];
        char one;
        for (int i = 0; i < source.length(); i++) {
            one = source.charAt(i);
            if (one >= '\u00c0' && one <= '\u017f') {
                one = tab00c0.charAt((int) one - '\u00c0');
            }
            vysl[i] = one;
        }
        return new String(vysl);
    }


    public static String resolverType(Element element,Item item){


        List<String> metadadosGerais = new ArrayList<>();
//        metadados.add("identifier");
//        metadados.add("type");
//        metadados.add("date");


        for (String mt:metadadosGerais) {
            if (element.getName().equalsIgnoreCase(mt)) {

//                item.addMetadata("","","","","");
            }
        }



        //Resolver
        String textValue;
        String valueElement;

        //Remove accentuation
        //Remove special characters
        valueElement = removeDiacritic(element.getText()).toLowerCase().replaceAll("[-_]+"," ");

        Pattern pattern = Pattern.compile("(artigo|texto|boletim)");

        if (valueElement.contains("video")){
            textValue = "vídeo";
        }else if (valueElement.contains("texto") || valueElement.contains("artigo")
                || valueElement.contains("nota")   || valueElement.contains("boletim")
                || valueElement.contains("artigo")  || valueElement.contains("dissertacao de mestrado")
                || valueElement.contains("resumo")  || valueElement.contains("tese de doutorado")
                || valueElement.contains("tese de livre docencia")|| valueElement.contains("article")
                || valueElement.contains("bachelorthesis") || valueElement.contains("doctoralthesis")
                || valueElement.contains("masterthesis") || valueElement.contains("report")
                || valueElement.contains("lecture") || valueElement.contains("preprint")
                || valueElement.contains("workingpaper") || valueElement.contains("dataset")
                || valueElement.contains("tese") || valueElement.contains("monografia especializacao digital")
                || valueElement.contains("pedagogicalpublication") || valueElement.contains("dissertacao")
                || valueElement.contains("emagazine") || valueElement.contains("relatorio")
                || valueElement.contains("portfolio") || valueElement.contains("objeto")
                || valueElement.contains("errata")    || valueElement.contains("regulamento")){
            textValue = "texto";
        }else if (valueElement.contains("audio") || valueElement.contains("gravacao")
                || valueElement.contains("partitura") || valueElement.contains("podcast")
                || valueElement.contains("mp3")) {
            textValue = "áudio";
        }else if (valueElement.contains("apresentacao") || valueElement.contains("review")
                || valueElement.contains("conferenceobject")
                || valueElement.contains("conferencepaper")
                || valueElement.contains("thesis")
                || valueElement.contains("presentation") || valueElement.contains("simulacao")) {
            textValue = "apresentação";
        }else if (valueElement.contains("planilha") || valueElement.contains("planilhas")) {
            textValue = "planilha";
        }else if (valueElement.contains("aula digital")) {
            textValue = "aula digital";
        }else if (valueElement.contains("livro digital")
                || valueElement.contains("learning")
                || valueElement.contains("jornal") || valueElement.contains("revista")
                || valueElement.contains("livro") || valueElement.contains("capitulo de livro")
                || valueElement.contains("editorial") || valueElement.contains("book")
                || valueElement.contains("bookpart")) {
            textValue = "livro digital";
        }else if (valueElement.contains("aplicativo movel")) {
            textValue = "aplicativo móvel";
        }else if (valueElement.contains("software")) {
            textValue = "software";
        }else if (valueElement.contains("animation") || valueElement.contains("animacao")) {
            textValue = "animação";
        }else if (valueElement.contains("ferramentas") || valueElement.contains("ferramenta")) {
            textValue = "ferramentas";
        }else if (valueElement.contains("curso") || valueElement.contains("cursos")) {
            textValue = "curso";
        }else if (valueElement.contains("jogo") ||valueElement.contains("jogos")
                ||valueElement.contains("game") || valueElement.contains("unity")) {
            textValue = "jogos";
        }else if (valueElement.contains("laboratorio") || valueElement.contains("experimento")) {
            textValue = "laboratório";
        }else if (valueElement.contains("imagem") || valueElement.contains("ilustration") || valueElement.contains("photo")) {
            textValue = "imagem";
        }else if (valueElement.contains("outros")
                || valueElement.contains("other")
                || valueElement.contains("outro")) {
            textValue = "";
        }else{
            textValue = element.getTextNormalize().toLowerCase();
        }
        return  textValue;

    }

    private static boolean isValidDateFormat(String format, String value) {
        Date date = null;
        try {
            SimpleDateFormat sdf = new SimpleDateFormat(format);
            date = sdf.parse(value);
            if (!value.equals(sdf.format(date))) {
                date = null;
            }
        }
        catch (ParseException ex) {
//             ex.getLocalizedMessage();
         }
        return date != null;
    }

    private static Boolean validValuesDate(String dcval){
        if (isValidDateFormat("yyyy-MM-dd", dcval)) {
            return true;
        } else if (isValidDateFormat("yyyy/MM/dd", dcval)) {
            return true;
        } else if(isValidDateFormat("yyyy", dcval)){
            return true;
        }else {
            return false;
        }

    }

    public static String resolverLang(String elementName){
        //Resolver
        String textValue;
        elementName = removeDiacritic(elementName).toLowerCase().replaceAll("[/-_]+","");

        if (elementName.contains("glg")
                || elementName.contains("cat")
                || elementName.contains("spa")
                || elementName.contains("ca")
                || elementName.contains("gl")){
            textValue = "es";
        }else if (elementName.contains("en")
                || elementName.contains("enus")
                || elementName.contains("eng")){
            textValue = "en";
        }else if (elementName.contains("nau")
                || elementName.contains("portugues")
                || elementName.contains("abk")
                || elementName.contains("ptbr")
                || elementName.contains("por")
                || elementName.contains("pt")
                || elementName.contains("br")
                || elementName.contains("other")
                || elementName.contains("latim")
                || elementName.contains("potugues")){
            textValue = "pt_BR";
        }else if (elementName.contains("jpn")
                || elementName.contains("ja")){
            textValue = "jp";
        }else if (elementName.contains("deu")
                || elementName.contains("alemao")){
            textValue = "de";
        }else if (elementName.contains("frances") || elementName.contains("fr")){
            textValue = "fr";
        }else if (elementName.contains("ita")){
            textValue = "it";
        }else if (elementName.contains("zho")){
            textValue = "zh";
        }else if (elementName.contains("ab")){
            textValue = "zh";
        }else if (elementName.contains("pol")){
            textValue = "pl";
        }else{
            textValue = elementName.toLowerCase();
        }
        return  textValue;
    }

}
