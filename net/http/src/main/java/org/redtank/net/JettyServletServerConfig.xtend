package org.redtank.net

import org.eclipse.jetty.server.Server
import org.eclipse.jetty.server.ServerConnector
import org.eclipse.jetty.server.handler.HandlerCollection
import org.eclipse.jetty.servlet.ServletContextHandler
import org.eclipse.jetty.servlet.ServletHolder
import org.eclipse.jetty.util.thread.QueuedThreadPool
import org.redtank.net.controller.HelloControllerConfig
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.context.ApplicationContext
import org.springframework.context.Lifecycle
import org.springframework.context.annotation.AnnotationConfigApplicationContext
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.web.context.support.AnnotationConfigWebApplicationContext
import org.springframework.web.servlet.DispatcherServlet

@Configuration
class JettyServletServerConfig
{
	def static void main(String[] args)
	{
		val ctx = new AnnotationConfigApplicationContext();
		ctx.register(JettyServletServerConfig)
		ctx.registerShutdownHook();
		ctx.refresh()
		ctx.start()
	}

	@Autowired
	private ApplicationContext applicationContext

	@Bean
	def serverLifecycle()
	{
		new Lifecycle()
		{
			private Server server = server()

			override isRunning()
			{
				server.running
			}

			override start()
			{
				server.start()
			}

			override stop()
			{
				server.stop()
			}
		}
	}

	@Bean
	def Server server()
	{
		new Server(createQueuedThreadPool()) => [
			connectors = createConnectors(it)
			handler = serverHandlers(null)
		]
	}

	def private createQueuedThreadPool()
	{
		new QueuedThreadPool() => [
			maxThreads = 10
			minThreads = 1
		]
	}

	def private createConnectors(Server server)
	{
		#[
			new ServerConnector(server) => [
				port = 8080
				idleTimeout = 30_0000
			]
		]
	}

	/**
	 * All Handler beans are injected to contextHandlerCollection().
	 */
	@Bean
	def HandlerCollection serverHandlers(ServletContextHandler[] handlers)
	{
		new HandlerCollection() => [
			it.handlers = handlers
		]
	}

	@Bean
	def ServletContextHandler ServletContextHandler()
	{
		new ServletContextHandler() => [
			contextPath = "/"
			addServlet(
				new ServletHolder("HelloServlet",
					new DispatcherServlet(
						new AnnotationConfigWebApplicationContext() => [
							parent = applicationContext
							register(HelloControllerConfig)
						])) => [
					initParameters.put("dispatch", "Hello World")
				],
				"/hello/*"
			)
		]
	}
}
