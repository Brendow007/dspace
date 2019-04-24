var cookieAltoContraste = "rep_capes_contraste";
var duracaoCookie = 30;

var PARAMETRO_ALTO_CONTRASTE = "altocontraste";
var PARAMETRO_SEM_CONTRASTE = "semcontraste";

function trocarEstilo ( tituloCSS )
{
  var contador;
  var tagLink;
  
  for (contador = 0, tagLink = document.getElementsByTagName("link") ; contador < tagLink.length ; contador++ ) 
  {
    if ((tagLink[contador].rel.indexOf( "stylesheet" ) != -1) && tagLink[contador].title) 
    {
      tagLink[contador].disabled = true ;
      if (tagLink[contador].title == tituloCSS) 
      {
        setarCookie( tituloCSS, duracaoCookie, "");  
        tagLink[contador].disabled = false ;
      }
    }
  }
  
}

function trocarAparenciaPeloCookie()
{
  var tituloCSS = lerCookie();
  
  if (tituloCSS.length) 
  {
      trocarEstilo( tituloCSS );
  }
}

function setarCookie ( valorCookie, diasVencimento, dominio )
{
    document.cookie = cookieAltoContraste + '=; expires=Thu, 01 Jan 1970 00:00:01 GMT;';
    
    var d = new Date();
    d.setTime(d.getTime() + (diasVencimento * 24 * 60 * 60 * 1000));
    var expires = "expires="+d.toUTCString();
    
    document.cookie = cookieAltoContraste + "=" + valorCookie + ";  expires=" + expires + ";  path=/";
    
}

function lerCookie() {
    var pairs = document.cookie.split("; ");
    var count = pairs.length, parts; 
    while ( count-- ) {
        parts = pairs[count].split("=");
        if ( parts[0] === cookieAltoContraste )
            return parts[1];
    }
    return false;
}

String.prototype.endsWith = function(str) 
{return (this.match(str+"$")==str)}

function inserirBotoesExpandirContrairHierarquia(){
    var urlAtual = document.URL;
    
    if(urlAtual.endsWith('community-list'))
    {
        $('#ds-body').find('li').each(function( index ) {
            if($(this).hasClass("community"))
            {
                $(this).before('<span class="expandButton">[+]</span>');
                $(this).children('ul').hide();
            }
            else
            {
                $(this).before('<span class="collectionMark">&nbsp;</span>');
            }
        });
       
       //$('#aspect_artifactbrowser_CommunityBrowser_div_comunity-browser').find('ul').find('ul').toggle();
    }
}

window.onload = function() {
    
    trocarAparenciaPeloCookie();
    inserirBotoesExpandirContrairHierarquia();
    
    $("#link_altocontraste").click( function() { 
        
        var valor_cookie = lerCookie();
         
        if(valor_cookie === PARAMETRO_ALTO_CONTRASTE)
        {
            trocarEstilo(PARAMETRO_SEM_CONTRASTE);
        }
        else
        {
            trocarEstilo(PARAMETRO_ALTO_CONTRASTE);
        }
    });
    
    $("#link-ds-search_repository").click( function() { 
        $("#ds-search_repository").focus();
    });
    
    $('.expandButton').click(function() {
        // $(this).next('li').find('ul').slideToggle();
//        $(this).next('li').find('ul:last-child').css("margin-top","0");
//        $(this).next('li').find('ul').slideToggle("fast");
        if($(this).next('li').children('ul').is(":visible"))
        {
            $(this).next('li').children('ul').hide();
        } 
        else
        {
            $(this).next('li').children('ul').show();
        }
        
       
        var tipoBotao = $(this).html();
        var novoTipoBotao = "";
        
        if(tipoBotao == "[-]")
        {
            novoTipoBotao = "[+]";
        }
        else 
        {
            novoTipoBotao = "[-]";
        }
        
        $(this).html(novoTipoBotao);
    });
    
};

