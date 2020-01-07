#!/usr/bin/env python
import gi

# Must come before other imports
gi.require_version("Gtk", "3.0")  # NOQA

from gi.repository import Gtk, Gdk


def print_possible_clipboard_types():
    '''
    Print possible clipboard types

    Stolen from
    https://stackoverflow.com/questions/3571179/how-does-x11-clipboard-handle-multiple-data-formats

    See also https://freedesktop.org/wiki/Specifications/ClipboardsWiki/
    '''
    print(
        *Gtk.Clipboard.get(
            Gdk.atom_intern("CLIPBOARD", True)
        ).wait_for_targets()[1], sep="\n")


if __name__ == '__main__':
    print_possible_clipboard_types()
