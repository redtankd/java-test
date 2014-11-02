package org.redtank.red

import org.springframework.shell.Bootstrap
import org.springframework.util.StopWatch

class Main
{
	val private static sw = new StopWatch("Spring Shell");

	def static void main(String[] args)
	{
		Bootstrap.main(args)
//		var ExitShellRequest exitShellRequest;
//		try
//		{
//			val bootstrap = new Bootstrap(args);
//
//			val bean = bootstrap.applicationContext.getBean(NioSocketServer)
//
//			new EmbeddedChannel(new LoggingHandler).writeInbound("sasfsafasa")
//
//			exitShellRequest = bootstrap.run();
//
//			println("------asjfa")
//		}
//		catch (RuntimeException t)
//		{
//			throw t;
//		}
//		finally
//		{
//			HandlerUtils.flushAllHandlers(Logger.getLogger(""));
//		}
//
//		System.exit(exitShellRequest.getExitCode());
	}

}
