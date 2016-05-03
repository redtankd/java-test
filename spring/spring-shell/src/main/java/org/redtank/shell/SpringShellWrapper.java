package org.redtank.shell;

import org.springframework.context.SmartLifecycle;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.shell.CommandLine;
import org.springframework.shell.core.CommandResult;
import org.springframework.shell.core.ExitShellRequest;
import org.springframework.shell.core.JLineShellComponent;

/**
 * see the member executeCommand(), executeShellCommandLine(), start()
 */
public class SpringShellWrapper implements SmartLifecycle
{
    public static void main(String[] args)
    {
	@SuppressWarnings("resource")
	AnnotationConfigApplicationContext ctx = new AnnotationConfigApplicationContext();

	SpringShellConfig.setArgs(args);
	ctx.register(SpringShellConfig.class);

	ctx.registerShutdownHook();
	ctx.refresh();

	SpringShellWrapper shellWrapper = ctx.getBean(SpringShellWrapper.class);
	ExitShellRequest exitShellRequest = shellWrapper
		.executeShellCommandLine();
	if (exitShellRequest != null)
	    System.exit(exitShellRequest.getExitCode());

	shellWrapper.start();
    }

    /**
     * <p>
     * Injected by container
     * <p>
     * the shell's command line, parsed from the java process's args.
     */
    protected CommandLine commandLine;

    /**
     * Injected by container
     */
    protected JLineShellComponent shell;

    /**
     * accepts command to execute. Even if the shell is not running
     * interactively, the shell may accept command
     * 
     * @param command
     *            one line of command
     * @return
     */
    public CommandResult executeCommand(String command)
    {
	return shell.executeCommand(command);
    }

    /**
     * executed the shell's command line arguments
     * 
     * @return <p>
     *         null, no command line arguments.
     *         <p>
     *         ExitShellRequest.FATAL_EXIT, executed wrongly
     *         <p>
     *         ExitShellRequest.NORMAL_EXIT, executed correctly
     */
    public ExitShellRequest executeShellCommandLine()
    {
	String[] shellCommandsToExecute = commandLine
		.getShellCommandsToExecute();
	ExitShellRequest exitShellRequest = null;

	if (null != shellCommandsToExecute)
	{// excecute the shell commands and the shell is running in the
	 // background
	    boolean successful = false;
	    exitShellRequest = ExitShellRequest.FATAL_EXIT;

	    for (String cmd : shellCommandsToExecute)
	    {
		successful = executeCommand(cmd).isSuccess();
		if (!successful)
		    break;
	    }

	    // if all commands were successful, set the normal exit status
	    if (successful)
	    {
		exitShellRequest = ExitShellRequest.NORMAL_EXIT;
	    }
	}

	return exitShellRequest;
    }

    @Override
    public int getPhase()
    {
	return 0;
    }

    @Override
    public boolean isAutoStartup()
    {
	return false;
    }

    @Override
    public boolean isRunning()
    {
	return shell.isRunning();
    }

    /**
     * start the interactive shell
     */
    @Override
    public void start()
    {
	shell.start();
    }

    @Override
    public void stop()
    {
	shell.stop();
    }

    @Override
    public void stop(Runnable callback)
    {
	stop();
	callback.run();
    }
}