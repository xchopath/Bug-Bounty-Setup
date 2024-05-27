# Bug Bounty Setup

My bug bounty setup.

## Cheatsheet

JavaScript Endpoint Dumper

```
curl -s "https://target.com/main.chunk.js" | grep -Po "(?<=['\"])\K[A-Za-z0-9\-_,\/.?=]+?(?=['\"])" | sort -V | uniq
```

Gowitness.sqlite3 GET Parameter Extraction

```
strings gowitness.sqlite3 | grep -P '(?<=\?)[a-zA-Z0-9]+(?==)'
```

Automate Parameter Fuzzing
```
echo http://testphp.vulnweb.com/ | katana -silent | bhedak 31337 | grep -v ".js\|.css\|.png\|.jpg\|.jpeg\|.gif\|.mp3\|.mp4\|.svg\|.woff\|.woff2\|.etf\|.eof\|.otf\|.css\|.exe\|.ttf\|.eot" | grep '?' | grep '=' | anew /tmp/paramfuzz.log | nuclei -t dast/vulnerabilities -dast -silent
```
