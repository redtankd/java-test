package org.redtank.red.message

/**
 * translate the message to the object of the required type
 * 
 * @author DENG Gangyi
 */
interface MessageDecoder<M>
{
	/**
	 * decode the message
	 */
	def <T> T decode(M message, Class<T> requiredType)
}
