package org.dspace.content;

import org.apache.log4j.Logger;
import org.dspace.authorize.AuthorizeException;
import org.dspace.authorize.AuthorizeManager;
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.dspace.core.LogManager;
import org.dspace.event.Event;
import org.dspace.storage.rdbms.DatabaseManager;
import org.dspace.storage.rdbms.TableRow;
import org.dspace.storage.rdbms.TableRowIterator;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by brendows on 14/09/2017.
 */
public class FaqGroup extends DSpaceObject {

    private static final Logger log = Logger.getLogger(FaqGroup.class);

    private final TableRow myRow;

    private boolean modified;

    FaqGroup(Context context, TableRow row) throws SQLException {
        super(context);

        // Ensure that my TableRow is typed.
        if (null == row.getTable()) {
            row.setTable("faqgroup");
        }

        myRow = row;

        modified = false;
        clearDetails();
    }

    public static FaqGroup create(Context context) throws SQLException,
            AuthorizeException {

        // Create a table row
        TableRow row = DatabaseManager.create(context, "faqgroup");

        FaqGroup a = new FaqGroup(context, row);

        log.info(LogManager.getHeader(context, "fag_group_create", "question_id:" + a.getID()));

        context.addEvent(new Event(Event.CREATE, Constants.FAQGROUP, a.getID(), null, a.getIdentifiers(context)));

        return a;
    }

    public static FaqGroup find(Context context, int id) throws SQLException {

        TableRow row = DatabaseManager.find(context, "faqgroup", id);

        if (row == null) {
            return null;
        } else {
            return new FaqGroup(context, row);
        }
    }

    public  static List<FaqGroup> selectAllFaqGroup (Context context) throws SQLException{

        List<FaqGroup> faqList = new ArrayList<FaqGroup>();

        TableRowIterator rows = DatabaseManager.query(context,"SELECT FAQGROUP_ID,GROUP_NAME,GROUP_ORDER FROM FAQGROUP ORDER BY GROUP_ORDER");

        try{

            List<TableRow> faqRows = rows.toList();

            for (int i = 0; i < faqRows.size(); i++ ){
                TableRow row = (TableRow) faqRows.get(i);

                faqList.add(new FaqGroup(context,row));
            }
            return faqList;


        }finally {

            if (rows != null){
                rows.close();
            }
        }
    }



    public int countMaxLimit(Context context) throws SQLException{

        Long count;
        TableRow row = DatabaseManager.querySingle(context,"SELECT count(FAQGROUP_ID) as FAQGROUP_ID from FAQGROUP");

        if (DatabaseManager.isOracle())
        {
            count = Long.valueOf(row.getIntColumn("FAQGROUP_ID"));
        }
        else  //getLongColumn works for postgres
        {
            count = Long.valueOf(row.getLongColumn("FAQGROUP_ID"));
        }
        return count.intValue();

    }


    public int countMaxQuestions(Context context) throws SQLException{

        Long count;
        TableRow row = DatabaseManager.querySingle(context,"SELECT COUNT(GROUP_ORDER) as FAQGROUP_ID FROM FAQGROUP");

        if (DatabaseManager.isOracle())
        {
            count = Long.valueOf(row.getIntColumn("GROUP_ORDER"));
        }
        else  //getLongColumn works for postgres
        {
            count = Long.valueOf(row.getLongColumn("GROUP_ORDER"));
        }
        return count.intValue();

    }

    public void update() throws SQLException, AuthorizeException {
        // Check authorisation - if you're not the eperson
        // see if the authorization system says you can


        if (!ourContext.ignoreAuthorization() && ((ourContext.getCurrentUser() == null)))

        {
            AuthorizeManager.authorizeAction(ourContext, this, Constants.WRITE);

        }

        DatabaseManager.update(ourContext, myRow);

        log.info(LogManager.getHeader(ourContext, "faqgroup_update",
                "faqgroup_id:" + getID()));

        if (modified) {
            ourContext.addEvent(new Event(Event.MODIFY, Constants.FAQGROUP,
                    getID(), null, getIdentifiers(ourContext)));
            modified = false;
        }
        if (modifiedMetadata) {
            updateMetadata();
            clearDetails();
        }

    }

    public void delete() throws SQLException, AuthorizeException {

        ourContext.addEvent(new Event(Event.DELETE, Constants.FAQGROUP, getID(), this.getGroupName(), getIdentifiers(ourContext)));

        // Remove from database
        DatabaseManager.delete(ourContext, myRow);

        //log
        log.info(LogManager.getHeader(ourContext, "delete_faqgroup", "faqgroup_id=" + getID()));

        //clean cache
        ourContext.removeCached(this, getID());
    }


    //Getts Setts
    public int getGroupID() {
        return myRow.getIntColumn("FAQGROUP_ID");
    }

    public int getGroupOrder(){
        return myRow.getIntColumn("GROUP_ORDER");
    }
    public void setGroupOrder(int i) {
        myRow.setColumn("GROUP_ORDER", i);
        modified = true;
    }

    public String getGroupName() {
        return myRow.getStringColumn("GROUP_NAME");
    }
    public void setGroupName(String s) {

        myRow.setColumn("GROUP_NAME", s);
        modified = true;

    }


    // Herdadas
    public int getType() {
        return Constants.FAQGROUP;
    }
    public String getHandle() {
        return null;
    }
    public void updateLastModified() {
    }
    public String getName() {
        return myRow.getStringColumn("test");
    }
    public int getID() {
        return myRow.getIntColumn("faqgroup_id");
    }


}
