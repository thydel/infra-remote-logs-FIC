# TL;DR

A new File Integrity Control tool for remote logs that use
[hashdeep(1)][] for generated a two level set of hashes and [gpg(1)][]
to sign the second level hashes. More than one user can use [gpg(1)][]
sign and verify.

The tool is implemented with a pair of idempotent Makefile for
respectively the remote ([hashdeep(1)][]) and the local ([gpg(1)][])
part of the task.

# Remote making of hashes

The [hashdeep_space_remote_log.mk][] makefile using [hashdeep(1)][] is
installed by [Makefile][] (`make init`) on `$(loghost)` (to be defined
in `loghost.mk`).

Once installed [hashdeep_space_remote_log.mk][] will be invoked by
`cron` with `hash` target.

The `hash` target invoke [hashdeep(1)][] for each log file of each
logged node for the previous day and store the file of known hashes in
`$node/YY/MM/DD/hashdeep.txt` (so that the file of known hashes will
be there when the day become a `tgz`), then invoked again
[hashdeep(1)][] upon all the new hashdeep.txt and store the global
file of known hashes in `.hashdeep` at the root of remote logs file
tree.

One can then invoke [hashdeep_space_remote_log.mk][] with target
`check`.

The `check` target will invoke [hashdeep(1)][] in *audit* mode for
each file of known hashes of the previous day (either failing or
dropping a `.audit` file), then invoke again [hashdeep(1)][] in
*audit* mode upon all the the global file of known hashes (but don't
make a `.audit` file, thus `hashdeep_space_remote_log.mk check` will
always at least run an audit of the global file of known hashes).

These target are idempotent and we never want to recompute the files
of known hashes, but we may want to replay *audit* mode, so the
`clean` target will remove all the `.audit` file of the previous day.

All three targets (`hash`, `check` and `clean`) can be invoke for all
available anterior day by using `n` argument to tell use the current
day - `n` (e.g. like `make check n=3` to generate and check all hashes
(because `check` depends on `hash`) from three days ago logs).  To
check again a previous day whose hashes already exists use `make clean
check n=3`.

Currently we keep 7 days available for this tool. Previous day are
archived as a `tgz` file. We should extend the tool to allow check of
any previous day.

# Local making of signatures

The same [Makefile][] used to install [hashdeep_space_remote_log.mk][]
on `$(loghost)` is also used to make [gpg(1)][] signatures of all
global files of known hashes.

First we copy all global file of known hashes for all days from
`$(loghost)` into `.hasdeep` (which is in `.gitignore`) and all
previously generated signatures into `.sig-$(USER)` (which is also in
`.gitignore`) so that different user may sign the files of known
hashes. This made via `make get`.

Then we generate all the missing signatures for all files in
`.hasdeep` and the generated signatures goes into `.hasdeep`. This is
made via `make sig` (via `gpg -ba` to generate *detached* ascii
signature) .

Then we push back all generated signatures on `$(loghost)` into
`.sig-$(USER)` at the root of remote logs file tree.

We can then verify all the files with their corresponding signatures
using `make chk` (via `gpg --verify $signature $hashes`).

All these steps are made via `make main`

As a extra step we can use `make get` again to get back latest
generated signatures and we then will be able to compare all remotes
signatures with local ones via `make cmp` (or `make full` to play the
full targets stack)

An alternative way would be to store signatures on a repository
instead on the remote node.

A evolution will be to limit the number of days to verify.

[infra-remote-logs-FIC]: https://github.com/thydel/infra-remote-logs-FIC "github.com repo"
[hashdeep_space_remote_log.mk]: https://github.com/thydel/infra-remote-logs-FIC/blob/master/hashdeep_space_remote_log.mk "github.com file"
[Makefile]: https://github.com/thydel/infra-remote-logs-FIC/blob/master/Makefile "github.com file"
[hashdeep(1)]: https://linux.die.net/man/1/hashdeep "linux.die.net"
[gpg(1)]: https://linux.die.net/man/1/gpg "linux.die.net"
