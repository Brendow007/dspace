package org.dspace.rest.common;


import javax.xml.bind.annotation.XmlRootElement;
import java.util.List;

@XmlRootElement(name = "itemList")
public class ItemReturn {
    private Context context;

    private List<org.dspace.rest.common.Item> item;

    public Context getContext() {
        return context;
    }

    public void setContext(Context context) {
        this.context = context;
    }

    public List<org.dspace.rest.common.Item> getItem() {
        return item;
    }

    public void setItem(List<Item> values) {
        this.item = values;
    }


}