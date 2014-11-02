package org.redtank.net

import io.undertow.Undertow
import io.undertow.io.IoCallback
import io.undertow.io.Sender
import io.undertow.server.HttpHandler
import io.undertow.server.HttpServerExchange
import io.undertow.util.Headers
import java.io.IOException
import org.springframework.context.Lifecycle
import org.springframework.context.annotation.AnnotationConfigApplicationContext
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

/**
 * 
 */
@Configuration
class UndertowHttpServerConfig
{
	def static void main(String[] args)
	{
		val ctx = new AnnotationConfigApplicationContext();
		ctx.register(UndertowHttpServerConfig)
		ctx.registerShutdownHook();
		ctx.refresh()
		ctx.start()
	}

	@Bean
	def server()
	{
		new Lifecycle
		{
			Undertow server = (Undertow.builder() => [
				addHttpListener(8080, "localhost")
				ioThreads = 2
				workerThreads = 2
				setHandler(rootHandler())
			]).build()

			boolean running = false

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

	@Bean
	def HttpHandler rootHandler()
	{
		[
			if (inIoThread)
			{ // the io thread could not be blocked, so the handler is dispatched to a worker thread.
				dispatch(self);
				return;
			}
			// the handler is rerun in a worker thread 
			responseHeaders.put(Headers.CONTENT_TYPE, "text/plain")
			startBlocking() // change the non-blocking HttpExchange to a blocking wrapper
			// if not blocking, send() is non-blocking
			responseSender.send("UndertowHttpServer: Hello World\n",
				DoNothingIoCallBack.instance) //
			httpNextHandler().handleRequest(it)
		]
	}

	@Bean
	def HttpHandler httpNextHandler()
	{
		[
			// automatically end the HttpExchange
			// if more responses need to be write, try the IoCallBack version send()
			responseSender.send("UndertowHttpServer: Hello World again")
		]
	}
}

class DoNothingIoCallBack implements IoCallback
{
	override onComplete(HttpServerExchange exchange, Sender sender)
	{
	}

	override onException(HttpServerExchange exchange, Sender sender,
		IOException exception)
	{
	}

	val public static IoCallback instance = new DoNothingIoCallBack
}
