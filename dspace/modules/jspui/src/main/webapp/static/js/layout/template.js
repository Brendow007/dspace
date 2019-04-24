'use strict';
jQuery(document).ready(function () {


    checkPosition();


    //copyrights year
    var currentYear = (new Date).getFullYear();
    jQuery("#year").text((currentYear));


    //tooltip animation
    jQuery('[data-toggle="tooltip"]').tooltip();

    // $('.submit_delete_partner').click(function() {
    //     if (confirm('Tem certeza que deseja deletar?')) {
    //         var url = $(this).attr('href');
    //         $('#content').load(url);
    //     }
    // });

    //font-size ++
    jQuery("#increaseFont").click(function () {
        jQuery("body").children().each(function () {
            var size = parseInt(jQuery(this).css("font-size"));
            size = size + 2 + "px";
            jQuery(this).css({
                'font-size': size
            });
        });
    });

    //font-size --
    jQuery("#decreaseFont").click(function () {
        jQuery("body").children().each(function () {
            var size = parseInt(jQuery(this).css("font-size"));
            if (size < 10) {

            } else {
                size = size - 2 + "px";
                jQuery(this).css({
                    'font-size': size
                });
            }

        });
    });

    //fonte-size default
    jQuery("#defaultFont").click(function () {
        jQuery("body").children().each(function () {
            var size = parseInt(jQuery(this).css("font-size"));
            size = 14 + "px";
            jQuery(this).css({
                'font-size': size
            });
        });
    });


    jQuery(".uploadlogo").change(function () {
        var filename = readURL(this);
        $(this).parent().children('span').html(filename);
    });

    // Read File and return value
    function readURL(input) {
        var url = input.value;
        var ext = url.substring(url.lastIndexOf('.') + 1).toLowerCase();
        if (input.files && input.files[0] && (
            ext == "png" || ext == "jpeg" || ext == "jpg" || ext == "gif" || ext == "pdf"
        )) {
            var path = $(input).val();
            var filename = path.replace(/^.*\\/, "");
            // $('.fileUpload span').html('Uploaded Proof : ' + filename);
            return "Logo adicionada: " + filename;
        } else {
            $(input).val("");
            return "Apenas formatos de imagem são permitidos!";
        }
    }

    // Upload btn end


    //Add filter Search
    jQuery('#modal-confirm').on('change', function () {
        var termoAceite = jQuery(this);
        if (termoAceite.is(':checked')) {
            jQuery('.files-list').find('.btn').removeAttr('disabled');
            //jQuery('.modal-footer.btn-special').children('.btn-success').removeAttr('disabled');
        } else {
            jQuery('.files-list').find('.btn').attr('disabled', true);
            //jQuery('.modal-footer.btn-special').children('.btn-success').attr('disabled', true);
        }
    });
    if (!jQuery('#modal-confirm').is(':checked')) {
        jQuery('.files-list').find('.btn').attr('disabled', true);
        jQuery('.modal-footer.btn-special').children('.btn-success').attr('disabled', true);
    }
    jQuery('.modal-footer.btn-special').children('.btn-success').on('click', function () {
        modal.modal('hide');
    });

    var buscaFiltros = {
        add: function () {
            var newFilter = jQuery('.busca-filtro-param-ref')
            newFilter.clone().prependTo('#busca-filtros')
                .addClass('busca-filtro-param')
                .removeClass('busca-filtro-param-ref')
                .on('click', 'button.applay', buscaFiltros.applay)
                .on('click', 'button.remove', buscaFiltros.remove);
        },
        remove: function () {
            jQuery(this).parent().remove();
            console.log('adicionar comportamento para aplicação do filtro');
        },
        applay: function () {
            var obj = jQuery(this);
            console.log('adicionar comportamento para aplicação do filtro');

            jQuery(this).parent().remove();

            jQuery('#filtro-tags').append(jQuery('<span>')
                .addClass('label label-default tag mr-sm')
                .html(jQuery('select', obj.parent()).val() + ': ' + jQuery('input', obj.parent()).val())
                .append(jQuery('<a>')
                    .addClass('remove glyphicon glyphicon-remove')
                    .on('click', buscaFiltros.remove)
                ));

        }
    }

    jQuery('button.add', '#busca-filtros').on('click', buscaFiltros.add);


    var setCookie = function (cookie_name, cookie_value, exdays) {
        var d = new Date();
        d.setTime(d.getTime() + (exdays * 24 * 60 * 60 * 1000));
        var expires = "expires=" + d.toUTCString();
        console.log(document.cookie = cookie_name + "=" + cookie_value + "; " + expires);
    };
    var getCookie = function (cookie_name) {
        var name = cookie_name + "=";
        var ca = document.cookie.split(';');
        for (var i = 0; i < ca.length; i++) {
            var c = ca[i];
            while (c.charAt(0) == ' ')
                c = c.substring(1);
            if (c.indexOf(name) == 0)
                return c.substring(name.length, c.length);
        }
        return "";
    };

    window.thisFontsize = 1;
    window.docFontSize = function (a) {

        switch (a) {
            case "up" :
                if (thisFontsize <= 2)
                    thisFontsize = thisFontsize + 0.1;
                break;
            case "down" :
                if (thisFontsize >= 0.5)
                    thisFontsize = thisFontsize - 0.1;
                break;
            default :
                thisFontsize = 1;
        }
        document.getElementById('main').style.fontSize = thisFontsize + "em";
        if (thisFontsize === 1) {
            document.getElementById('main').removeAttribute('style');
        }
        return thisFontsize;
    };
    window.altoContraste = function (a) {
        if (jQuery(a).hasClass('altoContraste')) {
            jQuery(a).removeClass('altoContraste');
            setCookie("altoContraste", false, 1);
        } else {
            jQuery(a).addClass('altoContraste');
            setCookie("altoContraste", true, 1);
        }
    };

    jQuery(document).ready(function () {
        if (getCookie("altoContraste")) {

        }
    });
    jQuery(window).load(function () {
        if (getCookie("altoContraste") === "true") {
            window.altoContraste('#main');
        }
    });

    jQuery('[data-ano]').html(new Date().getFullYear());

    jQuery('[open-link]').on('click', function () {
        console.log(jQuery(this).attr('open-link'));

        var link = jQuery(this).attr('open-link');
        window.open(link, "open link", 'width=750px, height=460px, scrollbars=no, menubar=no, resizable=no, status=no, titlebar=no, location=no, toolbar=no');
    });

    jQuery('.item-data .data-header').on('click', function () {
        var dataParent = jQuery(this).parent();
        var dataContent = jQuery(this).siblings('.data-body');

        if (!dataParent.hasClass('active')) {
            dataParent.addClass('active');
            dataContent.slideDown(200);
        } else {
            dataParent.removeClass('active');
            dataContent.slideUp(200);
        }

        dataParent.siblings('.item-data').each(function () {
            if (jQuery(this).hasClass('active')) {
                jQuery(this).removeClass('active');
                jQuery(this).children('.data-body').slideUp(200);
            }
        });
    });
    jQuery('a[disabled]').click(function (event) {
        event.preventDefault();
    });

    /*
     * MODAL FUNCTION
     * GET "DATA-URL" AND INJECTS  
     */
    jQuery('#modal').on('show.bs.modal', function (e) {
        var modal = jQuery(this);
        var triggerElm = jQuery(e.relatedTarget);
        if (typeof triggerElm.attr('data-url') === 'undefined') {
            if (typeof triggerElm.attr('data-ajax') !== 'undefined') {
                modal.modal('hide');
                console.error('Attribute \'data-url\' needed', 'Eg.: data-url="modal-content-link.html"');
            }
        } else {
            jQuery.get(triggerElm.attr('data-url'), function (data) {
                modal.html(data);
            }).done(function () {
                modal.trigger('data:updated');
            });

            // watch no triggr do update
            modal.on('data:updated', function (e) {
                jQuery('#modal-confirm').on('change', function () {
                    var termoAceite = jQuery(this);
                    if (termoAceite.is(':checked')) {
                        jQuery('.files-list').find('.btn').removeAttr('disabled');
                        //jQuery('.modal-footer.btn-special').children('.btn-success').removeAttr('disabled');
                    } else {
                        jQuery('.files-list').find('.btn').attr('disabled', true);
                        //jQuery('.modal-footer.btn-special').children('.btn-success').attr('disabled', true);
                    }
                });
                if (!jQuery('#modal-confirm').is(':checked')) {
                    jQuery('.files-list').find('.btn').attr('disabled', true);
                    jQuery('.modal-footer.btn-special').children('.btn-success').attr('disabled', true);
                }

                jQuery('.files-list').find('a.btn').click(function () {
                    event.preventDefault();
                    if (typeof jQuery(this).attr('disabled') !== 'undefined') {
                        console.error('Aceite o termo para poder baixar o arquivo');
                    } else {
                        window.location = jQuery(this).attr('href');

                    }
                })
            });
        }

    });
    // unbind do data:update
    jQuery('#modal').on('hide.bs.modal', function (e) {
        var modal = jQuery(this);
        modal.unbind('data:updated');
    });

    jQuery('[data-toogle-spiner]').on('click', function (e) {
        e.preventDefault();
        var spinner = (typeof jQuery(this).attr('data-spinner-type') === 'undefined') ? 'spinner-4' : jQuery(this).attr('data-spinner-type');
        console.log(spinner)
        var loaderTemplate = '<!-- spinner --><div class="loader"><div class="s-container "><div class="spinner"><i class="capes-glyph-' + spinner + '"></i></div></div></div><!-- spinner -->';
        jQuery('body').append(loaderTemplate);
        jQuery('.loader').addClass('active');
    });


    function checkPosition() {
        if (window.matchMedia('(max-width: 764px)').matches) {
            jQuery('a#showSearchFilters.pull-right').html("<span class=\"glyphicon glyphicon-plus\"></span>");
        } else {
        }
    }

});


