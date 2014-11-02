package org.redtank.red.net

import io.netty.channel.ChannelHandler
import io.netty.channel.ChannelHandlerContext
import io.netty.channel.SimpleChannelInboundHandler
import java.net.InetSocketAddress
import java.util.HashMap
import org.redtank.red.message.LoginMessage
import org.redtank.red.message.MessageDecoder
import org.redtank.red.message.MessageType
import org.slf4j.Logger
import org.slf4j.LoggerFactory

import static org.redtank.red.message.MessageConstants.*
import static org.redtank.red.message.MessageType.*
import org.redtank.red.message.MessageHead

/**
 * Message format:
 *   <message type><SOH><message>
 * 
 * login message
 *   LOGIN<SOH><userId><SOH><password>
 * 
 * logout message
 *   LOGOUT<SOH><userId><SOH><token>
 */
@ChannelHandler.Sharable
class StringMessageHandler extends SimpleChannelInboundHandler<String>
{
	static val Logger logger = LoggerFactory.getLogger(StringMessageHandler)

	@Property SessionManager sessionManager;

	@Property val messageDecoder = new HashMap<MessageType, MessageDecoder<String>>

	/**
 	 * 
 	 */
	override void channelActive(ChannelHandlerContext ctx)
	{
		logger.info("connected from " + (ctx.channel.remoteAddress as InetSocketAddress).address)
	}

	override void channelRead0(ChannelHandlerContext ctx, String request)
	{
		val String response = switch request
		{
			case request.startsWith(CMD.toString):
			{
			}
			case request.startsWith(JSON.toString):
			{
			}
			case request.startsWith(IMIX.toString):
			{
			}
			default:
			{
				val request1 = CMD + MESSAGE_DELIMITER + request
				val messageHead = messageDecoder.get(CMD).decode(request1, MessageHead)

				if(sessionManager.isLogin(messageHead.loginName))
					"Command Done!\n"
				else
				{
					val loginMessage = messageDecoder.get(CMD).decode(request1, LoginMessage)
					if(loginMessage != null)
					{
						sessionManager.login(loginMessage.loginName, loginMessage.password,
							ctx.channel)
						"Login OK\n"
					}
					else
						"Login Failed\n"
				}
			}
		}

		// We do not need to write a ChannelBuffer here.
		// We know the encoder inserted at TelnetPipelineFactory will do the conversion.
		val future = ctx.write(response);

		// Close the connection after sending 'Have a good day!'
		// if the client has sent 'bye'.
		//			if(close)
		//			{
		//				future.addListener(ChannelFutureListener.CLOSE);
		//			}
		}

		override void exceptionCaught(ChannelHandlerContext ctx, Throwable cause)
		{
			logger.warn("Unexpected exception from downstream.", cause);

		}
	}
	