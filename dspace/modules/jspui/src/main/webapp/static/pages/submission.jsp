<%-- 
    Document   : search
    Created on : 17/07/2016, 15:57:27
    Author     : guilherme
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>


<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<dspace:layout locbar="off" title="Como enviar seu material?">
    <div class="tutorialSubmission">


        <h1>Envie seu material</h1>
        

		<p>Enviar materiais para o eduCAPESé fácil: Inicialmente o portal eduCAPES esta disponibilizado somente para <b>universidades do programa UAB</b>. 

		Caso sua universidade participe do programa UAB, basta você possuir autoria do material ou a licença de direitos autorais e se cadastrar no portal.</p>
        

		<p>São permitidos arquivos de áudio, imagens, textos e vídeos em qualquer tipo de formato digital.</p>
        

		<p>Para enviar seu material, siga os seguintes passos:</p>
        

		<p>IMPORTANTE:para cada material que for submetido, você deverá seguir todos esses passos.</p>
        


		<ol class="lista-numerada">

		 <li>Verifique se você possuí os direitos referentes ao material;</li>
			<li>Verifique também se o material já está licenciado sob a licença Creative Commons em alguma das seguintes versões:
				<ul>
					<li><strong>CC-BY-SA:</strong> esta licença permite que outros remixem, adaptem e criem a partir do seu trabalho, mesmo para fins comerciais, desde que lhe atribuam o devido crédito e que licenciem as novas criações sob termos idênticos.</li>
					<li><strong>CC-BY:</strong> esta licença permite que outros distribuam, remixem, adaptem e criem a partir do seu trabalho, mesmo para fins comerciais, desde que lhe atribuam o devido crédito pela criação original.</li>
					<li><strong>CC-BY-NC-SA:</strong> esta licença permite que outros remixem, adaptem e criem a partir do seu trabalho para fins não comerciais, desde que atribuam o devido crédito e que licenciem as novas criações sob termos idênticos.</li>
					<li><strong>CC-BY-NC: esta</strong> licença permite que outros remixem, adaptem e criem a partir do seu trabalho para fins não comerciais, e embora os novos trabalhos tenham de lhe atribuir o devido crédito e não possam ser usados para fins comerciais, os usuários não têm de licenciar esses trabalhos derivados sob os mesmos termos.</li>
				</ul>
			</li>


			<li>Caso não esteja, realize o licenciamento do material antes de prosseguir com a submissão. O licenciamento pode ser feito diretamente pelo site do Creative Commons: <a href="https://creativecommons.org/choose/?lang=pt" target="_blank">https://creativecommons.org/choose/?lang=pt</a>;</li>
			<li>Caso seja sua primeira submissão no eduCAPES, realize o cadastro no portal clicando em <a class="btn btn-primary" href="<%= request.getContextPath()%>/register/edit-author">Cadastro de submissor</a></li>
			<li>Após finalizar a cadastro, você será notificado por email caso seu cadastro seja aprovado pelos gestores do portal.</li>
			<li>Após a aprovação do seu cadastro no portal eduCAPES faça autenticação em <a class="btn btn-primary" href="<%= request.getContextPath()%>/password-login">Login</a>, na opção <a class="btn btn-primary" href="<%= request.getContextPath()%>/mydspace">Submissões</a></li>
			<li>Clique no link "Iniciar nova submissão" para iniciar o cadastro do material;</li>
			<li>Preencha os formulários apresentados pelo sistema com os dados referentes ao material;</li>
			<li>Na etapa de "Upload", selecione o arquivo digital desejado referente ao material que está sendo compartilhado;</li>
			<li>Verifique se os dados e arquivos cadastrados estão corretos;</li>
			<li>Leia atentamente o termo de compromisso e selecione TODAS as opções;</li>
			<li>Pronto! Seu material foi enviado para a base do eduCAPES.</li>
        </ol>

    </div>
</dspace:layout>

