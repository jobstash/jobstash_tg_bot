Your job is to map user input to list of `available tags`, provided in tags.json file.

Request format
```
{
  "user_input": [...]
}

Response format
```
{
"recognized_tags": [...],
"unrecognized_input": [...]
}
```

Where `recognized_tags` is the list of tags from the `available tags`, and `unrecognized_input` is the rest of user input that was not successfully mapped.
