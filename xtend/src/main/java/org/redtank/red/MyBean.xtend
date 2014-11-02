package org.redtank.red

class MyBean
{
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
