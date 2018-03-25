package com.ws.controller;

import javax.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("login")
public class LoginController {
	@RequestMapping("/userLogin")
	public String login(String username,String password,HttpSession session){
		System.out.println("u:"+username+"pwd:"+password);
		//TODO:数据库验证
		session.setAttribute("username", username);
		return "index";
	}
}
