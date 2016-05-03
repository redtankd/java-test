package org.redtank.red

import org.eclipse.xtend.lib.annotations.Accessors

class MyBean
{
	@Accessors
	protected var String name;

	new()
	{
	}

	new(String name)
	{
		this.name = name
	}

	def void test()
	{
		println("------------test-" + name);
	}

}
