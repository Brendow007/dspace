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
 * @author brendows
 * This class represents a partner dinamic information on dspace.
 *
 * vars:
 *
 ** id
 ** path
 ** url
 ** name
 ** group
 ** status
 ** order
 * *
 */
public class Partners extends DSpaceObject {




    /**
     * log4j logger
     */
    private static final Logger log = Logger.getLogger(Partners.class);

    /**
     * The row in the table representing this partner
     */
    private final TableRow myRow;

    private boolean modified;


    /***
     * Constructor
     *
     * @param context
     *
     * @param
     * */

    Partners(Context context, TableRow row) throws SQLException {
        super(context);

        // Ensure that my TableRow is typed.
        if (null == row.getTable()) {
            row.setTable("partners");
        }

        myRow = row;

        modified = false;
        clearDetails();
    }


    /***
     *
     * Create a instantiate or representation of object
     *
     * @param context
     *
     * @return Bean
     *
     * @throws SQLException
     *
     */

    public static Partners Create(Context context) throws SQLException {

        TableRow row = DatabaseManager.create(context, "partners");

        Partners Partners = new Partners(context, row);

        log.info(LogManager.getHeader(context, "partner_create", "PARTNER_ID:" + Partners.getID()));

        context.addEvent(new Event(Event.CREATE, Constants.PARTNERS, Partners.getID(), null, Partners.getIdentifiers(context)));

        return Partners;

    }

    /**
     * Return a Ready Single representation of object
     *
     * @param context operation
     * @param id
     * @return bean
     * @throws SQLException
     */

    public static Partners find(Context context, int id) throws SQLException {

        TableRow row = DatabaseManager.find(context, "partners", id);

        if (row == null) {
            return null;
        } else {
            return new Partners(context, row);
        }
    }

    public static int  countMaxLimit(Context context) throws SQLException{

        Long count;
        TableRow row = DatabaseManager.querySingle(context,"SELECT max(GROUP_PARTNER) as GROUP_PARTNER from PARTNERS");

        if (DatabaseManager.isOracle())
        {
            count = Long.valueOf(row.getIntColumn("GROUP_PARTNER"));
        }
        else  //getLongColumn works for postgres
        {
            count = Long.valueOf(row.getLongColumn("GROUP_PARTNER"));
        }
        return count.intValue();

    }

    public int countMaxOrderByGroup(Context context,int group) throws SQLException{

        Long count;
        TableRow row = DatabaseManager.querySingle(context,"SELECT count(ORDER_PARTNER) as ORDER_PARTNER from PARTNERS WHERE PARTNERS.GROUP_PARTNER="+group);

        if (DatabaseManager.isOracle())
        {
            count = Long.valueOf(row.getIntColumn("ORDER_PARTNER"));
        }
        else  //getLongColumn works for postgres
        {
            count = Long.valueOf(row.getLongColumn("ORDER_PARTNER"));
        }
        return count.intValue();

    }

    public  static List<Partners> selectAllActivepartners(Context context) throws SQLException{

        List<Partners> partnerlist = new ArrayList<Partners>();

        TableRowIterator rows = DatabaseManager.query(context,"SELECT PARTNER_ID, NAME, URL, GROUP_PARTNER,ORDER_PARTNER, PATH, STATUS FROM PARTNERS WHERE STATUS = 1 ORDER BY GROUP_PARTNER, ORDER_PARTNER, PARTNER_ID");

        try{

            List<TableRow> faqRows = rows.toList();

            for (int i = 0; i < faqRows.size(); i++ ){
                TableRow row = (TableRow) faqRows.get(i);

                partnerlist.add(new Partners(context,row));
            }
            return partnerlist;


        }finally {

            if (rows != null){
                rows.close();
            }
        }
    }
    public  static List<Partners> selectAllpartners(Context context) throws SQLException{

        List<Partners> partnerlist = new ArrayList<>();

        TableRowIterator rows = DatabaseManager.query(context,"SELECT PARTNER_ID, NAME, URL, GROUP_PARTNER,ORDER_PARTNER, PATH, STATUS FROM PARTNERS ORDER BY GROUP_PARTNER, ORDER_PARTNER, PARTNER_ID");

        try{

            List<TableRow> faqRows = rows.toList();

            for (int i = 0; i < faqRows.size(); i++ ){
                TableRow row = (TableRow) faqRows.get(i);

                partnerlist.add(new Partners(context,row));
            }
            return partnerlist;


        }finally {

            if (rows != null){
                rows.close();
            }
        }
    }



    /**
     * Update representation or instantiate of object
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

        log.info(LogManager.getHeader(ourContext, "partner_update",
                "PARTNER_ID:" + getID()));

        if (modified) {
            ourContext.addEvent(new Event(Event.MODIFY, Constants.PARTNERS,
                    getID(), null, getIdentifiers(ourContext)));
            modified = false;
        }
        if (modifiedMetadata) {
            updateMetadata();
            clearDetails();
        }

    }

    /**
     * Delete the representation or instant of object but not of database if this not commit with context
     *
     * @throws SQLException
     * @throws AuthorizeException
     */
    public void delete() throws SQLException, AuthorizeException {

        ourContext.addEvent(new Event(Event.DELETE, Constants.PARTNERS, getID(), this.getPath(), getIdentifiers(ourContext)));

        // Remove from database
        DatabaseManager.delete(ourContext, myRow);

        //log
        log.info(LogManager.getHeader(ourContext, "delete_partner", "PARTNER_ID=" + getID()));

        //clean cache
        ourContext.removeCached(this, getID());

    }

    /**
     * @return id
     */
    public int getID() {
        return myRow.getIntColumn("PARTNER_ID");
    }

    /**
     * @return get set name
     */

    @Override
    public String getName() {


            return myRow.getStringColumn("name");

    }

    public void setName(String value) {

        if (!value.isEmpty() && value != null) {

            value = value.toLowerCase();

            myRow.setColumn("NAME", value);
            modified = true;

        }
    }

    /**
     * @return get set path
     */
    public String getPath() {

            return myRow.getStringColumn("path");

    }

    public void setPath(String value) {

        if (!value.isEmpty() || value != null) {


            myRow.setColumn("PATH", value);
            modified = true;


        } else {

            log.info("Cause::path value:" + value);
        }
    }

    /**
     * @return get set url
     */
    public String getUrl() {


            return myRow.getStringColumn("URL");


    }

    public void setUrl(String value) {

        if (!value.isEmpty() && value != null) {

            value = value.toLowerCase();

            myRow.setColumn("URL", value);
            modified = true;


        } else {

            log.info("Cause::url value:" + value);
        }
    }

    /**
     * @return get set group
     */
    public int getGroup() {


            return myRow.getIntColumn("GROUP_PARTNER");



    }

    public void setGroup(int value) {

            myRow.setColumn("GROUP_PARTNER", value);
            modified = true;


    }

    /**
     * @return get set group
     */
    public Boolean getStatus() {

        return myRow.getBooleanColumn("STATUS");

    }

    public void setStatus(Boolean value) {

            myRow.setColumn("STATUS", value);
//            modified = true;


    }


    /***
     * @returns get set order
     */

    public int getOrderPartner(){

        return myRow.getIntColumn("ORDER_PARTNER");

    }
    public void setOrderPartner(int value){

        myRow.setColumn("ORDER_PARTNER",value);
    }



    @Override
    public int getType() {
        return 0;
    }


    @Override
    public String getHandle() {
        return null;
    }


    @Override
    public void updateLastModified() {

    }
}
