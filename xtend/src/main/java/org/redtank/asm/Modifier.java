package org.redtank.asm;

import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.HashMap;

public class Modifier
{
    public static void main(String[] args) throws InstantiationException,
	    IllegalAccessException, ClassNotFoundException,
	    NoSuchMethodException, SecurityException, IllegalArgumentException,
	    InvocationTargetException
    {
	testMethod();
    }

    private static void testMethod() throws NoSuchMethodException,
	    SecurityException, IllegalAccessException,
	    IllegalArgumentException, InvocationTargetException
    {
	HashMap<Integer, Method> ms = new HashMap<Integer, Method>();

	Field[] fs = TestBean.class.getDeclaredFields();
	for (Field f : fs)
	{
	    if (f.isAnnotationPresent(ImixFieldTag.class))
	    {
		ImixFieldTag ann = f.getAnnotation(ImixFieldTag.class);
		int tag = ann.value();
		String mn = "set" + f.getName().substring(0, 1).toUpperCase()
			+ f.getName().substring(1);
		ms.put(Integer.valueOf(tag), TestBean.class.getMethod(mn,
			new Class<?>[] { int.class }));
	    }
	}

	TestBean a = new TestBean();

	long start = System.currentTimeMillis();
	for (int i = 0; i < 1_0000_0000; i++)
	{
	    a.setField(0);
	}
	System.out.println(System.currentTimeMillis() - start);

	start = System.currentTimeMillis();
	for (int i = 0; i < 1_0000_0000; i++)
	{
	    ms.get(23).invoke(a, 1);
	}
	System.out.println(System.currentTimeMillis() - start);

	System.out.println(a.getField());
    }

    @SuppressWarnings("unused")
    private static void testNewInstance() throws InstantiationException,
	    IllegalAccessException
    {
	HashMap<Integer, TestBean> h = new HashMap<>();

	long start = System.currentTimeMillis();
	for (int i = 0; i < 100_0000; i++)
	{
	    TestBean a = new TestBean();
	    h.put(Integer.valueOf(i), a);
	}
	System.out.println(System.currentTimeMillis() - start);

	HashMap<Integer, TestBean> h1 = new HashMap<>();

	start = System.currentTimeMillis();
	for (int i = 0; i < 100_0000; i++)
	{
	    TestBean a = TestBean.class.newInstance();
	    h1.put(Integer.valueOf(i), a);
	}
	System.out.println(System.currentTimeMillis() - start);
    }
}
