package spring

import java.util.Collection
import org.springframework.boot.SpringApplication
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.context.ConfigurableApplicationContext
import org.springframework.context.annotation.Bean
import org.springframework.integration.annotation.Gateway
import org.springframework.integration.annotation.IntegrationComponentScan
import org.springframework.integration.annotation.MessagingGateway
import org.springframework.integration.dsl.IntegrationFlow
import org.springframework.integration.dsl.IntegrationFlows
import org.springframework.integration.dsl.channel.MessageChannels
import org.springframework.integration.dsl.core.Pollers
import org.springframework.messaging.MessageChannel

@SpringBootApplication
@IntegrationComponentScan
class Main {
	def static void main(String[] args) throws InterruptedException {
		val ConfigurableApplicationContext ctx = SpringApplication.run(typeof(Main), args);

//		val List<String> strings = Arrays.asList("foo", "bar");
//		System.out.println(ctx.getBean(typeof(Upcase)).upcase(strings));

		System.in.read()
		ctx.close();
	}

	@Bean
	def SessionManager sessionManager(ClientService clientService) {
		new SessionManager(clientService)
	}
	
	@MessagingGateway
	interface ClientService {
		@Gateway(requestChannel="clientServiceChannel")
		def void send(Collection<String> Message);
	}

	@Bean
	def MessageChannel clientServiceChannel() {
		MessageChannels.queue().get()
	}
	
	@Bean
	def IntegrationFlow clientServiceFlow() {
		IntegrationFlows
			.from(clientServiceChannel()) 
			.split [ ec | ec.poller(Pollers.fixedRate(1).receiveTimeout(1000)) ]
			.<String, String>transform [ toUpperCase ]
			.aggregate()
			.<Collection<String>>handle [ p, h |
				sessionManager(null).callbackFromGateway(p)
				null
			]
			.get()
	}
}
