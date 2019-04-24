/**
 * The contents of this file are subject to the license and copyright detailed
 * in the LICENSE and NOTICE files at the root of the source tree and available
 * online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.webui.servlet;

import br.com.capes.video.VideoUtils;
import edu.sdsc.grid.io.GeneralFile;
import org.apache.log4j.Logger;
import org.dspace.app.webui.util.JSPManager;
import org.dspace.app.webui.util.UIUtil;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Bitstream;
import org.dspace.content.Bundle;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.dspace.core.*;
import org.dspace.handle.HandleManager;
import org.dspace.usage.UsageEvent;
import org.dspace.utils.DSpace;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.ByteBuffer;
import java.sql.SQLException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Servlet for retrieving bitstreams. The bits are simply piped to the user. If
 * there is an <code>If-Modified-Since</code> header, only a 304 status code is
 * returned if the containing item has not been modified since that date.
 * <P>
 * <code>/bitstream/handle/sequence_id/filename</code>
 *
 * @author Robert Tansley
 * @version $Revision$
 */
public class BitstreamServlet extends DSpaceServlet {

    /**
     * log4j category
     */
    private static Logger log = Logger.getLogger(BitstreamServlet.class);

    /**
     * Threshold on Bitstream size before content-disposition will be set.
     */
    private int threshold;

    private static final int BUFFER_LENGTH = 1024 * 16;
    private static final long EXPIRE_TIME = 1000 * 60 * 60 * 24;
    private static final Pattern RANGE_PATTERN = Pattern.compile("bytes=(?<start>\\d*)-(?<end>\\d*)");

    /**
     * The asset store locations. The information for each GeneralFile in the
     * array comes from dspace.cfg, so see the comments in that file.
     *
     * If an array element refers to a conventional (non_SRB) asset store, the
     * element will be a LocalFile object (similar to a java.io.File object)
     * referencing a local directory under which the bitstreams are stored.
     *
     * If an array element refers to an SRB asset store, the element will be an
     * SRBFile object referencing an SRB 'collection' (directory) under which
     * the bitstreams are stored.
     *
     * An SRBFile object is obtained by (1) using dspace.cfg properties to
     * create an SRBAccount object (2) using the account to create an
     * SRBFileSystem object (similar to a connection) (3) using the
     * SRBFileSystem object to create an SRBFile object
     *
     * Copy from BitstreamStorageManager
     */
    private static GeneralFile[] assetStores;

    @Override
    public void init(ServletConfig arg0) throws ServletException {

        super.init(arg0);
        threshold = ConfigurationManager.getIntProperty("webui.content_disposition_threshold");
    }

