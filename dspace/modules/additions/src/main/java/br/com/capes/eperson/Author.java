/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package br.com.capes.eperson;

import org.apache.log4j.Logger;
import org.dspace.authorize.AuthorizeException;
import org.dspace.authorize.AuthorizeManager;
import org.dspace.content.DSpaceObject;
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.dspace.core.LogManager;
import org.dspace.eperson.EPerson;
import org.dspace.eperson.EPersonDeletionException;
import org.dspace.event.Event;
import org.dspace.storage.rdbms.DatabaseManager;
import org.dspace.storage.rdbms.TableRow;
import org.dspace.storage.rdbms.TableRowIterator;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Class representing an capes author.
 *
 * @author Guilherme Lemeszenski
 * @author Brendow Adriel
 * @version $Revision$
 */
public class Author extends DSpaceObject {

    private EPerson eperson;

    /**
     * log4j logger
     */
    private static final Logger log = Logger.getLogger(Author.class);

    /**
     * The row in the table representing this eperson
     */
    private final TableRow myRow;

    private boolean modified;

    /**
     * Construct an Author
     *
     * @param context the context this object exists in
     * @param row the corresponding row in the table
     */
    Author(Context context, TableRow row) throws SQLException {
        super(context);

        // Ensure that my TableRow is typed.
        if (null == row.getTable()) {
            row.setTable("author");
        }

        myRow = row;

        modified = false;
        clearDetails();
    }

    /**
     * Create a new author
     *
     * @param context DSpace context object
     */
    public static Author create(Context context) throws SQLException,
            AuthorizeException {

        // Create a table row
        TableRow row = DatabaseManager.create(context, "author");

        Author a = new Author(context, row);

        log.info(LogManager.getHeader(context, "create_author", "author_id="
                + a.getID()));

        context.addEvent(new Event(Event.CREATE, Constants.AUTHOR, a.getID(),
                null, a.getIdentifiers(context)));

        a.setActive(false);

        return a;
    }

    @Override
    public int getType() {
        return Constants.AUTHOR;
    }

    @Override
    public int getID() {
        return myRow.getIntColumn("author_id");
    }

    @Override
    public String getHandle() {
        return null;
    }

    @Override
    public String getName() {
        try {
            return this.getEPerson().getName();
        } catch (SQLException e) {
            log.error("EPerson not found", e);
            return null;
        }
    }

    @Override
    public void update() throws SQLException, AuthorizeException {
        // Check authorisation - if you're not the eperson
        // see if the authorization system says you can
        if (!ourContext.ignoreAuthorization()
                && ((ourContext.getCurrentUser() == null) || (this.getEPersonId() != ourContext.getCurrentUser().getID()))) {
            AuthorizeManager.authorizeAction(ourContext, this, Constants.WRITE);
        }

        DatabaseManager.update(ourContext, myRow);

        log.info(LogManager.getHeader(ourContext, "update_author",
                "author_id=" + getID()));

        if (modified) {
            ourContext.addEvent(new Event(Event.MODIFY, Constants.AUTHOR,
                    getID(), null, getIdentifiers(ourContext)));
            modified = false;
        }
        if (modifiedMetadata) {
            updateMetadata();
            clearDetails();
        }
    }

    @Override
    public void updateLastModified() {

    }

    /**
     *
     */
    public static Author find(Context context, int id) throws SQLException {

        TableRow row = DatabaseManager.find(context, "author", id);

        if (row == null) {
            return null;
        } else {
            return new Author(context, row);
        }
    }
    
    /***/
    public static List<Author> findAll(Context context) throws SQLException {

        List<Author> authorList = new ArrayList<Author>();

        TableRowIterator rows = DatabaseManager.query(context, "SELECT * FROM author a ORDER BY author_id");

        try {
            List<TableRow> authorRows = rows.toList();

            for (int i = 0; i < authorRows.size(); i++) {
                TableRow row = (TableRow) authorRows.get(i);

                authorList.add(new Author(context, row));
            }

            return authorList;
        } finally {
            if (rows != null) {
                rows.close();
            }
        }

    }

//    public String canEdit(Context context) throws SQLException{
//
//        TableRow row = DatabaseManager.querySingle(context,"select handle.handle from item2bundle\n" +
//                "inner join item on item.item_id = item2bundle.item_id\n" +
//                "inner join handle on handle.resource_id = item2bundle.item_id\n" +
//                "inner join eperson on item.submitter_id = eperson.eperson_id\n" +
//                "where eperson.email " + context.getCurrentUser());
//
//        String handle = row.getStringColumn("handle.handle");
//
//        return handle;
//
//    }

    /***/
    public static List<Author> findAllInactive(Context context) throws SQLException {

        List<Author> authorList = new ArrayList<Author>();

        TableRowIterator rows = DatabaseManager.query(context, "SELECT * FROM author a WHERE active = '0' ORDER BY author_id");

        try {
            List<TableRow> authorRows = rows.toList();

            for (int i = 0; i < authorRows.size(); i++) {
                TableRow row = (TableRow) authorRows.get(i);

                authorList.add(new Author(context, row));
            }

            return authorList;
        } finally {
            if (rows != null) {
                rows.close();
            }
        }
    }


    /***
     *
     * @param context
     * @return eperson + item_submitted
     * @throws SQLException
     */
//Query to return all eperson that has submitted any item
//
//    select e.email, i.item_id from item i inner join eperson e on (e.eperson_id = i.submitter_id)
//    where e.email not like '%educapes@capes.gov.br%' or e.email not like '%rede@capes.gov.br%' ;
//
//
//     Seleciona todos os
//    select e.email, i.item_id from item i inner join eperson e on (e.eperson_id = i.submitter_id) where i.item_id = ?;


