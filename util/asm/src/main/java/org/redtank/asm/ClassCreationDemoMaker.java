package org.redtank.asm;

import static org.objectweb.asm.Opcodes.ACC_PRIVATE;
import static org.objectweb.asm.Opcodes.ACC_PUBLIC;
import static org.objectweb.asm.Opcodes.ACC_SUPER;
import static org.objectweb.asm.Opcodes.ALOAD;
import static org.objectweb.asm.Opcodes.ARETURN;
import static org.objectweb.asm.Opcodes.DUP;
import static org.objectweb.asm.Opcodes.GETFIELD;
import static org.objectweb.asm.Opcodes.ILOAD;
import static org.objectweb.asm.Opcodes.INVOKESPECIAL;
import static org.objectweb.asm.Opcodes.INVOKEVIRTUAL;
import static org.objectweb.asm.Opcodes.IRETURN;
import static org.objectweb.asm.Opcodes.NEW;
import static org.objectweb.asm.Opcodes.PUTFIELD;
import static org.objectweb.asm.Opcodes.RETURN;
import static org.objectweb.asm.Opcodes.V1_6;

import java.io.DataOutputStream;
import java.io.FileOutputStream;

import org.objectweb.asm.ClassWriter;
import org.objectweb.asm.FieldVisitor;
import org.objectweb.asm.MethodVisitor;

public class ClassCreationDemoMaker
{

    public static byte[] dump() throws Exception
    {
	// ClassWriter is a class visitor that generates the code for the class
	ClassWriter cw = new ClassWriter(0);
	FieldVisitor fv;
	MethodVisitor mv;
	// Start creating the class.
	cw.visit(V1_6, ACC_PUBLIC + ACC_SUPER,
		"org/redtank/asm/ClassCreationDemo", null, "java/lang/Object",
		null);

	{
	    // version field
	    fv = cw.visitField(ACC_PRIVATE, "version", "I", null, null);
	    fv.visitEnd();
	}
	{
	    // Implementing the constructor
	    mv = cw.visitMethod(ACC_PUBLIC, "<init>", "()V", null, null);
	    mv.visitCode();
	    mv.visitVarInsn(ALOAD, 0);
	    mv.visitMethodInsn(INVOKESPECIAL, "java/lang/Object", "<init>",
		    "()V");
	    mv.visitInsn(RETURN);
	    mv.visitMaxs(1, 1);
	    mv.visitEnd();
	}
	{
	    // getVersion Method
	    mv = cw.visitMethod(ACC_PUBLIC, "getVersion", "()I", null, null);
	    mv.visitCode();
	    mv.visitVarInsn(ALOAD, 0);
	    mv.visitFieldInsn(GETFIELD, "org/redtank/asm/ClassCreationDemo",
		    "version", "I");
	    mv.visitInsn(IRETURN);
	    mv.visitMaxs(1, 1);
	    mv.visitEnd();
	}
	{
	    // setVersion Method
	    mv = cw.visitMethod(ACC_PUBLIC, "setVersion", "(I)V", null, null);
	    mv.visitCode();
	    mv.visitVarInsn(ALOAD, 0);
	    mv.visitVarInsn(ILOAD, 1);
	    mv.visitFieldInsn(PUTFIELD, "org/retank/asm/ClassCreationDemo",
		    "version", "I");
	    mv.visitInsn(RETURN);
	    mv.visitMaxs(2, 2);
	    mv.visitEnd();
	}
	{
	    // toString method
	    mv = cw.visitMethod(ACC_PUBLIC, "toString", "()Ljava/lang/String;",
		    null, null);
	    mv.visitCode();
	    mv.visitTypeInsn(NEW, "java/lang/StringBuilder");
	    mv.visitInsn(DUP);
	    mv.visitLdcInsn("ClassCreationDemo: ");
	    mv.visitMethodInsn(INVOKESPECIAL, "java/lang/StringBuilder",
		    "<init>", "(Ljava/lang/String;)V");
	    mv.visitVarInsn(ALOAD, 0);
	    mv.visitFieldInsn(GETFIELD,
		    "com/geekyarticles/asm/ClassCreationDemo", "version", "I");
	    mv.visitMethodInsn(INVOKEVIRTUAL, "java/lang/StringBuilder",
		    "append", "(I)Ljava/lang/StringBuilder;");
	    mv.visitMethodInsn(INVOKEVIRTUAL, "java/lang/StringBuilder",
		    "toString", "()Ljava/lang/String;");
	    mv.visitInsn(ARETURN);
	    mv.visitMaxs(3, 1);
	    mv.visitEnd();
	}
	cw.visitEnd();

	return cw.toByteArray();
    }

    public static void main(String[] args) throws Exception
    {
	DataOutputStream dout = new DataOutputStream(new FileOutputStream(
		"ClassCreationDemo.class"));
	dout.write(dump());
	dout.flush();
	dout.close();
    }
}