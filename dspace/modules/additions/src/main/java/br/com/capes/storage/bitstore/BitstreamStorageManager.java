/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package br.com.capes.storage.bitstore;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.apache.log4j.Logger;
import org.dspace.core.ConfigurationManager;
import org.dspace.storage.rdbms.TableRow;

import edu.sdsc.grid.io.GeneralFile;
import edu.sdsc.grid.io.local.LocalFile;
import edu.sdsc.grid.io.srb.SRBAccount;
import edu.sdsc.grid.io.srb.SRBFile;
import edu.sdsc.grid.io.srb.SRBFileSystem;
import java.sql.SQLException;
import org.dspace.core.Context;
import org.dspace.storage.rdbms.DatabaseManager;

/**
 * @author Guilherme
 */
public class BitstreamStorageManager {

    /**
     * log4j log
     */
    private static Logger log = Logger.getLogger(BitstreamStorageManager.class);

    private static GeneralFile[] assetStores;

    // These settings control the way an identifier is hashed into
    // directory and file names
    //
    // With digitsPerLevel 2 and directoryLevels 3, an identifier
    // like 12345678901234567890 turns into the relative name
    // /12/34/56/12345678901234567890.
    //
    // You should not change these settings if you have data in the
    // asset store, as the BitstreamStorageManager will be unable
    // to find your existing data.
    private static final int digitsPerLevel = 2;

    private static final int directoryLevels = 3;

    /**
     * This prefix string marks registered bitstreams in internal_id
     */
    private static final String REGISTERED_FLAG = "-R";

    /* Read in the asset stores from the config. */
    static {
        List<Object> stores = new ArrayList<Object>();

        // 'assetstore.dir' is always store number 0
        String sAssetstoreDir = ConfigurationManager
                .getProperty("assetstore.dir");

        // see if conventional assetstore or srb
        if (sAssetstoreDir != null) {
            stores.add(sAssetstoreDir); // conventional (non-srb)
        } else if (ConfigurationManager.getProperty("srb.host") != null) {
            stores.add(new SRBAccount( // srb
                    ConfigurationManager.getProperty("srb.host"),
                    ConfigurationManager.getIntProperty("srb.port"),
                    ConfigurationManager.getProperty("srb.username"),
                    ConfigurationManager.getProperty("srb.password"),
                    ConfigurationManager.getProperty("srb.homedirectory"),
                    ConfigurationManager.getProperty("srb.mdasdomainname"),
                    ConfigurationManager
                    .getProperty("srb.defaultstorageresource"),
                    ConfigurationManager.getProperty("srb.mcatzone")));
        } else {
            log.error("No default assetstore");
        }

        // read in assetstores .1, .2, ....
        for (int i = 1;; i++) { // i == 0 is default above
            sAssetstoreDir = ConfigurationManager.getProperty("assetstore.dir."
                    + i);

            // see if 'i' conventional assetstore or srb
            if (sAssetstoreDir != null) { 		// conventional (non-srb)
                stores.add(sAssetstoreDir);
            } else if (ConfigurationManager.getProperty("srb.host." + i)
                    != null) { // srb
                stores.add(new SRBAccount(
                        ConfigurationManager.getProperty("srb.host." + i),
                        ConfigurationManager.getIntProperty("srb.port." + i),
                        ConfigurationManager.getProperty("srb.username." + i),
                        ConfigurationManager.getProperty("srb.password." + i),
                        ConfigurationManager
                        .getProperty("srb.homedirectory." + i),
                        ConfigurationManager
                        .getProperty("srb.mdasdomainname." + i),
                        ConfigurationManager
                        .getProperty("srb.defaultstorageresource." + i),
                        ConfigurationManager.getProperty("srb.mcatzone." + i)));
            } else {
                break; // must be at the end of the assetstores
            }
        }

        // convert list to array
        // the elements (objects) in the list are class
        //   (1) String - conventional non-srb assetstore
        //   (2) SRBAccount - srb assetstore
        assetStores = new GeneralFile[stores.size()];
        for (int i = 0; i < stores.size(); i++) {
            Object o = stores.get(i);
            if (o == null) { // I don't know if this can occur
                log.error("Problem with assetstore " + i);
            }
            if (o instanceof String) {
                assetStores[i] = new LocalFile((String) o);
            } else if (o instanceof SRBAccount) {
                SRBFileSystem srbFileSystem = null;
                try {
                    srbFileSystem = new SRBFileSystem((SRBAccount) o);
                } catch (NullPointerException e) {
                    log.error("No SRBAccount for assetstore " + i);
                } catch (IOException e) {
                    log.error("Problem getting SRBFileSystem for assetstore"
                            + i);
                }
                if (srbFileSystem == null) {
                    log.error("SRB FileSystem is null for assetstore " + i);
                }
                String sSRBAssetstore = null;
                if (i == 0) { // the zero (default) assetstore has no suffix
                    sSRBAssetstore = ConfigurationManager
                            .getProperty("srb.parentdir");
                } else {
                    sSRBAssetstore = ConfigurationManager
                            .getProperty("srb.parentdir." + i);
                }
                if (sSRBAssetstore == null) {
                    log.error("srb.parentdir is undefined for assetstore " + i);
                }
                assetStores[i] = new SRBFile(srbFileSystem, sSRBAssetstore);
            } else {
                log.error("Unexpected " + o.getClass().toString()
                        + " with assetstore " + i);
            }
        }
    }

