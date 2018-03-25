<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<!DOCTYPE html>
<html>
<head>
  <title>聊天室</title>
  <jsp:include page="commonfile.jsp"/>
  <meta name="renderer" content="webkit">
  <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
  <link rel="stylesheet" href="./css/layui.css"  media="all">
  <!-- 注意：如果你直接复制所有代码到本地，上述css路径需要改成你本地的 -->
</head>
<body>
	    <!-- 以下均为散件，具体效果调整等整合投入iframe时再议>
            <!-- 聊天区 -->
            <!-- 原件大小静态，不方便改动=.=整合时看着改，备用方案：h5弹性盒子，Amaze UI -->
	<div class="" style="width: 82%; float: left;">
		<!-- 聊天区 -->
		<div class="am-scrollable-vertical" id="chat-view"
			style="height: 610px;">
			<ul class="am-comments-list am-comments-list-flip" id="chat">
			</ul>
		</div>
		<!-- 输入区 -->
		<div class="layui-form-item layui-form-text">
			<textarea class="layui-textarea" id="sendMessageTextArea"
				name="sendMessageTextArea" rows="6" placeholder="消息快捷键 Ctrl+Enter"></textarea>
		</div>
		<!-- 接收者 -->
		<div class="" style="float: left">
			<p class="layui-text">发送给 : <span id="sendto">全体成员</span>
			<button class="am-btn am-btn-xs am-btn-danger"onclick="$('#sendto').text('全体成员')">复位</button>
			</p>
		</div>
		<!-- 按钮区 -->
          <div class="am-btn-group am-btn-group-xs" style="float:right;">
              <button class="am-btn am-btn-default" type="button" onclick="getConnection()"><span class="am-icon-plug"></span> 连接</button>
              <button class="am-btn am-btn-default" type="button" onclick="closeConnection()"><span class="am-icon-remove"></span> 断开</button>
              <button class="am-btn am-btn-default" type="button" onclick="checkConnection()"><span class="am-icon-bug"></span> 检查</button>
              <button class="am-btn am-btn-default" type="button" onclick="clearConsole()"><span class="am-icon-trash-o"></span> 清屏</button>
              <button class="am-btn am-btn-default" type="button" onclick="sendMessage()"><span class="am-icon-commenting"></span> 发送</button>
          </div>
        </div>
	</div>
	<!-- 列表区 -->
	<div class="am-panel am-panel-default"
		style="float: right; width: 18%;">
		<div class="am-panel-hd">
			<h3 class="am-panel-title">在线列表 [<span id="onlinenum"></span>]
			</h3>
		</div>
		<ul class="am-list am-list-static am-list-striped">
			<li>测试用户
				<button class="am-btn am-btn-xs am-btn-danger" id="tuling"data-am-button>未上线</button>
			</li>
		</ul>
		<ul class="am-list am-list-static am-list-striped" id="list">
		</ul>
	</div>
	<script type="text/javascript" src="./js/jquery-1.11.3.js"></script>
	    
   <script type="text/javascript">
      //变量名稍作替换，未测试
      //加入layer.msg弹性组件，表现形式为小弹窗
     var webSocket = null;
      $(function(){
    	  initSocket();//初始化websocket

      });
      
      function initSocket() {
    	    window.onbeforeunload = function () {
    	        //离开页面时的其他操作
    	    };

    	    if (!window.WebSocket) {
    	        console("您的浏览器不支持websocket！");
    	        return false;
    	    }

    	    var target = 'ws://' + window.location.host + "/ws.chat/chat";  
    			if ('WebSocket' in window) {  
    				webSocket = new WebSocket(target);  
    			} else if ('MozWebSocket' in window) {  
    				webSocket = new MozWebSocket(target);  
    			} else {  
    			    alert('WebSocket is not supported by this browser.');  
    			    return;  
    			}  
    	    
    	    
    	     // 收到服务端消息
    	    //分类接收到的信息
    	    webSocket.onmessage = function (evt){
    	    	analysisMessage(evt.data);
    	    }
    	    
    	    function analysisMessage(message){
    	        message = JSON.parse(message);
    	        if(message.type == "notice"){ //提示消息
    	        	showNotice(message.message);
    	        }
    	        if(message.type == "message"){ //用户消息
    	            publicTalk(message.message);
    	        }
    	        if(message.list != null && message.list != undefined){      //在线列表
    	            showOnline(message.list);
    	        }
    	    }
    	     /**
    	      * 展示提示信息
    	      */
				function showNotice(message) {
					$("#chat")
							.append(
									"<div><p class=\"am-text-success\" style=\"text-align:center\"><span class=\"am-icon-bell\"></span> "
											+ message.content
											+ "</p></div>");
					var chat = $("#chat-view");
					chat.scrollTop(chat[0].scrollHeight); //让聊天区始终滚动到最下面
					console.log(message.time);
				}
				/**
				 * 展示会话信息
				 */
				function publicTalk(message) {
					var to = message.to == null || message.to == ""? "全体成员" : message.to;   //获取接收人
					var isSef = '${sessionScope.username}' == message.from ? "am-comment-flip" : ""; //如果是自己则显示在右边,他人信息显示在左边
					var myhead = '${sessionScope.username}' == message.from ? "1.png" : "default_head.jpg";
					var html = "<li class=\"am-comment "+isSef+" am-comment-primary\"><a href=\"#link-to-user-home\"><img width=\"48\" height=\"48\" class=\"am-comment-avatar\" alt=\"\" src=\"${Path}/ws.chat/images/"+myhead+"\"></a><div class=\"am-comment-main\">\n"
							+ "<header class=\"am-comment-hd\"><div class=\"am-comment-meta\">   <a class=\"am-comment-author\" href=\"#link-to-user\">"
							+ message.from
							+ "</a> 发表于<time> "
							+ message.time
							+ "</time> 发送给: "
							+to
							+ " </div></header><div class=\"am-comment-bd\"> <p>"
							+ message.content + "</p></div></div></li>";						
					$("#chat").append(html);
					$("#message").val(""); //清空输入区
					var chat = $("#chat-view");
					chat.scrollTop(chat[0].scrollHeight); //让聊天区始终滚动到最下面
				}
				
			    /**
			     * 展示在线列表
			     */
			    function showOnline(list){
			        $("#list").html("");    //清空在线列表
			        $.each(list, function(index, item){     //添加私聊按钮
			            var li = "<li>"+item+"</li>";
			            if('${sessionScope.username}' != item){    //排除自己
			                li = "<li>"+item+" <button type=\"button\" class=\"am-btn am-btn-xs am-btn-primary am-round\" onclick=\"addChat('"+item+"');\"><span class=\"am-icon-phone\"><span> 私聊</button></li>";
			            }
			            $("#list").append(li);
			        });
			        $("#onlinenum").text($("#list li").length);     //获取在线人数
			    }


					// 异常
					webSocket.onerror = function(event) {
						console.log(event);
					};

					// 建立连接
					webSocket.onopen = function(event) {
						console.log(event);
						console.log(webSocket);
					};

					// 断线
					webSocket.onclose = function() {
						console.log(event);
						console.log(webSocket);
				}
      }

				/**
				 * Json格式								   
				 * "message"{ 
				     content : message,         
				     from : userid,           
				     to : to,      //接收人,如果没有则置空,如果有多个接收人则用,分隔
				     time : getDateFull()
				  },
				  "type" : {message:notice}
				 */

				//封装&发送消息
				function sendMessage() {
					var myDate = new Date();//获取系统当前时间
					var date = myDate.toLocaleString();
					var to = $("#sendto").text() == "全体成员"? "": $("#sendto").text(); //接受人
					if (webSocket != null)
						webSocket.send(JSON.stringify({
							message : {
								content : $('#sendMessageTextArea').val(),
								from : '${sessionScope.username}',
								to : to,      //接收人,如果没有则置空,如果有多个接收人则用,分隔
								time : date
							},
							type : "message"
						}));
					$('#sendMessageTextArea').val("");
				}
	/**
	* 添加接收人
	*/
	function addChat(user){
	 	var sendto = $("#sendto");
	 	var receive = sendto.text() == "全体成员" ? "" : sendto.text() + ",";
	   	if(receive.indexOf(user) == -1){    //排除重复
	    	sendto.text(receive + user);
       	}
   	}
	/**
     * 清空聊天区
     */
    function clearConsole(){
        $("#chat").html("");
    }
    /**
     * 连接
     */
    function getConnection() {
    	var target = 'ws://' + window.location.host + "/ws.chat/chat";
    	if (webSocket == null) {
    		webSocket = new WebSocket(target); //创建WebSocket对象
    		webSocket.onopen = function(evt) {
    			layer.msg("成功建立连接!", {
    				offset : 0
    			});
    		};
    		webSocket.onmessage = function(evt) {
    			analysisMessage(evt.data); //解析后台传回的消息,并予以展示
    		};
    		webSocket.onerror = function(evt) {
    			layer.msg("产生异常", {
    				offset : 0
    			});
    		};
    		webSocket.onclose = function(evt) {
    			layer.msg("已经关闭连接", {
    				offset : 0
    			});
    		};
    	} else {
    		layer.msg("连接已存在!", {
    			offset : 0,
    			shift : 6
    		});
    	}
    }

    /**
     * 关闭连接
     */
    function closeConnection() {
    	if (webSocket != null) {
    		webSocket.close();
    		webSocket = null;
    		$("#list").html(""); //清空在线列表
    		layer.msg("已经关闭连接", {
    			offset : 0
    		});
    	} else {
    		layer.msg("未开启连接", {
    			offset : 0,
    			shift : 6
    		});
    	}
    }

    /**
     * 检查连接
     */
    function checkConnection() {
    	if (webSocket != null) {
    		layer.msg(webSocket.readyState == 0 ? "连接异常" : "连接正常", {
    			offset : 0
    		});
    	} else {
    		layer.msg("连接未开启!", {
    			offset : 0,
    			shift : 6
    		});
    	}
    }
    /**
     * 消息快捷键
     *Ctrl+Enter
     */
    $(document).ready(  
    	    function(){  
    	        document.onkeydown = function()  
    	        {  
    	            var oEvent = window.event;  
    	            if (oEvent.keyCode == 13 && oEvent.ctrlKey) {  
    	            	sendMessage();
    	            }  
    	        }  
    	    }  
    	); 
</script>
</body>
</html>