/*
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
/*
 * Utility Javascript methods for DSpace
 */

// Popup window - here so it can be referred to by several methods
var popupWindow;

// =========================================================
//  Methods for e-person popup window
// =========================================================

// Add to list of e-people on this page -- invoked by eperson popup window
function addEPerson(id, email, name)
{
    var newplace = window.document.epersongroup.eperson_id.options.length;

    if (newplace > 0 && window.document.epersongroup.eperson_id.options[0].value == "")
    {
        newplace = 0;
    }

    // First we check to see if e-person is already there
    for (var i = 0; i < window.document.epersongroup.eperson_id.options.length; i++)
    {
        if (window.document.epersongroup.eperson_id.options[i].value == id)
        {
            newplace = -1;
        }
    }

    if (newplace > -1)
    {
        window.document.epersongroup.eperson_id.options[newplace] = new Option(name + " (" + email + ")", id);
    }
}

// Add to list of groups on this page -- invoked by eperson popup window
function addGroup(id, name)
{
    var newplace = window.document.epersongroup.group_ids.options.length;

    if (newplace > 0 && window.document.epersongroup.group_ids.options[0].value == "")
    {
        newplace = 0;
    }

    // First we check to see if group is already there
    for (var i = 0; i < window.document.epersongroup.group_ids.options.length; i++)
    {
        // is it in the list already
        if (window.document.epersongroup.group_ids.options[i].value == id)
        {
            newplace = -1;
        }

        // are we trying to add the new group to the new group on an Edit Group page (recursive)
        if (window.document.epersongroup.group_id)
        {
            if (window.document.epersongroup.group_id.value == id)
            {
                newplace = -1;
            }
        }
    }

    if (newplace > -1)
    {
        window.document.epersongroup.group_ids.options[newplace] = new Option(name + " (" + id + ")", id);
    }
}

// This needs to be invoked in the 'onClick' javascript event for buttons
// on pages with a dspace:selecteperson element in them
function finishEPerson()
{
    selectAll(window.document.epersongroup.eperson_id);

    if (popupWindow != null)
    {
        popupWindow.close();
    }
}

// This needs to be invoked in the 'onClick' javascript event for buttons
// on pages with a dspace:selecteperson element in them
function finishGroups()
{
    selectAll(window.document.epersongroup.group_ids);

    if (popupWindow != null)
    {
        popupWindow.close();
    }
}

// =========================================================
//  Miscellaneous utility methods
// =========================================================

// Open a popup window (or bring to front if already open)
function popup_window(winURL, winName)
{
    var props = 'scrollBars=yes,resizable=yes,toolbar=no,menubar=no,location=no,directories=no,width=640,height=480';
    popupWindow = window.open(winURL, winName, props);
    popupWindow.focus();
}


// Select all options in a <SELECT> list
function selectAll(sourceList)
{
    for (var i = 0; i < sourceList.options.length; i++)
    {
        if ((sourceList.options[i] != null) && (sourceList.options[i].value != ""))
            sourceList.options[i].selected = true;
    }
    return true;
}

// Deletes the selected options from supplied <SELECT> list
function removeSelected(sourceList)
{
    var maxCnt = sourceList.options.length;
    for (var i = maxCnt - 1; i >= 0; i--)
    {
        if ((sourceList.options[i] != null) && (sourceList.options[i].selected == true))
        {
            sourceList.options[i] = null;
        }
    }
}


// Disables accidentally submitting a form when the "Enter" key is pressed.
// Just add "onkeydown='return disableEnterKey(event);'" to form.
function disableEnterKey(e)
{
    var key;

    if (window.event)
        key = window.event.keyCode;     //Internet Explorer
    else
        key = e.which;     //Firefox & Netscape

    if (key == 13)  //if "Enter" pressed, then disable!
        return false;
    else
        return true;
}


//******************************************************
// Functions used by controlled vocabulary add-on
// There might be overlaping with existing functions
//******************************************************

function expandCollapse(node, contextPath) {
    node = node.parentNode;
    var childNode = (node.getElementsByTagName("ul"))[0];

    if (!childNode)
        return false;

    var image = node.getElementsByTagName("img")[0];

    if (childNode.style.display != "block") {
        childNode.style.display = "block";
        image.src = contextPath + "/image/controlledvocabulary/m.gif";
        image.alt = "Collapse search term category";
    } else {
        childNode.style.display = "none";
        image.src = contextPath + "/image/controlledvocabulary/p.gif";
        image.alt = "Expand search term category";
    }

    return false;
}


function getAnchorText(ahref) {
    if (isMicrosoft())
        return ahref.childNodes.item(0).nodeValue;
    else
        return ahref.text;
}

function getTextValue(node) {
    if (node.nodeName == "A") {
        return getAnchorText(node);
    } else {
        return "";
    }

}


function getParentTextNode(node) {
    var parentNode = node.parentNode.parentNode.parentNode;
    var children = parentNode.childNodes;
    var textNode;
    for (var i = 0; i < children.length; i++) {
        var child = children.item(i);
        if (child.className == "value") {
            return child;
        }
    }
    return null;
}

function ec(node, contextPath) {
    expandCollapse(node, contextPath);
    return false;
}


function i(node) {
    return sendBackToParentWindow(node);
}


