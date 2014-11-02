package org.redtank.red.message.commandline

import org.redtank.red.message.LoginMessage
import org.redtank.red.message.MessageConstants
import org.redtank.red.message.MessageDecoder
import org.redtank.red.message.MessageHead

class CommandLineDecoder implements MessageDecoder<String>
{
	override <T> T decode(String message, Class<T> requiredType)
	{
		message.doDecode(requiredType.newInstance) as T
	}

	def protected dispatch Object doDecode(String message, LoginMessage obj)
	{
		obj => [
			loginName = message.split(MessageConstants.MESSAGE_DELIMITER).get(1)
			password = message.split(MessageConstants.MESSAGE_DELIMITER).get(2)
		]
	}

	def protected dispatch Object doDecode(String message, MessageHead obj)
	{
		obj => [
			loginName = message.split(MessageConstants.MESSAGE_DELIMITER).get(1)
		]
	}
}
