package org.dspace.content;

import org.dspace.authorize.AuthorizeException;
import org.dspace.core.Context;
import org.dspace.storage.rdbms.DatabaseManager;
import org.dspace.storage.rdbms.TableRow;

import java.sql.SQLException;
import java.util.Date;

/**
 * Created by Daniel on 26/07/2016.
 */
public class ItemEvaluation{

    public ItemEvaluation() {

    }

    private TableRow itemEvaluationRow;

    public int getItemId() {
        return itemId;
    }

    public void setItemId(int itemId) {
        this.itemId = itemId;
    }

    public int getGrade() {
        return grade;
    }

    public void setGrade(int grade) {
        this.grade = grade;
    }

    public Date getCreated() {
        return created;
    }

    public void setCreated(Date created) {
        this.created = created;
    }

    private int evaluationId = 0;

    public int getEvaluationId() {
        return evaluationId;
    }

    public void setEvaluationId(int evaluationId) {
        this.evaluationId = evaluationId;
    }

    private int itemId = 0;
    private int grade = 0;
    private Date created;


    private TableRow row;


    public void create(Context context) throws SQLException, AuthorizeException
    {
        row = DatabaseManager.create(context, "itemevaluation");
        this.evaluationId =  row.getIntColumn("id");
        row.setColumn("item_id", itemId);
        row.setColumn("grade", grade);
        created = new Date();
        row.setColumn("created", created);
        DatabaseManager.update(context, row);
        context.commit();
    }
}
