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
        alert("Seu navegador está com a opção de cookie DESATIVADA.\nPara que este recurso funcione corretamente, seránecessário habilitar o registro de cookies.");
    }

}

function applyConstrast(contrastType) {

    var cssFile = "capes_sem_contraste.css";

    if (contrastType == CONTRAST_HIGH) {
        cssFile = "capes_contraste.css";
    }

    var cssToShow = "<%= request.getContextPath() %>/static/css/" + cssFile;
    document.getElementById("cssContraste").href = cssToShow;
    setCookie(v_cookie_contraste, contrastType, 360);

    if (getCookie(v_cookie_contraste) == "high")
    {
        jQuery("select").each(function (index) {
            if (!jQuery(this).closest(".highcontrast_select").length) {
                jQuery(this).wrap("<div class='highcontrast_select'></div>");
            }
        });
    } else
    {
        jQuery("select").each(function (index) {
            if (jQuery(this).closest(".highcontrast_select").length) {
                jQuery(this).unwrap();
            }
        });
    }

}