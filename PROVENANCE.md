# Provenance

## Current Implementation

Beginning with version 2.0.0, `go-template-helper-mode` delegates Go template
action scanning and fontification to the public API in
`go-template-mode-font-lock.el` from `go-template-mode`:

- <https://codeberg.org/rch/go-template-mode>

The helper retains only minor-mode setup and calls the owner's public install
and uninstall functions.  The owner repository documents the language sources
and history of the shared implementation in its `PROVENANCE.md`.

## Versions Through 1.0.3

Versions through 1.0.3 contained a helper-local regular-expression matcher and
lists of selected Go template words.  The matcher and vocabulary closely
matched the implementation released as `go-template-mode` 1.0.0 under
helper-prefixed names, without its HTML tag tables.  Repository history does
not establish whether the helper copied an unpublished major-mode draft or
supplied code later used by that package.

The `go-template-mode` provenance notice documents the history of its matching
code: portions of version 1.0.0 were derived from a 2012 Go template mode Gist,
the Gist had no explicit copyright or license notice, and that implementation
used substantial code from Go's historical Emacs mode.  Historical helper
releases did not include that attribution.  Version 2.0.0 removes the
duplicated helper implementation rather than retaining compatibility aliases
for its private symbols.

## Scope of This Notice

This document records the helper's source history and implementation boundary.
The helper and owner repositories declare GPL-3.0-or-later; see `COPYING` in
each repository for those terms.  That declaration does not by itself establish
the license status of every historical component or retroactively resolve
distribution of earlier versions.  Historical tags, repository history, and
previously distributed artifacts remain separate provenance and compliance
questions.
