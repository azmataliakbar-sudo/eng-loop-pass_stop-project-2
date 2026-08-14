# pass_stop

Project 2 from the Loop Engineering crash course.

## Run

```powershell
.\reset.ps1
.\loop.ps1
```

## What happens

- `src/calc.js` starts broken (3 bugs).
- `loop.ps1` runs `maker.js` (fixes one bug per beat), then `npm test`.
- A real command (`node --test`) decides done, not the maker.
- Max 6 tries, then it stops.

## Done when

The loop stops because `npm test` returned 0, not because it hit 6.
