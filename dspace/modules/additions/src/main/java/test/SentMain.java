package test;

import com.ibm.icu.text.SimpleDateFormat;
import org.apache.commons.lang.StringUtils;
import org.dspace.authorize.AuthorizeException;

import java.sql.SQLException;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

/**
 * Created by brendows on 28/11/2017.
 */


public class SentMain {

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

    public static String resolver(String elementName) {


        String textValue;
        String valueElement;
        String valueElement2;

        //Normalized String
//              String resolverElement = Normalizer.normalize(elementName, Normalizer.Form.NFD);
//              String resolverElement = "";
        //Remove accentuation
//              elementName = resolverElement.replaceAll("\\p{InCombiningDiacriticalMarks}+", "");
        //Remove special characters
        valueElement = elementName.toLowerCase().replaceAll("[-_]+", " ");
        valueElement2 = valueElement.replaceAll("[^\\P{ASCII}]", "");

        if (valueElement2.contains("video")) {
            textValue = "vídeo";
        } else if (valueElement2.contains("texto") || valueElement.contains("artigo") || valueElement.contains("nota") || valueElement.contains("boletim") || valueElement.contains("artigo") || valueElement.contains("dissertacao de mestrado") || valueElement.contains("resumo") || valueElement.contains("tese de doutorado") || valueElement.contains("tese de livre docencia")) {
            textValue = "texto";
        } else if (valueElement2.contains("audio")) {
            textValue = "áudio";
        } else if (valueElement2.contains("apresentacao")) {
            textValue = "apresentação";
        } else if (valueElement2.contains("planilha") || valueElement.contains("planilhas")) {
            textValue = "planilha";
        } else if (valueElement2.contains("aula digital")) {
            textValue = "aula digital";
        } else if (valueElement2.contains("livro digital") || valueElement.contains("jornal") || valueElement.contains("livro") || valueElement.contains("capitulo de livro") || valueElement.contains("editorial")) {
            textValue = "livro digital";
        } else if (valueElement2.contains("aplicativo movel")) {
            textValue = "aplicativo móvel";
        } else if (valueElement2.contains("software")) {
            textValue = "Software";
        } else if (valueElement2.contains("ferramentas") || valueElement.contains("ferramenta")) {
            textValue = "ferramentas";
        } else if (valueElement2.contains("curso") || valueElement.contains("cursos")) {
            textValue = "curso";
        } else if (valueElement2.contains("jogo") || valueElement.contains("jogos")) {
            textValue = "jogo";
        } else if (valueElement2.contains("laboratorio")) {
            textValue = "laboratório";
        } else if (valueElement2.contains("imagem")) {
            textValue = "imagem";
        } else {
            textValue = "outro";
        }
        return textValue;

    }

    public static boolean isValidFormat(String format, String value) {
        Date date = null;
        try {
            SimpleDateFormat sdf = new SimpleDateFormat(format);
            date = sdf.parse(value);
            if (!value.equals(sdf.format(date))) {
                date = null;
            }
        } catch (ParseException ex) {
//            ex.getLocalizedMessage();
        }
        return date != null;
    }

    public static void addMetadado(String vl) {
        System.out.println("Filtrado");
    }

