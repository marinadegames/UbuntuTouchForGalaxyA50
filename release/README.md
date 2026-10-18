# Local recovery artifacts

## `ubuntu-touch-a50-server-patched-2026-10-12.zip`

A valid TWRP-flashable installer containing a rootfs image and a boot image.
The ZIP passed `unzip -t` on 2026-10-18.

Important: this installer predates the live fixes listed in
`../RECOVERY-2026-10-13.md`. Keep it as an emergency installer, not as an exact
gold image of the currently working phone.

In TWRP: **Install → select the ZIP → swipe → Reboot System**.

## `boot-aa13-usb-configfs.img`

The newer standalone boot image built on 2026-10-13. It is not a complete
system installer and does not contain `/data/ubuntu.img`.

## Exact gold image still required

Follow `../SAVE-WORKING-IMAGE.md` while the phone is in TWRP. A true recovery
set must contain:

- `ubuntu.img.gz` copied from `/data/ubuntu.img`;
- `boot.img` copied from the BOOT partition;
- `SHA256SUMS` verified after capture.

Do not commit these large files to normal Git history. Store a second copy on
another disk and publish a distributable installer, if desired, as a GitHub
Release asset.

