# package-lock-fix

It seems `package-lock.json` files can sometimes get into states where npm complains about extraneous and missing dependencies.

```
npm ERR! extraneous: is-fullwidth-code-point@1.0.0 ./node_modules/fsevents/node_modules/is-fullwidth-code-point
npm ERR! extraneous: nopt@4.0.1 /Users/michael/src/github.com/99designs/spa/node_modules/fsevents/node_modules/nopt
npm ERR! missing: nopt@^4.0.1, required by node-pre-gyp@0.12.0
npm ERR! missing: yallist@^3.0.2, required by tar@4.4.8
```

This script attempts to resolve these issues using `npm dedupe`, `npm prune` and `npm install --no-save`, in order to avoid updating transitive dependencies.
