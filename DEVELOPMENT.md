# Developing asdf-arbitrary-code-execution

## Releasing a new version

`develop` is a long-running branch, which can be merged into `main`. Only do
this when the tests pass, and make sure it's a fast-forward merge!

```
$ git checkout develop
$ dagger do test
$ git checkout main
$ git merge --ff-only develop
$ dagger do test
$ git tag v0.0.{$NEXT}
$ git push --tags
```
