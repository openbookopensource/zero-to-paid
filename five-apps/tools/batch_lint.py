#!/usr/bin/env python3
"""batch_lint.py - static checker for Windows .bat/.cmd files (no Windows needed).
Catches the classic mistakes that break batch files at run time.
Usage: python3 batch_lint.py FILE [FILE...]   exit code 1 if any ERROR.
"""
import re, sys

def strip_quoted(s):
    return re.sub(r'"[^"]*"', '""', s)

def lint(path):
    raw = open(path, "rb").read()
    text = raw.decode("utf-8", "replace")
    issues = []
    def add(level, n, msg): issues.append((level, n, msg))
    if b"\r\n" not in raw or re.search(rb"(?<!\r)\n", raw):
        add("ERROR", 0, "line endings are not all CRLF (labels/goto can fail on Windows)")
    lines = text.replace("\r", "").split("\n")
    labels = {}
    for i, l in enumerate(lines, 1):
        m = re.match(r"^\s*:([A-Za-z0-9_\-]+)", l)
        if m and not l.lstrip().startswith("::"):
            k = m.group(1).lower()
            if k in labels: add("ERROR", i, f"duplicate label :{k} (first at line {labels[k]})")
            labels[k] = i
    delayed = any(re.search(r"EnableDelayedExpansion", l, re.I) for l in lines)
    depth = 0
    for i, l in enumerate(lines, 1):
        s = l.strip()
        if not s or s.lower().startswith(("rem ", "::")) or s.lower() == "rem":
            continue
        for m in re.finditer(r"\b(?:goto|call)\s+:?([A-Za-z0-9_\-]+)", s, re.I):
            tgt = m.group(1).lower()
            if tgt == "eof" or (m.group(0).lower().startswith("call") and ":" not in m.group(0)):
                continue
            if tgt not in labels: add("ERROR", i, f"goto/call to missing label :{tgt}")
        q = strip_quoted(s)
        if re.search(r"Start-Process[^\n]*'[^']*%~f0", s, re.I):
            add("WARN", i, "path embedded in a PowerShell quoted string breaks on apostrophes; pass it via an environment variable")
        if re.search(r"\b(?:winget\s+\w+|del|rd|rmdir)\b[^\n]*--id\s+%%?\w+%?(?!\")", s, re.I) and '--id "' not in s:
            add("WARN", i, "unquoted variable passed to winget/del/rd; quote it")
        if re.search(r"\b(?:rd|rmdir)\s+/s[^\n]*%", s, re.I):
            add("WARN", i, "recursive delete with a variable path; make sure the variable cannot be empty or wrong")
        is_echo = re.match(r"^(@|>+\"?[^ ]*\"?\s*)*echo\b", q, re.I) or re.search(r"\becho\b", q, re.I)
        # a lone digit before > is parsed as a file handle (echo 2>>file); a variable that may expand to one is risky
        if re.search(r"\becho\b[^>]*\s\d>>?", q, re.I):
            add("ERROR", i, "echo text has a lone digit right before '>' (parsed as a file handle); put the redirect first")
        elif re.search(r"\becho\b[^>]*%[^%]+%>>?", q, re.I):
            add("WARN", i, "echo %VAR% directly before '>' breaks if VAR is a single digit; write the redirect first: >>file echo %VAR%")
        if depth > 0 and re.search(r"\becho\b", q, re.I):
            after = re.split(r"\becho\b", q, maxsplit=1, flags=re.I)[1]
            after = re.sub(r"\^.", "", after)
            if ")" in after.split(">")[0].split("|")[0]:
                add("ERROR", i, "unescaped ')' in echo text inside a ( ) block closes the block early; write ^) or reword")
        if re.search(r"\becho\b", q, re.I):
            after = re.sub(r"\^.", "", re.split(r"\becho\b", q, maxsplit=1, flags=re.I)[1])
            if re.search(r"[<|]", after.split(">")[0]) or re.search(r"&(?!&)", after) and depth == 0 and False:
                add("WARN", i, "unescaped < or | in echo text")
        if "!" in re.sub(r"\^.", "", q) and not delayed:
            add("WARN", i, "'!' used but EnableDelayedExpansion is not set")
        if depth > 0 and re.search(r"%errorlevel%", s, re.I) and delayed:
            add("WARN", i, "%errorlevel% inside a block is expanded early; use !errorlevel!")
        if re.match(r"^pause\s*$", s, re.I):
            add("INFO", i, "pause waits for a key (fine for customers; in CI feed input from NUL)")
        # parenthesis depth (ignore quoted text and escaped chars)
        t = re.sub(r"\^.", "", q)
        for ch in t:
            if ch == "(" and re.search(r"(\bif\b|\belse\b|\bfor\b|^\s*\()", t, re.I): pass
        opens = len(re.findall(r"\($", t.rstrip())) + (1 if re.match(r"^\s*\(", t) and not t.rstrip().endswith(")") else 0)
        closes = 1 if re.match(r"^\s*\)", t) else 0
        if re.search(r"\)\s*else\s*\($", t, re.I): closes, opens = 1, 1
        depth += opens - closes
        if depth < 0:
            add("ERROR", i, "closing ')' without an open block"); depth = 0
    if depth != 0: add("ERROR", len(lines), f"unbalanced ( ) blocks, depth {depth} at end of file")
    return issues

if __name__ == "__main__":
    bad = 0
    for f in sys.argv[1:]:
        res = lint(f)
        print(f"== {f}: {sum(1 for r in res if r[0]=='ERROR')} error(s), {sum(1 for r in res if r[0]=='WARN')} warning(s)")
        for lv, n, msg in res:
            print(f"  {lv:5} line {n}: {msg}")
        bad += any(r[0] == "ERROR" for r in res)
    sys.exit(1 if bad else 0)
