package org.redtank.config;

import com.fasterxml.jackson.core.JsonFactory
import com.typesafe.config.ConfigFactory
import com.typesafe.config.ConfigParseOptions
import com.typesafe.config.ConfigRenderOptions
import com.typesafe.config.ConfigSyntax
import java.io.StringWriter
import org.eclipse.xtend.lib.annotations.Accessors

class Test
{
	def static void main(String[] args)
	{
		val hoconStringWriter = new StringWriter()

		val factory = new JsonFactory();
		val generator = factory.createGenerator(hoconStringWriter);
		val printer = new HOCONPrettyPrinter().setLinefeedIntentSize(4)
		generator.prettyPrinter = printer

		// start writing with {
		generator.writeStartObject();

		printer.writeComment(generator, "the node's name")
		generator.writeStringField("name", "TestServer");

		generator.writeObjectFieldStart("domain");
		{
			generator.writeStringField("name", "TestDomain");
			generator.writeObjectFieldStart("database");
			{
				generator.writeObjectFieldStart("online");
				{
					generator.writeStringField("url", "java.database")
					generator.writeStringField("user", "user")
					generator.writeStringField("password", "pass")
				}
				generator.writeEndObject();
			}
			generator.writeEndObject();
		}
		generator.writeEndObject();

		generator.writeArrayFieldStart("dataset");
		generator.writeStartObject();
		generator.writeStringField("album_title", "A.B.A.Y.A.M");
		generator.writeEndObject();
		generator.writeStartObject();
		generator.writeStringField("album_title", "A.B.A.Y.A.M");
		generator.writeEndObject();
		generator.writeString("ok")
		generator.writeString("ok")
		generator.writeEndArray();

		generator.writeArrayFieldStart("array");
		generator.writeString("ok")
		generator.writeString("ok")
		generator.writeEndArray();

		generator.writeEndObject();
		generator.close();

		println(hoconStringWriter.toString())
		println()

		val ccc = ConfigFactory.parseString(hoconStringWriter.toString(),
			ConfigParseOptions.defaults().setSyntax(ConfigSyntax.CONF))

		println(
			ccc.root.render(
				ConfigRenderOptions.defaults().setOriginComments(false)))
	}

	val static node = '''
		{
			# the node's name
			name : "TestServer",
			
			# the domain's envrionment
			domain : 
			{
				name : TestDomain,
				
				databases : {
					online : {
						url : "java.database",
						user: "user",
						password: "pass"
					}
					
					historydb : {
						url : "java.database",
						user: "user",
						password: "pass"
					}
				},
			}
		}
	'''
	
	@Accessors val test = "One"
}
