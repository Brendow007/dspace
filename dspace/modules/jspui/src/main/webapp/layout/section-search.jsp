<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<script>
    $(document).ready(function () {
        $('[data-toggle="tooltip"]').tooltip();
    });

    $(document).ready(function () {
        $('#searchButton').click(function () {
            $("#span-button").submit();
        });
    })
</script>

<style>

    .col-md-1{
        margin: -1.5% 0% 2% 0%;

    }


    .page-header {
        /*margin-right: -16em !important;*/
        z-index: -1;
        color: #fff;
        background-color: #0078A5;
        padding-bottom: 9px;
        margin: 40px 0 20px;
        border-bottom: 1px solid #eeeeee;
        margin-top: 0%;
    }


    .row {
        margin-right: -15px;
        margin-left: -15px;
    }

    .large {
        font-size: x-large;
    }


</style>



<section id="main-content">
    <header class="page-header">



        <div class="container">
            <form id="span-button" class="" method="get" action="<%= request.getContextPath()%>/simple-search">

                <div class="row">
                    <div class="col-md-12">
                        <h1 class="large" align="center"><label for="query"><fmt:message key="jsp.home.search.label"/></label>
                        </h1>
                    </div>
                </div>


                <div class="col-md-3">
                    <%--<img class="imgcapes" src="<%= request.getContextPath()%>/image/capes/logoEducapesHome.png">--%>
                </div>



                    <div class="col-md-12">

                        <div class="col-md-10">
                            <input type="text" class="form-control"
                                   placeholder="<fmt:message key="jsp.layout.navbar-default.search"/>"
                                   id="tequery-main-page" name="query"
                                   id="query" size="50"/>
                        </div>
                        <div class="col-md-1 hi-icon-effect-8">
                                <span id="searchButton" class="hi-icon material-icons"
                                      onclick="document.forms['form-name'].submit();">search</span>
                        </div>


                    </div>


                <div class="row">
                    <div class="col-md-12 form-inline">


                    </div>

                </div>
            </form>
        </div>
    </header>


</section>
