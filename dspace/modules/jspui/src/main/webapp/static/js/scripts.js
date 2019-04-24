
jQuery(function(){

        // EFEITO DE CONTRASTE  
    var Contrast = {
        storage: 'contrastState',
        cssClass: 'contraste',
        currentState: null,
        check: checkContrast,
        getState: getContrastState,
        setState: setContrastState,
        toogle: toogleContrast,
        updateView: updateViewContrast
    };

    window.toggleContrast = function () { Contrast.toogle(); };
    Contrast.check();
    function checkContrast() {
        this.updateView();
    }
    function getContrastState() {
        return localStorage.getItem(this.storage) === 'true';
    }
    function setContrastState(state) {
        localStorage.setItem(this.storage, '' + state);
        this.currentState = state;
        this.updateView();
    }
    function updateViewContrast() {
        var body = document.body;

        if (this.currentState === null)
            this.currentState = this.getState();
        if (this.currentState)
            body.classList.add(this.cssClass);
        else
            body.classList.remove(this.cssClass);
    }
    function toogleContrast() {
        this.setState(!this.currentState);
    }


         //jQuery to collapse the navbar on scroll
       
        jQuery(".logo-menu").hide(); 
        jQuery(".menu-scroll").css("top","-100px");
        jQuery(".menu-scroll").hide();  

         jQuery(window).scroll(function(){
               var window_scrolltop = jQuery(this).scrollTop();
               var top = jQuery(window).scrollTop(); 
               var lagura = screen.width, altura = screen.height;

            if(top > 400){ 
               jQuery(".menu-scroll").show();                 
               jQuery(".menu-scroll").stop().animate({ top: "0px" }, 300);

               jQuery(".logo-menu").show();
               jQuery(".busca").css("top","27px");               
               jQuery(".barra-top").stop().animate({ top: "-100px" }, 150);  
               

            } else{
               
               jQuery(".menu-scroll").show();                 
               jQuery(".menu-scroll").stop().animate({ top: "-100px" }, 300);

               
                              
               jQuery(".busca").css("top","15px");               
               jQuery(".barra-top").stop().animate({ top: "0px" }, 150); 


            }

            if(top > 500){ 
              jQuery(".super-banner").attr("style","z-index:-10"); 

            } else{
              jQuery(".super-banner").attr("style","z-index:100"); 
            }

              if(lagura < 767) { 
                   jQuery(".menu").removeClass("menu-scroll");
                   if(top > 2){ 
                    jQuery(".navbar").stop().animate({ top: "0px" }, 0); 
                    jQuery("#barra-brasil").stop().animate({ top: "0px" }, 0);                   
                     
                   }
                   else {
                       

                   }
                  }

        });


         

             

  jQuery(".navbar-nav").click(function() {  //use a class, since your ID gets mangled
    jQuery(".navbar-collapse").removeClass("in");
          //add the class to the clicked element
  });

  //MENU RESPONSIVO
    jQuery(".bt-responsive.visible-xs.visible-sm").click(function() {
        jQuery(".navbar-collapse").slideToggle( "slow" );
        jQuery(".navbar-collapse").toggleClass("collapse ");

    });

    // jQuery(".nav a").click(function() {
    //     jQuery(".navbar-collapse").slideToggle( "slow" );
    // });






 jQuery('a.page-scroll').bind('click', function(event) {
        var jQueryanchor = jQuery(this);
        jQuery('html, body').stop().animate({
            scrollTop: jQuery(jQueryanchor.attr('href')).offset().top-20
        }, 1500, 'easeInOutExpo');
        event.preventDefault();

    jQuery('h1.header').css('display','none');

    });





   //controla efeito do header durante scroll da pagina
   var shrinkHeader = 300;
   jQuery(window).scroll(function() {
      var scroll = getCurrentScroll();
      if ( scroll >= shrinkHeader ) {
         jQuery('.header').addClass('shrink');
      }else{
         jQuery('.header').removeClass('shrink');
      }
   });
   function getCurrentScroll() {
      return window.pageYOffset || document.documentElement.scrollTop;
   }

   //controla parallax da imagem de fundo
   jQuery('div.bgFixo').each(function(){
      var obj = jQuery(this);
      jQuery(window).scroll(function() {
         var yPos = -(jQuery(window).scrollTop() / obj.data('speed'));
         var bgpos = '30% '+ yPos + 'px';
         obj.css('background-position', bgpos );

      });
   });




    // BUSCA
   jQuery(function(){
        jQuery('.menu .busca').click(function(){

            if(jQuery(this).attr('class') == 'btn'){
               jQuery(".menu-modal").show();
               jQuery("body").attr("style","overflow:hidden;");
            }else{
               jQuery(".busca-modal").show();
               jQuery("body").attr("style","overflow:hidden;");
            }

            jQuery("#barra-brasil").css("z-index","10");
        });

        jQuery(".fechar-modal, #menu a").click(function(){
          jQuery("#barra-brasil").css("z-index","615");
          jQuery(".modal-plano").hide();
            jQuery("body").removeAttr("style");
        });
    });

   //mantem o focu no input da modal de pesquisa.
    jQuery(".btn-busca").click(function() {
      jQuery('#myModal').on('shown.bs.modal', function() {
        jQuery('#mod-search-searchword').focus();
      })
    });


    jQuery('#ver-mais').on('shown.bs.collapse', function () {
       jQuery(".glyphicon").removeClass("glyphicon-plus").addClass("glyphicon-minus");
    });

    jQuery('#ver-mais').on('hidden.bs.collapse', function () {
       jQuery(".glyphicon").removeClass("glyphicon-minus").addClass("glyphicon-plus");
    });

   //acao botao de alto contraste
   jQuery('a.toggle-contraste').click(function(){   
      if(!jQuery('body').hasClass('contraste')){
         jQuery('body').addClass('contraste'); 
         body_classes = jQuery.cookie('body_classes');
         if( body_classes != 'undefined' )
            body_classes = body_classes + ' contraste';
         else
            body_classes = 'contraste';
         jQuery.cookie('body_classes', onpage_classes );
      }else{
         jQuery('body').removeClass('contraste');
         body_classes = jQuery.cookie('body_classes');
         body_classes = body_classes.replace('contraste', '');     
         jQuery.cookie('body_classes', body_classes );   
      }
   });

});