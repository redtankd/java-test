package org.redtank.red.net

import io.netty.channel.Channel
import java.util.HashMap
import org.redtank.red.message.MessageType
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.redtank.red.message.MessageDecoder

/**
 * @author DENG Gangyi
 */
class SessionManager
{
	static val Logger logger = LoggerFactory.getLogger(SessionManager)

	/**
	 * key: user's login name
	 * value: the net channel
	 */
	val sessions = new HashMap<String, Channel>
	
	@Property val messageDecoder = new HashMap<MessageType, MessageDecoder<String>>

	def Channel getChannel(String loginName)
	{
		return sessions.get(loginName)
	}

	def boolean isLogin(String loginName)
	{
		if(sessions.get(loginName) != null) true else false
	}

	def boolean login(String loginName, String password, Channel channel)
	{
		logger.debug("the user '{}' login successfully with password '{}'", loginName, password)
		sessions.put(loginName, channel)
		true
	}

	def void logout(String loginName)
	{
		sessions.remove(loginName)
	}
}
