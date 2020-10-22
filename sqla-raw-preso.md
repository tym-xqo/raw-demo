# The making of `sqla-raw`

Thomas Yager-Madden  
[BenchPrep](https://www.benchprep.com/)  
([We're hiring!](https://www.builtinchicago.org/company/benchprep))

## Intro/agenda

"Building a toolbox is a useful skill"
    - Aly Sivji

## Why a raw-SQL query library

"Every data analyst learns SQL" - Craig Kerstiens

- I'm a DBA. I'm not militantly anti-ORM, but I have limited use for them.
  - (If you want a nice anti-ORM rant that I'll admit I'm partial to, see Erik Bernhardsson, ["I don't want to learn your garbage query language"](https://erikbern.com/2018/08/30/i-dont-want-to-learn-your-garbage-query-language.html))
- For all its flaws, when it comes to RDMBS access, SQL is actually the right tool for the job.
- As a DBA, I have folders full of SQL files _anyway_.
  - SQL is code, I want to write it and version it as code.
  - It's handy to be able to (re)use the same code in a `psql` invocation or an automated job.
- I want results in a format that's easy to introspect—not a higher level data class.
  - List of dicts with column names as keys
  - List of rows as tuples
  - CSV
- Could just use DB-ABI and a database driver (e.g. `psycopg2`) but:
  - it's cumbersome
  - involves a lot of boilerplate and reinventing the wheel
  - tends to be driver-specific
- I noticed I had several projects that had a `db.py` module, with only minor differences among them

**TL;DR**: I just want to call a single function or method that will send SQL to my database and return results with a minimum of fuss.

## Alternatives and prior art

- [PugSQL](https://pugsql.org/)
  - Based on Clojure's HugSQL library
  - Not entirely sold on metadata in SQL comments
- [aiosql](https://github.com/nackjicholson/aiosql) 
  - Looks good, similar philosophy, newer than mine
  - Only for mysql and postgres
  - Supports Async I/O, if you're into that sort of thing
- [Records](https://github.com/kennethreitz-archive/records)
  - Doesn't seem to be maintained
  - Results as specialized class, based on `tablib`

## [sqla-raw](https://github.com/tym-xqo/sqla-raw)

- Originally a [gist](https://gist.github.com/tym-xqo/8548c2bb35151ea6a334f3da99344b2d/1817fefe6ec20d53c9052ca0d2e8255356089afa) I sent to friends with the comment "this is all the SQLAlchemy you really need"
- Uses SQLAlchemy Engine
  - Unbelievable collection of SQL dialects and driver compatibility
  - Named bind parameters (with `text()`)
  - Takes connection configuration from `$DATABASE_URL` in the environment
- Returns results as a list of dicts, with column headings as dictionary keys
  - I might add an option to get back tuples instead
  - CSV? I'd probably rather leave that to upstream application code
- Got enough good feedback it seemed worth packaging
  - Put the script in a folder with `__init__.py`
  - Wrote a setup.py
  - Added a `__main__` routine that performs a basic test
  - MIT License
  - PyPi makes it handy for me, even if no one else ever uses it
- Iterate

## Demo

```python
# interactive repl commands
>>> import json

>>> from raw import db

>>> help(db)
>>> db.result("select 'foo' as bar")
>>> db.result("select version(), current_database()")
>>> db.result("select 'foo' as bar from not_a_table")
>>> data = db.result_from_file("demo-query.sql", type="docked_bike")
>>> print(json.dumps(data, indent=2))
```

## Things I use it for

- Micro Reporting/Analytics API ([Nerium](https://github.com/tym-xqo/nerium)) - Flask webservice. Point it at a folder full of SQL files, get a set of JSON endpoints with serialized results of each query
- Monitoring - APScheduler executes a set of SQL files every X seconds, saves results to a timeseries table, sends Slack alerts based on configurable thresholds
- Headless CMS ([Tulipwood](https://github.com/tym-xqo/tulipwood)) - More of an experiment. Don't try this. Turns out this is what ORMs are good for.
- More one-off things than you can shake a stick at

## Known limitations (design tradeoffs)

- No `fetchone` (I particularly like this, I'll admit)
- Exceptions are caught and returned as if they were results
- No paging
- The whole jinja thing might not be the best idea

## Lessons

- DRY, Rule of three, "pave the cowpaths"
- Roll your own vs find the closest existing library
  - Library can save time and effort
  - Owning and knowing the code can be a win
    - Troubleshooting & maintenance
    - Design to taste
- Don't be shy about using PyPi
- Share your work
