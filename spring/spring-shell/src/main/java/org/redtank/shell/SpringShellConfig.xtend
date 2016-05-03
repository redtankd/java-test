package org.redtank.shell

import java.io.IOException
import org.springframework.beans.BeansException
import org.springframework.context.ApplicationContext
import org.springframework.context.ApplicationContextAware
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.ClassPathBeanDefinitionScanner
import org.springframework.context.annotation.ComponentScan
import org.springframework.context.annotation.Configuration
import org.springframework.context.support.GenericApplicationContext
import org.springframework.shell.ShellException
import org.springframework.shell.SimpleShellCommandLineOptions
import org.springframework.shell.converters.AvailableCommandsConverter
import org.springframework.shell.converters.BigDecimalConverter
import org.springframework.shell.converters.BigIntegerConverter
import org.springframework.shell.converters.BooleanConverter
import org.springframework.shell.converters.CharacterConverter
import org.springframework.shell.converters.DateConverter
import org.springframework.shell.converters.DoubleConverter
import org.springframework.shell.converters.EnumConverter
import org.springframework.shell.converters.FloatConverter
import org.springframework.shell.converters.IntegerConverter
import org.springframework.shell.converters.LocaleConverter
import org.springframework.shell.converters.LongConverter
import org.springframework.shell.converters.ShortConverter
import org.springframework.shell.converters.SimpleFileConverter
import org.springframework.shell.converters.StaticFieldConverterImpl
import org.springframework.shell.converters.StringConverter
import org.springframework.shell.core.JLineShellComponent

/**
 * <p>If the shell's command line arguments need to be executed, passes 
 * the command line arguments to <code>setArgs(String[])</code> before 
 * register <code>SpringShellConfig</code> to ApplicationContext. 
 * <p>A <code>GenericApplicationContext</code> is required.
 */
@Configuration
@ComponentScan(#["org.springframework.shell.converters",
	"org.springframework.shell.plugin.support"])
class SpringShellConfig implements ApplicationContextAware
{

	/**
     * the shell's command line arguments
     */
	private static String[] args = null

	static def void setArgs(String[] _args)
	{
		args = _args
	}

	private GenericApplicationContext applicationContext

	override setApplicationContext(ApplicationContext applicationContext)
	throws BeansException {
		this.applicationContext = applicationContext as GenericApplicationContext
	}

	@Bean
	def commandLine()
	{
		try
		{
			val commandLine = SimpleShellCommandLineOptions.
				parseCommandLine(args)

			if (! commandLine.disableInternalCommands)
				new ClassPathBeanDefinitionScanner(applicationContext).scan(
					"org.springframework.shell.commands")

			return commandLine
		}
		catch (IOException e)
		{
			throw new ShellException(e);
		}
	}

	@Bean
	def shell()
	{
		new JLineShellComponent()
	}

	@Bean
	def springShellWrapper()
	{
		val wrapper = new SpringShellWrapper()
		wrapper.commandLine = commandLine()
		wrapper.shell = shell()
		return wrapper
	}

	@Bean
	def stringConverter()
	{
		new StringConverter()
	}

	@Bean
	def bigDecimalConverter()
	{
		new BigDecimalConverter
	}

	@Bean
	def bigIntegerConverter()
	{
		new BigIntegerConverter
	}

	@Bean
	def booleanConverter()
	{
		new BooleanConverter()
	}

	@Bean
	def characterConverter()
	{
		new CharacterConverter()
	}

	@Bean
	def dateConverter()
	{
		new DateConverter()
	}

	@Bean
	def doubleConverter()
	{
		new DoubleConverter()
	}

	@Bean
	def enumConverter()
	{
		new EnumConverter()
	}

	@Bean
	def floatConverter()
	{
		new FloatConverter()
	}

	@Bean
	def integerConverter()
	{
		new IntegerConverter()
	}

	@Bean
	def localeConverter()
	{
		new LocaleConverter()
	}

	@Bean
	def longConverter()
	{
		new LongConverter()
	}

	@Bean
	def shortConverter()
	{
		new ShortConverter()
	}

	@Bean
	def staticFieldConverterImpl()
	{
		new StaticFieldConverterImpl()
	}

	@Bean
	def simpleFileConverter()
	{
		new SimpleFileConverter()
	}

	@Bean
	def availableCommandsConverter()
	{
		new AvailableCommandsConverter
	}
}
