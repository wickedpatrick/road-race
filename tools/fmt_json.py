#!/usr/bin/env python3
"""Shared JSON layout for data/ files: short lists and objects stay on one line, long ones break up.
usage: tools/fmt_json.py file.json [...]  (rewrites the files in place)"""
import json, sys

def num(v):
    return int(v) if isinstance(v, float) and v.is_integer() else v

def clean(v):
    if isinstance(v, dict): return {k: clean(x) for k, x in v.items()}
    if isinstance(v, list): return [clean(x) for x in v]
    return num(v)

def fmt(v, ind=0, width=118):
    one = json.dumps(v, ensure_ascii=False, separators=(", ", ": "))
    if len(one) + ind <= width or not isinstance(v, (list, dict)) or not v:
        return one
    pad = "\t" * (ind // 4 + 1)
    end = "\t" * (ind // 4)
    if isinstance(v, list):
        if all(not isinstance(x, dict) and len(json.dumps(x, ensure_ascii=False)) < 40 for x in v):
            lines, cur = [], ""
            for x in v:
                s = json.dumps(x, ensure_ascii=False, separators=(", ", ": "))
                if cur and len(cur) + len(s) + 2 + ind + 4 > width:
                    lines.append(cur); cur = s
                else:
                    cur = s if not cur else cur + ", " + s
            lines.append(cur)
            return "[\n" + ",\n".join(pad + l for l in lines) + "\n" + end + "]"
        return "[\n" + ",\n".join(pad + fmt(x, ind + 4, width) for x in v) + "\n" + end + "]"
    items = [pad + json.dumps(k, ensure_ascii=False) + ": " + fmt(x, ind + 4, width) for k, x in v.items()]
    return "{\n" + ",\n".join(items) + "\n" + end + "}"

def dump(v):
    return fmt(clean(v)) + "\n"

if __name__ == "__main__":
    for path in sys.argv[1:]:
        data = json.load(open(path))
        open(path, "w").write(dump(data))
