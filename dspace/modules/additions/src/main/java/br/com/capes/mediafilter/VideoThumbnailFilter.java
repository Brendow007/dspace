/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package br.com.capes.mediafilter;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import org.apache.log4j.Logger;
import org.dspace.app.mediafilter.FormatFilter;
import org.dspace.content.Bitstream;
import org.dspace.content.Item;
import org.dspace.core.Context;
import br.com.capes.storage.bitstore.BitstreamStorageManager;
import br.com.capes.video.VideoUtils;

/**
 *
 * @author Guilherme
 */
public class VideoThumbnailFilter implements FormatFilter {

    private final static Logger log = Logger.getLogger(VideoThumbnailFilter.class);

    private String thumbnailFullPath;

    @Override
    public String getFilteredName(String sourceName) {
        return sourceName + VideoUtils.THUMBNAIL_EXTENSION;
    }

    @Override
    public String getBundleName() {
        return "THUMBNAIL";
    }

    @Override
    public String getFormatString() {
        return "JPEG";
    }

    @Override
    public String getDescription() {
        return "Generated Thumbnail";
    }

    @Override
    public boolean preProcessBitstream(Context c, Item item, Bitstream bitstream) throws Exception {
        String bitstreamPath = BitstreamStorageManager.retrieveStoredFilePath(c, bitstream.getID());
        File bitstreamFile = new File(bitstreamPath);

        if (bitstreamFile.exists()) {
            thumbnailFullPath = VideoUtils.createThumbnail(bitstreamPath, item.getHandle(), bitstream.getSequenceID());
            return true;
        } else {
            log.warn("Bitstream file not found " + bitstreamPath);
            return false;
        }
    }

    @Override
    public InputStream getDestinationStream(InputStream source) throws Exception {
        File thumbFile = new File(thumbnailFullPath);

        FileInputStream fis = new FileInputStream(thumbFile);
        return fis;
    }

    @Override
    public void postProcessBitstream(Context c, Item item, Bitstream generatedBitstream) throws Exception {
        File thumbFile = new File(thumbnailFullPath);
        thumbFile.delete();
    }

}
