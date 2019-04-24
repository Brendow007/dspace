
/**
 * ARQUIVO DE DEMOSTRAÇÃO
 * NÃO HÁ A NECESSIDADE EM ADICINA-LO AO PROJETO
 * 
 * Exemplos em página para demostração de algumas funcionalidades
 * 
 */

//jQuery('#modal').on('show.bs.modal', function (e) {
//    var modal = jQuery(this);
//    jQuery.get('./modal.html', function (data) {
//        modal.html(data);
//    }).done(function () {
//        modal.trigger('data:updated');
//    });
//    modal.on('data:updated', function () {
//        jQuery('#modal-confirm').on('change', function () {
//            var termoAceite = jQuery(this);
//            if (termoAceite.is(':checked')) {
//                jQuery('.files-list').find('.btn').removeAttr('disabled');
//                //jQuery('.modal-footer.btn-special').children('.btn-success').removeAttr('disabled');
//            } else {
//                jQuery('.files-list').find('.btn').attr('disabled', true);
//                //jQuery('.modal-footer.btn-special').children('.btn-success').attr('disabled', true);
//            }
//        });
//        if (!jQuery('#modal-confirm').is(':checked')) {
//            jQuery('.files-list').find('.btn').attr('disabled', true);
//            jQuery('.modal-footer.btn-special').children('.btn-success').attr('disabled', true);
//        }
//        jQuery('.modal-footer.btn-special').children('.btn-success').on('click', function () {
//            modal.modal('hide');
//        });
//    });
//});

jQuery(document).ready(function () {
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
        add: function(){
            var newFilter = jQuery('.busca-filtro-param-ref')
            newFilter.clone().prependTo('#busca-filtros')
                .addClass('busca-filtro-param')
                .removeClass('busca-filtro-param-ref')
                .on('click', 'button.applay', buscaFiltros.applay)
                .on('click', 'button.remove', buscaFiltros.remove);
        },
        remove: function(){
            jQuery(this).parent().remove();
            console.log('adicionar comportamento para aplicação do filtro');
        },
        applay: function(){
            var obj = jQuery(this);
            console.log('adicionar comportamento para aplicação do filtro');

            jQuery(this).parent().remove();

            jQuery('#filtro-tags').append(jQuery('<span>')
                .addClass('label label-default tag mr-sm')
                .html(jQuery('select', obj.parent() ).val() + ': '+ jQuery('input', obj.parent() ).val())
                .append( jQuery('<a>')
                    .addClass('remove glyphicon glyphicon-remove')
                    .on('click', buscaFiltros.remove)
                ));

        }
    }

    jQuery('button.add', '#busca-filtros').on('click', buscaFiltros.add);


});