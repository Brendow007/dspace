/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 * <p>
 * http://www.dspace.org/license/
 */
package org.dspace.rest;

import org.apache.log4j.Logger;
import org.dspace.authorize.AuthorizeException;
import org.dspace.authorize.AuthorizeManager;
import org.dspace.content.BitstreamFormat;
import org.dspace.content.Bundle;
import org.dspace.content.ItemIterator;
import org.dspace.content.Metadatum;
import org.dspace.content.service.ItemService;
import org.dspace.core.ConfigurationManager;
import org.dspace.eperson.Group;
import org.dspace.rest.common.Bitstream;
import org.dspace.rest.common.Item;
import org.dspace.rest.common.MetadataEntry;
import org.dspace.rest.exceptions.ContextException;
import org.dspace.rest.search.Search;
import org.dspace.storage.rdbms.TableRow;
import org.dspace.storage.rdbms.TableRowIterator;
import org.dspace.usage.UsageEvent;
import org.dspace.utils.DSpace;

import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.*;
import javax.ws.rs.core.*;
import javax.ws.rs.core.Response.Status;
import java.io.*;
import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.net.URLDecoder;
import java.sql.SQLException;
import java.util.*;


/**
 * Class which provide all CRUD methods over items.
 *
 * @author Rostislav Novak (Computing and Information Centre, CTU in Prague)
 */
// Every DSpace class used without namespace is from package org.dspace.rest.common.*. Otherwise namespace is defined.
@SuppressWarnings("deprecation")
@Path("/items")
public class ItemsResource extends Resource {
    private static final String OFFSET = "offset";
    private static final String LIMIT = "limit";
    private static final String EXPAND = "expand";
    private static final String HANDLE = "handle";
    private static final String SEARCHC = "searchc";
    private static final String ORDER_ASC = "order_asc";
    private static final String ORDER_DESC = "order_desc";
    private static final String FILTERFIELD = "filter";
    private static final String OPERATIONS = "op";
    private static final String VALUEFIELD = "val";

    private static final String SEARCH_PREFIX = "item.search.";
    private static final String SORT_PREFIX = "item.sort.";

    private static final boolean writeStatistics;
    private static final int maxPagination;
    private static final HashMap<String, String> searchMapping;
    private static final HashMap<String, String> sortMapping;
    private static final ArrayList<String> reservedWords;
    private static final String searchClass;

    static {
        writeStatistics = ConfigurationManager.getBooleanProperty("rest", "stats", false);
        maxPagination = ConfigurationManager.getIntProperty("rest", "max_pagination");
        HashMap<String, String> sm = new HashMap<String, String>();
        HashMap<String, String> sortm = new HashMap<String, String>();
        Enumeration<?> propertyNames = ConfigurationManager.getProperties("rest").propertyNames();
        while (propertyNames.hasMoreElements()) {
            String key = ((String) propertyNames.nextElement()).trim();
            if (key.startsWith(SEARCH_PREFIX)) {
                sm.put(key.substring(SEARCH_PREFIX.length()), ConfigurationManager.getProperty("rest", key));
            }
            if (key.startsWith(SORT_PREFIX)) {
                sortm.put(key.substring(SORT_PREFIX.length()), ConfigurationManager.getProperty("rest", key));
            }
        }
        searchMapping = sm;
        sortMapping = sortm;

        searchClass = ConfigurationManager.getProperty("rest", "implementing.search.class");

        ArrayList<String> reservedWord = new ArrayList<String>();
        reservedWord.add(OFFSET);
        reservedWord.add(LIMIT);
        reservedWord.add(EXPAND);
        reservedWord.add(ORDER_ASC);
        reservedWord.add(ORDER_DESC);
        reservedWords = reservedWord;
    }


    private static final Logger log = Logger.getLogger(ItemsResource.class);

