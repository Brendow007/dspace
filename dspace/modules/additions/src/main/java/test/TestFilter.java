package test;

import java.util.ArrayList;
import java.util.List;

public class TestFilter {
    static List<String> filterField = new ArrayList<String>();
    static List<String> filterOp = new ArrayList<String>();
    static List<String> value = new ArrayList<String>();
   static List<String[]> appliedFilters = new ArrayList<String[]>();


    public static void main(String args[]) {



        filterField.add("subject");
        filterOp.add("contais");
        value.add("matematica");
        filterField.add("subject");
        filterOp.add("equals");
        value.add("fasdsad");
        filterField.add("subject");
        filterOp.add("equals");
        value.add("fisica quantica");
        filterField.add("subject");
        filterOp.add("contais");
        value.add("texto");

        int ignore = -1;

        if (filterOp.size()>1) {
           ignore=-1;
        }
        if (ignore > 0)
        for (int idx = 0; idx < filterOp.size(); idx++)
        {
            appliedFilters.add(new String[] {
                    filterField.get(idx),
                    filterOp.get(idx),
                    value.get(idx)
            });
        }
            for (String [] test:appliedFilters) {
                String sdasd =  test[0]+"::"+test[1]+"::"+test[2];
                System.out.println(sdasd);
            }
    }

}
