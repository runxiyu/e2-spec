# e2 language testing space

Many languages attempt to be "memory safe" by processes such as reference
counting, borrow checking, and mark-and-sweep garbage collection. These, for
the most part, are guided towards preventing programmer error that causes
use-after-frees, memory leaks, and similar conditions. We hereby refer to them
as "conventional memory safety features".

However, in most cases, languages other than assembly (including these allegedly
memory safe languages) do not handle stack overflows correctly;
although dynamic allocation failures could be easily handled, correctly-written
programs could crash when running out of stack space, with no method to detect
this condition and fail gracefully.

Conventional memory safety features are not our priority, but we may choose to
include them in the future, likely with reference counting while allowing weak
pointers to be labelled.

## General idea of how it should work

We haven't decided on general syntax yet. We generally prefer C-like syntax,
although syntax inspired from other languages are occasionally used when
appropriate; for example, multiple return values look rather awkward in the C
syntax, so perhaps we could use Go syntax for that (`func f(param1, param2)
(return1, return2)`), although we'd prefer naming parameters with `type
identifier` rather than `identifier type`.

For stack safety: When defining a function, the programmer must specify what to
do if the function could not be called (for example, if the stack is full). For
example, `malloc` for allocating dynamic memory would be structured something
like follows:

```e2
func malloc(size_t s) (void*) {
	/* What malloc is supposed to do */
	return ptr;
} onfail {
	return NULL;
}
```

If something causes `malloc` to be uncallable, e.g. if there is insufficient
stack space to hold its local variables, it simply returns NULL as if it failed.

Other functions may have different methods of failure. Some might return an
error, so it might be natural to set their error return value to something like
`ESTACK`:

```e2
func f() (err) {
	return NIL;
} onfail {
	return ESTACK;
}
```

The above lets us define how functions should fail due to insufficient stack.
This pattern is also useful outside of functions as a unit, therefore we
introduce the following syntax for generic stack failure handling:

```e2
try {
	/* Do something */
} onfail {
	/* Do something else, perhaps returning errors */
}
```

Note that the `onfail` block must not fail; therefore, the compiler must begin
to fail functions, whenever subroutines that those functions call have `onfail`
blocks that would be impossible to fulfill due to stack size constraints.

Functions can be marked as `nofail`, in either the function definition or when
calling it. A `nofail` specification when calling it overrides the function
definition.

```e2
nofail func free() () {
	/* What free is supposed to do */
}
```

This will ensure that calling `free` can never fail due to lack of stack space.
If such a case were to present itself, the compiler must make the caller fail
instead. This is recursive, and thus you cannot create a loop of `nofail` functions.
You may use `canfail` to be explicit about the reverse in function definitions,
or to override a function when calling it. In the latter case, if the function
does not define an `onfail` section, you must wrap it in a `try {...} onfail {...}`
block.