    /**
     * Does the internal_id column in the bitstream row indicate the bitstream
     * is a registered file
     *
     * @param internalId the value of the internal_id column
     * @return true if the bitstream is a registered file
     */
    public static boolean isRegisteredBitstream(String internalId) {
        if (internalId.substring(0, REGISTERED_FLAG.length())
                .equals(REGISTERED_FLAG)) {
            return true;
        }
        return false;
    }

    /**
     * Return the file corresponding to a bitstream. It's safe to pass in
     * <code>null</code>.
     *
     * @param bitstream the database table row for the bitstream. Can be
     * <code>null</code>
     *
     * @return The corresponding file in the file system, or <code>null</code>
     *
     * @exception IOException If a problem occurs while determining the file
     */
    private static GeneralFile getFile(TableRow bitstream) throws IOException {
        // Check that bitstream is not null
        if (bitstream == null) {
            return null;
        }

        // Get the store to use
        int storeNumber = bitstream.getIntColumn("store_number");

        // Default to zero ('assetstore.dir') for backwards compatibility
        if (storeNumber == -1) {
            storeNumber = 0;
        }

        GeneralFile assetstore = assetStores[storeNumber];

        // turn the internal_id into a file path relative to the assetstore
        // directory
        String sInternalId = bitstream.getStringColumn("internal_id");

        // there are 4 cases:
        // -conventional bitstream, conventional storage
        // -conventional bitstream, srb storage
        // -registered bitstream, conventional storage
        // -registered bitstream, srb storage
        // conventional bitstream - dspace ingested, dspace random name/path
        // registered bitstream - registered to dspace, any name/path
        String sIntermediatePath = null;
        if (isRegisteredBitstream(sInternalId)) {
            sInternalId = sInternalId.substring(REGISTERED_FLAG.length());
            sIntermediatePath = "";
        } else {

            // Sanity Check: If the internal ID contains a
            // pathname separator, it's probably an attempt to
            // make a path traversal attack, so ignore the path
            // prefix.  The internal-ID is supposed to be just a
            // filename, so this will not affect normal operation.
            if (sInternalId.indexOf(File.separator) != -1) {
                sInternalId = sInternalId.substring(sInternalId.lastIndexOf(File.separator) + 1);
            }

            sIntermediatePath = getIntermediatePath(sInternalId);
        }

        StringBuffer bufFilename = new StringBuffer();
        if (assetstore instanceof LocalFile) {
            bufFilename.append(assetstore.getCanonicalPath());
            bufFilename.append(File.separator);
            bufFilename.append(sIntermediatePath);
            bufFilename.append(sInternalId);
            if (log.isDebugEnabled()) {
                log.debug("Local filename for " + sInternalId + " is "
                        + bufFilename.toString());
            }
            return new LocalFile(bufFilename.toString());
        }
        if (assetstore instanceof SRBFile) {
            bufFilename.append(sIntermediatePath);
            bufFilename.append(sInternalId);
            if (log.isDebugEnabled()) {
                log.debug("SRB filename for " + sInternalId + " is "
                        + ((SRBFile) assetstore).toString()
                        + bufFilename.toString());
            }
            return new SRBFile((SRBFile) assetstore, bufFilename.toString());
        }
        return null;
    }

    /**
     * Return the intermediate path derived from the internal_id. This method
     * splits the id into groups which become subdirectories.
     *
     * @param iInternalId The internal_id
     * @return The path based on the id without leading or trailing separators
     */
    private static String getIntermediatePath(String iInternalId) {
        StringBuffer buf = new StringBuffer();
        for (int i = 0; i < directoryLevels; i++) {
            int digits = i * digitsPerLevel;
            if (i > 0) {
                buf.append(File.separator);
            }
            buf.append(iInternalId.substring(digits, digits
                    + digitsPerLevel));
        }
        buf.append(File.separator);
        return buf.toString();
    }

    /**
     * Method added to provide the dspace with the
     * pseudostreaming video files hability.
     *
     * @param context The current context
     * @param id The ID of the bitstream to retrieve
     * @exception IOException If a problem occurs while retrieving the bits
     * @exception SQLException If a problem occurs accessing the RDBMS
     *
     * @return The stored file, or null
     */
    public static String retrieveStoredFilePath(Context context, int id)
            throws SQLException, IOException {
        TableRow bitstream = DatabaseManager.find(context, "bitstream", id);

        GeneralFile generalFile = getFile(bitstream);

        return (generalFile != null) ? generalFile.getCanonicalPath() : null;
    }

}
