# Gitpod Local Companion CI Builder

Andrei Jiroh maintains an fork of Gitpod in GitLab SaaS with tweaks to Gitpod workspace configuration and even uses GitLab CI behind the scenes.

## Meta

* Status: Experimental, not part of either Gitpodify project or Recap Time Squad OSS projects
* Canonical repo: <https://gitlab.com/ajhalili2006-experiments/gp-localapp-glci-builder>, with read-only mirrors at <https://github.com/ajhalili2006/gp-localapp-glci-builder>.
* License: Mixed, since it's forked from <https://github.com/gitpod-io/gitpod>, usually either MIT or AGPL. Small portions of the code contains Gitpod GmbH's custom license for EE-only code.

## Supported arches

We target our builds at mostly Linux-based machines supported on our build systems and available at `gp-localapp.pkgs.rtapp.tk` (through Storj DCS).

```bash
# Mostly supported by our CI builds, based on components/local-app/BUILD.yaml
linux/386
linux/amd64
linux/arm
linux/arm64
# Technically supported by the golang compilier, though we don't
# have builds for these arches, but we're open for these, especially if
# requested by your distribution's package maintainer.
linux/mips
linux/mips64
linux/mips64le
linux/mipsle
linux/ppc64
linux/ppc64le
linux/riscv64
linux/s390x
```

## Building from source

### With Leeway installed

> TODO: Work in progress

```bash
leeway build components/local-app:app
```