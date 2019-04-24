/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.content.crosswalk;

import org.apache.commons.lang.StringUtils;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.jdom.Element;
import org.jdom.Namespace;

import java.io.IOException;
import java.sql.SQLException;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * DIM ingestion crosswalk
 * <p>
 * Processes metadata encoded in DSpace Intermediate Format, without the
 * overhead of XSLT processing.
 *
 * @author Alexey Maslov
 * @version $Revision: 1 $
 */
public class DIMIngestionCrosswalk
        implements IngestionCrosswalk {

    private static final Namespace DIM_NS = Namespace.getNamespace("http://www.dspace.org/xmlns/dspace/dim");
    
    private final Set<String> iso6392Set = new HashSet();
    
    public void loadLocaleMap() {
        Locale[] locales = Locale.getAvailableLocales();

        for (Locale locale : locales) {
            iso6392Set.add(locale.getISO3Language());
        }
    }

    public void ingest(Context context, DSpaceObject dso, List<Element> metadata) throws CrosswalkException, IOException, SQLException, AuthorizeException {
        Element first = metadata.get(0);
        if (first.getName().equals("dim") && metadata.size() == 1) {
            ingest(context, dso, first);
        } else if (first.getName().equals("field") && first.getParentElement() != null) {
            ingest(context, dso, first.getParentElement());
        } else {
            Element wrapper = new Element("wrap", metadata.get(0).getNamespace());
            wrapper.addContent(metadata);
            ingest(context, dso, wrapper);
        }
    }

    public void ingest(Context context, DSpaceObject dso, Element root) throws CrosswalkException, IOException, SQLException, AuthorizeException {
        if (dso.getType() != Constants.ITEM) {
            throw new CrosswalkObjectNotSupported("DIMIngestionCrosswalk can only crosswalk an Item.");
        }
        Item item = (Item) dso;

        if (root == null) {
            System.err.println("The element received by ingest was null");
            return;
        }

        List<Element> metadata = root.getChildren("field", DIM_NS);
        for (Element field : metadata) {
            
            String qualifier = field.getAttributeValue("qualifier");
            
            if (field.getAttributeValue("element").equalsIgnoreCase("type") && qualifier == null) {

                String textValue = resolverType(field.getText());
                if(StringUtils.isNotEmpty(textValue)){
                    item.addMetadata("dc", field.getAttributeValue("element"), null, field.getAttributeValue("lang"), textValue);
                }


            } else if (field.getAttributeValue("element").equalsIgnoreCase("language")) {

                    String textValue = resolverLang(field.getText());
                    item.addMetadata("dc", field.getAttributeValue("element"), null, field.getAttributeValue("lang"), textValue);

                
            } else if (field.getAttributeValue("element").equalsIgnoreCase("identifier")
                    && (qualifier != null && qualifier.equalsIgnoreCase("uri"))) {
                item.addMetadata(field.getAttributeValue("mdschema"), field.getAttributeValue("element"), null,
                        field.getAttributeValue("lang"), field.getText());
            } else if (field.getAttributeValue("element").equalsIgnoreCase("identifier") && qualifier == null) {
                
                Pattern p = Pattern.compile("^(http|https){1}(.)+");
                String textValue = field.getText().trim();
                Matcher m = p.matcher(textValue);
                if(m.matches())
                {
                    item.addMetadata("dc", "identifier", null, null, textValue);
                }
            } else if (field.getAttributeValue("element").equalsIgnoreCase("date")) {
                
                Pattern p = Pattern.compile("^[0-9]{4}([-]{1}[0-9]{2}){0,2}([T]{1}[0-9]{2}[:]{1}[0-9]{2}[:]{1}[0-9]{2}.){0,1}");
		Matcher m = p.matcher(field.getText());
                if(m.matches())
                {
                    item.addMetadata(field.getAttributeValue("mdschema"), field.getAttributeValue("element"), qualifier,
                        field.getAttributeValue("lang"), field.getText());
                }
                
            } else {
                if (StringUtils.isNotEmpty(field.getText())){
                item.addMetadata(field.getAttributeValue("mdschema"), field.getAttributeValue("element"), qualifier,
                        field.getAttributeValue("lang"), field.getText());
                }
            }
            
        }

    }

    @Override
    public void ingest(Context context, DSpaceObject dso, Element root, int colId) throws CrosswalkException, IOException, SQLException, AuthorizeException {

    }


    private static final String tab00c0 = "AAAAAAACEEEEIIII" +
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


    public static String resolverType(String elementName){
        //Resolver
        String textValue;
        String valueElement;

        //Remove accentuation
        //Remove special characters
        valueElement = removeDiacritic(elementName).toLowerCase().replaceAll("[-_]+"," ");


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
                || valueElement.contains("errata"))
        {
            textValue = "texto";
        }else if (valueElement.contains("audio") || valueElement.contains("gravacao") || valueElement.contains("mp3")) {
            textValue = "áudio";
        }else if (valueElement.contains("apresentacao") || valueElement.contains("review")
                || valueElement.contains("conferenceobject") || valueElement.contains("conferencepaper")
                || valueElement.contains("presentation")
                || valueElement.contains("thesis")
                || valueElement.contains("simulacao")) {
            textValue = "apresentação";
        }else if (valueElement.contains("planilha") || valueElement.contains("planilhas")) {
            textValue = "planilha";
        }else if (valueElement.contains("aula digital")) {
            textValue = "aula digital";
        }else if (valueElement.contains("livro digital")
                || valueElement.contains("learning")
                || valueElement.contains("jornal")
                || valueElement.contains("livro")|| valueElement.contains("capitulo de livro")
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
        }
        else{
            textValue = elementName.toLowerCase();
        }
        return  textValue;

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
                || elementName.contains("eng")){
            textValue = "en";
        }else if (elementName.contains("nau")
                || elementName.contains("na")
                || elementName.contains("abk")
                || elementName.contains("ptbr")
                || elementName.contains("other")
                || elementName.contains("latim")
                || elementName.contains("potugues")
                || elementName.contains("portugues")){
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
