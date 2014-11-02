package org.redtank.net.controller

import javax.servlet.http.HttpServletRequest
import org.springframework.stereotype.Controller
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestMethod
import org.springframework.web.bind.annotation.ResponseBody

@Controller
class HelloController
{

	// spring does not handle servlet path "/hello", so redirect "/hello" to "/hello/"
	// the servlet needs to be injected
	@RequestMapping()
	def String redirect(HttpServletRequest request)
	{

		//remove context path
		var str = request.requestURI.replace(request.contextPath, "")
		var String redirectPath

		// if context path is "/", the leading "/" can not be removed
		if (!str.startsWith("/"))
		{
			str = "/" + str
			redirectPath = "hello/"
		}
		else
		{
			redirectPath = "/hello/"
		}

		if (str == "/hello")
			return "redirect:" + redirectPath
		else
		{
			throw new RuntimeException()
		}
	}

	@RequestMapping(value="/", method=RequestMethod.GET)
	@ResponseBody
	def String hello(HttpServletRequest request)
	{
		"hello: the path is '" + request.requestURI + "'"
	}

	@RequestMapping(value="/s", method=RequestMethod.GET)
	@ResponseBody
	def String hello_s(HttpServletRequest request)
	{
		"hello_s: the path is '" + request.requestURI + "'"
	}
}
