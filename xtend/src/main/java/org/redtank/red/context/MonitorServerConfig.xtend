package org.redtank.red.context

import org.springframework.context.annotation.Configuration
import org.springframework.context.annotation.Bean
import org.redtank.red.MyBean

/**
 * 
 * @author DENG Gangyi
 * 
 */
@Configuration
class MonitorServerConfig
{
	@Bean
	def MyBean bean()
	{
		new MyBean("Monitor")
	}
}
