package org.redtank.shell

import java.io.File
import org.apache.sshd.server.Command
import org.apache.sshd.server.SshServer
import org.apache.sshd.server.keyprovider.SimpleGeneratorHostKeyProvider

class SshShellServer
{
	int port

	String hostKeyFileName

	SshServer sshd

	def isRunning()
	{
		throw new UnsupportedOperationException(
			"TODO: auto-generated method stub")
	}

	def start()
	{
		sshd = SshServer.setUpDefaultServer()

		sshd.port = this.port
		sshd.keyPairProvider = new SimpleGeneratorHostKeyProvider(
			new File(hostKeyFileName))

		sshd.setPasswordAuthenticator [ u, p, s |
			true
		]
//		val userAuthFactories = new ArrayList<NamedFactory<UserAuth>>();
//		userAuthFactories.add(new UserAuthPassword());
//		getSshd.userAuthFactories = userAuthFactories
//		getSshd.passwordAuthenticator = [username, password, session|true]

		sshd.shellFactory = [|new SshShellThread(sshd) as Command]

		sshd.start();
	}

	def stop()
	{
		sshd.stop()
	}

	def static void main(String[] args)
	{
		val ssh = new SshShellServer()
		ssh.port = 8022
		ssh.hostKeyFileName = "var/hostkey.ser"
		ssh.start()
		
		while (! ssh.sshd.closed) {
			Thread.sleep(1000)
		}	
	}
}
