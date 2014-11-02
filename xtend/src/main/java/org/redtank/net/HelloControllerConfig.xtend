package org.redtank.net

import org.redtank.net.controller.HelloController
import org.springframework.context.annotation.ComponentScan
import org.springframework.context.annotation.Configuration
import org.springframework.web.servlet.config.annotation.EnableWebMvc

@Configuration
@EnableWebMvc
@ComponentScan(basePackageClasses=#[HelloController])
class HelloControllerConfig
{
}
