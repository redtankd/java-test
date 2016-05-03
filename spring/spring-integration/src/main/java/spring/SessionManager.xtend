package spring

import java.util.Arrays
import java.util.Collection
import java.util.HashMap
import java.util.Map
import java.util.concurrent.Executors
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.Data
import org.springframework.context.SmartLifecycle
import spring.Main.ClientService

class SessionManager implements SmartLifecycle {
	@Accessors ClientService clientService;
	@Accessors Map<String, Session> sessionStore;

	var running = false;

	new(ClientService clientService) {
		this.clientService = clientService
		this.sessionStore = new HashMap
	}

	override isAutoStartup() {
		true
	}

	override isRunning() {
		running
	}

	override getPhase() {
		1
	}

	override start() {
		sessionStore.clear()
		
		Executors.newSingleThreadExecutor.execute [
			running = true;
			while (running) {
				clientService.send(Arrays.asList("foo", "bar"))
				Thread.sleep(1000)
			}
			println("exit connMgr")
		]
	}

	override stop(Runnable callback) {
		running = false
		callback.run()
	}

	override stop() {
		stop(null)
	}
	
	def sendToGateway() {
		clientService.send(Arrays.asList("foo", "bar"))
	}
	
	def callbackFromGateway(Collection<String> msg) {
		println(msg)
	}
}

@Data
class Session {
	String userName
	long sessionId
}

class TestClient {
	
}
