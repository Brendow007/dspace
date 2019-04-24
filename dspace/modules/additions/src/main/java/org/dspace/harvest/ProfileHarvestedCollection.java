package org.dspace.harvest;

import org.dspace.authorize.AuthorizeException;
import org.dspace.content.DSpaceObject;
import org.dspace.core.Context;
import org.dspace.storage.rdbms.DatabaseManager;
import org.dspace.storage.rdbms.TableRow;
import org.dspace.storage.rdbms.TableRowIterator;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;


public class ProfileHarvestedCollection extends DSpaceObject {
    private final Context context;
    private final TableRow harvestRow;

    private ProfileHarvestedCollection(Context c, TableRow row) {
        context = c;
        harvestRow = row;
    }


    public static List<ProfileHarvestedCollection> findAllProfiles(Context context) throws SQLException {
        List<ProfileHarvestedCollection> profiles = new ArrayList<>();
        TableRowIterator rows = DatabaseManager.query(context, "SELECT PROFILE_ID, NAME_PROFILE, METADATA_STANDARD, IDENTIFY FROM PROFILECOLLECTION");
        try {
            List<TableRow> profileRows = rows.toList();
            for (int i = 0; i < profileRows.size(); i++) {
                profiles.add(new ProfileHarvestedCollection(context, profileRows.get(i)));
            }
            return profiles;
        } finally {
            if (rows != null)
                rows.close();
        }
    }

    public static ProfileHarvestedCollection find(Context c, String id) throws SQLException {
        TableRow row = DatabaseManager.findByUnique(c, "profilecollection", "identify", id);
        return new ProfileHarvestedCollection(c, row);
    }

    @Override
    public void update() throws SQLException, AuthorizeException {
    }

    @Override
    public void updateLastModified() {
    }


    @Override
    public int getID() {
        return harvestRow.getIntColumn("PROFILE_ID");
    }

    @Override
    public String getName() {
        return harvestRow.getStringColumn("NAME_PROFILE");
    }

    @Override
    public String getHandle() {
        return harvestRow.getStringColumn("IDENTIFY");
    }

    public String getStandard() {
        return harvestRow.getStringColumn("METADATA_STANDARD");
    }

    @Override
    public int getType() {
        return 0;
    }


}
