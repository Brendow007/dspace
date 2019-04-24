package test;

import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class FiltroDinamico {

    //HarvestCollection ↓
    //profileID:Name:standard:id Ex: DC_UNESP / UNESP / DC / 23131321
    //metadataValuesProfile ↓
    //profileID:TypeMD:ArrayValuesSplit: Ex: 21321351 /DC_UNESP / type / {ArraySplitValues}
    //profileID:TypeMD:ArrayValuesSplit: Ex: 21321351 /DC_UNESP / lang / {ArraySplitValues}

    public static void addMetadado(String vl) {
        System.out.println(vl);
    }

    long startTime = System.nanoTime();


    public static boolean useArraysBinarySearch(String[] arr, String targetValue) {
        Arrays.sort(arr);
        int a = Arrays.binarySearch(arr, targetValue);
        if (a > 0)
            return true;
        else
            return false;
    }

    static boolean doesValueBelongToKey(HashMap map, Object key, Object value) {
        if (map.containsKey(key) && map.get(key).equals(value))
            return true;
        else
            return false;
    }



    public static void main(String args[]) {

        filterValues();

    }





    public static void filterValues(){
        HashMap<String, Pattern> patterns = new HashMap<>();
        patterns.put("type", Pattern.compile("(mp3|wave|audi|aud|text|video|test|texto|vide|resumo|musical)"));        // for each list patterns returned from list
        patterns.put("language", Pattern.compile("(pt|ptbr|en|enus)"));
        Matcher finded;// Searcher to MT
        String elementText = "wave"; // Object Element from DOM

        for (Map.Entry<String, Pattern> standards : patterns.entrySet()) {

            //Types from database
            //Element equals type
            if (standards.getKey().equalsIgnoreCase("type")) {
                finded = standards.getValue().matcher(elementText);
                armazenar(finded, standards.getKey());

            } else if (standards.getKey().equalsIgnoreCase("language")) {
                finded = standards.getValue().matcher(elementText);
                armazenar(finded, standards.getKey());

            } else {
                finded = null;
                armazenar(finded, elementText);
            }
        }
    }


    static void armazenar(Matcher r, String typeMT) {
        //Query from database... hash maps to text types
        List<HashMap<String, String[]>> listMap = new ArrayList<>();
        HashMap<String, String[]> typeText = new HashMap<>();
        String[] text = {"nota", "artigo", "resumo", "texto"};
        String[] video = {"mp4", "flv", "blueray", "video"};
        String[] audio = {"mp3", "wave", "ogg", "musical"};
        typeText.put("texto", text);
        typeText.put("video", video);
        typeText.put("audio", audio);
        listMap.add(typeText);

        final String[] arrayTypes = {"texto", "test", "audio", "video", "apresentação", "animação", "mapa", "aplicativo móvel", "aula digital", "curso", "ferramentas", "imagem", "jogo", "laboratório", "portal", "software", "planilha", "mapa"};
        String[] arrayLangs = {"pt_br", "pt", "en", "es", "fr", "pt", "it", "jpn", "de", "lat"};

        //Limit from values to store in db
        int sizeList = listMap.size();
        if (r.find()) {
            if (typeMT.equalsIgnoreCase("type"))
                for (int i=0; i<sizeList; i++) {
                    for (Map.Entry<String, String[]> mapa : listMap.get(i).entrySet()) {
                        if (useArraysBinarySearch(mapa.getValue(), r.group()))
                            System.out.println("Stored::"+mapa.getKey()); // stored the key from result values shit
                    }
                }
        }

        if (r.find()) {
            if (typeMT.equalsIgnoreCase("type")) {
                if (useArraysBinarySearch(arrayTypes, r.group())) {
                    System.out.println("add: " + r.group());
                }
                int index = Arrays.asList(arrayTypes).indexOf(r.group());
                System.out.println(index);
                if (index >= 0)
                    System.out.println(typeText.containsKey(Arrays.asList(arrayTypes).get(index)));

                for (String fkvalue : arrayTypes) {
                    if (fkvalue.contains(r.group()))
                        System.err.println(r.matches() + ": " + r.group() + ": item stored...  → " + typeMT + " valueAdd: " + fkvalue);
                }
            } else if (typeMT.equalsIgnoreCase("language")) {
                for (String fkvalue : arrayLangs) {
                    if (fkvalue.contains(r.group()))
                        System.err.println(r.matches() + ": " + r.group() + ": item stored...  → " + typeMT + " valueAdd: " + fkvalue);
                }
            }
        }
    }


    public static void splitValues() {
        String regexToSplit = "(pt|ptbr|en|eng|rus)".replaceAll("\\(|\\)", "");
//        String values = regexToSplit.replaceAll("\\(|\\)", "");
        List<String> splittedValues = Arrays.asList(regexToSplit.split("\\|"));


        for (String spltiedval:splittedValues)
            System.out.println(spltiedval);
    }


}
