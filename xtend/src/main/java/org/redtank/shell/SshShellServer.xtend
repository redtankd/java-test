package org.redtank.shell

import java.util.ArrayList
import org.apache.sshd.SshServer
import org.apache.sshd.common.NamedFactory
import org.apache.sshd.server.Command
import org.apache.sshd.server.UserAuth
import org.apache.sshd.server.auth.UserAuthPassword
import org.apache.sshd.server.keyprovider.SimpleGeneratorHostKeyProvider
import org.springframework.context.Lifecycle

class SshShellServer implements Lifecycle
{
	@Property
	int port

	@Property
	String hostKeyFileName

	@Property
	SshServer sshd

	override isRunning()
	{
		throw new UnsupportedOperationException(
			"TODO: auto-generated method stub")
	}

	override start()
	{
		sshd = SshServer.setUpDefaultServer()

		getSshd.port = this.getPort
		getSshd.keyPairProvider = new SimpleGeneratorHostKeyProvider(
			getHostKeyFileName)

		// only password authentication
		val userAuthFactories = new ArrayList<NamedFactory<UserAuth>>();
		userAuthFactories.add(typeof(UserAuthPassword.Factory).newInstance);
		getSshd.userAuthFactories = userAuthFactories
		getSshd.passwordAuthenticator = [username, password, session|true]

		getSshd.shellFactory = [|new SshShellThread(sshd) as Command]

		getSshd.start();
	}

	override stop()
	{
		sshd.stop()
	}

	def static void main(String[] args)
	{
		val ssh = new SshShellServer()
		ssh.port = 8022
		ssh.hostKeyFileName = "var/hostkey.ser"
		ssh.start()
	}
}
