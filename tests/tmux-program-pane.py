#!/usr/bin/env python3

import json
import os
from pathlib import Path
import shutil
import signal
import subprocess
import tempfile
import time
import unittest


ROOT = Path(__file__).resolve().parents[1]


class ProgramPaneTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        for command in ("tmux", "nvim", "node"):
            if not shutil.which(command):
                raise unittest.SkipTest(f"{command} is required")
        cls.temp = tempfile.TemporaryDirectory(prefix="tmux-program-pane-")
        cls.directory = Path(cls.temp.name)
        cls.socket = str(cls.directory / "tmux.sock")
        executables = cls.directory / "bin"
        executables.mkdir()
        init = cls.directory / "init.lua"
        init.write_text("""if vim.env.TMUX_PANE then
  vim.fn.system({ 'tmux', 'set-option', '-pq', '-t', vim.env.TMUX_PANE, '@nvim-server', vim.v.servername })
end
""")
        nvim = shutil.which("nvim")
        (executables / "nvim").write_text(f'#!/bin/sh\nexec "{nvim}" --noplugin -u "{init}" "$@"\n')
        (executables / "lazygit").write_text("""#!/usr/bin/env node
process.title = 'lazygit';
setInterval(() => {}, 1000);
""")
        (executables / "pi-entrypoint.js").write_text("""#!/usr/bin/env node
import fs from 'node:fs';
setTimeout(() => {
  process.stdin.setRawMode(true);
  process.stdin.on('data', data => {
    fs.appendFileSync(process.env.PANE_TEST_ROOT + '/' + process.env.TMUX_PANE + '.input', data);
  });
  process.stdout.write('\x1b[?2004h');
}, 400);
setInterval(() => {}, 1000);
""")
        (executables / "pi").symlink_to("pi-entrypoint.js")
        for executable in executables.iterdir():
            executable.chmod(0o755)
        cls.env = os.environ.copy()
        cls.env.pop("TMUX", None)
        cls.env.pop("TMUX_PANE", None)
        cls.env["PATH"] = str(executables) + ":" + cls.env["PATH"]
        cls.env["PANE_TEST_ROOT"] = str(cls.directory)
        cls.tmux("-f", "/dev/null", "new-session", "-d", "-s", "tests", "-x", "120", "-y", "80", "/bin/sh")
        cls.tmux("set-option", "-g", "default-shell", "/bin/sh")
        cls.tmux("set-option", "-g", "remain-on-exit", "on")
        pid = cls.tmux("display-message", "-p", "#{pid}")
        cls.env["TMUX"] = f"{cls.socket},{pid},0"

    @classmethod
    def tearDownClass(cls):
        cls.tmux("kill-server")
        cls.temp.cleanup()

    @classmethod
    def tmux(cls, *args):
        return subprocess.check_output(["tmux", "-S", cls.socket, *args], env=cls.env, text=True).strip()

    def setUp(self):
        self.cwd = self.directory / self._testMethodName
        self.cwd.mkdir()
        self.tmux("set-option", "-g", "@program-pane-close-on-exit", "false")
        self.source = self.tmux("new-window", "-P", "-F", "#{pane_id}", "-c", str(self.cwd), "/bin/sh")
        self.window = self.format(self.source, "#{window_id}")
        self.test_env = dict(self.env, TMUX_PANE=self.source)

    def tearDown(self):
        self.tmux("kill-window", "-t", self.window)

    def format(self, pane, expression):
        return self.tmux("display-message", "-p", "-t", pane, expression)

    def panes(self):
        return self.tmux("list-panes", "-t", self.window, "-F", "#{pane_id}").splitlines()

    def active(self):
        return self.tmux("list-panes", "-t", self.window, "-f", "#{pane_active}", "-F", "#{pane_id}")

    def run_script(self, script, *args, source=None):
        env = dict(self.test_env, TMUX_PANE=source or self.source)
        return subprocess.check_output([str(ROOT / "bin" / script), *args], env=env, cwd=self.cwd, text=True, timeout=40).strip()

    def program(self, name, action="toggle", source=None):
        return self.run_script("tmux-program-pane", name, action, source=source)

    def wait(self, predicate):
        deadline = time.monotonic() + 10
        while time.monotonic() < deadline:
            if predicate():
                return
            time.sleep(0.05)
        self.fail("timed out waiting for pane readiness")

    def wait_program(self, pane, name):
        self.wait(lambda: self.format(pane, "#{pane_current_command}") == name)

    def assert_state(self, pane, zoomed):
        self.assertEqual(self.active(), pane)
        self.assertEqual(self.format(pane, "#{window_zoomed_flag}"), str(zoomed))

    def split(self, command, target=None):
        options = []
        if self.format(self.source, "#{window_zoomed_flag}") == "1":
            options.append("-Z")
        return self.tmux("split-window", "-d", *options, "-P", "-F", "#{pane_id}", "-t", target or self.source, "-c", str(self.cwd), command)

    def test_create_and_restore_unzoomed(self):
        lazygit = self.program("lazygit")
        self.wait_program(lazygit, "lazygit")
        self.assert_state(lazygit, 1)
        self.assertEqual(self.format(lazygit, "#{pane_current_path}"), str(self.cwd))
        self.assertEqual(self.program("lazygit", source=lazygit), self.source)
        self.assert_state(self.source, 0)
        self.assertEqual(self.program("lazygit"), lazygit)
        self.assertEqual(len(self.panes()), 2)

    def test_restore_previously_zoomed_pane(self):
        self.split("/bin/sh")
        self.tmux("resize-pane", "-Z", "-t", self.source)
        lazygit = self.program("lazygit")
        self.wait_program(lazygit, "lazygit")
        self.assert_state(lazygit, 1)
        self.program("lazygit", source=lazygit)
        self.assert_state(self.source, 1)

    def test_first_existing_pane_and_toggle_from_later_match(self):
        first = self.split("lazygit")
        second = self.split("lazygit", target=first)
        self.wait_program(first, "lazygit")
        self.wait_program(second, "lazygit")
        self.assertEqual(self.program("lazygit"), first)
        self.assertEqual(len(self.panes()), 3)
        self.program("lazygit", source=first)
        self.tmux("select-pane", "-t", second)
        self.program("lazygit", source=second)
        self.assert_state(self.source, 0)

    def test_wrapper_editor_precedes_later_direct_editor(self):
        wrapper = self.split("/bin/sh -c 'nvim; sleep 60'")
        direct = self.split("nvim", target=wrapper)
        self.wait(lambda: self.tmux("show-options", "-pqv", "-t", wrapper, "@nvim-server") != "")
        self.wait_program(direct, "nvim")
        self.assertEqual(self.format(wrapper, "#{pane_current_command}"), "sh")
        self.assertEqual(self.program("nvim", "ensure"), wrapper)
        self.assertEqual(len(self.panes()), 3)

    def test_zoomed_return_batches_updates_without_process_scan(self):
        lazygit = self.program("lazygit")
        self.wait_program(lazygit, "lazygit")
        editor = self.program("nvim", source=lazygit)
        self.wait_program(editor, "nvim")
        traced = self.cwd / "traced-bin"
        traced.mkdir()
        log = self.cwd / "operations.jsonl"
        for command in ("tmux", "ps"):
            executable = traced / command
            real = shutil.which(command)
            executable.write_text(f"""#!{shutil.which('python3')}
import json
import os
import sys
with open({str(log)!r}, 'a') as output:
    output.write(json.dumps([{command!r}, *sys.argv[1:]]) + '\\n')
os.execv({real!r}, [{real!r}, *sys.argv[1:]])
""")
            executable.chmod(0o755)
        self.test_env["PATH"] = str(traced) + ":" + self.test_env["PATH"]
        self.assertEqual(self.program("nvim", source=editor), lazygit)
        operations = [json.loads(line) for line in log.read_text().splitlines()]
        self.assertEqual([operation[0] for operation in operations], ["tmux", "tmux", "tmux"])
        self.assertEqual(operations[-1][1:], ["select-pane", "-Z", "-t", lazygit])
        self.assert_state(lazygit, 1)
        log.write_text("")
        self.assertEqual(self.program("nvim", source=lazygit), editor)
        operations = [json.loads(line) for line in log.read_text().splitlines()]
        scans = [operation for operation in operations if operation[0] == "ps"]
        self.assertTrue(scans)
        self.assertTrue(all(operation[1] == "-t" for operation in scans))
        self.assertEqual(len([operation for operation in operations if operation[0] == "tmux"]), 3)
        self.assertNotIn("resize-pane", operations[-1])
        self.assertIn("select-pane", operations[-1])
        self.assertIn("-Z", operations[-1])
        self.assert_state(editor, 1)

    def test_existing_editor_reused_by_lowest_pane_index(self):
        earlier = self.split("nvim")
        later = self.split("nvim")
        self.wait_program(earlier, "nvim")
        self.wait_program(later, "nvim")
        self.assertEqual(self.program("nvim"), later)
        self.assertEqual(len(self.panes()), 3)
        self.assert_state(later, 1)
        self.program("nvim", source=later)
        self.assert_state(self.source, 0)

    def test_nested_toggles_restore_each_return_state(self):
        lazygit = self.program("lazygit")
        self.wait_program(lazygit, "lazygit")
        editor = self.program("nvim", source=lazygit)
        self.wait_program(editor, "nvim")
        self.assert_state(editor, 1)
        self.program("nvim", source=editor)
        self.assert_state(lazygit, 1)
        self.program("lazygit", source=lazygit)
        self.assert_state(self.source, 0)

    def test_edit_creates_editor_then_reuses_first_editor(self):
        file = self.cwd / "file with 'quotes'.txt"
        file.write_text("one\ntwo\nthree\nfour\n")
        lazygit = self.program("lazygit")
        self.wait_program(lazygit, "lazygit")
        self.run_script("lazygit-edit", file.name, "3", source=lazygit)
        editor = self.active()
        self.assert_state(editor, 1)
        server = self.tmux("show-options", "-pqv", "-t", editor, "@nvim-server")
        self.assertEqual(self.tmux("display-message", "-p", "-t", editor, "#{pane_current_path}"), str(self.cwd))
        expression = "json_encode([expand('%:p'), line('.')])"
        result = subprocess.check_output([shutil.which("nvim"), "--server", server, "--remote-expr", expression], text=True).strip()
        self.assertEqual(json.loads(result), [str(file), 3])
        self.program("nvim", source=editor)
        self.assert_state(lazygit, 1)
        self.run_script("lazygit-edit", file.name, "2", source=lazygit)
        self.assert_state(editor, 1)
        self.assertEqual(len(self.panes()), 3)

    def test_note_creates_pi_and_waits_before_pasting_without_focus_change(self):
        lazygit = self.program("lazygit")
        self.wait_program(lazygit, "lazygit")
        before = time.monotonic()
        self.run_script("lazygit-send-note", "src/a.ts", "2", "4", "a note\nsecond line", source=lazygit)
        self.assertGreaterEqual(time.monotonic() - before, 0.35)
        self.assert_state(lazygit, 1)
        pi = self.panes()[-1]
        received = self.directory / (pi + ".input")
        self.wait(received.exists)
        self.assertEqual(received.read_bytes(), b"\x1b[200~src/a.ts:2-4\ra note\rsecond line\r\r\x1b[201~")
        self.assertEqual(self.format(pi, "#{pane_current_path}"), str(self.cwd))
        self.assertNotEqual(self.format(pi, "#{pane_current_command}"), "pi")
        self.assertEqual(self.program("pi", "ensure", source=lazygit), pi)
        self.assertEqual(self.program("pi", source=lazygit), pi)
        self.assert_state(pi, 1)
        self.program("pi", source=pi)
        self.assert_state(lazygit, 1)

    def test_note_reuses_first_pi_and_preserves_unzoomed_layout(self):
        first = self.program("pi", "ensure")
        self.wait(lambda: self.format(first, "#{bracket_paste_flag}") == "1")
        second = self.split("pi", target=first)
        self.wait(lambda: self.format(second, "#{bracket_paste_flag}") == "1")
        self.run_script("lazygit-send-note", "a.ts", "5", "5")
        self.assert_state(self.source, 0)
        received = self.directory / (first + ".input")
        self.wait(received.exists)
        self.assertEqual(received.read_bytes(), b"\x1b[200~a.ts:5\r\r\x1b[201~")
        self.assertFalse((self.directory / (second + ".input")).exists())
        self.assertEqual(len(self.panes()), 3)

    def test_note_preserves_commit_location(self):
        self.run_script("lazygit-send-note", "a.ts", "5", "5", "fix this", "abcdef123456")
        pi = self.panes()[-1]
        received = self.directory / (pi + ".input")
        self.wait(received.exists)
        self.assertEqual(received.read_bytes(), b"\x1b[200~abcdef12:a.ts:5\rfix this\r\r\x1b[201~")
        self.assert_state(self.source, 0)

    def test_pi_discovery_uses_runtime_entrypoint_not_arbitrary_arguments(self):
        pi_path = str(self.directory / "bin" / "pi")
        unrelated_script = self.cwd / "unrelated.js"
        unrelated_script.write_text("setInterval(() => {}, 1000);\n")
        commands = (
            f"node -e 'setInterval(() => {{}}, 1000)' {pi_path}",
            f"node --eval='setInterval(() => {{}}, 1000)' {pi_path}",
            f"node {unrelated_script} {pi_path}",
            f"node --import {pi_path} {unrelated_script}",
        )
        if shutil.which("bun"):
            commands += (
                f"bun -e 'setInterval(() => {{}}, 1000)' {pi_path}",
                f"bun run {unrelated_script} {pi_path}",
            )
        for command in commands:
            with self.subTest(command=command):
                unrelated = self.split(command)
                self.wait_program(unrelated, command.split()[0])
                pi = self.program("pi", "ensure")
                self.assertNotEqual(pi, unrelated)
                self.assertEqual(len(self.panes()), 3)
                self.tmux("kill-pane", "-t", pi)
                self.tmux("kill-pane", "-t", unrelated)

    def test_pi_discovery_accepts_resolved_entrypoint_with_runtime_options(self):
        entrypoint = self.directory / "bin" / "pi-entrypoint.js"
        pi = self.split(f"node --no-warnings --require fs -- {entrypoint}")
        self.wait(lambda: self.format(pi, "#{bracket_paste_flag}") == "1")
        self.assertEqual(self.program("pi", "ensure"), pi)
        self.assertEqual(len(self.panes()), 2)

    @unittest.skipUnless(shutil.which("bun"), "bun is required")
    def test_pi_discovery_accepts_bun_runtime_entrypoint(self):
        entrypoint = self.directory / "bin" / "pi-entrypoint.js"
        pi = self.split(f"bun --cwd={self.cwd} run --bun {entrypoint}")
        self.wait(lambda: self.format(pi, "#{bracket_paste_flag}") == "1")
        self.assertEqual(self.program("pi", "ensure"), pi)
        self.assertEqual(len(self.panes()), 2)

    def test_program_exit_keeps_pane_as_a_live_shell_when_other_panes_remain(self):
        self.tmux("set-option", "-w", "-t", self.window, "remain-on-exit", "off")
        editor = self.program("nvim", "ensure")
        self.wait_program(editor, "nvim")
        self.wait(lambda: self.tmux("show-options", "-pqv", "-t", editor, "@nvim-server") != "")
        server = self.tmux("show-options", "-pqv", "-t", editor, "@nvim-server")
        subprocess.check_call([shutil.which("nvim"), "--server", server, "--remote-send", "<Cmd>qa!<CR>"])
        self.wait(lambda: self.format(editor, "#{pane_current_command}") in ("sh", "bash"))
        self.assertEqual(self.panes(), [self.source, editor])
        self.assertEqual(self.format(editor, "#{pane_dead}"), "0")
        screen = self.tmux("capture-pane", "-p", "-t", editor)
        self.assertNotIn("@program-pane-close-on-exit", screen)
        self.assertNotIn("tmux-program-pane-run", screen)
        self.tmux("send-keys", "-t", editor, "printf 'shell %s' 'is alive'", "Enter")
        self.wait(lambda: "shell is alive" in self.tmux("capture-pane", "-p", "-t", editor))

    def test_program_exit_closes_pane_when_enabled(self):
        editor = self.program("nvim", "ensure")
        self.wait_program(editor, "nvim")
        self.wait(lambda: self.tmux("show-options", "-pqv", "-t", editor, "@nvim-server") != "")
        server = self.tmux("show-options", "-pqv", "-t", editor, "@nvim-server")
        self.tmux("set-option", "-g", "@program-pane-close-on-exit", "true")
        subprocess.check_call([shutil.which("nvim"), "--server", server, "--remote-send", "<Cmd>qa!<CR>"])
        self.wait(lambda: editor not in self.panes())
        self.assertEqual(self.panes(), [self.source])

    def test_program_exit_restores_return_pane_and_zoom(self):
        self.tmux("set-option", "-g", "@program-pane-close-on-exit", "true")
        other = self.split("/bin/sh")
        for zoomed in (0, 1):
            with self.subTest(zoomed=zoomed):
                if zoomed:
                    self.tmux("resize-pane", "-Z", "-t", self.source)
                editor = self.program("nvim")
                self.wait_program(editor, "nvim")
                self.wait(lambda: self.tmux("show-options", "-pqv", "-t", editor, "@nvim-server") != "")
                server = self.tmux("show-options", "-pqv", "-t", editor, "@nvim-server")
                subprocess.check_call([shutil.which("nvim"), "--server", server, "--remote-send", "<Cmd>qa!<CR>"])
                self.wait(lambda: editor not in self.panes())
                self.wait(lambda: self.active() == self.source and self.format(self.source, "#{window_zoomed_flag}") == str(zoomed))
                self.assert_state(self.source, zoomed)
                self.assertEqual(self.panes(), [self.source, other])

    def test_background_program_exit_does_not_restore_return_pane(self):
        self.tmux("set-option", "-g", "@program-pane-close-on-exit", "true")
        self.split("/bin/sh")
        self.tmux("resize-pane", "-Z", "-t", self.source)
        editor = self.program("nvim")
        self.wait_program(editor, "nvim")
        self.wait(lambda: self.tmux("show-options", "-pqv", "-t", editor, "@nvim-server") != "")
        server = self.tmux("show-options", "-pqv", "-t", editor, "@nvim-server")
        self.program("nvim", source=editor)
        self.tmux("resize-pane", "-Z", "-t", self.source)
        self.assert_state(self.source, 0)
        subprocess.check_call([shutil.which("nvim"), "--server", server, "--remote-send", "<Cmd>qa!<CR>"])
        self.wait(lambda: editor not in self.panes())
        self.assert_state(self.source, 0)

    def test_program_exit_keeps_last_pane_as_a_live_shell(self):
        self.tmux("set-option", "-w", "-t", self.window, "remain-on-exit", "off")
        editor = self.program("nvim", "ensure")
        self.wait_program(editor, "nvim")
        self.wait(lambda: self.tmux("show-options", "-pqv", "-t", editor, "@nvim-server") != "")
        server = self.tmux("show-options", "-pqv", "-t", editor, "@nvim-server")
        self.tmux("kill-pane", "-t", self.source)
        subprocess.check_call([shutil.which("nvim"), "--server", server, "--remote-send", "<Cmd>qa!<CR>"])
        self.wait(lambda: self.format(editor, "#{pane_current_command}") in ("sh", "bash"))
        self.assertEqual(self.panes(), [editor])
        self.assertEqual(self.format(editor, "#{pane_dead}"), "0")
        self.tmux("send-keys", "-t", editor, "printf 'shell %s' 'is alive'", "Enter")
        self.wait(lambda: "shell is alive" in self.tmux("capture-pane", "-p", "-t", editor))

    def test_dead_program_panes_are_not_reused_or_toggled_back(self):
        for program in ("lazygit", "nvim", "pi"):
            with self.subTest(program=program):
                dead = self.split(program)
                if program == "pi":
                    self.wait(lambda: self.format(dead, "#{bracket_paste_flag}") == "1")
                else:
                    self.wait_program(dead, program)
                if program == "nvim":
                    self.wait(lambda: self.tmux("show-options", "-pqv", "-t", dead, "@nvim-server") != "")
                    server = self.tmux("show-options", "-pqv", "-t", dead, "@nvim-server")
                    subprocess.check_call([shutil.which("nvim"), "--server", server, "--remote-send", "<Cmd>qa!<CR>"])
                else:
                    os.kill(int(self.format(dead, "#{pane_pid}")), signal.SIGTERM)
                self.wait(lambda: self.format(dead, "#{pane_dead}") == "1")
                if program != "pi":
                    self.assertEqual(self.format(dead, "#{pane_current_command}"), program)
                replacement = self.program(program, "ensure")
                self.assertNotEqual(replacement, dead)
                if program == "pi":
                    self.wait(lambda: self.format(replacement, "#{bracket_paste_flag}") == "1")
                else:
                    self.wait_program(replacement, program)
                self.tmux("select-pane", "-t", dead)
                self.assertEqual(self.program(program, source=dead), replacement)
                self.assert_state(replacement, 1)
                self.tmux("select-pane", "-t", self.source)
                self.tmux("kill-pane", "-t", replacement)
                self.tmux("kill-pane", "-t", dead)

    def test_current_window_only(self):
        other = self.tmux("new-window", "-d", "-P", "-F", "#{pane_id}", "pi")
        try:
            self.wait(lambda: self.format(other, "#{bracket_paste_flag}") == "1")
            pi = self.program("pi", "ensure")
            self.assertNotEqual(pi, other)
            self.assertIn(pi, self.panes())
            self.assert_state(self.source, 0)
        finally:
            self.tmux("kill-window", "-t", other)


if __name__ == "__main__":
    unittest.main()
