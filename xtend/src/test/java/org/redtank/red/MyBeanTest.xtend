package org.redtank.red;

import static org.junit.Assert.*;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

class MyBeanTest
{

	@Before
	def void setUp()
	throws Exception
    {
	}

	@After
	def void tearDown()
	throws Exception
    {
	}

	@Test
	def void test() {
		val bean = new MyBean("a")
		
		assertEquals("a", bean.name)
	}

}
