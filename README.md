# Linux on Samsung Galaxy A50 (local workspace)

This directory records the working Ubuntu Touch / Halium setup for the Samsung
Galaxy A50 SM-A505F (`a50`). It is a small coordination repository around two
independent source repositories:

- [`a50-halium`](https://github.com/sadatdaniel/a50-halium) — kernel and build tooling;
- [`a50-ubuntu-touch`](https://github.com/sadatdaniel/a50-ubuntu-touch) — device configuration, overlay, installer, and port documentation.

## Recovery artifacts

Large local artifacts are under `release/` and are deliberately excluded from
normal Git history. Upload distributable ZIP files as GitHub Release assets.
See `release/README.md` before flashing anything.

The existing recovery-flashable ZIP is an older emergency installer. It was
built on 2026-10-12 and predates live fixes recorded on 2026-10-13. The exact
currently working phone installation is not preserved until `/data/ubuntu.img`
and the boot partition are captured from TWRP as described in
[`SAVE-WORKING-IMAGE.md`](SAVE-WORKING-IMAGE.md).

## Local-only inputs

`firmware/blobs/` contains proprietary Samsung firmware used for local kernel
rebuilds and must not be committed. Both directories under `sources/` retain
their own Git history and remotes, so they are also excluded from this wrapper
repository.

## What is safe to commit here

- recovery and backup instructions;
- local setup scripts;
- small rootfs patch files under `patches/`;
- release metadata and checksums (but not the large binary artifacts).