    public static void main(String args[]) throws InterruptedException, SQLException, AuthorizeException {


        String testt = "n/a-_--";
        testt = removeDiacritic(testt).toLowerCase().replaceAll("[/_-]","");
        System.out.println(testt);


        HashMap<String, String> ListaFiltro = new HashMap<>();
        ListaFiltro.put("dc.type", "texto");

        List<String> listaMetadados = new ArrayList<>();
        listaMetadados.add("type");
        listaMetadados.add("subject");
        String element = "type";
        String getFiltroType = "10";


        List<String> listaValorMetadado = new ArrayList<>();
        listaValorMetadado.add("portugues");
        listaValorMetadado.add("video");
        listaValorMetadado.add("vids");
        listaValorMetadado.add("text");
        listaValorMetadado.add("texto");
        listaValorMetadado.add("audio");
        listaValorMetadado.add("aud");

//        Poll ep = new Poll();
/**/
//        if (listaMetadados.size() > 0) {
            //if this is profile collection? yep::GetConfiguration Metadata
            //Profile prof = new Profile.find(context,idCol);
            //prof.getListMetadados;
/*            if (true) {
                for (String tipoMetadado : listaMetadados) {
                    if (tipoMetadado.equalsIgnoreCase(element)) {
                        for (String filtroValor : listaValorMetadado) {
                            if ("codigoValor" == "codigoValor") {
                                addMetadado(filtroValor);
                            }
                        }
                    }
                }
            }
        } else {
            addMetadado("default");
        }*/


//
//        System.out.println(str.replace("(with nice players)", ""));
//        int index = str.indexOf("(");

//        System.out.println(str.substring(0, index));
        String test = "<ul><p>This is a paragraph.</p>" +
                "<p>This is a paragraph.</p> >";
        StringBuilder str = new StringBuilder(test);


//        String init = "<img";
//        String endi = ">" ;
//
//
//        int startIdx = str.indexOf(init);
//        int endIdx = str.indexOf(endi);
//        ++endIdx;


//        String straws = str.substring(startIdx,endIdx);
//        String stringText= str.substring(startIdx,endIdx);
//        StringBuilder stringBuilding = str.replace(startIdx,endIdx,"");

//        System.out.println(stringBuilding.toString());
//        System.out.println(stringBuilding.toString());
//        String input = "2018";
//
//            if (isValidFormat("yyyy-MM-dd", input)) {
//                System.out.println("true1");
//            } else if (isValidFormat("yyyy/MM/dd", input)) {
//                System.out.println("true2");
//            } else if(isValidFormat("yyyy", input)){
//                System.out.println("true3");
//            }

        ;

        System.out.println();
        String var = "";
//        var = null;

        if (StringUtils.isNotEmpty(var)) {
            System.out.println(StringUtils.isBlank(var));
        }
   /*     Locale locale = new Locale("por");
//        System.out.println(locale.getDisplayName());
        System.out.println(locale.getLanguage());
        System.out.println(locale.getISO3Language());*/


//        StringBuilder stringBuilding = str.replace(startIdx,endIdx);
//        replace(--startIdx, endIdx, "");
//        String str2 = stringBuilding.toString();
//
//        int start = str2.indexOf("<img");
//        int end = str2.indexOf("D");
//        str2.replace();


//        System.out.println(str2);


        Object o = new ArrayList<>();

        List<String> items = new ArrayList<>();
        o = items;

//        t.stream().forEach(t1 -> System.out.print("test"));
//        t.forEach(a->System.out.print(a));


        items.add("Video");
        items.add("vídeo");
        items.add("textó");
        items.add("Texto");
        items.add("Dissertação de Mestrado");
        items.add("aulã-digital");
        items.add("livro-digital");
        items.add("Lívro___digitál");
        items.add("Aulã_--_digital");
        items.add("apresentação");
        items.add("maçã");
        items.add("artigo");
        items.add("artigo  ããaããã");
        items.add("info:eu-repo/semantics/review");
        items.add("info:eu-repo/semantics/article");
        items.add("info:eu-repo/semantics/asdasdsd");
        items.add("artigo boletim nota imagem");
        items.add("Video UFPR TV (Web)");


//        Map<String,String> map = new HashMap<String,String>();
//
//        map.put("Key",new String("KeyVal"));
//
//
//        for (String key:map.keySet()) {
//            String val = map.get(key);
//
//            System.out.println(key +" "+ val);
//        }


//
//        Normalizer.normalize(test, Normalizer.Form.NFD);
//        valueElement = test.toLowerCase().replaceAll("[-_]+"," ");
//        test2 = test.replaceAll("\\p{M}", "");
//
//        valueElement2 = valueElement.replaceAll("\\p{M}", "");
//        System.out.println(valueElement);
//        System.out.println(test2);
//        System.out.println(valueElement2);


        for (String s : items) {
//

            //    String fff = s.toLowerCase().replaceAll("[-_]+", " ");
            String a = resolverType(s);

//            System.out.println(a);


        }


//        for (String i : items) {
//            a++;
//            if (a == 999) {
//                Thread.sleep(5000);
//                a = 0;
//            }
//            System.out.println(i + a);
//
//        }


    }

    public static String resolverType(String elementName) {

        /**
         *
         * http://repositorio.unesp.br/oai/request
         *
         * */

        //Resolver
        String textValue = "";
        String valueElement;
        //Remove accentuation
        //Remove special characters
        valueElement = removeDiacritic(elementName).toLowerCase().replaceAll("[-_]+", " ");

        //   valueElement = removeDiacritic(elementName.toLowerCase());

        if (valueElement.contains("video")) {
            textValue = "vídeo";
        } else if (valueElement.contains("texto") || valueElement.contains("artigo")
                || valueElement.contains("nota") || valueElement.contains("boletim")
                || valueElement.contains("artigo") || valueElement.contains("dissertacao de mestrado")
                || valueElement.contains("resumo") || valueElement.contains("tese de doutorado")
                || valueElement.contains("tese de livre docencia")) {
            textValue = "texto";
        } else if (valueElement.contains("audio")) {
            textValue = "áudio";
        } else if (valueElement.contains("apresentacao")) {
            textValue = "apresentação";
        } else if (valueElement.contains("planilha") || valueElement.contains("planilhas")) {
            textValue = "planilha";
        } else if (valueElement.contains("aula digital")) {
            textValue = "aula digital";
        } else if (valueElement.contains("livro digital") ||
                valueElement.contains("jornal") ||
                valueElement.contains("livro") ||
                valueElement.contains("capitulo de livro") ||
                valueElement.contains("editorial")) {
            textValue = "livro digital";
        } else if (valueElement.contains("aplicativo movel")) {
            textValue = "aplicativo móvel";
        } else if (valueElement.contains("software")) {
            textValue = "Software";
        } else if (valueElement.contains("ferramentas") || valueElement.contains("ferramenta")) {
            textValue = "ferramentas";
        } else if (valueElement.contains("curso") || valueElement.contains("cursos")) {
            textValue = "curso";
        } else if (valueElement.contains("jogo") || valueElement.contains("jogos")) {
            textValue = "jogo";
        } else if (valueElement.contains("laboratorio")) {
            textValue = "laboratório";
        } else if (valueElement.contains("imagem")) {
            textValue = "imagem";
        } else if (valueElement.contains("article")) {
            textValue = "texto";
        } else if (valueElement.contains("review") || valueElement.equals("maca")) {
            textValue = "texto";
        } else {
            textValue = "ASDAD ASDASD ASDASD ASDASD ASDASDSA ASDASD";
        }
        return textValue;

    }

}
