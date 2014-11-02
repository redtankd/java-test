package org.redtank.net

import io.netty.bootstrap.ServerBootstrap
import io.netty.channel.Channel
import io.netty.channel.ChannelHandler
import io.netty.channel.ChannelInitializer
import io.netty.channel.EventLoopGroup
import io.netty.channel.ServerChannel
import io.netty.channel.nio.NioEventLoopGroup
import io.netty.channel.socket.nio.NioServerSocketChannel
import java.util.LinkedHashMap
import org.springframework.context.Lifecycle

class NettyServer implements Lifecycle
{

	/**
	 * the service port
	 */
	@Property int port = 0

	@Property Class<? extends ServerChannel> channelClass = NioServerSocketChannel

	EventLoopGroup bossGroup
	EventLoopGroup workerGroup

	/**
	 * the tcp listening channel
	 */
	Channel channel = null

	/**
	 * the channel handlers for the server
	 * 
	 * key: the handler's name
	 * value: the channel handler.
	 */
	val handlers = new LinkedHashMap<String, ChannelHandler>

	def void addChannelHandler(String name, ChannelHandler channelHandler)
	{
		handlers.put(name, channelHandler)
	}

	def void clearChannelHandler()
	{
		handlers.clear()
	}

	override isRunning()
	{
		if (channel != null) channel.active else false
	}

	override void start()
	{
		if (channel != null) return;

		if (port <= 0) throw new RuntimeException("a negative port number")

		bossGroup = new NioEventLoopGroup();
		workerGroup = new NioEventLoopGroup();

		try
		{
			val ChannelInitializer<? extends Channel> channelInitializer = [ch|
				val pipeline = ch.pipeline();
				handlers.forEach[name, handler|
					pipeline.addLast(
						name,
						handler
					)]]

			channel = new ServerBootstrap().group(bossGroup, workerGroup).
				channel(channelClass).childHandler(channelInitializer).bind(port).
				sync().channel
		}
		catch (Exception e)
		{
			bossGroup.shutdownGracefully()
			bossGroup = null
			workerGroup.shutdownGracefully()
			workerGroup = null
			channel = null
			throw e
		}

	}

	override void stop()
	{
		try
		{
			channel.close()
			channel.closeFuture().sync();
		}
		finally
		{
			bossGroup.shutdownGracefully()
			bossGroup = null
			workerGroup.shutdownGracefully()
			workerGroup = null
			channel = null
		}
	}
}
