jQuery(function ($) {
    $("#editor").on("DOMSubtreeModified", function () {
        // console.log('changed');
        var content = $("#editor").html();
        $("#news").html(content);
    });
    // $('#arquivo').change(function(){
    //     var filename = $('input[type=file]').val();
    //     var combinedSize = 0;
    //     for(var i=0;i<this.files.length;i++) {
    //         combinedSize += (this.files[i].size||this.files[i].fileSize);
    //         if(combinedSize > 10){
    //             alert(this.files[i]);
    //             alert(filename);
    //             alert(this.files[i].size);
    //         }
    //     }
    // });
    // removeImage();
    // selectOption();
    function selectOption() {
        $("#selectPublication").on('change', function () {
            if (this.value == "text") {
                $("#news").show();
                $("#image-context").hide();
            } else if (this.value == "image") {
                $("#news").hide();
                $("#image-context").show();
            } else if (this.value == "textImg") {
                $("#news").show();
                $("#image-context").show();
            }
        });
    }

    function readFile() {
        // console.log($("#areaNews").html());
        if (this.files && this.files[0]) {
            var FR = new FileReader();
            if (this.files[0].size < 2097152) {
                // console.log(this.files[0].size);
                $("#errorSize").addClass("hide");
                FR.addEventListener("load", function (e) {
                    document.getElementById("img").src = e.target.result;
                    document.getElementById("image").innerHTML += document.getElementById("wrapper-img").innerHTML;
                });
            } else {
                $("#errorSize").removeClass("hide");
            }
            FR.readAsDataURL(this.files[0]);
        }
    }

    // document.getElementById("arquivo").addEventListener("change", readFile);
});

function removeImage() {
    $("#removeImage").click(function () {
        //Image parameter sended to database
        var img = $("#image");
        //preview img
        var previewImg = $("#img");
        //base html image
        var previewImgWrapper = $("#wrapper-img");
        //image extracted from file
        var extractedImage = $("#extractedImage");
        //Clean html
        img.html("");
        previewImg.html("");
        previewImgWrapper.html("");
        extractedImage.html("");
        // console.log(img);
    });
}

jQuery(function ($) {
    function initToolbarBootstrapBindings() {
        var fonts = ['Serif', 'Sans', 'Arial', 'Arial Black', 'Courier',
                'Courier New', 'Comic Sans MS', 'Helvetica', 'Impact', 'Lucida Grande', 'Lucida Sans', 'Tahoma', 'Times',
                'Times New Roman', 'Verdana'],
            fontTarget = $('[title=Font]').siblings('.dropdown-menu');
        $.each(fonts, function (idx, fontName) {
            fontTarget.append($('<li><a data-edit="fontName ' + fontName + '" style="font-family:\'' + fontName + '\'">' + fontName + '</a></li>'));
        });
        $('a[title]').tooltip({container: 'body'});
        $('.dropdown-menu input').click(function () {
            return false;
        })
            .change(function () {
                $(this).parent('.dropdown-menu').siblings('.dropdown-toggle').dropdown('toggle');
            })
            .keydown('esc', function () {
                this.value = '';
                $(this).change();
            });

        $('[data-role=magic-overlay]').each(function () {
            var overlay = $(this), target = $(overlay.data('target'));
            overlay.css('opacity', 0).css('position', 'absolute').offset(target.offset()).width(target.outerWidth()).height(target.outerHeight());
        });
        if ("onwebkitspeechchange" in document.createElement("input")) {
            var editorOffset = $('#editor').offset();
            $('#voiceBtn').css('position', 'absolute').offset({
                top: editorOffset.top,
                left: editorOffset.left + $('#editor').innerWidth() - 35
            });
        } else {
            $('#voiceBtn').hide();
        }
    };

    function showErrorAlert(reason, detail) {
        var msg = '';
        if (reason === 'unsupported-file-type') {
            msg = "Unsupported format " + detail;
        }
        else {
            console.log("error uploading file", reason, detail);
        }
        $('<div class="alert"> <button type="button" class="close" data-dismiss="alert">&times;</button>' +
            '<strong>File upload error</strong> ' + msg + ' </div>').prependTo('#alerts');
    };
    initToolbarBootstrapBindings();
    $('#editor').wysiwyg({fileUploadError: showErrorAlert});
    $("#news").wysiwyg();


    window.prettyPrint && prettyPrint();
});