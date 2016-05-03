package spring;

import java.util.concurrent.Executors;

import org.springframework.integration.dsl.channel.MessageChannels;
import org.springframework.messaging.MessageChannel;

public class MainHelper {
	
	public static MessageChannel publishSubscribe() {
		return MessageChannels.executor(Executors.newFixedThreadPool(1)).get();
	}
}
