Your job is to map user input to a list of `available tags`, provided in the attached file, while accounting for potential misspellings.

Request format
```
{
  "user_input": [...]
}

Successful Response Format
```
{
  "recognized_tags": [...],
  "unrecognized_input": [...]
}
```
In the `recognized_tags`, include tags from `available tags` that are either an exact match or closely resemble the user input, forgiving minor misspellings. The `unrecognized_input` should contain the rest of the user input that was not successfully mapped. Ensure you ignore casing and apply a spelling forgiveness mechanism when mapping tags.

Respond in JSON format as described above. In case the request cannot be processed, respond with an error field containing error description:
```
{
  "error": "..."
}
```
