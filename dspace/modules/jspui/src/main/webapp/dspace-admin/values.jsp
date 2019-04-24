<%@ page import="org.dspace.harvest.MetadataValuesProfile" %>
<%@ page import="org.dspace.harvest.ProfileHarvestedCollection" %>
<%@ page import="java.util.List" %>
<%--
  Created by IntelliJ IDEA.
  User: brendows
  Date: 11/03/2019
  Time: 10:34
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%
    List values = (List<String>) request.getAttribute("values");
    String typeValue = (String) request.getAttribute("typeValue");
    String id = (String) request.getAttribute("idValue");
%>
<dspace:layout locbar="commLink" title="Editando values" navbar="admin">
    <style>
        .wrap input[type="text"] {
            padding: 8px !important;
        }

        #msgStatus {
            float: right;
        }
    </style>
    <script>
        $(function () {
            arrayValues = [];
            window.state = $("#msgStatus");
            window.url = '<%=request.getContextPath()%>/dspace-admin/manager-profile';

            /*        var getJson = {
                        action: "test",
                        idValues:jsptag<id>jsptag
                    };
                    $.get(url, getJson, function (res) {
                        console.log(res);
                    });*/

            dropdownPopulate();
            saveDropdown();
            addTranscription();
        });

        function saveDropdown() {
            $("#salveArrayValues").click(function () {
                var typeVal = $("#typeValue").val();
                if (arrayValues.length > 0) {
                    if (typeVal.length > 0) {
                        $("#salveArrayValues").transition('horizontal flip');
                        setTimeout(function () {
                            var data = {
                                action: "jsonValuesUpdate",
                                transcription: typeVal,
                                idValues:<%=id%>,
                                nameJson: JSON.stringify(arrayValues)
                            };
                            $.post(url, data, function (res) {
                                // console.log(res);
                                showMsg(res, state)
                            });
                        }, 2000)
                    } else {
                        showMsg(412, state, null, "emptyTranscription");
                    }
                } else {
                    showMsg(412, state, null, "emptyValues");
                }
            });
        }

        function showMsg(type, state, timer, condition) {
            if (timer == null) {
                timer = 2500;
            }
            var visibility = $("#msgDisplay").is(":visible");
            if (!visibility) {
                if (type === 202) {
                    state.transition('horizontal flip');
                    $("#msgDisplay").remove();
                    state.prepend("<div id='msgDisplay' class='ui green message'><i class=\'close icon\'></i>\n" + "Transcrição salva com sucesso!" + "</div>");
                    setTimeout(function () {
                        state.transition('horizontal flip');
                        $("#salveArrayValues").transition('horizontal flip');
                    }, timer);
                } else if (type === 412) {
                    if (condition === "emptyValues") {
                        state.transition('horizontal flip');
                        $("#msgDisplay").remove();
                        state.prepend("<div id='msgDisplay' class='ui orange message'><i class=\'close icon\'></i>\n" + "Não é permitido armazenar uma lista de filtros vazia!" + "</div>");
                        setTimeout(function () {
                            state.transition('horizontal flip');
                        }, timer);
                    } else if (condition === "emptyFilter") {
                        state.transition('horizontal flip');
                        $("#msgDisplay").remove();
                        state.prepend("<div id='msgDisplay' class='ui orange message'><i class=\'close icon\'></i>\n" + "Campo de filtro vazio!" + "</div>");
                        setTimeout(function () {
                            state.transition('horizontal flip');
                        }, timer);
                    } else if (condition === "emptyTranscription") {
                        state.transition('horizontal flip');
                        $("#msgDisplay").remove();
                        state.prepend("<div id='msgDisplay' class='ui orange message'><i class=\'close icon\'></i>\n" + "Campo de transcrição vazio!" + "</div>");
                        setTimeout(function () {
                            state.transition('horizontal flip');
                        }, timer);
                    }
                    else if (condition === "duplicated") {
                        state.transition('horizontal flip');
                        $("#msgDisplay").remove();
                        state.prepend("<div id='msgDisplay' class='ui orange message'><i class=\'close icon\'></i>\n" + "Não é permitido armazenar valores duplicados!" + "</div>");
                        setTimeout(function () {
                            state.transition('horizontal flip');
                        }, timer);
                    }
                }
            }
        }


        function dropdownPopulate() {
            $('.ui.fluid.dropdown').dropdown({
                fields: {name: "name", value: "value"},
                selected: true,
                transition: 'drop',
                onRemove: function (value, text, $choice) {
                    $("#selectValues option[value='" + text + "']").remove();
                    updateJSON();
                }
            });
            dropdownSet();
        }

        function dropdownSet() {
            $("#selectValues > option").each(function () {
                $('.ui.fluid.dropdown').dropdown('set selected', this.text);
            });
            $('.ui.fluid.dropdown').dropdown('set active');
            updateJSON();
        }

        function addTranscription() {
            $("#buttonAddValue").click(function () {
                var addValue = $('#addValue').val().length;
                var add = $('#addValue').val();
                var select = $("#selectValues");
                var options = $("#selectValues option[value='" + add + "']").length !== 0;
                if (CheckNotEmptyStrg(addValue)) {
                    if (!options) {
                        select.dropdown('set selected', add);
                        select.append(new Option(add, add));
                        select.find("option[value='" + add + "']").attr("selected", "selected");
                        $('#addValue').val('');
                        updateJSON();
                    } else {
                        showMsg(412, state, null, "duplicated");
                        select.dropdown('set selected', add);
                    }
                } else {
                    showMsg(412, state, null, "emptyFilter");
                }
            });
        }

        function updateJSON() {
            arrayValues = $("#selectValues > option").map(function () {
                return this.value;
            }).get();
        }

        function CheckNotEmptyStrg(str) {
            if (str === 0) {
                return false;
            } else {
                return true
            }
        }
    </script>
    <h2>Editando transcrição de: <%=typeValue%>
    </h2>
    <div class="col-md-2">
        <h4> Transcrição de:</h4>
        <div class="ui input focus">
            <input type="text" name="typeValue" id="typeValue" placeholder="Transcrição..." value="<%=typeValue%>">
        </div>
    </div>
    <div class="col-md-3">
        <div class="ui right hidden" id="msgStatus"></div>
    </div>
    <br/>
    <br/>
    <br/>
    <br/>

    <select id="selectValues" multiple="" class="ui fluid dropdown">
        <%for (Object test : values) {%>
        <option value="<%=test%>"><%=test%>
        </option>
        <%}%>
    </select>
    <br/>

    <div class="ui icon input focus">
        <input id="addValue" name="addValue" type="text" placeholder="Filtros...">
        <i id="buttonAddValue" class="inverted link green circular check icon"></i>
    </div>
    <br/>
    <br/>

    <div class="col-md-2">
        <form method="POST" action="<%= request.getContextPath()%>/dspace-admin/manager-profile">
            <input type="hidden" name="action" value="list"/>
            <button class="btn btn-primary" type="submit"><i class="angle double left icon"></i>&nbsp;Voltar</button>
        </form>
    </div>

    <div class="col-md-8" align="center">
        <div id="salveArrayValues" class="inverted link green circular btn btn-warning">SALVAR</div>
    </div>


</dspace:layout>



