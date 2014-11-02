package org.redtank.red.kernel

import io.netty.channel.embedded.EmbeddedChannel
import io.netty.handler.logging.LoggingHandler
import org.apache.commons.configuration.HierarchicalINIConfiguration
import org.apache.commons.configuration.tree.DefaultExpressionEngine
import org.springframework.context.annotation.AnnotationConfigApplicationContext

/**
 * @author DENG Gangyi
 * 
 */
class Main
{
	def static void main(String[] args)
	{
		val url = Thread.currentThread().contextClassLoader.
			getResource("node-roles.conf");
		val nodeRole = "MonitorServer1";
		val config = new HierarchicalINIConfiguration(url);
		( config.expressionEngine as DefaultExpressionEngine).propertyDelimiter = "/"
		val moduleList = config.getList(nodeRole.trim() + "/moduleList");

		val ctx = new AnnotationConfigApplicationContext();

		moduleList?.filter[
			toString().trim() != "Kernel" && toString().trim() != ""].forEach[
			ctx.register(
				Class.forName(
					"org.redtank.red.config." + toString().trim() + "Config"))]

		ctx.refresh();

		//		val bean = ctx.getBean(MyBean);
		//		bean.test();
		new EmbeddedChannel(new LoggingHandler).writeInbound("sasfsafasa")

	}

}
