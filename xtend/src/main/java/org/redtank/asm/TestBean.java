package org.redtank.asm;

public class TestBean
{
    @ImixFieldTag(23)
    private int field;

    public int getField()
    {
	return field;
    }

    public void setField(int field)
    {
	this.field = field;
    }
}
