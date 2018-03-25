package com.ws.chat;
import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageListener;
import javax.jms.TextMessage;
import javax.websocket.Session;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;


public class QueueMessageListener implements MessageListener {
	
    public void onMessage(Message _message) {
        TextMessage tm = (TextMessage) _message; //解析activemq的消息
        try {
            System.out.println("QueueMessageListener监听到了文本消息：\t"+ tm.getText());
            //分情况转发消息
            JSONObject chat = JSON.parseObject(tm.getText());
    		JSONObject message = JSON.parseObject(chat.get("message").toString()); //获取jason中message
            if(message.get("to") == null || message.get("to").equals("")){      //如果to为空,则广播;如果不为空,则对指定的用户发送消息
            	ChatServer.broadcast(tm.getText());
            }
            
            else{
                String [] userlist = message.get("to").toString().split(",");
                ChatServer.singleSend(tm.getText(), (Session) ChatServer.getSessionMap().get(message.get("from"))); //发送给自己
                for(String user : userlist){
                    if(!user.equals(message.get("from"))){
                    	ChatServer.singleSend(tm.getText(), (Session) ChatServer.getSessionMap().get(user));     //分别发送给每个指定用户
                    }
                }
            }
//            ChatServer.broadcast(tm.getText());
        } catch (JMSException e) {
            e.printStackTrace();
        }
    }
}
