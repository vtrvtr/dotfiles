"""LLDB summary provider for `compact_str::CompactString`.

Repr is three words: a pointer, a usize, then u32/u16/u8/u8. The final byte is
the discriminant: < 192 means the string is inline and that byte is the last
UTF-8 byte; 192..=216 encodes an inline length as `byte - 192`; 216 is heap
(pointer + len in the first two words); 217 is a `&'static str`.
"""

HEAP_MASK = 216
STATIC_MASK = 217
LENGTH_MASK = 192
MAX_SIZE = 24


def _read(process, addr, size):
    err = __import__("lldb").SBError()
    data = process.ReadMemory(addr, size, err)
    return data if err.Success() else None


def compact_string_summary(valobj, _internal_dict):
    # The Repr is the only field, so it starts where CompactString starts. Read
    # the address off the value itself: a synthetic provider hides the child.
    addr = valobj.GetLoadAddress()
    process = valobj.GetProcess()
    if addr == __import__("lldb").LLDB_INVALID_ADDRESS or not process.IsValid():
        return "<unavailable>"

    raw = _read(process, addr, MAX_SIZE)
    if raw is None:
        return "<unreadable>"

    last = raw[MAX_SIZE - 1]

    if last in (HEAP_MASK, STATIC_MASK):
        ptr = int.from_bytes(raw[0:8], "little")
        length = int.from_bytes(raw[8:16], "little")
        if length == 0:
            return '""'
        body = _read(process, ptr, length)
        if body is None:
            return "<unreadable heap>"
        return '"%s"' % body.decode("utf-8", "replace")

    length = min(last - LENGTH_MASK, MAX_SIZE) if last >= LENGTH_MASK else MAX_SIZE
    return '"%s"' % raw[:length].decode("utf-8", "replace")


def __lldb_init_module(debugger, _internal_dict):
    # No `-e`: the summary is the whole story, and expanding the children just
    # shows the raw Repr words the summary exists to hide.
    debugger.HandleCommand(
        "type summary add -F compact_str.compact_string_summary -x "
        '"^compact_str::CompactString$" --category Rust'
    )
    debugger.HandleCommand(
        'type synthetic add -x "^compact_str::CompactString$" --category Rust '
        "-l compact_str.CompactStringSynth"
    )
    debugger.HandleCommand("type category enable Rust")


class CompactStringSynth:
    """Hide the Repr internals: the summary already shows the string."""

    def __init__(self, valobj, _internal_dict):
        self.valobj = valobj

    def num_children(self):
        return 0

    def get_child_index(self, _name):
        return None

    def get_child_at_index(self, _index):
        return None

    def update(self):
        return True

    def has_children(self):
        return False
