# Description

Briefly describe what this PR does and why. Link to related issue if applicable.

## Type of changes

* [ ] fix
* [ ] feat
* [ ] chore
* [ ] docs
* [ ] ci

## Related issues

Closes: #<issue-number> (if applicable)

## How to test (locally)

1. Checkout the branch:
   git checkout -b feat/your-feature

2. Install dependencies:
   poetry install --no-root

3. Run tests (if any):
   poetry run pytest -q services/mail-alias-api/tests

4. Example API check (if applicable):
   curl -i -X GET "[http://localhost:8000/v1/health](http://localhost:8000/v1/health)"

## Checklist

* [ ] Tests executed (if applicable)
* [ ] Lint passed (ruff/mypy/black)
* [ ] README/docs updated (if functionality added/changed)

## Notes for reviewer

Focus on key changes or potential risks.
