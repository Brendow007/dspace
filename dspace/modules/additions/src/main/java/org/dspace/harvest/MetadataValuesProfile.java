package org.dspace.harvest;

import org.apache.log4j.Logger;
import org.dspace.authorize.AuthorizeException;
import org.dspace.authorize.AuthorizeManager;
import org.dspace.content.DSpaceObject;
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

public class MetadataValuesProfile extends DSpaceObject {

    private static final Logger log = Logger.getLogger(MetadataValuesProfile.class);
    private final TableRow valuesRow;
    private boolean modified;


    MetadataValuesProfile(Context context, TableRow row) {
        super(context);

        if (null == row.getTable()) {
            row.setTable("METADATAVALUESPROFILE");
        }

        valuesRow = row;

        modified = false;
        clearDetails();
    }


    public static List<MetadataValuesProfile> findAllMetadataValuesByProfile(Context context, String standard) throws SQLException {
        List<MetadataValuesProfile> values = new ArrayList<>();
        TableRowIterator rows = DatabaseManager.query(context, "SELECT METADATAVALUES_ID, PROFILE, TYPE, METADATAVALUES, METADATA FROM METADATAVALUESPROFILE WHERE PROFILE = '" + standard + "'");
        try {
            List<TableRow> metadataValues = rows.toList();
            for (int i = 0; i < metadataValues.size(); i++) {
                values.add(new MetadataValuesProfile(context, metadataValues.get(i)));
            }
            return values;
        } finally {
            if (rows != null)
                rows.close();
        }
    }


    public int getIdValues() {
        return valuesRow.getIntColumn("METADATAVALUE_ID");
    }

    public String getProfileValues() {
        return valuesRow.getStringColumn("METADATAVALUE_ID");
    }

    public String getTypeValues() {
        return valuesRow.getStringColumn("TYPE");
    }

    public String getProfile() {
        return valuesRow.getStringColumn("PROFILE");
    }

    public void setProfile(String s) {
        if (s != null) {
            s = s.toUpperCase();
        }
        valuesRow.setColumn("PROFILE", s);
        modified = true;
    }


    public void setType(String s) {
        if (s != null) {
            s = s.toLowerCase();
        }
        valuesRow.setColumn("TYPE", s);
        modified = true;
    }

    public String getMetadataValues() {

        return valuesRow.getStringColumn("METADATA");
    }

    public void setMetadataValues(String s) {
        if (s != null) {
            s = s.toLowerCase();
        }
        valuesRow.setColumn("METADATA", s);
        modified = true;
    }

    public String getArrayValues() {
        return valuesRow.getStringColumn("METADATAVALUES");
    }

    public void setArrayValues(String s) {
        if (s != null) {
            s = s.toLowerCase();
        }


        valuesRow.setColumn("METADATAVALUES", s);
        modified = true;
    }


    public int getID() {
        return valuesRow.getIntColumn("METADATAVALUES_ID");
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
    public String getName() {
        return null;
    }


    public static MetadataValuesProfile create(Context context) throws SQLException
             {



        TableRow row = DatabaseManager.create(context, "METADATAVALUESPROFILE");

        MetadataValuesProfile a = new MetadataValuesProfile(context, row);

        log.info(LogManager.getHeader(context, "MetadataValuesProfile_create", "MetadataValuesProfile_id:" + a.getID()));

        context.addEvent(new Event(Event.CREATE, Constants.METADATAPROFILEVALUES, a.getID(), null, a.getIdentifiers(context)));

        return a;
    }

    public static MetadataValuesProfile find(Context context, int id) throws SQLException {
        TableRow row = DatabaseManager.find(context, "METADATAVALUESPROFILE", id);
        if (row == null) {
            return null;
        }
        return new MetadataValuesProfile(context, row);
    }

    @Override
    public void update() throws SQLException, AuthorizeException {
        if (!ourContext.ignoreAuthorization() && ((ourContext.getCurrentUser() == null))) {
            AuthorizeManager.authorizeAction(ourContext, this, Constants.WRITE);
        }
        DatabaseManager.update(ourContext, valuesRow);
        log.info(LogManager.getHeader(ourContext, "MetadataValuesProfile_update",
                "MetadataValuesProfile_id:" + getID()));
        if (modified) {
            ourContext.addEvent(new Event(Event.MODIFY, Constants.METADATAPROFILEVALUES,
                    getID(), null, getIdentifiers(ourContext)));
            modified = false;
        }
        if (modifiedMetadata) {
            updateMetadata();
            clearDetails();
        }
    }

    public void delete() throws SQLException, AuthorizeException {
        ourContext.addEvent(new Event(Event.DELETE, Constants.METADATAPROFILEVALUES, getID(), this.getName(), getIdentifiers(ourContext)));
        // Remove from database
        DatabaseManager.delete(ourContext, valuesRow);

        //log
        log.info(LogManager.getHeader(ourContext, "delete_MetadataValuesProfile", "MetadataValuesProfile_id=" + getID()));

        //clean cache
        ourContext.removeCached(this, getID());
    }

    @Override
    public void updateLastModified() {

    }
}
