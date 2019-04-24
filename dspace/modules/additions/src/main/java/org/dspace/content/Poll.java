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
 * Created by brendows on 19/08/2016.
 *
 *  Poll
 *
 */
public class Poll extends DSpaceObject {


    private static final Logger log = Logger.getLogger(Poll.class);

    private TableRow row;

    private final TableRow myRow;
    private boolean modified;


    /**
     * @Constructor Class
     * @return
     */

    Poll(Context context, TableRow row) throws SQLException {
        super(context);

        // Ensure that my TableRow is typed.
        if (null == row.getTable()) {
            row.setTable("poll");
        }

        myRow = row;

        modified = false;
        clearDetails();
    }

    public static List<Poll> selectallnotes (Context context) throws SQLException{
        List<Poll> polllist = new ArrayList<Poll>();

        TableRowIterator rows = DatabaseManager.query(context,"SELECT * FROM poll");

        try {
            List<TableRow> pollRows = rows.toList();

            for (int i = 0; i < pollRows.size(); i++) {
                TableRow row = (TableRow) pollRows.get(i);


                polllist.add(new Poll(context,row));
                   }


            return polllist;
        }finally {

            if (rows != null) {
                rows.close();
            }
        }

    }



    public int selectnote1(Context context) throws SQLException{

        Long count;


        TableRow row = DatabaseManager.querySingle(context,"SELECT COUNT(NOTE) as note FROM POLL WHERE NOTE = 1");

        if (DatabaseManager.isOracle())
        {

            count = Long.valueOf(row.getIntColumn("note"));


           // count = Long.valueOf(row.getIntColumn("note"));
        }
        else  //getLongColumn works for postgres
        {
            count = Long.valueOf(row.getLongColumn("note"));
        }


        return count.intValue();
    }


    public int selectnote2(Context context) throws SQLException{

        Long count;


        TableRow row = DatabaseManager.querySingle(context,"SELECT COUNT (NOTE) as note FROM POLL WHERE NOTE = 2");

        if (DatabaseManager.isOracle())
        {

            count = Long.valueOf(row.getIntColumn("note"));

       //     count = Long.valueOf(row.getIntColumn("note"));
        }
        else  //getLongColumn works for postgres
        {
            count = Long.valueOf(row.getLongColumn("note"));
        }


        return count.intValue();
    }


    public int selectnote3(Context context) throws SQLException{

        Long count;


        TableRow row = DatabaseManager.querySingle(context,"SELECT COUNT (NOTE) as note FROM POLL WHERE NOTE = 3");

        if (DatabaseManager.isOracle())
        {
            //count = Long.valueOf(row.getIntColumn("note"));
            count = Long.valueOf(row.getIntColumn("note"));

        }
        else  //getLongColumn works for postgres
        {
            count = Long.valueOf(row.getLongColumn("note"));
        }


        return count.intValue();
    }


    public int selectnote4(Context context) throws SQLException{

        Long count;


        TableRow row = DatabaseManager.querySingle(context,"SELECT COUNT (NOTE) as note FROM POLL WHERE NOTE = 4");

        if (DatabaseManager.isOracle())
        {
            count = Long.valueOf(row.getIntColumn("note"));
        }
        else  //getLongColumn works for postgres
        {
            count = Long.valueOf(row.getLongColumn("note"));
        }


        return count.intValue();
    }


    public int selectnote5(Context context) throws SQLException{

        Long count;


        TableRow row = DatabaseManager.querySingle(context,"SELECT COUNT (NOTE) as note FROM POLL WHERE NOTE = 5");

        if (DatabaseManager.isOracle())
        {
            count = Long.valueOf(row.getIntColumn("note"));
        }
        else  //getLongColumn works for postgres
        {
            count = Long.valueOf(row.getLongColumn("note"));
        }


        return count.intValue();
    }

    public static Poll create(Context context) throws SQLException,
            AuthorizeException{



        TableRow row = DatabaseManager.create(context,"poll");


        Poll p = new Poll(context, row);


        log.info(LogManager.getHeader(context, "poll_registry", "Poll_id")
                + p.getID());

        context.addEvent(new Event(Event.CREATE, Constants.POLL, p.getID(), null, p.getIdentifiers(context)));

        return p;

    }


    public void update() throws SQLException, AuthorizeException {
        // Check authorisation - if you're not the eperson
        // see if the authorization system says you can


        if (!ourContext.ignoreAuthorization() && ((ourContext.getCurrentUser() == null)))

        {
            AuthorizeManager.authorizeAction(ourContext, this, Constants.WRITE);

        }

        DatabaseManager.update(ourContext, myRow);

        log.info(LogManager.getHeader(ourContext, "poll_update",
                    "poll_id=" + getID()));

        if (modified) {
            ourContext.addEvent(new Event(Event.MODIFY, Constants.POLL,
                        getID(), null, getIdentifiers(ourContext)));
            modified = false;
        }
        if (modifiedMetadata) {
            updateMetadata();
            clearDetails();
        }

    }

    public int getType() {
        return Constants.POLL;
    }

    public int getID() {
        return myRow.getIntColumn("poll_id");
    }

    public String getEmail() {
        return myRow.getStringColumn("email");
    }

    public String getHandle() {
        return null;
    }

    public String getName() {

        return null;

    }


    public int  getNote() {

        return myRow.getIntColumn("note");


    }

    public void updateLastModified() {

    }


    /**
     *  Setters Methods
     */

    public void setEmail (String s){

        if (s != null){
            s = s.toLowerCase();


        }
        myRow.setColumn("email", s);
        modified = true;

    }

    public void setNote (int i){

        if (i != 0 || i < 6) {

            myRow.setColumn("note", i);
            modified = true;
        }
    }




}
