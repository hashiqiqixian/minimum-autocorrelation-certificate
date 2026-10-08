#!/usr/bin/env python3
"""Conservative lexical screen. NOT a Lean parser or proof checker."""
import re,sys
from pathlib import Path
root=Path(__file__).resolve().parents[1]

def strip_comments(text):
    out=[];i=0;depth=0
    while i<len(text):
        if text.startswith('/-',i): depth+=1;i+=2
        elif depth and text.startswith('-/',i): depth-=1;i+=2
        elif depth: i+=1
        elif text.startswith('--',i):
            end=text.find('\n',i);i=len(text) if end<0 else end
        else: out.append(text[i]);i+=1
    if depth: raise ValueError('Unclosed block comment')
    return ''.join(out)

bad=[]
# The toolchain and dependencies are not project-owned proof sources.  Restrict
# traversal itself so a local .tools installation cannot enlarge this scan.
paths=sorted(root.glob('*.lean'))+sorted((root/'Autocorrelation').rglob('*.lean'))
for path in paths:
    text=strip_comments(path.read_text(encoding='utf-8-sig'))
    for match in re.finditer(r'\b(?:sorry|admit|axiom|native_decide|unsafe|implemented_by|extern)\b',text):
        bad.append(f'{path.relative_to(root)}: {match.group(0)}')
if bad:
    print('\n'.join(bad));sys.exit(1)
print(f'PASS lexical screen: {len(paths)} Lean source files; no placeholder/custom-axiom/unsafe bypass tokens.')
print('This is NOT a Lean compilation and NOT a proof of the main theorem.')
