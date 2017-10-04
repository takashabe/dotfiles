let g:jedi#completions_enabled = 0

python << EOF
import os
import sys

path = os.path.expanduser("/usr/local/lib/python3.6/site-packages")
if not path in sys.path:
    sys.path.append(path)
EOF
