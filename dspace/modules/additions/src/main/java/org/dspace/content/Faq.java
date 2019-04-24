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
 */


public class Faq extends DSpaceObject {


    private static final Logger log = Logger.getLogger(Faq.class);


    private final TableRow myRow;

    private boolean modified;

    Faq(Context context, TableRow row) throws SQLException {
        super(context);

        // Ensure that my TableRow is typed.
        if (null == row.getTable()) {
            row.setTable("faq");
        }

        myRow = row;

        modified = false;
        clearDetails();
    }

    /***
     *  Create Object
     *
     * @param context
     *
     * @return Create Bean
     *
     * @throws
     *
     * @throws AuthorizeException
     */
    public static Faq create(Context context) throws SQLException,AuthorizeException {

        // Create a table row
        TableRow row = DatabaseManager.create(context, "faq");

        Faq a = new Faq(context, row);

        log.info(LogManager.getHeader(context, "faq_create", "question_id:"+ a.getID()));

        context.addEvent(new Event(Event.CREATE, Constants.FAQ, a.getID(),null, a.getIdentifiers(context)));

        return a;
    }


    /***
     * Ready Single
     *
     * @param context
     *
     * @param id
     *
     * @return bean
     *
     * @throws SQLException
     */

    public static Faq find(Context context, int id) throws SQLException {

        TableRow row = DatabaseManager.find(context, "faq", id);

        if (row == null) {
            return null;
        } else {
            return new Faq(context, row);
        }
    }

    /***
     * Update object
     *
     * @throws SQLException
     * @throws AuthorizeException
     */
    public void update() throws SQLException, AuthorizeException {
        // Check authorisation - if you're not the eperson
        // see if the authorization system says you can


        if (!ourContext.ignoreAuthorization() && ((ourContext.getCurrentUser() == null)))

        {
            AuthorizeManager.authorizeAction(ourContext, this, Constants.WRITE);

        }

        DatabaseManager.update(ourContext, myRow);

        log.info(LogManager.getHeader(ourContext, "faq_update",
                "faq_id:" + getID()));

        if (modified) {
            ourContext.addEvent(new Event(Event.MODIFY, Constants.FAQ,
                    getID(), null, getIdentifiers(ourContext)));
            modified = false;
        }
        if (modifiedMetadata) {
            updateMetadata();
            clearDetails();
        }

    }

    public void delete() throws SQLException, AuthorizeException{

        ourContext.addEvent(new Event(Event.DELETE, Constants.FAQ, getID(), this.getQuestion(), getIdentifiers(ourContext)));

        // Remove from database
        DatabaseManager.delete(ourContext, myRow);

        //log
        log.info(LogManager.getHeader(ourContext, "delete_faq", "faq_id="+ getID()));

        //clean cache
        ourContext.removeCached(this, getID());
        
    }


    public  static List<Faq> selectAllfaq (Context context) throws SQLException{

        List<Faq> faqList = new ArrayList<Faq>();

        TableRowIterator rows = DatabaseManager.query(context,"SELECT FAQ_ID,QUESTION_ID,QUESTION, GROUP_ID , ANSWER FROM FAQ ORDER BY GROUP_ID,QUESTION_ID");

        try{

           List<TableRow> faqRows = rows.toList();

            for (int i = 0; i < faqRows.size(); i++ ){
                TableRow row = (TableRow) faqRows.get(i);

                faqList.add(new Faq(context,row));
        }
        return faqList;


    }finally {

            if (rows != null){
                rows.close();
            }
        }
    }

    public int countMaxLimit(Context context,int i) throws SQLException{

        Long count;

        TableRow row = DatabaseManager.querySingle(context,"SELECT count(question_id) as question_id from faq WHERE faq.group_id ="+ i +" ");

        if (DatabaseManager.isOracle())
        {
            count = Long.valueOf(row.getIntColumn("QUESTION_ID"));
        }
        else  //getLongColumn works for postgres
        {
            count = Long.valueOf(row.getLongColumn("QUESTION_ID"));
        }
        return count.intValue();

    }

    public int countMaxQuestions(Context context) throws SQLException{

        Long count;
        TableRow row = DatabaseManager.querySingle(context,"SELECT COUNT(question_id) as question_id FROM FAQ");

        if (DatabaseManager.isOracle())
        {
            count = Long.valueOf(row.getIntColumn("question_id"));
        }
        else  //getLongColumn works for postgres
        {
            count = Long.valueOf(row.getLongColumn("question_id"));
        }
        return count.intValue();

    }

    public int countMinQuestions(Context context) throws SQLException{

        Long count;

        TableRow row = DatabaseManager.querySingle(context,"SELECT MIN(question_id) as question_id FROM FAQ");

        if (DatabaseManager.isOracle())
        {
            count = Long.valueOf(row.getIntColumn("question_id"));
        }
        else  //getLongColumn works for postgres
        {
            count = Long.valueOf(row.getLongColumn("question_id"));
        }

        return count.intValue();
    }

    public String getName() {
        return myRow.getStringColumn("test");
    }


    public int getType() {
        return Constants.FAQ;
    }
    //    get ids
    public int getID() {
        return myRow.getIntColumn("faq_id");
    }

    public int getGroupID() {
        return myRow.getIntColumn("group_id");
    }
    public int getQuestionID() {
            return myRow.getIntColumn("question_id");
        }

// get questions and answers
    public String getQuestion() {
        return myRow.getStringColumn("question");
    }
    public String getAnswer() {
        return myRow.getStringColumn("answer");
    }

// setts
    public void setAnswer (String s){

//        if (s != null){
//            s = s.toLowerCase();
//        }
        myRow.setColumn("answer", s);
        modified = true;

    }

    public void setQuestion (String i){

//        if (i != null){
//            i = i.toLowerCase();
//        }

        myRow.setColumn("question", i);
        modified = true;

    }


    public  void setQuestionID(int i){
            myRow.setColumn("question_id", i);
            modified = true;


    }

    public  void setGroupID(int i){

            myRow.setColumn("group_id", i);
            modified = true;

    }




    public String getHandle() {
        return null;
    }


    public void updateLastModified() {

    }


}
