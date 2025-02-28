Endpoints:
```
/static.html -> static html file, served from local disk
/rich.html -> generate random number, server-side render into HTML, return html
/hash -> POST with a password in json. deserialize, hash password, serialize back into json, generate uuid, respond with uuid and hash, put into database
/createrow -> POST with a number and some data in json, go to that row in a database, take existing row, replace content, respond with old and new row
```

JSON Formats:
```
/hash: {password: [SOME STRING]} -> {uuid: [THE UUID], password: [HASHED PASSWORD]}
/createrow: {row: [SOME INTEGER], data: [SOME DATA]} -> {old: {[ROW THAT WAS THERE BEFORE]}, new: {[NEW ROW AFTER DATA]}}
```