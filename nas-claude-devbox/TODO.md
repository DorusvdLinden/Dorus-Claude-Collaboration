# TODO

Rough items noticed while building this, not yet resolved.

- [ ] Verify Docker's data-root on the target NAS actually points at the
      storage pool volume, not a small system partition — a documented
      QNAP pitfall (extension installs failing on a 64MB `/tmp`) traces
      back to this class of misconfiguration.
- [ ] code-server defaults to the Open VSX registry, not the Microsoft
      Marketplace — some MS-published extensions may need manual `.vsix`
      sideloading if they're not on Open VSX.
- [ ] Confirm in practice that the first-boot manual login/trust step
      (README section 6) really is one-time — i.e. that it doesn't need
      repeating for every new worktree Remote Control spawns.
- [ ] Claude mobile app has a known upstream bug where closed Remote
      Control sessions linger in the session list with no bulk-clear
      option (anthropics/claude-code#50496) — not fixable from this
      project, just something to expect.
