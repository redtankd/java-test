package org.redtank.red.message

/**
 * translate the object to the message
 * 
 * @author DENG Gangyi
 */
interface MessageEncoder<M>
{
	/**
 	 * encode the message
 	 */
	def <T> M encode(T object)
}