function getChildrenByTagName(rootNode, tagName) {
    var children = rootNode.childNodes;
    var result = new Array(0);
    if (children == null)
        return result;
    for (var i = 0; i < children.length; i++) {
        if (children[i].tagName == tagName) {
            var elementArray = new Array(1);
            elementArray[0] = children[i];
            result = result.concat(elementArray);
        }
    }
    return result;
}

function popUp(URL) {
    var page;
    page = window.open(URL, 'controlledvocabulary', 'toolbar=0,scrollbars=1,location=0,statusbar=0,menubar=0,resizable=1,width=650,height=450');
}


function isNetscape(v) {
    return isBrowser("Netscape", v);
}

function isMicrosoft(v) {
    return isBrowser("Microsoft", v);
}

function isMicrosoft() {
    return isBrowser("Microsoft", 0);
}


function isBrowser(b, v) {
    browserOk = false;
    versionOk = false;

    browserOk = (navigator.appName.indexOf(b) != -1);
    if (v == 0)
        versionOk = true;
    else
        versionOk = (v <= parseInt(navigator.appVersion));
    return browserOk && versionOk;
}

var CONTRAST_HIGH = "high";
var CONTRAST_NONE = "none";
var v_cookie_contraste = "acessibilidade_capes_contraste";

var cookieEnabled = (navigator.cookieEnabled) ? true : false;

//if not IE4+ nor NS6+
if (typeof navigator.cookieEnabled == "undefined" && !cookieEnabled) {
    document.cookie = "testcookie";
    cookieEnabled = (document.cookie.indexOf("testcookie") != -1) ? true : false;
}

function setCookie(name, value, days) {

    if (cookieEnabled) {
        if (days) {
            var date = new Date();
            date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
            var expires = "; expires=" + date.toGMTString();
        } else
            var expires = "";
        document.cookie = name + "=" + value + expires + "; path=/";
    } else {
        alert("Seu navegador está com a opção de cookie DESATIVADA.\nPara que este recurso funcione corretamente, será necessário habilitar o registro de cookies.");
    }
}

function getCookie(name) {
    var nameEQ = name + "=";
    var ca = document.cookie.split(';');
    for (var i = 0; i < ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0) == ' ')
            c = c.substring(1, c.length);
        if (c.indexOf(nameEQ) == 0)
            return c.substring(nameEQ.length, c.length);
    }
    return null;
}

function applyContrast(contrastType) {

    var cssFile = "capes_sem_contraste.css";

    if (contrastType == CONTRAST_HIGH) {
        cssFile = "capes_contraste.css";
    }

    var cssLink = jQuery("#cssContraste").attr("href");
    var cssToShow = cssLink.substring(0, cssLink.lastIndexOf("/"))+ "/" + cssFile;
    document.getElementById("cssContraste").href = cssToShow;
    setCookie(v_cookie_contraste, contrastType, 360);
}

jQuery(document).ready(function () {

    jQuery('#searchGear').click(function () {
        if (jQuery('.discovery-pagination-controls').hasClass('hidden')) {
            jQuery('.discovery-pagination-controls').removeClass('hidden');
            jQuery(this).children('div').addClass('gearActivated');
            jQuery(this).children('div').removeClass('gear');
            // jQuery("html, body").animate({ scrollTop: jQuery("div.discovery-pagination-controls").width() }, 1000);

        } else {
            jQuery('.discovery-pagination-controls').addClass('hidden');
            jQuery(this).children('div').removeClass('gearActivated');
            jQuery(this).children('div').addClass('gear');
            jQuery("input#filterquery").focus();

            // jQ("html, body").animate({ scrollTop: jQ("div.discovery-pagination-controls").height() }, 1000);

        }
    });

    jQuery('#showSearchFilters').click(function () {
        jQuery('#searchFilterPanel').removeClass('hidden');
        jQuery(this).addClass('hidden');
        // jQuery("html, body").animate({ scrollTop: jQuery("a#hideSearchFilters").width() }, 1000);
        jQuery("input#filterquery").focus();

    });

    jQuery('#hideSearchFilters').click(function () {
        jQuery('#searchFilterPanel').addClass('hidden');
        jQuery('#showSearchFilters').removeClass('hidden');
        // jQ("html, body").animate({ scrollTop: jQ("input#query").height() }, 1000);
        jQuery("input#query").focus();
    });

    jQuery('.expandButton').click(function () {
        if (jQuery(this).parent().children('ul').is(":visible"))
        {
            jQuery(this).parent().children('ul').hide();
        }
        else
        {
            jQuery(this).parent().children('ul').show();
        }


        var tipoBotao = jQuery(this).html();
        var novoTipoBotao = "";

        if (tipoBotao == "[-]")
        {
            novoTipoBotao = "[+]";
        }
        else
        {
            novoTipoBotao = "[-]";
        }

        jQuery(this).html(novoTipoBotao);
    });

    jQuery('#contrastLink').click(function (event) {
        event.preventDefault();
        jQuery(this).parent().addClass("hidden");
        jQuery('#noContrastLink').parent().removeClass("hidden");
        applyContrast(CONTRAST_HIGH);
    });

    jQuery('#noContrastLink').click(function (event) {
        event.preventDefault();
        jQuery(this).parent().addClass("hidden");
        jQuery('#contrastLink').parent().removeClass("hidden");
        applyContrast(CONTRAST_NONE);
    });

});



