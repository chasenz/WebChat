package com.ws.chat;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;

public class ChatMessage {
    /**
     * 组装返回给前台的消息
     * @param message   交互信息
     * @param type      信息类型
     * @param list      在线列表
     * @return
     */
    public String getJsonMessage(String message, String type, List list){
        JSONObject member = new JSONObject();
        member.put("message", message);
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
}
