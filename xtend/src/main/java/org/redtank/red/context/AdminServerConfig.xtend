package org.redtank.red.context;

import org.redtank.red.MyBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * 
 * @author DENG Gangyi
 * 
 */
@Configuration
class AdminServerConfig
{
    @Bean
    def MyBean bean()
    {
		new MyBean("Admin")
    }

}
