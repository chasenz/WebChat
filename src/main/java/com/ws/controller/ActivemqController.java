package com.ws.controller;

import java.text.SimpleDateFormat;
import java.util.Date;

import javax.annotation.Resource;
import javax.servlet.http.HttpSession;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.ws.chat.*;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.annotation.Resource;
import javax.jms.Destination;
import javax.jms.TextMessage;

/**
 * 
 * @description controller测试
 */
@Controller
@RequestMapping("/activemq")
public class ActivemqController {
    @Resource(name = "wsQueueDestination")
    private Destination destination;

    
    @Resource(name = "producerService")
    private ProducerService producer;
    
	@RequestMapping("topicSender")//队列消息生产者
	public String queueSender(@RequestParam("message")String message,HttpSession session){
		String op="scc";
		System.out.println("activemqController 发送成功:"+message);
		producer.sendMessage(message);
		return op;
	}
}
