package org.redtank.net

import io.netty.handler.codec.DelimiterBasedFrameDecoder
import io.netty.handler.codec.Delimiters
import io.netty.handler.codec.string.StringDecoder
import io.netty.handler.codec.string.StringEncoder
import org.redtank.red.message.MessageType
import org.redtank.red.message.commandline.CommandLineDecoder
import org.redtank.red.net.SessionManager
import org.redtank.red.net.StringMessageHandler
import org.springframework.context.annotation.AnnotationConfigApplicationContext
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

/**
 * 
 * @author DENG Gangyi
 * 
 */
@Configuration
class NettyServerConfig
{
	def static void main(String[] args)
	{
		val ctx = new AnnotationConfigApplicationContext();
		ctx.register(NettyServerConfig)
		ctx.registerShutdownHook();
		ctx.refresh()
		ctx.start()
	}

	@Bean
	def NettyServer telnetServer()
	{
		new NettyServer() => [
			addChannelHandler("framer",
				new DelimiterBasedFrameDecoder(8192, Delimiters.lineDelimiter()))
			addChannelHandler("decoder", new StringDecoder)
			addChannelHandler("encoder", new StringEncoder)
			addChannelHandler("handler",
				new StringMessageHandler => [
					sessionManager = new SessionManager
					messageDecoder.put(MessageType.CMD, new CommandLineDecoder)
				])
			port = 8080
		]
	}

}
