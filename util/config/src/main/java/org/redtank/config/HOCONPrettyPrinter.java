package org.redtank.config;

import java.io.*;
import java.util.Arrays;

import com.fasterxml.jackson.core.*;
import com.fasterxml.jackson.core.io.SerializedString;
import com.fasterxml.jackson.core.util.Instantiatable;

/**
 * A {@link PrettyPrinter} implementation that uses 4-space indentation with
 * platform-default linefeeds.
 */
@SuppressWarnings("serial")
public class HOCONPrettyPrinter implements PrettyPrinter,
		Instantiatable<HOCONPrettyPrinter>, java.io.Serializable {

	/**
	 * Constant that specifies default "root-level" separator to use between
	 * root values: a single space character.
	 * 
	 */
	public final static SerializedString DEFAULT_ROOT_VALUE_SEPARATOR = new SerializedString(
			"\n");

	/**
	 * Interface that defines objects that can produce indentation used to
	 * separate object entries and array values. Indentation in this context
	 * just means insertion of white space, independent of whether linefeeds are
	 * output.
	 */
	public interface Indenter {
		void writeIndentation(JsonGenerator jg, int level) throws IOException,
				JsonGenerationException;

		/**
		 * @return True if indenter is considered inline (does not add
		 *         linefeeds), false otherwise
		 */
		boolean isInline();
	}

	/***********************************************************
	 * Config, white spaces
	 */

	/**
	 * By default, let's use only spaces to separate array values.
	 */
	protected Indenter _arrayIndenter = FixedSpaceIndenter.instance;

	/**
	 * By default, let's use linefeed-adding indenter for separate object
	 * entries. We'll further configure indenter to use system-specific
	 * linefeeds, and 4 spaces per level (as opposed to, say, single tabs)
	 */
	protected Indenter _objectIndenter = LinefeedIndenter.instance;

	/**
	 * String printed between root-level values, if any.
	 */
	protected final SerializableString _rootSeparator;

	/**
	 * By default we will add spaces around colons used to separate object
	 * fields and values. If disabled, will not use spaces around colon.
	 */
	protected boolean _spacesInObjectEntries = true;

	/***********************************************************
	 * State:
	 */

	/**
	 * Number of open levels of nesting. Used to determine amount of indentation
	 * to use.
	 */
	protected transient int _nesting = 0;

	/***********************************************************
	 * Life-cycle (construct, configure)
	 * 
	 */

	public HOCONPrettyPrinter() {
		this(DEFAULT_ROOT_VALUE_SEPARATOR);
	}

	/**
	 * Constructor that specifies separator String to use between root values;
	 * if null, no separator is printed.
	 */
	public HOCONPrettyPrinter(String rootSeparator) {
		this((rootSeparator == null) ? null : new SerializedString(
				rootSeparator));
	}

	/**
	 * Constructor that specifies separator String to use between root values;
	 * if null, no separator is printed.
	 */
	public HOCONPrettyPrinter(SerializableString rootSeparator) {
		_rootSeparator = rootSeparator;
	}

	public HOCONPrettyPrinter(HOCONPrettyPrinter base) {
		this(base, base._rootSeparator);
	}

	public HOCONPrettyPrinter(HOCONPrettyPrinter base,
			SerializableString rootSeparator) {
		_arrayIndenter = base._arrayIndenter;
		_objectIndenter = base._objectIndenter;
		_spacesInObjectEntries = base._spacesInObjectEntries;
		_nesting = base._nesting;

		_rootSeparator = rootSeparator;
	}

	public HOCONPrettyPrinter withRootSeparator(SerializableString rootSeparator) {
		if (_rootSeparator == rootSeparator
				|| (rootSeparator != null && rootSeparator
						.equals(_rootSeparator))) {
			return this;
		}
		return new HOCONPrettyPrinter(this, rootSeparator);
	}

	public void indentArraysWith(Indenter i) {
		_arrayIndenter = (i == null) ? NopIndenter.instance : i;
	}

	public void indentObjectsWith(Indenter i) {
		_objectIndenter = (i == null) ? NopIndenter.instance : i;
	}

	public void spacesInObjectEntries(boolean b) {
		_spacesInObjectEntries = b;
	}

	public HOCONPrettyPrinter setLinefeedIntentSize(int size) {
		if (_objectIndenter instanceof LinefeedIndenter)
			((LinefeedIndenter) _objectIndenter).setIntentSize(size);
		return this;
	}

	/***********************************************************
	 * Instantiatable impl
	 */

	@Override
	public HOCONPrettyPrinter createInstance() {
		return new HOCONPrettyPrinter(this);
	}

	/***********************************************************
	 * PrettyPrinter impl
	 */

	@Override
	public void writeRootValueSeparator(JsonGenerator jg) throws IOException,
			JsonGenerationException {
		if (_rootSeparator != null) {
			jg.writeRaw(_rootSeparator);
		}
	}

	@Override
	public void writeStartObject(JsonGenerator jg) throws IOException,
			JsonGenerationException {
		if (_nesting > 0)
			_objectIndenter.writeIndentation(jg, _nesting);
		jg.writeRaw("{");
		if (!_objectIndenter.isInline()) {
			++_nesting;
		}
	}

	@Override
	public void beforeObjectEntries(JsonGenerator jg) throws IOException,
			JsonGenerationException {
		_objectIndenter.writeIndentation(jg, _nesting);
	}

	/**
	 * Method called after an object field has been output, but before the value
	 * is output.
	 * <p>
	 * Default handling (without pretty-printing) will output a single colon to
	 * separate the two. Pretty-printer is to output a colon as well, but can
	 * surround that with other (white-space) decoration.
	 */
	@Override
	public void writeObjectFieldValueSeparator(JsonGenerator jg)
			throws IOException, JsonGenerationException {
		if (_spacesInObjectEntries) {
			jg.writeRaw(" : ");
		} else {
			jg.writeRaw(':');
		}
	}

	/**
	 * Method called after an object entry (field:value) has been completely
	 * output, and before another value is to be output.
	 * <p>
	 * Default handling (without pretty-printing) will output a single comma to
	 * separate the two. Pretty-printer is to output a comma as well, but can
	 * surround that with other (white-space) decoration.
	 */
	@Override
	public void writeObjectEntrySeparator(JsonGenerator jg) throws IOException,
			JsonGenerationException {
		jg.writeRaw(",");
		_objectIndenter.writeIndentation(jg, _nesting);
	}

	@Override
	public void writeEndObject(JsonGenerator jg, int nrOfEntries)
			throws IOException, JsonGenerationException {
		if (!_objectIndenter.isInline()) {
			--_nesting;
		}
		if (nrOfEntries > 0) {
			_objectIndenter.writeIndentation(jg, _nesting);
		} else {
			jg.writeRaw(' ');
		}
		jg.writeRaw('}');
	}

	@Override
	public void writeStartArray(JsonGenerator jg) throws IOException,
			JsonGenerationException {
		_objectIndenter.writeIndentation(jg, _nesting);
		if (!_arrayIndenter.isInline()) {
			++_nesting;
		}
		jg.writeRaw('[');
	}

	@Override
	public void beforeArrayValues(JsonGenerator jg) throws IOException,
			JsonGenerationException {
		_arrayIndenter.writeIndentation(jg, _nesting);
	}

	/**
	 * Method called after an array value has been completely output, and before
	 * another value is to be output.
	 * <p>
	 * Default handling (without pretty-printing) will output a single comma to
	 * separate the two. Pretty-printer is to output a comma as well, but can
	 * surround that with other (white-space) decoration.
	 */
	@Override
	public void writeArrayValueSeparator(JsonGenerator jg) throws IOException,
			JsonGenerationException {
		jg.writeRaw(',');
		_arrayIndenter.writeIndentation(jg, _nesting);
	}

	@Override
	public void writeEndArray(JsonGenerator jg, int nrOfValues)
			throws IOException, JsonGenerationException {
		if (!_arrayIndenter.isInline()) {
			--_nesting;
		}
		if (nrOfValues > 0) {
			_arrayIndenter.writeIndentation(jg, _nesting);
		} else {
			jg.writeRaw(' ');
		}
		_objectIndenter.writeIndentation(jg, _nesting);
		jg.writeRaw("]");
	}

	public void writeComment(JsonGenerator jg, String comment)
			throws IOException, JsonGenerationException {
		_objectIndenter.writeIndentation(jg, _nesting);
		jg.writeRaw("# " + comment);
	}

	/**********************************************************
	 * Helper classes
	 */

	/**
	 * Dummy implementation that adds no indentation whatsoever
	 */
	public static class NopIndenter implements Indenter, java.io.Serializable {
		public static final NopIndenter instance = new NopIndenter();

		@Override
		public void writeIndentation(JsonGenerator jg, int level)
				throws IOException, JsonGenerationException {
		}

		@Override
		public boolean isInline() {
			return true;
		}
	}

	/**
	 * This is a very simple indenter that only every adds a single space for
	 * indentation. It is used as the default indenter for array values.
	 */
	public static class FixedSpaceIndenter extends NopIndenter {
		public static final FixedSpaceIndenter instance = new FixedSpaceIndenter();

		@Override
		public void writeIndentation(JsonGenerator jg, int level)
				throws IOException, JsonGenerationException {
			jg.writeRaw(' ');
		}

		@Override
		public boolean isInline() {
			return false;
		}
	}

	/**
	 * Default linefeed-based indenter uses system-specific linefeeds and spaces
	 * for indentation per level.
	 */
	public static class LinefeedIndenter extends NopIndenter {
		public static final LinefeedIndenter instance = new LinefeedIndenter();

		private final static String SYS_LF;
		static {
			String lf = null;
			try {
				lf = System.getProperty("line.separator");
			} catch (Throwable t) {
			} // access exception?
			SYS_LF = (lf == null) ? "\n" : lf;
		}

		final static int SPACE_COUNT = 64;
		final static char[] SPACES = new char[SPACE_COUNT];
		static {
			Arrays.fill(SPACES, ' ');
		}

		private int intentSize = 4;

		public LinefeedIndenter setIntentSize(int size) {
			this.intentSize = size;
			return this;
		}

		@Override
		public boolean isInline() {
			return false;
		}

		@Override
		public void writeIndentation(JsonGenerator jg, int level)
				throws IOException, JsonGenerationException {
			jg.writeRaw(SYS_LF);
			if (level > 0) { // should we err on negative values (as there's
								// some flaw?)
				level = level * intentSize;
				while (level > SPACE_COUNT) { // should never happen but...
					jg.writeRaw(SPACES, 0, SPACE_COUNT);
					level -= SPACES.length;
				}
				jg.writeRaw(SPACES, 0, level);
			}
		}
	}
}