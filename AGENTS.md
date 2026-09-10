# AGENTS.md

Guidance for coding agents working in this repository.

## Project overview

zap is a structured, leveled, high-performance logging library for Go.

This repository is part of the `sourcegraph-testing` organization and exists for
testing purposes only. It is not a production project — code, configuration, and
history here may be used to exercise tooling, automation, and experiments. It
mirrors [uber-go/zap](https://github.com/uber-go/zap), which is the source of
truth.

- Module path: `go.uber.org/zap`
- Go version: `go 1.13` per `go.mod`
- HEAD sits ahead of the latest tag (`v1.14.1`); `CHANGELOG.md` carries an
  unreleased `1.15.0` entry.

This repository contains **two Go modules**: the root module and `benchmarks/`.
The Makefile tracks both through `MODULE_DIRS = . ./benchmarks`, so module-wide
commands must run in each.

## Repository layout

| Path | Role |
| --- | --- |
| root `*.go` | Public API — `logger.go`, `sugar.go`, `field.go`, `config.go`, `global.go`, `encoder.go` |
| `zapcore/` | Core encoder, level, and field abstractions |
| `zapgrpc/` | gRPC logger adapter |
| `zaptest/` | Testing helpers |
| `buffer/` | Pooled byte buffers |
| `internal/` | `bufferpool`, `color`, `exit`, `readme`, `ztest` |
| `benchmarks/` | Separate Go module benchmarking zap against other loggers |

## Test

```bash
make test
```

Runs `go test -race ./...` in each module directory.

```bash
make cover
make bench
BENCH=<pattern> make bench
```

## Lint

```bash
make lint
```

Runs, in order: `gofmt -d -s` (check only), `go vet ./...`, `golint ./...`,
`staticcheck ./...`, a `git grep -i fixme` check that fails on unresolved FIXME
markers, and `./checklicense.sh`. Output accumulates in `lint.log` and the target
fails if that file is non-empty.

`make all` runs `lint` followed by `test`. Lint tools are pinned through the
build-tagged `tools_test.go` (`golang.org/x/lint/golint`,
`honnef.co/go/tools/cmd/staticcheck`).

## Conventions

- Every `*.go` file must open with a `Copyright (c) ... Uber Technologies, Inc.`
  header. `./checklicense.sh` enforces it, so new files fail lint without one.
- `gofmt` is only checked, not applied. Run `gofmt -s -w` on files you touch.
- Do not leave `FIXME` markers; `make lint` fails on them.
- `README.md` is generated from `.readme.tmpl`. Edit the template, then run
  `make updatereadme` — do not hand-edit `README.md`.
- Upstream asks that new exported APIs be raised in an issue first and that
  changes preserve backward compatibility.

## Gotchas

- Run test and lint in both module directories. A root-only `go test ./...` does
  not cover `benchmarks/`.
- `CONTRIBUTING.md` references a `make dependencies` target and a
  `LINTABLE_MINOR_VERSIONS` Makefile variable. Neither exists in the current
  Makefile — treat both as stale guidance.
- CI is split and misleading. `.github/workflows/ci.yaml` runs `go build ./...`
  only, with no tests or lint; Travis (`.travis.yml`) is what runs `make lint`,
  `make test`, `make bench`, and coverage. A green GitHub Actions check proves
  very little.
- `.github/workflows/simple-test.yml` is `sourcegraph-testing` scaffolding that
  passes or fails based on a `[fail]` marker in the commit message or a
  `should_fail` dispatch input. It carries no signal about code correctness.
- `CONTRIBUTING.md` describes the fork-and-upstream-remote flow for contributing
  to uber-go/zap, which does not apply to changes made in this mirror.