//
// jssor_1_slider_init = function () {
//     var jssor_1_options = {
//         $AutoPlay: 1,
//         $Idle: 0,
//         $SlideDuration: 9500,
//         $SlideEasing: $Jease$.$Linear,
//         $PauseOnHover: 4,
//         $SlideWidth: 270,
//         $Align: 0
//     };
//
//     var jssor_1_slider = new $JssorSlider$("jssor_1", jssor_1_options);
//
//     /*#region responsive code begin*/
//
//     var MAX_WIDTH = 1200;
//
//     function ScaleSlider() {
//         var containerElement = jssor_1_slider.$Elmt.parentNode;
//         var containerWidth = containerElement.clientWidth;
//
//         if (containerWidth) {
//
//             var expectedWidth = Math.min(MAX_WIDTH || containerWidth, containerWidth);
//
//             jssor_1_slider.$ScaleWidth(expectedWidth);
//         }
//         else {
//             window.setTimeout(ScaleSlider, 30);
//         }
//     }
//
//     ScaleSlider();
//
//     $Jssor$.$AddEvent(window, "load", ScaleSlider);
//     $Jssor$.$AddEvent(window, "resize", ScaleSlider);
//     $Jssor$.$AddEvent(window, "orientationchange", ScaleSlider);
// /*#endregion responsive code end*/