    @Override
    protected void doDSGet(Context context, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException {

        try {

            Item item = null;
            Bitstream bitstream = null;

            String handle = "";
            String sequenceText = "";
            String filename = null;
            int sequenceID;
            InputStream is = null;

            // Get the ID from the URL
            String idString = null;
            if (request.getPathInfo() != null) {
                if (request.getPathInfo() == null) {
                    idString = "";
                } else {
                    idString = request.getPathInfo();
                }
            } else {
                JSPManager.showJSP(request, response, "/error/404.jsp");
                return;
            }

            // Parse 'handle' and 'sequence' (bitstream seq. number) out
            // of remaining URL path, which is typically of the format:
            // {handle}/{sequence}/{bitstream-name}
            // But since the bitstream name MAY have any number of "/"s in
            // it, and the handle is guaranteed to have one slash, we
            // scan from the start to pick out handle and sequence:
            // Remove leading slash if any:
            if (idString.startsWith("/")) {
                idString = idString.substring(1);
            }

            // skip first slash within handle
            int slashIndex = idString.indexOf('/');
            if (slashIndex != -1) {
                slashIndex = idString.indexOf('/', slashIndex + 1);
                if (slashIndex != -1) {
                    handle = idString.substring(0, slashIndex);
                    int slash2 = idString.indexOf('/', slashIndex + 1);
                    if (slash2 != -1) {
                        sequenceText = idString.substring(slashIndex + 1, slash2);
                        filename = idString.substring(slash2 + 1);
                    }
                }
            }

            try {
                sequenceID = Integer.parseInt(sequenceText);
            } catch (NumberFormatException nfe) {
                sequenceID = -1;
            }

            // Now try and retrieve the item
            DSpaceObject dso = HandleManager.resolveToObject(context, handle);

            // Make sure we have valid item and sequence number
            if (dso != null && dso.getType() == Constants.ITEM && sequenceID >= 0) {
                item = (Item) dso;

                if (item.isWithdrawn()) {
                    log.info(LogManager.getHeader(context, "view_bitstream",
                            "handle=" + handle + ",withdrawn=true"));
                    JSPManager.showJSP(request, response, "/tombstone.jsp");
                    return;
                }

                boolean found = false;

                Bundle[] bundles = item.getBundles();

                for (int i = 0; (i < bundles.length) && !found; i++) {
                    Bitstream[] bitstreams = bundles[i].getBitstreams();

                    for (int k = 0; (k < bitstreams.length) && !found; k++) {
                        if (sequenceID == bitstreams[k].getSequenceID()) {
                            bitstream = bitstreams[k];
                            found = true;
                        }
                    }
                }
            }

            if (bitstream == null || filename == null
                    || !filename.equals(bitstream.getName())) {
                // No bitstream found or filename was wrong -- ID invalid
                log.info(LogManager.getHeader(context, "invalid_id", "path="
                        + idString));
                JSPManager.showInvalidIDError(request, response, idString,
                        Constants.BITSTREAM);

                return;
            }

            log.info(LogManager.getHeader(context, "view_bitstream",
                    "bitstream_id=" + bitstream.getID()));

            //new UsageEvent().fire(request, context, AbstractUsageEvent.VIEW,
            //		Constants.BITSTREAM, bitstream.getID());
            new DSpace().getEventService().fireEvent(
                    new UsageEvent(
                            UsageEvent.Action.VIEW,
                            request,
                            context,
                            bitstream));

            // Modification date
            // Only use last-modified if this is an anonymous access
            // - caching content that may be generated under authorisation
            //   is a security problem
            if (context.getCurrentUser() == null) {
                // TODO: Currently the date of the item, since we don't have dates
                // for files
                response.setDateHeader("Last-Modified", item.getLastModified()
                        .getTime());

                // Check for if-modified-since header
                long modSince = request.getDateHeader("If-Modified-Since");

                if (modSince != -1 && item.getLastModified().getTime() < modSince) {
                    // Item has not been modified since requested date,
                    // hence bitstream has not; return 304
                    response.setStatus(HttpServletResponse.SC_NOT_MODIFIED);
                    return;
                }
            }

            // Pipe the bits
            is = bitstream.retrieve();

            // Set the response MIME type
            response.setContentType(bitstream.getFormat().getMIMEType());

            // Response length
            response.setHeader("Content-Length", String.valueOf(bitstream.getSize()));

            // Response range
//			response.setHeader("Accept-Ranges", "bytes");
            if (threshold != -1 && bitstream.getSize() >= threshold) {
                UIUtil.setBitstreamDisposition(bitstream.getName(), request, response);
            }

            //for displayable video requests with the browser range option enabled
            //this servlet will work like a pseudostreaming server
            if (request.getHeader("Range") != null && VideoUtils.isBitstreamDisplayable(bitstream.getName())) {

                String range = request.getHeader("Range");
                Matcher matcher = RANGE_PATTERN.matcher(range);

                int length = (int) bitstream.getSize();
                int start = 0;
                int end = length - 1;

                if (matcher.matches()) {
                    String startGroup = matcher.group("start");
                    start = startGroup.isEmpty() ? start : Integer.valueOf(startGroup);
                    start = start < 0 ? 0 : start;

                    String endGroup = matcher.group("end");
                    end = endGroup.isEmpty() ? end : Integer.valueOf(endGroup);
                    end = end > length - 1 ? length - 1 : end;
                }

                int contentLength = end - start + 1;

                response.reset();
                response.setBufferSize(BUFFER_LENGTH);
                response.setHeader("Content-Disposition", String.format("inline;filename=\"%s\"", bitstream.getName()));
                response.setHeader("Accept-Ranges", "bytes");
                response.setDateHeader("Expires", System.currentTimeMillis() + EXPIRE_TIME);
                response.setHeader("Content-Range", String.format("bytes %s-%s/%s", start, end, length));
                response.setStatus(HttpServletResponse.SC_PARTIAL_CONTENT);

                int bytesRead;
                int bytesLeft = contentLength;
                ByteBuffer buffer = ByteBuffer.allocate(BUFFER_LENGTH);

                String[] bitstreamNameParts = bitstream.getName().split("[.]");

                if (bitstreamNameParts.length == 2) {

                    InputStream stream = bitstream.retrieve();
                    BufferedInputStream bufferedinputStream = new BufferedInputStream(stream);

                    OutputStream output = response.getOutputStream();

                    byte[] byteArray = new byte[BUFFER_LENGTH];

                    while ((bytesRead = bufferedinputStream.read(byteArray, start, BUFFER_LENGTH)) != -1 && bytesLeft > 0) {
                        output.write(byteArray, 0, bytesLeft < bytesRead ? bytesLeft : bytesRead);
                        bytesLeft -= bytesRead;
                    }
                }

            } else {
                Utils.bufferedCopy(is, response.getOutputStream());
                if (is != null) {
                    is.close();
                }
                response.getOutputStream().flush();
            }

        } catch (java.io.IOException e) {
            //nothing to be done here
        }

    }
}