    /**
     * Return item properties without metadata and bitstreams. You can add
     * additional properties by parameter expand.
     *
     * @param itemId  Id of item in DSpace.
     * @param expand  String which define, what additional properties will be in
     *                returned item. Options are separeted by commas and are: "all",
     *                "metadata", "parentCollection", "parentCollectionList",
     *                "parentCommunityList" and "bitstreams".
     * @param headers If you want to access to item under logged user into context.
     *                In headers must be set header "rest-dspace-token" with passed
     *                token from login method.
     * @return If user is allowed to read item, it returns item. Otherwise is
     * thrown WebApplicationException with response status
     * UNAUTHORIZED(401) or NOT_FOUND(404) if was id incorrect.
     * @throws WebApplicationException This exception can be throw by NOT_FOUND(bad id of item),
     *                                 UNAUTHORIZED, SQLException if wasproblem with reading from
     *                                 database and ContextException, if there was problem with
     *                                 creating context of DSpace.
     */
    @GET
    @Path("/{item_id}")
    @Produces({MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public Item getItem(@PathParam("item_id") Integer itemId,
                        @QueryParam("expand") String expand,
                        @QueryParam("userIP") String user_ip,
                        @QueryParam("userAgent") String user_agent,
                        @QueryParam("xforwardedfor") String xforwardedfor,
                        @Context HttpHeaders headers, @Context HttpServletRequest request)
            throws WebApplicationException {

        log.info("Reading item(id=" + itemId + ").");
        org.dspace.core.Context context = null;
        Item item = null;

        try {
            context = createContext(getUser(headers));
            org.dspace.content.Item dspaceItem = findItem(context, itemId, org.dspace.core.Constants.READ);

            writeStats(dspaceItem, UsageEvent.Action.VIEW, user_ip, user_agent, xforwardedfor, headers, request, context);

            item = new Item(dspaceItem, expand, context);
            context.complete();
            log.trace("Item(id=" + itemId + ") was successfully read.");

        } catch (SQLException e) {
            processException("Could not read item(id=" + itemId + "), SQLException. Message: " + e, context);
        } catch (ContextException e) {
            processException("Could not read item(id=" + itemId + "), ContextException. Message: " + e.getMessage(), context);
        } finally {
            processFinally(context);
        }

        return item;
    }

    private static org.dspace.core.Context context;


    @GET
    @Path("/search")
    @Produces({MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public org.dspace.rest.common.ItemReturn search(
            @QueryParam("q") String query,
            @QueryParam(HANDLE) String parent,
            @QueryParam(SEARCHC) String searchc,
            @QueryParam(EXPAND) String expand,
            @QueryParam(LIMIT) Integer limit,
            @QueryParam(OFFSET) Integer offset,
            @QueryParam(ORDER_ASC) String order_asc,
            @QueryParam(ORDER_DESC) String order_desc,
            @QueryParam(FILTERFIELD) List<String> field,
            @QueryParam(OPERATIONS) List<String> op,
            @QueryParam(VALUEFIELD) List<String> val,
            @Context HttpServletRequest request) throws WebApplicationException {


        int ignore = -1;
        if (op.size() > 0) {
            ignore = 1;
        }
        List<String[]> appliedFilters;
        if (ignore > 0) {
            appliedFilters = getFilters(field, op, val);
        } else {
            appliedFilters = new ArrayList<String[]>();
        }

        if (query == null) {
            if (searchc != null) {
                if (searchc.equals("true")){
                    query = "search.resourcetype:2";
                }
            }
        }


        try {


            if (context == null || !context.isValid()) {
                context = new org.dspace.core.Context();
                //Failed SQL is ignored as a failed SQL statement, prevent: current transaction is aborted, commands ignored until end of transaction block
                context.getDBConnection().setAutoCommit(true);
            }
            if (limit == null || limit > maxPagination) {
                limit = maxPagination;
            }
            if (offset == null) {
                offset = 0;
            }

            if (query != null) {
                return luceneSearch(query,parent, expand, limit, offset, request, order_asc, order_desc,appliedFilters);
            } else {
                return parameterSearch(expand, limit, offset, request, order_asc, order_desc);
            }

        } catch (SQLException e) {
            log.error(e.getMessage());
            throw new WebApplicationException(Response.Status.INTERNAL_SERVER_ERROR);
        } catch (IOException e) {
            log.error(e.getMessage());
            throw new WebApplicationException(Response.Status.INTERNAL_SERVER_ERROR);
        }
    }


    private List<String[]> getFilters(List<String> filterField, List<String> filterOp, List<String> value) {

        List<String[]> appliedFilters = new ArrayList<String[]>();
        int ignore = -1;
        if (filterOp.size() > 0) {
            ignore = 1;
        }
        if (ignore > 0)
            for (int idx = 0; idx < filterOp.size(); idx++) {
                appliedFilters.add(new String[]{
                        filterField.get(idx),
                        filterOp.get(idx),
                        value.get(idx)
                });
            }

        return appliedFilters;
    }


    @GET
    @Path("/search/help")
    @Produces({MediaType.TEXT_HTML})
    public String search_help() {
        BufferedReader br = null;
        InputStream input = null;
        String marker1 = "\\{searchfields\\}";
        String marker2 = "\\{sortfields\\}";
        StringBuilder content = new StringBuilder();
        StringBuilder searchfields = new StringBuilder();
        StringBuilder sortfields = new StringBuilder();
        try {
            input = this.getClass().getClassLoader().getResourceAsStream("/html/searchHelp.html");
            br = new BufferedReader(new InputStreamReader(input));
            String line;
            while ((line = br.readLine()) != null) {
                content.append(line);
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
            log.error(e);
        } catch (IOException e) {
            e.printStackTrace();
            log.error(e);
        } finally {
            if (input != null) {
                try {
                    input.close();
                } catch (IOException e) {
                    e.printStackTrace();
                    log.error(e);
                }
            }
            if (br != null) {
                try {
                    br.close();
                } catch (IOException e) {
                    e.printStackTrace();
                    log.error(e);
                }
            }
        }
        Iterator<String> search = searchMapping.keySet().iterator();
        while (search.hasNext()) {
            searchfields.append("<tr><td>" + search.next() + "</td></tr>");
        }
        Iterator<String> sort = sortMapping.keySet().iterator();
        while (sort.hasNext()) {
            sortfields.append("<tr><td>" + sort.next() + "</td></tr>");
        }
        String all = content.toString();
        all = all.replaceAll(marker1, searchfields.toString());
        all = all.replaceAll(marker2, sortfields.toString());

        return all;
    }

    private org.dspace.rest.common.ItemReturn luceneSearch(String query,
                                                           String parent,
                                                           String expand,
                                                           Integer limit,
                                                           Integer offset,
                                                           HttpServletRequest request,
                                                           String order_asc,
                                                           String order_desc,
                                                           List<String[]> filters) throws IOException, SQLException,
            WebApplicationException {
        org.dspace.rest.common.ItemReturn item_return = new org.dspace.rest.common.ItemReturn();
        org.dspace.rest.common.Context item_context = new org.dspace.rest.common.Context();

        item_context.setLimit(limit);
        item_context.setOffset(offset);
        item_return.setContext(item_context);
        if (order_asc != null && order_desc != null) {
            log.error("Both order ascending and order descending set - invalid use");
            item_context.addError("It is not allowed to set both parameters 'order_asc' and 'order_desc'.");
            return item_return;
        }
        String sortfield = null;
        String field = null;
        String sortorder = null;
        if (order_asc != null) {
            sortorder = "asc";
            field = order_asc;
        } else if (order_desc != null) {
            sortorder = "desc";
            field = order_desc;
        }

        if (field != null && sortMapping.containsKey(field)) {
            sortfield = sortMapping.get(field);
        } else if (field != null) {
            log.error("order field " + field + " not supported");
            item_context.addError("not recognised order field: " + field);
            return item_return;
        }

        try {
            Class<?> clazz = Class.forName(searchClass);
            Constructor<?> constructor = clazz.getConstructor();
            Search instance = (Search) constructor.newInstance();
            item_return.setItem(instance.searchAll(context,parent ,query, expand, limit, offset, sortfield, sortorder,filters));
            item_context.setTotal_count(instance.getTotalCount());
        } catch (ClassNotFoundException ex) {
            item_context.addError("'implementing.search.class' does not point to an existing class");
            log.error(ex);
        } catch (NoSuchMethodException ex) {
            item_context.addError("'implementing.search.class' does have an empty contructor");
            log.error(ex);
        } catch (InstantiationException ex) {
            item_context.addError("constructor for 'implementing.search.class' could not be instantiated");
            log.error(ex);
        } catch (IllegalAccessException ex) {
            item_context.addError("'caught IllegalAccessException for instance of 'implementing.search.class'");
            log.error(ex);
        } catch (InvocationTargetException ex) {
            item_context.addError("'caught InvocationTargetException for instance of 'implementing.search.class'");
            log.error(ex);
        }

        return item_return;


    }


    private org.dspace.rest.common.ItemReturn parameterSearch(
            String expand, Integer limit, Integer offset,
            HttpServletRequest request, String order_asc, String order_desc) throws IOException, SQLException,
            WebApplicationException {

        org.dspace.rest.common.ItemReturn item_return = new org.dspace.rest.common.ItemReturn();
        org.dspace.rest.common.Context item_context = new org.dspace.rest.common.Context();

        item_context.setLimit(limit);
        item_context.setOffset(offset);
        item_return.setContext(item_context);
        StringBuffer requestURL = request.getRequestURL();
        String queryString = request.getQueryString();

        if (queryString == null) {
            item_context.setQuery(requestURL.toString());
        } else {
            item_context.setQuery(requestURL.append('?').append(URLDecoder.decode(queryString, "UTF-8")).toString());
        }
        if (searchClass == null) {
            log.error("'implementing.search.class' not set in rest config");
            item_context.addError("'implementing.search.class' not set in rest config");
            return item_return;
        }

        Map<String, String[]> requestMap = request.getParameterMap();


        HashMap<String, String> querymap = new HashMap<String, String>();
        Iterator<String> requestKeys = requestMap.keySet().iterator();
        while (requestKeys.hasNext()) {
            String key = requestKeys.next();
            String[] values = requestMap.get(key);
            log.debug("key, value " + key + " " + values);
            if (searchMapping.containsKey(key) && values != null) {
                for (String value : values) {
                    querymap.put(searchMapping.get(key), URLDecoder.decode(value, "UTF-8"));
                    log.debug("segments " + key + " " + "not decoded " + value + " decoded " + URLDecoder.decode(value, "UTF-8"));
                }
            } else if (!reservedWords.contains(key)) {
                log.error("query parameter " + key + " not supported or value null");
                item_context.addError("not recognised query parameter: " + key);
                return item_return;
            }
        }

        if (order_asc != null && order_desc != null) {
            log.error("Both order ascending and order descending set - invalid use");
            item_context.addError("It is not allowed to set both parameters 'order_asc' and 'order_desc'.");
            return item_return;
        }
        String sortfield = null;
        String field = null;
        String sortorder = null;
        if (order_asc != null) {
            sortorder = "asc";
            field = order_asc;
        } else if (order_desc != null) {
            sortorder = "desc";
            field = order_desc;
        }

        if (field != null && sortMapping.containsKey(field)) {
            sortfield = sortMapping.get(field);
        } else if (field != null) {
            log.error("order field " + field + " not supported");
            item_context.addError("not recognised order field: " + field);
            return item_return;
        }


        try {
            Class<?> clazz = Class.forName(searchClass);
            Constructor<?> constructor = clazz.getConstructor();
            Search instance = (Search) constructor.newInstance();
            item_return.setItem(instance.search(context, querymap, expand, limit, offset, sortfield, sortorder));
            item_context.setTotal_count(instance.getTotalCount());
        } catch (ClassNotFoundException ex) {
            item_context.addError("'implementing.search.class' does not point to an existing class");
            log.error(ex);
        } catch (NoSuchMethodException ex) {
            item_context.addError("'implementing.search.class' does have an empty contructor");
            log.error(ex);
        } catch (InstantiationException ex) {
            item_context.addError("constructor for 'implementing.search.class' could not be instantiated");
            log.error(ex);
        } catch (IllegalAccessException ex) {
            item_context.addError("'caught IllegalAccessException for instance of 'implementing.search.class'");
            log.error(ex);
        } catch (InvocationTargetException ex) {
            item_context.addError("'caught InvocationTargetException for instance of 'implementing.search.class'");
            log.error(ex);
        }

        return item_return;
    }


    private void writeStats(org.dspace.content.DSpaceObject dso, String user_ip, String user_agent,
                            String xforwarderfor, HttpHeaders headers,
                            HttpServletRequest request) {

        if (user_ip == null || user_ip.length() == 0) {
            new DSpace().getEventService().fireEvent(
                    new UsageEvent(
                            UsageEvent.Action.VIEW,
                            request,
                            context,
                            dso));
        } else {
            new DSpace().getEventService().fireEvent(
                    new UsageEvent(
                            UsageEvent.Action.VIEW,
                            user_ip,
                            user_agent,
                            xforwarderfor,
                            context,
                            dso));
        }
        log.debug("fired event");


    }


    /**
     * It returns an array of items in DSpace. You can define how many items in
     * list will be and from which index will start. Items in list are sorted by
     * handle, not by id.
     *
     * @param limit   How many items in array will be. Default value is 100.
     * @param offset  On which index will array start. Default value is 0.
     * @param headers If you want to access to item under logged user into context.
     *                In headers must be set header "rest-dspace-token" with passed
     *                token from login method.
     * @return Return array of items, on which has logged user into context
     * permission.
     * @throws WebApplicationException It can be thrown by SQLException, when was problem with
     *                                 reading items from database or ContextException, when was
     *                                 problem with creating context of DSpace.
     */
    @GET
    @Produces({MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public Item[] getItems(@QueryParam("expand") String expand, @QueryParam("limit") @DefaultValue("100") Integer limit,
                           @QueryParam("offset") @DefaultValue("0") Integer offset, @QueryParam("userIP") String user_ip,
                           @QueryParam("userAgent") String user_agent, @QueryParam("xforwardedfor") String xforwardedfor,
                           @Context HttpHeaders headers, @Context HttpServletRequest request) throws WebApplicationException {

        log.info("Reading items.(offset=" + offset + ",limit=" + limit + ").");
        org.dspace.core.Context context = null;
        List<Item> items = null;

        try {
            context = createContext(getUser(headers));

            ItemIterator dspaceItems = org.dspace.content.Item.findAllUnfiltered(context);
            items = new ArrayList<Item>();

            if (!((limit != null) && (limit >= 0) && (offset != null) && (offset >= 0))) {
                log.warn("Pagging was badly set, using default values.");
                limit = 100;
                offset = 0;
            }

            for (int i = 0; (dspaceItems.hasNext()) && (i < (limit + offset)); i++) {
                org.dspace.content.Item dspaceItem = dspaceItems.next();
                if (i >= offset) {
                    if (ItemService.isItemListedForUser(context, dspaceItem)) {
                        items.add(new Item(dspaceItem, expand, context));
                        writeStats(dspaceItem, UsageEvent.Action.VIEW, user_ip, user_agent, xforwardedfor,
                                headers, request, context);
                    }
                }
            }
            context.complete();
        } catch (SQLException e) {
            processException("Something went wrong while reading items from database. Message: " + e, context);
        } catch (ContextException e) {
            processException("Something went wrong while reading items, ContextException. Message: " + e.getMessage(), context);
        } finally {
            processFinally(context);
        }

        log.trace("Items were successfully read.");
        return items.toArray(new Item[0]);
    }

    /**
     * Returns item metadata in list.
     *
     * @param itemId  Id of item in DSpace.
     * @param headers If you want to access to item under logged user into context.
     *                In headers must be set header "rest-dspace-token" with passed
     *                token from login method.
     * @return Return list of metadata fields if was everything ok. Otherwise it
     * throw WebApplication exception with response code NOT_FOUND(404)
     * or UNAUTHORIZED(401).
     * @throws WebApplicationException It can be thrown by two exceptions: SQLException if was
     *                                 problem wtih reading item from database and ContextException,
     *                                 if was problem with creating context of DSpace. And can be
     *                                 thrown by NOT_FOUND and UNAUTHORIZED too.
     */
    @GET
    @Path("/{item_id}/metadata")
    @Produces({MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public MetadataEntry[] getItemMetadata(@PathParam("item_id") Integer itemId, @QueryParam("userIP") String user_ip,
                                           @QueryParam("userAgent") String user_agent, @QueryParam("xforwardedfor") String xforwardedfor,
                                           @Context HttpHeaders headers, @Context HttpServletRequest request) throws WebApplicationException {

        log.info("Reading item(id=" + itemId + ") metadata.");
        org.dspace.core.Context context = null;
        List<MetadataEntry> metadata = null;

        try {
            context = createContext(getUser(headers));
            org.dspace.content.Item dspaceItem = findItem(context, itemId, org.dspace.core.Constants.READ);

            writeStats(dspaceItem, UsageEvent.Action.VIEW, user_ip, user_agent, xforwardedfor, headers, request, context);

            metadata = new org.dspace.rest.common.Item(dspaceItem, "metadata", context).getMetadata();
            context.complete();
        } catch (SQLException e) {
            processException("Could not read item(id=" + itemId + "), SQLException. Message: " + e, context);
        } catch (ContextException e) {
            processException("Could not read item(id=" + itemId + "), ContextException. Message: " + e.getMessage(), context);
        } finally {
            processFinally(context);
        }

        log.trace("Item(id=" + itemId + ") metadata were successfully read.");
        return metadata.toArray(new MetadataEntry[0]);
    }

    /**
     * Return array of bitstreams in item. It can be pagged.
     *
     * @param itemId  Id of item in DSpace.
     * @param limit   How many items will be in array.
     * @param offset  On which index will start array.
     * @param headers If you want to access to item under logged user into context.
     *                In headers must be set header "rest-dspace-token" with passed
     *                token from login method.
     * @return Return pagged array of bitstreams in item.
     * @throws WebApplicationException It can be throw by NOT_FOUND, UNAUTHORIZED, SQLException if
     *                                 was problem with reading from database and ContextException
     *                                 if was problem with creating context of DSpace.
     */
    @GET
    @Path("/{item_id}/bitstreams")
    @Produces({MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public Bitstream[] getItemBitstreams(@PathParam("item_id") Integer itemId,
                                         @QueryParam("limit") @DefaultValue("20") Integer limit, @QueryParam("offset") @DefaultValue("0") Integer offset,
                                         @QueryParam("userIP") String user_ip, @QueryParam("userAgent") String user_agent,
                                         @QueryParam("xforwardedfor") String xforwardedfor, @Context HttpHeaders headers, @Context HttpServletRequest request)
            throws WebApplicationException {

        log.info("Reading item(id=" + itemId + ") bitstreams.(offset=" + offset + ",limit=" + limit + ")");
        org.dspace.core.Context context = null;
        List<Bitstream> bitstreams = null;
        try {
            context = createContext(getUser(headers));
            org.dspace.content.Item dspaceItem = findItem(context, itemId, org.dspace.core.Constants.READ);

            writeStats(dspaceItem, UsageEvent.Action.VIEW, user_ip, user_agent, xforwardedfor, headers, request, context);

            List<Bitstream> itemBitstreams = new Item(dspaceItem, "bitstreams", context).getBitstreams();

            if ((offset + limit) > (itemBitstreams.size() - offset)) {
                bitstreams = itemBitstreams.subList(offset, itemBitstreams.size());
            } else {
                bitstreams = itemBitstreams.subList(offset, offset + limit);
            }
            context.complete();
        } catch (SQLException e) {
            processException("Could not read item(id=" + itemId + ") bitstreams, SQLExcpetion. Message: " + e, context);
        } catch (ContextException e) {
            processException("Could not read item(id=" + itemId + ") bitstreams, ContextException. Message: " + e.getMessage(),
                    context);
        } finally {
            processFinally(context);
        }

        log.trace("Item(id=" + itemId + ") bitstreams were successfully read.");
        return bitstreams.toArray(new Bitstream[0]);
    }

    /**
     * Adding metadata fields to item. If metadata key is in item, it will be
     * added, NOT REPLACED!
     *
     * @param itemId   Id of item in DSpace.
     * @param metadata List of metadata fields, which will be added into item.
     * @param headers  If you want to access to item under logged user into context.
     *                 In headers must be set header "rest-dspace-token" with passed
     *                 token from login method.
     * @return It returns status code OK(200) if all was ok. UNAUTHORIZED(401)
     * if user is not allowed to write to item. NOT_FOUND(404) if id of
     * item is incorrect.
     * @throws WebApplicationException It is throw by these exceptions: SQLException, if was problem
     *                                 with reading from database or writing to database.
     *                                 AuthorizeException, if was problem with authorization to item
     *                                 fields. ContextException, if was problem with creating
     *                                 context of DSpace.
     */
    @POST
    @Path("/{item_id}/metadata")
    @Consumes({MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public Response addItemMetadata(@PathParam("item_id") Integer itemId, List<org.dspace.rest.common.MetadataEntry> metadata,
                                    @QueryParam("userIP") String user_ip, @QueryParam("userAgent") String user_agent,
                                    @QueryParam("xforwardedfor") String xforwardedfor, @Context HttpHeaders headers, @Context HttpServletRequest request)
            throws WebApplicationException {

        log.info("Adding metadata to item(id=" + itemId + ").");
        org.dspace.core.Context context = null;

        try {
            context = createContext(getUser(headers));
            org.dspace.content.Item dspaceItem = findItem(context, itemId, org.dspace.core.Constants.WRITE);

            writeStats(dspaceItem, UsageEvent.Action.UPDATE, user_ip, user_agent, xforwardedfor, headers, request, context);

            for (MetadataEntry entry : metadata) {
                // TODO Test with Java split
                String data[] = mySplit(entry.getKey()); // Done by my split, because of java split was not function.
                if ((data.length >= 2) && (data.length <= 3)) {
                    dspaceItem.addMetadata(data[0], data[1], data[2], entry.getLanguage(), entry.getValue());
                }
            }
            dspaceItem.update();
            context.complete();

        } catch (SQLException e) {
            processException("Could not write metadata to item(id=" + itemId + "), SQLException. Message: " + e, context);
        } catch (AuthorizeException e) {
            processException("Could not write metadata to item(id=" + itemId + "), AuthorizeException. Message: " + e, context);
        } catch (ContextException e) {
            processException("Could not write metadata to item(id=" + itemId + "), ContextException. Message: " + e.getMessage(),
                    context);
        } finally {
            processFinally(context);
        }

        log.info("Metadata to item(id=" + itemId + ") were successfully added.");
        return Response.status(Status.OK).build();
    }

    /**
     * Create bitstream in item.
     *
     * @param itemId      Id of item in DSpace.
     * @param inputStream Data of bitstream in inputStream.
     * @param headers     If you want to access to item under logged user into context.
     *                    In headers must be set header "rest-dspace-token" with passed
     *                    token from login method.
     * @return Returns bitstream with status code OK(200). If id of item is
     * invalid , it returns status code NOT_FOUND(404). If user is not
     * allowed to write to item, UNAUTHORIZED(401).
     * @throws WebApplicationException It is thrown by these exceptions: SQLException, when was
     *                                 problem with reading/writing from/to database.
     *                                 AuthorizeException, when was problem with authorization to
     *                                 item and add bitstream to item. IOException, when was problem
     *                                 with creating file or reading from inpustream.
     *                                 ContextException. When was problem with creating context of
     *                                 DSpace.
     */
    // TODO Add option to add bitstream by URI.(for very big files)
    @POST
    @Path("/{item_id}/bitstreams")
    public Bitstream addItemBitstream(@PathParam("item_id") Integer itemId, InputStream inputStream,
                                      @QueryParam("name") String name, @QueryParam("description") String description,
                                      @QueryParam("groupId") Integer groupId, @QueryParam("year") Integer year, @QueryParam("month") Integer month,
                                      @QueryParam("day") Integer day, @QueryParam("userIP") String user_ip, @QueryParam("userAgent") String user_agent,
                                      @QueryParam("xforwardedfor") String xforwardedfor, @Context HttpHeaders headers, @Context HttpServletRequest request)
            throws WebApplicationException {

        log.info("Adding bitstream to item(id=" + itemId + ").");
        org.dspace.core.Context context = null;
        Bitstream bitstream = null;

        try {
            context = createContext(getUser(headers));
            org.dspace.content.Item dspaceItem = findItem(context, itemId, org.dspace.core.Constants.WRITE);

            writeStats(dspaceItem, UsageEvent.Action.UPDATE, user_ip, user_agent, xforwardedfor, headers, request, context);

            // Is better to add bitstream to ORIGINAL bundle or to item own?
            log.trace("Creating bitstream in item.");
            org.dspace.content.Bundle bundle = null;
            org.dspace.content.Bitstream dspaceBitstream = null;
            Bundle[] bundles = dspaceItem.getBundles("ORIGINAL");
            if (bundles != null && bundles.length != 0) {
                bundle = bundles[0]; // There should be only one bundle ORIGINAL.
            }
            if (bundle == null) {
                log.trace("Creating bundle in item.");
                dspaceBitstream = dspaceItem.createSingleBitstream(inputStream);
            } else {
                log.trace("Getting bundle from item.");
                dspaceBitstream = bundle.createBitstream(inputStream);
            }

            dspaceBitstream.setSource("DSpace Rest api");

            // Set bitstream name and description
            if (name != null) {
                if (BitstreamResource.getMimeType(name) == null) {
                    dspaceBitstream.setFormat(BitstreamFormat.findUnknown(context));
                } else {
                    dspaceBitstream.setFormat(BitstreamFormat.findByMIMEType(context, BitstreamResource.getMimeType(name)));
                }
                dspaceBitstream.setName(name);
            }
            if (description != null) {
                dspaceBitstream.setDescription(description);
            }

            dspaceBitstream.update();

            // Create policy for bitstream
            if (groupId != null) {
                bundles = dspaceBitstream.getBundles();
                for (Bundle dspaceBundle : bundles) {
                    List<org.dspace.authorize.ResourcePolicy> bitstreamsPolicies = dspaceBundle.getBitstreamPolicies();

                    // Remove default bitstream policies
                    List<org.dspace.authorize.ResourcePolicy> policiesToRemove = new ArrayList<org.dspace.authorize.ResourcePolicy>();
                    for (org.dspace.authorize.ResourcePolicy policy : bitstreamsPolicies) {
                        if (policy.getResourceID() == dspaceBitstream.getID()) {
                            policiesToRemove.add(policy);
                        }
                    }
                    for (org.dspace.authorize.ResourcePolicy policy : policiesToRemove) {
                        bitstreamsPolicies.remove(policy);
                    }

                    org.dspace.authorize.ResourcePolicy dspacePolicy = org.dspace.authorize.ResourcePolicy.create(context);
                    dspacePolicy.setAction(org.dspace.core.Constants.READ);
                    dspacePolicy.setGroup(Group.find(context, groupId));
                    dspacePolicy.setResourceID(dspaceBitstream.getID());
                    dspacePolicy.setResource(dspaceBitstream);
                    dspacePolicy.setResourceType(org.dspace.core.Constants.BITSTREAM);
                    if ((year != null) || (month != null) || (day != null)) {
                        Date date = new Date();
                        if (year != null) {
                            date.setYear(year - 1900);
                        }
                        if (month != null) {
                            date.setMonth(month - 1);
                        }
                        if (day != null) {
                            date.setDate(day);
                        }
                        date.setHours(0);
                        date.setMinutes(0);
                        date.setSeconds(0);
                        dspacePolicy.setStartDate(date);
                    }

                    dspacePolicy.update();
                    dspaceBitstream.updateLastModified();
                }
            }

            dspaceBitstream = org.dspace.content.Bitstream.find(context, dspaceBitstream.getID());
            bitstream = new Bitstream(dspaceBitstream, "");

            context.complete();

        } catch (SQLException e) {
            processException("Could not create bitstream in item(id=" + itemId + "), SQLException. Message: " + e, context);
        } catch (AuthorizeException e) {
            processException("Could not create bitstream in item(id=" + itemId + "), AuthorizeException. Message: " + e, context);
        } catch (IOException e) {
            processException("Could not create bitstream in item(id=" + itemId + "), IOException Message: " + e, context);
        } catch (ContextException e) {
            processException(
                    "Could not create bitstream in item(id=" + itemId + "), ContextException Message: " + e.getMessage(), context);
        } finally {
            processFinally(context);
        }

        log.info("Bitstream(id=" + bitstream.getId() + ") was successfully added into item(id=" + itemId + ").");
        return bitstream;
    }

    /**
     * Replace all metadata in item with new passed metadata.
     *
     * @param itemId   Id of item in DSpace.
     * @param metadata List of metadata fields, which will replace old metadata in
     *                 item.
     * @param headers  If you want to access to item under logged user into context.
     *                 In headers must be set header "rest-dspace-token" with passed
     *                 token from login method.
     * @return It returns status code: OK(200). NOT_FOUND(404) if item was not
     * found, UNAUTHORIZED(401) if user is not allowed to write to item.
     * @throws WebApplicationException It is thrown by: SQLException, when was problem with database
     *                                 reading or writting, AuthorizeException when was problem with
     *                                 authorization to item and metadata fields. And
     *                                 ContextException, when was problem with creating context of
     *                                 DSpace.
     */
    @PUT
    @Path("/{item_id}/metadata")
    @Consumes({MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public Response updateItemMetadata(@PathParam("item_id") Integer itemId, MetadataEntry[] metadata,
                                       @QueryParam("userIP") String user_ip, @QueryParam("userAgent") String user_agent,
                                       @QueryParam("xforwardedfor") String xforwardedfor, @Context HttpHeaders headers, @Context HttpServletRequest request)
            throws WebApplicationException {

        log.info("Updating metadata in item(id=" + itemId + ").");
        org.dspace.core.Context context = null;

        try {
            context = createContext(getUser(headers));
            org.dspace.content.Item dspaceItem = findItem(context, itemId, org.dspace.core.Constants.WRITE);

            writeStats(dspaceItem, UsageEvent.Action.UPDATE, user_ip, user_agent, xforwardedfor, headers, request, context);

            log.trace("Deleting original metadata from item.");
            for (MetadataEntry entry : metadata) {
                String data[] = mySplit(entry.getKey());
                if ((data.length >= 2) && (data.length <= 3)) {
                    dspaceItem.clearMetadata(data[0], data[1], data[2], org.dspace.content.Item.ANY);
                }
            }

            log.trace("Adding new metadata to item.");
            for (MetadataEntry entry : metadata) {
                String data[] = mySplit(entry.getKey());
                if ((data.length >= 2) && (data.length <= 3)) {
                    dspaceItem.addMetadata(data[0], data[1], data[2], entry.getLanguage(), entry.getValue());
                }
            }

            dspaceItem.update();
            context.complete();

        } catch (SQLException e) {
            processException("Could not update metadata in item(id=" + itemId + "), SQLException. Message: " + e, context);
        } catch (AuthorizeException e) {
            processException("Could not update metadata in item(id=" + itemId + "), AuthorizeException. Message: " + e, context);
        } catch (ContextException e) {
            processException(
                    "Could not update metadata in item(id=" + itemId + "), ContextException. Message: " + e.getMessage(), context);
        } finally {
            processFinally(context);
        }

        log.info("Metadata of item(id=" + itemId + ") were successfully updated.");
        return Response.status(Status.OK).build();
    }

    /**
     * Delete item from DSpace. It delete bitstreams only from item bundle.
     *
     * @param itemId  Id of item which will be deleted.
     * @param headers If you want to access to item under logged user into context.
     *                In headers must be set header "rest-dspace-token" with passed
     *                token from login method.
     * @return It returns status code: OK(200). NOT_FOUND(404) if item was not
     * found, UNAUTHORIZED(401) if user is not allowed to delete item
     * metadata.
     * @throws WebApplicationException It can be thrown by: SQLException, when was problem with
     *                                 database reading. AuthorizeException, when was problem with
     *                                 authorization to item.(read and delete) IOException, when was
     *                                 problem with deleting bitstream file. ContextException, when
     *                                 was problem with creating context of DSpace.
     */
    @DELETE
    @Path("/{item_id}")
    public Response deleteItem(@PathParam("item_id") Integer itemId, @QueryParam("userIP") String user_ip,
                               @QueryParam("userAgent") String user_agent, @QueryParam("xforwardedfor") String xforwardedfor,
                               @Context HttpHeaders headers, @Context HttpServletRequest request) throws WebApplicationException {

        log.info("Deleting item(id=" + itemId + ").");
        org.dspace.core.Context context = null;

        try {
            context = createContext(getUser(headers));
            org.dspace.content.Item dspaceItem = findItem(context, itemId, org.dspace.core.Constants.DELETE);

            writeStats(dspaceItem, UsageEvent.Action.REMOVE, user_ip, user_agent, xforwardedfor, headers, request, context);

            log.trace("Deleting item.");
            org.dspace.content.Collection collection = org.dspace.content.Collection.find(context,
                    dspaceItem.getCollections()[0].getID());
            collection.removeItem(dspaceItem);
            context.complete();

        } catch (SQLException e) {
            processException("Could not delete item(id=" + itemId + "), SQLException. Message: " + e, context);
        } catch (AuthorizeException e) {
            processException("Could not delete item(id=" + itemId + "), AuthorizeException. Message: " + e, context);
            throw new WebApplicationException(Response.Status.INTERNAL_SERVER_ERROR);
        } catch (IOException e) {
            processException("Could not delete item(id=" + itemId + "), IOException. Message: " + e, context);
        } catch (ContextException e) {
            processException("Could not delete item(id=" + itemId + "), ContextException. Message: " + e.getMessage(), context);
        } finally {
            processFinally(context);
        }

        log.info("Item(id=" + itemId + ") was successfully deleted.");
        return Response.status(Status.OK).build();
    }

    /**
     * Delete all item metadata.
     *
     * @param itemId  Id of item in DSpace.
     * @param headers If you want to access to item under logged user into context.
     *                In headers must be set header "rest-dspace-token" with passed
     *                token from login method.
     * @return It returns status code: OK(200). NOT_FOUND(404) if item was not
     * found, UNAUTHORIZED(401) if user is not allowed to delete item
     * metadata.
     * @throws WebApplicationException It is thrown by three exceptions. SQLException, when was
     *                                 problem with reading item from database or editting metadata
     *                                 fields. AuthorizeException, when was problem with
     *                                 authorization to item. And ContextException, when was problem
     *                                 with creating context of DSpace.
     */
    @DELETE
    @Path("/{item_id}/metadata")
    public Response deleteItemMetadata(@PathParam("item_id") Integer itemId, @QueryParam("userIP") String user_ip,
                                       @QueryParam("userAgent") String user_agent, @QueryParam("xforwardedfor") String xforwardedfor,
                                       @Context HttpHeaders headers, @Context HttpServletRequest request) throws WebApplicationException {

        log.info("Deleting metadata in item(id=" + itemId + ").");
        org.dspace.core.Context context = null;

        try {
            context = createContext(getUser(headers));
            org.dspace.content.Item dspaceItem = findItem(context, itemId, org.dspace.core.Constants.WRITE);

            writeStats(dspaceItem, UsageEvent.Action.UPDATE, user_ip, user_agent, xforwardedfor, headers, request, context);

            log.trace("Deleting metadata.");
            // TODO Rewrite without deprecated object. Leave there only generated metadata.
            Metadatum[] value = dspaceItem.getMetadata("dc", "date", "accessioned", org.dspace.content.Item.ANY);
            Metadatum[] value2 = dspaceItem.getMetadata("dc", "date", "available", org.dspace.content.Item.ANY);
            Metadatum[] value3 = dspaceItem.getMetadata("dc", "identifier", "uri", org.dspace.content.Item.ANY);
            Metadatum[] value4 = dspaceItem.getMetadata("dc", "description", "provenance", org.dspace.content.Item.ANY);

            dspaceItem.clearMetadata(org.dspace.content.Item.ANY, org.dspace.content.Item.ANY, org.dspace.content.Item.ANY,
                    org.dspace.content.Item.ANY);
            dspaceItem.update();

            // Add there generated metadata
            dspaceItem.addMetadata(value[0].schema, value[0].element, value[0].qualifier, null, value[0].value);
            dspaceItem.addMetadata(value2[0].schema, value2[0].element, value2[0].qualifier, null, value2[0].value);
            dspaceItem.addMetadata(value3[0].schema, value3[0].element, value3[0].qualifier, null, value3[0].value);
            dspaceItem.addMetadata(value4[0].schema, value4[0].element, value4[0].qualifier, null, value4[0].value);

            dspaceItem.update();
            context.complete();

        } catch (SQLException e) {
            processException("Could not delete item(id=" + itemId + "), SQLException. Message: " + e, context);
        } catch (AuthorizeException e) {
            processException("Could not delete item(id=" + itemId + "), AuthorizeExcpetion. Message: " + e, context);
        } catch (ContextException e) {
            processException("Could not delete item(id=" + itemId + "), ContextException. Message:" + e.getMessage(), context);
        } finally {
            processFinally(context);
        }

        log.info("Item(id=" + itemId + ") metadata were successfully deleted.");
        return Response.status(Status.OK).build();
    }

    /**
     * Delete bitstream from item bundle.
     *
     * @param itemId      Id of item in DSpace.
     * @param headers     If you want to access to item under logged user into context.
     *                    In headers must be set header "rest-dspace-token" with passed
     *                    token from login method.
     * @param bitstreamId Id of bitstream, which will be deleted from bundle.
     * @return Return status code OK(200) if is all ok. NOT_FOUND(404) if item
     * or bitstream was not found. UNAUTHORIZED(401) if user is not
     * allowed to delete bitstream.
     * @throws WebApplicationException It is thrown, when: Was problem with edditting database,
     *                                 SQLException. Or problem with authorization to item, bundle
     *                                 or bitstream, AuthorizeException. When was problem with
     *                                 deleting file IOException. Or problem with creating context
     *                                 of DSpace, ContextException.
     */
    @DELETE
    @Path("/{item_id}/bitstreams/{bitstream_id}")
    public Response deleteItemBitstream(@PathParam("item_id") Integer itemId, @PathParam("bitstream_id") Integer bitstreamId,
                                        @QueryParam("userIP") String user_ip, @QueryParam("userAgent") String user_agent,
                                        @QueryParam("xforwardedfor") String xforwardedfor, @Context HttpHeaders headers, @Context HttpServletRequest request)
            throws WebApplicationException {

        log.info("Deleting bitstream in item(id=" + itemId + ").");
        org.dspace.core.Context context = null;

        try {
            context = createContext(getUser(headers));
            org.dspace.content.Item item = findItem(context, itemId, org.dspace.core.Constants.WRITE);

            org.dspace.content.Bitstream bitstream = org.dspace.content.Bitstream.find(context, bitstreamId);
            if (bitstream == null) {
                context.abort();
                log.warn("Bitstream(id=" + bitstreamId + ") was not found.");
                return Response.status(Status.NOT_FOUND).build();
            } else if (!AuthorizeManager.authorizeActionBoolean(context, bitstream, org.dspace.core.Constants.DELETE)) {
                context.abort();
                log.error("User(" + getUser(headers).getEmail() + ") is not allowed to delete bitstream(id=" + bitstreamId + ").");
                return Response.status(Status.UNAUTHORIZED).build();
            }

            writeStats(item, UsageEvent.Action.UPDATE, user_ip, user_agent, xforwardedfor, headers, request, context);
            writeStats(bitstream, UsageEvent.Action.REMOVE, user_ip, user_agent, xforwardedfor, headers,
                    request, context);

            log.trace("Deleting bitstream...");
            for (org.dspace.content.Bundle bundle : item.getBundles()) {
                for (org.dspace.content.Bitstream bit : bundle.getBitstreams()) {
                    if (bit == bitstream) {
                        bundle.removeBitstream(bitstream);
                    }
                }
            }

            context.complete();

        } catch (SQLException e) {
            processException("Could not delete bitstream(id=" + bitstreamId + "), SQLException. Message: " + e, context);
        } catch (AuthorizeException e) {
            processException("Could not delete bitstream(id=" + bitstreamId + "), AuthorizeException. Message: " + e, context);
        } catch (IOException e) {
            processException("Could not delete bitstream(id=" + bitstreamId + "), IOException. Message: " + e, context);
        } catch (ContextException e) {
            processException("Could not delete bitstream(id=" + bitstreamId + "), ContextException. Message:" + e.getMessage(),
                    context);
        } finally {
            processFinally(context);
        }

        log.info("Bitstream(id=" + bitstreamId + ") from item(id=" + itemId + ") was successfuly deleted .");
        return Response.status(Status.OK).build();
    }

    /**
     * Find items by one metadada field.
     *
     * @param metadataEntry Metadata field to search by.
     *                      //     * @param schemee
     *                      Scheme of metadata(key).
     *                      //     * @param valuee
     *                      Value of metadata field.
     * @param headers       If you want to access the item as the user logged into context,
     *                      header "rest-dspace-token" must be set to token value retrieved
     *                      from the login method.
     * @return Return array of found items.
     * @throws WebApplicationException Can be thrown: SQLException - problem with
     *                                 database reading. AuthorizeException - problem with
     *                                 authorization to item. IOException - problem with
     *                                 reading from metadata field. ContextException -
     *                                 problem with creating DSpace context.
     */
    @POST
    @Path("/find-by-metadata-field")
    @Produces({MediaType.APPLICATION_JSON, MediaType.APPLICATION_XML})
    public Item[] findItemsByMetadataField(MetadataEntry metadataEntry, @QueryParam("expand") String expand,
                                           @QueryParam("userIP") String user_ip, @QueryParam("userAgent") String user_agent,
                                           @QueryParam("likeEnabled") String like,
                                           @QueryParam("xforwardedfor") String xforwardedfor, @Context HttpHeaders headers, @Context HttpServletRequest request)
            throws WebApplicationException {

        log.info("Looking for item with metadata(key=" + metadataEntry.getKey() + ",value=" + metadataEntry.getValue()
                + ", language=" + metadataEntry.getLanguage() + ").");
        org.dspace.core.Context context = null;

        List<Item> items = new ArrayList<Item>();
        String[] metadata = mySplit(metadataEntry.getKey());

        try {
            context = createContext(getUser(headers));

            // TODO Repair, it ends by error:
            // "java.sql.SQLSyntaxErrorException: ORA-00932: inconsistent datatypes: expected - got CLOB"
            /*
             * if (metadata.length == 3){
             *     itemIterator =  org.dspace.content.Item.findByMetadataField(context, metadata[0],
             *     metadata[1], metadata[2], value);
             * } else if (metadata.length == 2){
             *     itemIterator = org.dspace.content.Item.findByMetadataField(context, metadata[0],
             *     metadata[1], null, value);
             * } else {
             *     context.abort();
             *     log.error("Finding failed, bad metadata key.");
             *     throw new WebApplicationException(Response.Status.NOT_FOUND);
             * }
             *
             * if (itemIterator.hasNext()) {
             * item = new Item(itemIterator.next(), "", context);
             * }
             */

            // Must used own style.
            if ((metadata.length < 2) || (metadata.length > 3)) {
                context.abort();
                log.error("Finding failed, bad metadata key.");
                throw new WebApplicationException(Response.Status.NOT_FOUND);
            }

            List<Object> parameterList = new LinkedList<>();
            String sql = "SELECT RESOURCE_ID, TEXT_VALUE, TEXT_LANG, SHORT_ID, ELEMENT, QUALIFIER " +
                    "FROM METADATAVALUE " +
                    "JOIN METADATAFIELDREGISTRY ON METADATAVALUE.METADATA_FIELD_ID = METADATAFIELDREGISTRY.METADATA_FIELD_ID " +
                    "JOIN METADATASCHEMAREGISTRY ON METADATAFIELDREGISTRY.METADATA_SCHEMA_ID = METADATASCHEMAREGISTRY.METADATA_SCHEMA_ID " +
                    "WHERE " +
                    "SHORT_ID= ?  AND " +
                    "ELEMENT= ? AND ";
            parameterList.add(metadata[0]);
            parameterList.add(metadata[1]);
            if (metadata.length > 3) {
                sql += "QUALIFIER= ? AND ";
                parameterList.add(metadata[2]);
            }
            if (like.equals("true")) {
                sql += "TEXT_VALUE LIKE ? AND";
                parameterList.add(metadataEntry.getValue());
            } else if (org.dspace.storage.rdbms.DatabaseManager.isOracle()) {

                sql += "dbms_lob.compare(TEXT_VALUE, ?) = 0 AND ";
                parameterList.add(metadataEntry.getValue());

            } else {
                sql += "TEXT_VALUE=? AND ";
                parameterList.add(metadataEntry.getValue());
            }
            if (metadataEntry.getLanguage() != null) {
                sql += "TEXT_LANG=?";
                parameterList.add(metadataEntry.getLanguage());
            } else {
                sql += "TEXT_LANG is null";
            }

            Object[] parameters = parameterList.toArray();
            TableRowIterator iterator = org.dspace.storage.rdbms.DatabaseManager.query(context, sql, parameters);
            while (iterator.hasNext()) {
                TableRow row = iterator.next();
                org.dspace.content.Item dspaceItem = this.findItem(context, row.getIntColumn("RESOURCE_ID"),
                        org.dspace.core.Constants.READ);
                //TEst
                Item item = new Item(dspaceItem, expand, context);
                writeStats(dspaceItem, UsageEvent.Action.VIEW, user_ip, user_agent, xforwardedfor, headers,
                        request, context);
                items.add(item);
            }

            context.complete();

        } catch (SQLException e) {
            processException("Something went wrong while finding item. SQLException, Message: " + e, context);
        } catch (ContextException e) {
            processException("Context error:" + e.getMessage(), context);
        } finally {
            processFinally(context);
        }

        if (items.size() == 0) {
            log.info("Items not found.");
        } else {
            log.info("Items were found.");
        }

        return items.toArray(new Item[0]);
    }

    /**
     * Find item from DSpace database. It is encapsulation of method
     * org.dspace.content.Item.find with checking if item exist and if user
     * logged into context has permission to do passed action.
     *
     * @param context Context of actual logged user.
     * @param id      Id of item in DSpace.
     * @param action  Constant from org.dspace.core.Constants.
     * @return It returns DSpace item.
     * @throws WebApplicationException Is thrown when item with passed id is not exists and if user
     *                                 has no permission to do passed action.
     */
    private org.dspace.content.Item findItem(org.dspace.core.Context context, int id, int action) throws WebApplicationException {
        org.dspace.content.Item item = null;
        try {
            item = org.dspace.content.Item.find(context, id);

            if (item == null) {
                context.abort();
                log.warn("Item(id=" + id + ") was not found!");
                throw new WebApplicationException(Response.Status.NOT_FOUND);
            } else if (!AuthorizeManager.authorizeActionBoolean(context, item, action)) {
                context.abort();
                if (context.getCurrentUser() != null) {
                    log.error("User(" + context.getCurrentUser().getEmail() + ") has not permission to "
                            + getActionString(action) + " item!");
                } else {
                    log.error("User(anonymous) has not permission to " + getActionString(action) + " item!");
                }
                throw new WebApplicationException(Response.Status.UNAUTHORIZED);
            }

        } catch (SQLException e) {
            processException("Something get wrong while finding item(id=" + id + "). SQLException, Message: " + e, context);
        }
        return item;
    }
}