    public static List<Author> findAllActive(Context context) throws SQLException {

        List<Author> authorList = new ArrayList<Author>();

        TableRowIterator rows = DatabaseManager.query(context, "SELECT * FROM author a WHERE active = '1' ORDER BY author_id");

        try {
            List<TableRow> authorRows = rows.toList();

            for (int i = 0; i < authorRows.size(); i++) {
                TableRow row = (TableRow) authorRows.get(i);

                authorList.add(new Author(context, row));
            }

            return authorList;
        } finally {
            if (rows != null) {
                rows.close();
            }
        }
    }

    /**
     *
     */
    public void delete() throws SQLException, AuthorizeException,
            EPersonDeletionException {
        // authorized?
        if (!AuthorizeManager.isAdmin(ourContext)) {
            throw new AuthorizeException(
                    "You must be an admin to delete an Author");
        }

        ourContext.addEvent(new Event(Event.DELETE, Constants.AUTHOR, getID(), this.getEPerson().getEmail(), getIdentifiers(ourContext)));

        // Remove ourself
        DatabaseManager.delete(ourContext, myRow);

        this.getEPerson().delete();
    }

    /**
     * 
     */
    /*public static Author[] search(Context context, String email, Boolean active, int offset, int limit)
            throws SQLException {
        StringBuilder builder = new StringBuilder();
        builder.append("SELECT * FROM author a");

        if ((email != null && !email.isEmpty()) || (active != null)) {
            builder.append(" WHERE ");

            if (email != null && !email.isEmpty()) {
                builder.append(" email LIKE '%" + email + "%' ");
            }

            if (active != null) {

                if (active) {
                    builder.append(" active =  '' ");
                }

            }
        }

    }*/

    /**
     *
     */
    public void setEPersonId(int i) {
        myRow.setColumn("eperson_id", i);
        modified = true;

    }

    /**
     *
     */
    public void setCpf(String s) {
        if (s != null) {
            s = s.toLowerCase();
        }

        myRow.setColumn("cpf", s);
        modified = true;
    }

    /**
     *
     */
    public void setInstitutionName(String s) {
        myRow.setColumn("institution_name", s);
        modified = true;
    }

    /**
     *
     */
    public void setInstitutionShortName(String s) {
        if (s != null) {
            s = s.toUpperCase();
        }

        myRow.setColumn("institution_shortname", s);
        modified = true;
    }

    /**
     *
     */
    public void setDepartment(String s) {

        myRow.setColumn("department", s);
        modified = true;
    }

    /**
     *
     */
    public void setJobTitle(String s) {
        myRow.setColumn("job_title", s);
        modified = true;
    }

    /**
     *
     */
    public void setCelphone(String s) {
        myRow.setColumn("celphone", s);
        modified = true;
    }

    /**
     *
     */
    public void setInstitutionSite(String s) {
        myRow.setColumn("institution_site", s);
        modified = true;
    }

    /**
     *
     */
    public void setInstitutionRepository(String s) {

        myRow.setColumn("institution_repository", s);
        modified = true;
    }

    /**
     *
     */
    public void setInstitutionAva(String s) {
        myRow.setColumn("institution_ava", s);
        modified = true;
    }

    /**
     *
     */
    public void setRefusalCause(String s) {
        myRow.setColumn("refusal_cause", s);
        modified = true;
    }

    /**
     *
     */
    public void setItemCount(int s) {

        myRow.setColumn("item_count", s);
        modified = true;
    }

    /**
     *
     */
    public void setActive(boolean s) {
        myRow.setColumn("active", s);
        modified = true;
    }

    /**
     *
     */
    public void setToken(String s) {
        myRow.setColumn("token", s);
        modified = true;
    }

    /**
     *
     */
    public int getEPersonId() {
        return myRow.getIntColumn("eperson_id");
    }

    /**
     *
     */
    public String getCpf() {
        return myRow.getStringColumn("cpf");
    }

    /**
     *
     */
    public String getInstitutionName() {
        return myRow.getStringColumn("institution_name");
    }

    /**
     *
     */
    public String getInstitutionShortName() {
        return myRow.getStringColumn("institution_shortname");
    }

    /**
     *
     */
    public String getDepartment() {
        return myRow.getStringColumn("department");
    }

    /**
     *
     */
    public String getJobTitle() {
        return myRow.getStringColumn("job_title");
    }

    /**
     *
     */
    public String getCelphone() {
        return myRow.getStringColumn("celphone");
    }

    /**
     *
     */
    public String getInstitutionSite() {
        return myRow.getStringColumn("institution_site");
    }

    /**
     *
     */
    public String getInstitutionRepository() {
        return myRow.getStringColumn("institution_repository");
    }

    /**
     *
     */
    public String getInstitutionAva() {
        return myRow.getStringColumn("institution_ava");
    }

    /**
     *
     */
    public String getRefusalCause() {
        return myRow.getStringColumn("refusal_cause");
    }

    /**
     *
     */
    public Integer getItemCount() {
        return myRow.getIntColumn("item_count");
    }

    /**
     *
     */
    public boolean getActive() {
        return myRow.getBooleanColumn("active");

    }

    /**
     *
     */
    public String getToken() {
        return myRow.getStringColumn("token");
    }

    /**
     *
     */
    public EPerson getEPerson() throws SQLException {
        if (this.eperson == null) {
            this.eperson = EPerson.find(ourContext, this.getEPersonId());
        }

        return this.eperson;
    }

}
