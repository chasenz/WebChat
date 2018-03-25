package com.ws.chat;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;
import javax.jms.Destination;
import javax.servlet.http.HttpSession;
import javax.websocket.EndpointConfig;
import javax.websocket.OnClose;
import javax.websocket.OnError;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.socket.server.standard.SpringConfigurator;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.ws.chat.*;

@ServerEndpoint(value="/chat",configurator =  NewConfigurator.class)

public class ChatServer {
	public static List<Session> allSessions = new ArrayList<Session>(); //所以用户session
	public static List<String> userName = new ArrayList<String>(); //记录用户名称
	public static Map<String,Session> sessionMap = new HashMap<String,Session>();//用户名和websocket的session绑定的路由表
	
	private String getMsg; //Json的Messgae
	private String getJsonMsg; //Json字符串
	private String nickname; //获取用户名
	
    @Resource(name = "wsQueueDestination")
    private Destination destination;
    @Resource(name = "producerService")
    private ProducerService producer; 
    
	@OnOpen
	public void onOpen(Session session,EndpointConfig config) throws IOException{
		HttpSession httpSession= (HttpSession) config.getUserProperties().get(HttpSession.class.getName());
		this.nickname = (String)httpSession.getAttribute("username");
		System.out.println("username" + nickname);
		//添加List信息
		this.userName.add(this.nickname);
		sessionMap.put(nickname, session);
		allSessions.add(session);
		//广播消息
		this.getJsonMsg = getJsonMessage("欢迎用户" +this.nickname+ "进入聊天室！", "notice", userName);
		producer.sendMessage(destination,getJsonMsg);
	}
	
	@OnClose
	public void onClose(Session session){
		//删除List信息
		this.userName.remove(this.nickname);
		sessionMap.remove(nickname);
		allSessions.remove(session);
		// 广播消息
		this.getJsonMsg = getJsonMessage("用户" + this.nickname + "已经离开聊天室！", "notice", userName);
		producer.sendMessage(destination, getJsonMsg);
	}
	
	@OnMessage
	public void onMessage(String _message, Session session){
		JSONObject chat = JSON.parseObject(_message);
		JSONObject message = JSON.parseObject(chat.get("message").toString());
		System.out.println("Receive message:" + message.get("content").toString());
		//TODO: do activemq
		System.out.println("p:" + producer);
		producer.sendMessage(destination,_message);
	}
	
	@OnError
	public void onError(Session session, Throwable error){
		System.out.println("Error:" + error.getMessage());
	}
	
    /**
     * 将数据传回客户端
     * 异步的方式
     * @param myWebsocket
     * @param message
     */
    public static void broadcast(String message) {
		for (Session s : allSessions)
			try {
				s.getBasicRemote().sendText(message);
			} catch (IOException e) {
				e.printStackTrace();
			}
    }
    /**
     * 对特定用户发送消息
     * @param message
     * @param session
     */
    public static void singleSend(String message, Session session){
        try {
            session.getBasicRemote().sendText(message);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    /**
     * 组装返回给前台的消息
     * @param message   交互信息
     * @param type      信息类型
     * @param list      在线列表
     * @return
     */
    public String getJsonMessage(String message, String type, List list){
        JSONObject member = new JSONObject();
        JSONObject Jmessage = new JSONObject();
        Jmessage.put("content", message);
        Jmessage.put("from", "admin");
        member.put("message", Jmessage);
        member.put("type", type);
        member.put("list", list);
        return member.toString();
    }
    public String getMsg(String content,String from,String to){
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");  
        String time = sdf.format(new Date());
    	String message = "content:"+content+",from:"+from+",to:"+to+",time:"+time;
    	return message;
    }

	public static Map<String, Session> getSessionMap() {
		return sessionMap;
	}

	public static void setSessionMap(Map<String, Session> sessionMap) {
		ChatServer.sessionMap = sessionMap;
	}
    
}
