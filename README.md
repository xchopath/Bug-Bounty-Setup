# Bug Bounty Setup

My bug bounty setup.

## Cheatsheet

JavaScript Endpoint Dumper

```
curl -s "https://target.com/main.chunk.js" | grep -Po "(?<=['\"])\K[A-Za-z0-9\-_,\/.?=]+?(?=['\"])" | sort -V | uniq
```
