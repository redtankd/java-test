package org.redtank.shell

import java.io.IOException
import java.io.InputStream
import java.io.OutputStream
import org.apache.sshd.SshServer
import org.apache.sshd.server.Command
import org.apache.sshd.server.Environment
import org.apache.sshd.server.ExitCallback
import org.slf4j.LoggerFactory

/**
 * the Shell thread
 */
class SshShellThread implements Command, Runnable
{
	private static val logger = LoggerFactory.getLogger(SshShellThread)

	private static val char CR = '\r'

	private static val char LF = '\n'

	private String shellPrompt

	private InputStream in;

	private OutputStream out;

	private OutputStream err;

	private ExitCallback callback;

	private SshServer sshd

	private Thread thread;

	new(SshServer sshd)
	{
		this(sshd, "Shell>")
	}

	new(SshServer sshd, String shellPrompt)
	{
		this.sshd = sshd
		this.shellPrompt = shellPrompt
	}

	override start(Environment env)
	throws IOException {
		thread = new Thread(this, SshShellThread.name);
		thread.start();
	}

	override destroy()
	{
	}

	override void run()
	{
		try
		{
			logger.debug("a new shell begins.")
			var int ch
			var StringBuffer buffer = new StringBuffer()
			out.write(shellPrompt.getBytes());
			out.flush();

			while ((ch = in.read()) > 0)
			{
				if (CR != ch as char)
				{ // a normal char
					logger.debug("read a new character: {}({}).", ch as char, ch)
					out.write(ch);
					out.flush();
					buffer.append(ch as char);
				}
				else
				{ // read a CR, so a command is got
					out.write(CR);
					out.write(LF);
					out.flush();
					val line = buffer?.toString();
					logger.debug("the command is '{}'.", line)

					if (line.trim().equalsIgnoreCase("exit"))
					{
						out.write("Bye!".bytes)
						out.write(CR);
						out.write(LF);
						out.flush();
						return
					}

					if (line.trim().equalsIgnoreCase("shutdown"))
					{
						out.write("the remote server is shutdown!".bytes)
						out.write(CR)
						out.write(LF)
						out.flush()
						sshd.stop()
						return
					}

					out.write(line.getBytes());
					out.write(CR);
					out.write(LF);

					// the next command
					out.write(shellPrompt.getBytes());
					out.flush();
					buffer = new StringBuffer()
				}
			}
		}
		catch (IOException e)
		{
			logger.error("the shell is closed because of an exception.", e)
			return;
		}
		finally
		{
			logger.debug("the shell is closed.")
			callback.onExit(0);
		}
	}

	override setExitCallback(ExitCallback callback)
	{
		this.callback = callback
	}

	override setInputStream(InputStream in)
	{
		this.in = in
	}

	override setOutputStream(OutputStream out)
	{
		this.out = out
	}

	override setErrorStream(OutputStream err)
	{
		this.err = err
	}
}
