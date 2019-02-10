# https://raw.githubusercontent.com/woefe/git-prompt.zsh/master/git-prompt.zsh
# zsh-git-prompt a lightweight git prompt for zsh.
# Copyright © 2018 Wolfgang Popp
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
# OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

setopt PROMPT_SUBST

function gitprompt() {
    git status --branch --porcelain=v2 2>&1 | awk '
        BEGIN {
            YELLOW = "%F{yellow}";
            BOLD = "%B";
            NB = "%b";
            NC = "%f";

            fatal = 0;
            oid = "";
            head = "";
            ahead = 0;
            behind = 0;
            untracked = 0;
            unmerged = 0;
            staged = 0;
            unstaged = 0;
        }

        $1 == "fatal:" {
            fatal = 1;
        }

        $2 == "branch.oid" {
            oid = $3;
        }

        $2 == "branch.head" {
            head = $3;
        }

        $2 == "branch.ab" {
            ahead = $3;
            behind = $4;
        }

        $1 == "?" {
            ++untracked;
        }

        $1 == "u" {
            ++unmerged;
        }

        $1 == "1" || $1 == "2" {
            split($2, arr, "");
            if (arr[1] != ".") {
                ++staged;
            }
            if (arr[2] != ".") {
                ++unstaged;
            }
        }

        END {
            if (fatal == 1) {
                exit(1);
            }

            dirty = (untracked > 0 || unmerged > 0 || staged > 0 || unstaged > 0)

            printf "%s", YELLOW
            printf "%s", BOLD

            printf "‹";

            if (head == "(detached)") {
                printf ":%s", substr(oid, 0, 7);
            } else {
                printf "%s", head;
            }

            if (dirty) {
                printf "*"
            }

            printf "› ";

            printf "%s", NB
            printf "%s", NC
        }
    '
}