/*jssor slider loading skin spin css*/
// .jssorl-009-spin img {
//     animation-name: jssorl-009-spin;
//     animation-duration: 4.6s;
//     animation-iteration-count: infinite;
//     animation-timing-function: linear;
// }
//
//     @keyframes jssorl-009-spin {
//     from {
//         transform: rotate(0deg);
//     }
//     to {
//         transform: rotate(360deg);
//     }
// }


//consumindo serviço rest educapes exemplo
// jQ('.ui.search.dropdown, #test').dropdown('setting',  'onChange', function(value, text, $choice) {
//     // console.log(text);
//     console.log($choice.attr('value'));
//     console.log();
// });
// jQ("body").on('DOMSubtreeModified', '.ui.search.selection.dropdown', function() {
//
//     itemSelectedVal = jQ('.item.active.selected').attr('value');
//     // code here
//     // console.log("changed");
//         console.log(itemSelectedVal);
//
// });


// jQ("#botao").click(function () {
/*            function FullCom() {
                jQ.ajax({
                    dataType: 'json',
                    headers: {
                        Accept: "application/json",
                        "Access-Control-Allow-Origin": "*"
                    },
                    type: 'GET',
                    url: '/communities/top-communities',
                    success: function (data) {
                        // Object.keys(data).forEach(function (index) {
                        jQ.each(data, function (key, value) {
                            jQ('#TopCons')
                                .append(jQ("<div>").attr("class", "item").attr("name", value.name)
                                    .append(jQ("<a></a>").attr("value", key).attr("id", value.id).attr("class", "text").attr("href", "handle/" + value.handle).text(value.name))
                                    .append(jQ("<i></i>").attr("class", "pull-right icon-caret-right"))
                                    .append(jQ("<div>").attr("class", "menu sub-com").attr("id", "last_" + value.id).attr("name", value.name)
                                    // .append(jQ("<div></div>").attr("class", "item").text(value.name))
                                        .append(jQ("</div>")))
                                    .append(jQ("</div>")));
                            window.test = value.name;
                            getComFromCom(value.id, value.name);
                            getColFromCom(value.id, value.name);
                        });


                        // console.log('Comunidade: ' + ' - ' + key + value.handle + value.id + value.name);
                        // });

                        // });

                        // Object.keys(data).forEach(function (index) {
                        //     getSubCollections(data[index].id, data[index].name);
                        // });

                    },
                    error: function (data) {
                        alert(data.error());
                    }
                });
            }*/
// });
/*            function getComFromCom(id, TopComName) {
    jQ.ajax({
        dataType: 'json',
        headers: {
            Accept: "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        type: 'GET',
        url: 'rest/communities/' + id + '/communities',
        success: function (data) {
            jQ.each(data, function (key, value) {
                console.log(TopComName+" id : "+ id +" : "+"sub-com: ",value.name + " id :" + value.id);
                console.log(id);
                jQ('#last_'+id).prepend(jQ("<div>" + value.name + "</div>").attr("class", "item"));
            });
        },
        error: function (data) {
            alert(data.error());
        }
    });
}*/

/*function getColFromCom(id, TopComName) {
    jQ.ajax({
        dataType: 'json',
        headers: {
            Accept: "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        type: 'GET',
        url: 'restapi/communities/' + id + '/collections',
        success: function (data) {
            jQ.each(data, function (key, value) {
                jQ('#last_'+id).prepend(jQ("<div>" + value.name + "</div>").attr("class", "item"));
            });
        },
        error: function (data) {
            alert(data.error());
        }
    });
}*/