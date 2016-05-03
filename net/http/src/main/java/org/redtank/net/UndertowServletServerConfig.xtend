package org.redtank.net

import io.undertow.Handlers
import io.undertow.Undertow
import io.undertow.server.handlers.PathHandler
import io.undertow.servlet.Servlets
import io.undertow.servlet.api.DeploymentManager
import io.undertow.servlet.api.InstanceHandle
import io.undertow.servlet.api.ServletInfo
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.context.ApplicationContext
import org.springframework.context.Lifecycle
import org.springframework.context.annotation.AnnotationConfigApplicationContext
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.web.context.support.AnnotationConfigWebApplicationContext
import org.springframework.web.servlet.DispatcherServlet
import org.springframework.context.SmartLifecycle
import org.redtank.net.controller.HelloControllerConfig

/**
 * <p>server() is the main bootstrap bean. 
 * <p>rootHandler() is the http handler for root path, which is registered to server().
 * <p>deployer() deploys the servlet context to the root handler  .
 * <p>servletContext() is a deployment for a servlet context handler.
 * <p>servletInfo() is the servlet definition, which is registered to servletContextDeployment().
 */
@Configuration
class UndertowServletServerConfig
{
	def static void main(String[] args)
	{
		val ctx = new AnnotationConfigApplicationContext();
		ctx.register(UndertowServletServerConfig)
		ctx.registerShutdownHook();
		ctx.refresh()
		ctx.start()
	}

	@Autowired
	private ApplicationContext applicationContext

	private String contextPath = "/app"

	/**
	 * <p>The main bootstrap bean, which is  the Lifecycle wrapper class for the Undertow server.  
	 * <p>When the spring context starts, the server starts. 
	 */
	@Bean
	def server()
	{
		new Lifecycle
		{
			boolean running = false

			Undertow server = (Undertow.builder() => [
				addHttpListener(8080, "localhost")
				setHandler(rootHandler())
			]).build()

			override isRunning()
			{
				running
			}

			override start()
			{
				if (running) return;
				server.start()
				running = true
			}

			override stop()
			{
				if (!running) return;
				server.stop()
				running = false
			}
		}
	}

	/**
	 * A http handler for the root path, which the servlet context handler is registered to. 
	 */
	@Bean
	def PathHandler rootHandler()
	{

		// Handlers.path（）create a new path handler, whose augment is the required default handler. 
		// The path "/" means default handler, which handles request without the matching handler. 
		// Our default handler is a RedirectHandler. 
		Handlers.path(
			Handlers.redirect(contextPath)
		)
	}

	/**
	 * deploy the servlet context to the root handler
	 */
	@Bean
	def deployer(Pair<String, DeploymentManager>[] deployment)
	{
		new SmartLifecycle
		{
			boolean running = false

			override isAutoStartup()
			{
				true
			}

			override stop(Runnable callback)
			{
				stop()
			}

			override isRunning()
			{
				running
			}

			override start()
			{
				if (running) return;

				// register the servlet context
				// if the path is "/", the default handler is replaced.
				deployment.forEach [
					value.deploy()
					rootHandler().addPrefixPath(key, value.start())
				]
			}

			override stop()
			{
				if (!running) return;

				deployment.forEach [
					rootHandler().removePrefixPath(key)
					value.stop()
					value.undeploy()
				]
			}

			override getPhase()
			{
				1
			}
		}
	}

	/**
	 * A Servlet Context Depolyment
	 * 
	 * ServletInfo beans are injected to servletContext().
	 */
	@Bean
	def Pair<String, DeploymentManager> servletContext(
		ServletInfo[] servletInfos)
	{
		contextPath -> Servlets.defaultContainer().addDeployment(
			Servlets.deployment() => [
				classLoader = UndertowServletServerConfig.getClassLoader()
				it.contextPath = this.contextPath
				deploymentName = this.contextPath
				addServlets(servletInfos)
			])
	}

	/**
	 * A Servlet definition
	 */
	@Bean
	def ServletInfo servletInfo()
	{
		Servlets.servlet("HelloServlet", DispatcherServlet) [ |
			// a factory is required to create customizable Servlet
			new InstanceHandle<DispatcherServlet>
			{
				private DispatcherServlet servlet = null

				override getInstance()
				{
					if (servlet == null)
						servlet = new DispatcherServlet(
							new AnnotationConfigWebApplicationContext() => [
								parent = UndertowServletServerConfig.this.
									applicationContext
								register(HelloControllerConfig)
							])
					servlet
				}

				override release()
				{
					servlet = null
				}
			}
		] => [
			addInitParam("dispatch", "Hello World")
			addMapping("/hello/*")
		]
	}
}
